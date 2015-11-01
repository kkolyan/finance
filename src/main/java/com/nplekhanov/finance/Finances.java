package com.nplekhanov.finance;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.PreparedStatementCreator;
import org.springframework.jdbc.core.RowCallbackHandler;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.simple.SimpleJdbcInsert;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.TransactionStatus;
import org.springframework.transaction.support.TransactionCallback;
import org.springframework.transaction.support.TransactionOperations;
import org.springframework.transaction.support.TransactionTemplate;

import java.sql.*;
import java.sql.Date;
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
        return template.queryForList("select distinct name from item order by name", String.class);
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
                parent.getChildren().add(item);
                item.setParent(parent);
            } else {
                roots.add(item);
            }
        }
        Collection<Transfer> transfers = loadTransfers();
        for (Transfer transfer: transfers) {
            itemById.get(transfer.getItemId()).getTransfers().add(transfer);
        }
        if (roots.size() != 1) {
            throw new IllegalStateException("expected 1 root, but found: "+roots);
        }
        return roots.iterator().next();
    }

    public Collection<Transfer> loadTransfers() {
        final Collection<Transfer> transfers = new ArrayList<>();
        template.query("select * from instant_transfer", new RowCallbackHandler() {
            @Override
            public void processRow(ResultSet rs) throws SQLException {

                InstantTransfer t = new InstantTransfer();
                t.setItemId(rs.getLong("item_id"));
                t.setAmount(rs.getLong("amount"));

                t.setDate(rs.getDate("at").toLocalDate());

                transfers.add(t);
            }
        });
        template.query("select * from monthly_transfer", new RowCallbackHandler() {
            @Override
            public void processRow(ResultSet rs) throws SQLException {

                MonthlyTransfer t = new MonthlyTransfer();
                t.setItemId(rs.getLong("item_id"));
                t.setAmount(rs.getLong("amount"));

                t.setBegin(YearMonth.from(rs.getDate("begin").toLocalDate()));
                t.setEnd(YearMonth.from(rs.getDate("end").toLocalDate()));
                transfers.add(t);
            }
        });
        return transfers;
    }

    public void createGroup(String name, long parentId) {
        template.update("insert into item (name,parent_id) values (?, ?)", name, parentId);
    }

    public void associate(final long itemId, final long parentId) {
        tx.execute(new TransactionCallback<Object>() {
            @Override
            public Object doInTransaction(TransactionStatus status) {
                template.update("update item set parent_id = ? where id = ?", parentId, itemId);
                return null;
            }
        });
    }

    public Collection<Item> loadShallowItems() {
        final Map<Long,Item> itemMap = new HashMap<>();
        template.query("select * from item", new RowCallbackHandler() {

            @Override
            public void processRow(ResultSet rs) throws SQLException {
                Item item = new Item();
                item.setItemId(rs.getLong("id"));
                item.setName(rs.getString("name"));
                item.setParentItemId(fetchLong(rs, "parent_id"));

                itemMap.put(item.getItemId(), item);
            }
        });

        for (Item item: itemMap.values()) {
            Item parent = itemMap.get(item.getParentItemId());
            item.setParent(parent);
        }

        List<Item> items = new ArrayList<>(itemMap.values());
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
                long itemId = getOrCreateItem(name, parent);

                template.update("insert into instant_transfer (item_id, amount, at) values (?, ?, ?)", itemId, amount, Date.valueOf(at));
                return null;
            }
        });
    }

    public void addMonthlyTransfer(final String name, final long amount, final YearMonth begin,final YearMonth end, final Long parent) {
        tx.execute(new TransactionCallback<Object>() {
            @Override
            public Object doInTransaction(TransactionStatus status) {
                long itemId = getOrCreateItem(name, parent);

                template.update("insert into monthly_transfer (item_id, amount, begin, end) values (?, ?, ?,?)",
                        itemId, amount, Date.valueOf(begin.atDay(1)), Date.valueOf(end.atDay(1)));

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

    private long getOrCreateItem(String name, Long parent) {

        if (parent != null) {

            List<Item> matched = template.query("select id, parent_id from item where name = ?", new RowMapper<Item>() {
                @Override
                public Item mapRow(ResultSet rs, int rowNum) throws SQLException {
                    Item item = new Item();
                    item.setItemId(rs.getLong("id"));
                    item.setParentItemId(fetchLong(rs, "parent_id"));
                    return item;
                }
            }, name);
            if (!matched.isEmpty()) {
                if (matched.size() > 1) {
                    throw new IllegalStateException("too many matchings for "+name);
                }
                if (!Objects.equals(matched.get(0).getParentItemId(),parent)) {
                    throw new IllegalStateException("parent id of existing item differs of specified");
                }
                return matched.get(0).getItemId();
            }
        }

        SimpleJdbcInsert insert = new SimpleJdbcInsert(template);
        insert.setTableName("item");
        Map<String, Object> params = new HashMap<>();
        params.put("name", name);
        params.put("parent_id", parent);
        insert.setGeneratedKeyName("id");
        return insert.executeAndReturnKey(params).longValue();
    }

    private Long fetchLong(ResultSet rs, String label) throws SQLException {
        long n = rs.getLong(label);
        if (rs.wasNull()) {
            return null;
        }
        return n;
    }
}
