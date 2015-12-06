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

    @Autowired
    private BalanceCorrection balanceCorrection;

    public Item loadRoot(Long userId) {
        final Map<Long,Item> itemById = loadHierarchy(userId);
        Collection<Item> roots = new ArrayList<>();

        for (Item item: itemById.values()) {
            Long parentId = item.getParentItemId();
            if (parentId == null) {
                roots.add(item);
            }
        }
        if (roots.size() != 1) {
            throw new IllegalStateException("expected 1 root, but found: "+roots);
        }
        Item root = roots.iterator().next();
        balanceCorrection.addCorrections(root, userId);
        return root;
    }

    public void createGroup(String name, Long parentId, Long userId) {
        template.update("insert into item1 (name, parent_id, type, owner_id) values (?, ?, ?, ?)", name, parentId, ItemType.GROUP.name(), userId);
    }

    public void associate(final long itemId, final Long parentId, final Long userId) {
        tx.execute(new TransactionCallback<Object>() {
            @Override
            public Object doInTransaction(TransactionStatus status) {
                template.update("update item1 set parent_id = ? where id = ? and owner_id = ?", parentId, itemId, userId);
                return null;
            }
        });
    }

    public Collection<Group> loadGroups(Long userId) {
        Collection<Group> groups = new ArrayList<>();
        for (Item item: loadShallowItems(userId)) {
            if (item instanceof Group) {
                groups.add((Group) item);
            }
        }
        return groups;
    }

    public Collection<Item> loadShallowItems(Long userId) {
        final Map<Long,Item> itemMap = new HashMap<>();

        List<Item> items = template.query("select * from item1 where owner_id = ?", new ItemRowMapper(), userId);

        Group root = new Group();
        root.setName("Total");
        root.setItemId(0);
        items.add(root);

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

    public void addInstantTransfer(String name, final long amount, final LocalDate at, final Long parent, Long userId) {
        if (name.isEmpty()) {
            name = template.queryForObject("select name from item1 where id = ? and owner_id = ?", String.class, parent, userId);
        }
        ItemType type = !at.withDayOfMonth(1).isAfter(LocalDate.now().withDayOfMonth(1)) ? ItemType.INSTANT_ACTUAL : ItemType.INSTANT_PLANNED;
        template.update("insert into item1 (name, parent_id, amount, at, type, owner_id) values (?, ?, ?, ?, ?, ?)", name, parent, amount, Date.valueOf(at), type.name(), userId);
    }

    public void deleteItem(Long itemId, Long userId) {
        template.update("delete from item1 where id = ? and owner_id = ?", itemId, userId);
    }

    public void addMonthlyTransfer(final String name, final long amount, final YearMonth begin,final YearMonth end, final Long parent, final Long userId) {
        tx.execute(new TransactionCallback<Object>() {
            @Override
            public Object doInTransaction(TransactionStatus status) {

                LocalDate thisMonth = LocalDate.now().withDayOfMonth(1);
                for (LocalDate d = LocalDate.of(begin.getYear(), begin.getMonth(), 1); d.isBefore(thisMonth); d = d.plusMonths(1)) {
                    addInstantTransfer(name, amount, d, parent, userId);
                }

                template.update("insert into item1 (name, parent_id, amount, period_begin, period_end, type, owner_id) values (?, ?, ?, ?, ?, ?, ?)",
                        name, parent, amount, Date.valueOf(begin.atDay(1)), Date.valueOf(end.atDay(1)), ItemType.MONTHLY_PLANNED.name(), userId);

                return null;
            }
        });
    }

    private Map<Long,Item> loadHierarchy(Long userId) {
        final Map<Long,Item> itemById = new HashMap<>();
        for (Item item: loadShallowItems(userId)) {
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
            }
        }
        return itemById;
    }

    public Item getTransfer(Long transferId, Long userId) {
        if (Objects.equals(transferId, 0L)) {
            return loadRoot(userId);
        }
        return loadHierarchy(userId).get(transferId);
    }

    private YearMonth of(java.sql.Date sqlDate) {
        LocalDate date = sqlDate.toLocalDate();
        return YearMonth.of(date.getYear(), date.getMonth());
    }

    private java.sql.Date asSql(YearMonth month) {
        return Date.valueOf(LocalDate.of(month.getYear(), month.getMonth(), 1));
    }

    public void modifyTransfer(long transferId, LocalDate at, long amount, String name, Long parent, Long userId) {
        template.update(
                "update item1 set name = ?, parent_id = ?, at = ?, amount = ? where id = ? and (type = ? or type = ?) and owner_id = ?",
                name, parent, Date.valueOf(at), amount, transferId, ItemType.INSTANT_ACTUAL.name(), ItemType.INSTANT_PLANNED.name(), userId);
    }

    public void modifyTransfer(long transferId, YearMonth begin, YearMonth end, long amount, String name, Long parent, Long userId) {
        template.update(
                "update item1 set name = ?, parent_id = ?, period_begin = ?, period_end = ?, amount = ? where id = ? and type = ? and owner_id = ?",
                name, parent, asSql(begin), asSql(end), amount, transferId, ItemType.MONTHLY_PLANNED.name(), userId);
    }

    public void modifyGroup(long transferId, String name, Long parent, Long userId) {
        template.update(
                "update item1 set name = ?, parent_id = ? where id = ? and type = ? and owner_id = ?",
                name, parent, transferId, ItemType.GROUP.name(), userId);
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
                    AmountType amountType = type == ItemType.INSTANT_PLANNED ? AmountType.PLANNED : AmountType.ACTUAL;
                    ((InstantTransfer)item).setAmountType(amountType);
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
