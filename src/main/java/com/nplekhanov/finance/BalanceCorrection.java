package com.nplekhanov.finance;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowCallbackHandler;
import org.springframework.stereotype.Service;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.NavigableMap;
import java.util.TreeMap;

/**
 * @author nplekhanov
 */
@Service
public class BalanceCorrection {

    @Autowired
    private JdbcTemplate jdbc;

    public Item createCorrection(Item root, NavigableMap<LocalDate, Balance> corrections) {
        NavigableMap<YearMonth,Balance> registeredBalance = new TreeMap<>();
        for (YearMonth month: root.calculateRange()) {

        }
        throw new UnsupportedOperationException();
    }

    public NavigableMap<YearMonth, Balance> getActualBalances() {
        final NavigableMap<YearMonth, Balance> map = new TreeMap<>();
        jdbc.query("select * from actual_balance", new RowCallbackHandler() {
            @Override
            public void processRow(ResultSet rs) throws SQLException {
                LocalDate at = rs.getDate("at").toLocalDate();
                long amount = rs.getLong("amount");
                Balance balance = new Balance();
                balance.setAmount(amount);
                balance.setAt(YearMonth.of(at.getYear(), at.getMonth()));
                map.put(balance.getAt(), balance);
            }
        });
        return map;
    }
}
