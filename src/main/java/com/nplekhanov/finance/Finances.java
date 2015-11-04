package com.nplekhanov.finance;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.TransactionStatus;
import org.springframework.transaction.support.TransactionCallback;
import org.springframework.transaction.support.TransactionOperations;

import java.sql.Date;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.*;

/**
 * @author nplekhanov
 */
@Service
public class Finances {

    @Autowired
    private JdbcTemplate template;

    @Autowired
    private TransactionOperations tx;

    public Collection<String> loadItemNames() {
        return template.queryForList("select distinct name from item1 order by name", String.class);
    }

    public Item loadRoot() {
        final Map<Long,Item> itemById = new HashMap<>();
        Collection<Item> roots = new ArrayList<>();
        for (Item item: loadShallowItems()) {
            itemById.put(item.getItemId(), item);
        }
        for (Item item: itemById.values()) {
            Long parentId = item.getParentItemId();
            if (parentId != null) {
                Item parent = itemById.get(parentId);
                if (parent == null) {
                    throw new IllegalStateException("parent for "+item+" not found");
                }
                parent.addChild(item);
                item.setParent(parent);
            } else {
                roots.add(item);
            }
        }
        if (roots.size() != 1) {
            throw new IllegalStateException("expected 1 root, but found: "+roots);
        }
        return roots.iterator().next();
    }

    public void createGroup(String name, long parentId) {
        template.update("insert into item1 (name, parent_id, type) values (?, ?, ?)", name, parentId, ItemType.GROUP.name());
    }

    public void associate(final long itemId, final long parentId) {
        tx.execute(new TransactionCallback<Object>() {
            @Override
            public Object doInTransaction(TransactionStatus status) {
                template.update("update item1 set parent_id = ? where id = ?", parentId, itemId);
                return null;
            }
        });
    }

    public Collection<Group> loadGroups() {
        Collection<Group> groups = new ArrayList<>();
        for (Item item: loadShallowItems()) {
            if (item instanceof Group) {
                groups.add((Group) item);
            }
        }
        return groups;
    }

    public Collection<Item> loadShallowItems() {
        final Map<Long,Item> itemMap = new HashMap<>();
        List<Item> items = template.query("select * from item1", new ItemRowMapper());
        for (Item item: items) {
            itemMap.put(item.getItemId(), item);
        }

        for (Item item: itemMap.values()) {
            Item parent = itemMap.get(item.getParentItemId());
            item.setParent(parent);
        }

        Collections.sort(items, new Comparator<Item>() {
            @Override
            public int compare(Item o1, Item o2) {
                return o1.getPathAsString("/").compareTo(o2.getPathAsString("/"));
            }
        });
        return items;
    }

    public void addInstantTransfer(final String name, final long amount, final LocalDate at, final Long parent) {
        tx.execute(new TransactionCallback<Object>() {
            @Override
            public Object doInTransaction(TransactionStatus status) {
                ItemType type = at.isBefore(LocalDate.now().withDayOfMonth(1)) ? ItemType.INSTANT_ACTUAL : ItemType.INSTANT_PLANNED;
                template.update("insert into item1 (name, parent_id, amount, at, type) values (?, ?, ?, ?, ?)", name, parent, amount, Date.valueOf(at), type.name());
                return null;
            }
        });
    }

    public void addMonthlyTransfer(final String name, final long amount, final YearMonth begin,final YearMonth end, final Long parent) {
        tx.execute(new TransactionCallback<Object>() {
            @Override
            public Object doInTransaction(TransactionStatus status) {

                LocalDate thisMonth = LocalDate.now().withDayOfMonth(1);
                for (LocalDate d = LocalDate.of(begin.getYear(), begin.getMonth(), 1); d.isBefore(thisMonth); d = d.plusMonths(1)) {
                    addInstantTransfer(name, amount, d, parent);
                }

                template.update("insert into item1 (name, parent_id, amount, period_begin, period_end, type) values (?, ?, ?, ?, ?, ?)",
                        name, parent, amount, Date.valueOf(begin.atDay(1)), Date.valueOf(end.atDay(1)), ItemType.MONTHLY_PLANNED.name());

                return null;
            }
        });
    }

    public void setInitialBalance(final long amount) {
        tx.execute(new TransactionCallback<Object>() {
            @Override
            public Object doInTransaction(TransactionStatus status) {
                template.update("delete from initial_balance");
                template.update("insert into initial_balance (amount) values (?)", amount);
                return null;
            }
        });
    }

    public long loadInitialBalance() {
        return template.queryForObject("select amount from initial_balance", Long.class);
    }

    public Item getTransfer(long transferId) {
        String q = "select * from item1 where id = ?";

        return template.queryForObject(q, new ItemRowMapper(), transferId);
    }

    private YearMonth of(java.sql.Date sqlDate) {
        LocalDate date = sqlDate.toLocalDate();
        return YearMonth.of(date.getYear(), date.getMonth());
    }

    private java.sql.Date asSql(YearMonth month) {
        return Date.valueOf(LocalDate.of(month.getYear(), month.getMonth(), 1));
    }

    public void modifyTransfer(long transferId, LocalDate at, long amount, String name, Long parent) {
        template.update(
                "update item1 set name = ?, parent_id = ?, at = ?, amount = ? where id = ? and (type = ? or type = ?)",
                name, parent, Date.valueOf(at), amount, transferId, ItemType.INSTANT_ACTUAL.name(), ItemType.INSTANT_PLANNED.name());
    }

    public void modifyTransfer(long transferId, YearMonth begin, YearMonth end, long amount, String name, long parent) {
        template.update(
                "update item1 set name = ?, parent_id = ?, period_begin = ?, period_end = ?, amount = ? where id = ? and type = ?",
                name, parent, asSql(begin), asSql(end), amount, transferId, ItemType.MONTHLY_PLANNED.name());
    }

    public void modifyGroup(long transferId, String name, long parent) {
        template.update(
                "update item1 set name = ?, parent_id = ? where id = ? and type = ?",
                name, parent, transferId, ItemType.GROUP.name());
    }

    private class ItemRowMapper implements RowMapper<Item> {
        @Override
        public Item mapRow(ResultSet rs, int rowNum) throws SQLException {
            ItemType type = ItemType.valueOf(rs.getString("type"));
            Item item;
            switch (type) {
                case GROUP:
                    item = new Group();
                    break;
                case INSTANT_PLANNED:
                case INSTANT_ACTUAL:
                    item = new InstantTransfer();
                    ((InstantTransfer)item).setPlanned(type == ItemType.INSTANT_PLANNED);
                    ((InstantTransfer)item).setAt(rs.getDate("at").toLocalDate());
                    ((InstantTransfer)item).setAmount(rs.getLong("amount"));
                    break;
                case MONTHLY_PLANNED:
                    item = new MonthlyPlannedTransfer();
                    ((MonthlyPlannedTransfer)item).setBegin(of(rs.getDate("period_begin")));
                    ((MonthlyPlannedTransfer)item).setEnd(of(rs.getDate("period_end")));
                    ((MonthlyPlannedTransfer)item).setAmount(rs.getLong("amount"));
                    break;
                default:
                    throw new IllegalStateException();
            }
            item.setName(rs.getString("name"));
            item.setItemId(rs.getLong("id"));
            item.setParentItemId(fetchLong(rs, "parent_id"));
            return item;
        }
    }

    private Long fetchLong(ResultSet rs, String label) throws SQLException {
        long n = rs.getLong(label);
        if (rs.wasNull()) {
            return null;
        }
        return n;
    }
}
