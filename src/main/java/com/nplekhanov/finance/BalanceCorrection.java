package com.nplekhanov.finance;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowCallbackHandler;
import org.springframework.stereotype.Service;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.*;

/**
 * @author nplekhanov
 */
@Service
public class BalanceCorrection {

    @Autowired
    private JdbcTemplate jdbc;

    public void addCorrections(Item root) {

        Group rootCorrectionItem = new Group();
        rootCorrectionItem.setName("Auto ХЗ");
        rootCorrectionItem.setParentItemId(root.getItemId());
        rootCorrectionItem.setParent(root);
        rootCorrectionItem.setItemId(-1);

        Balance last = null;
        for (Balance balance: getActualBalances().values()) {
            if (last != null) {
                long registeredChangeAtPeriod = 0;
                Collection<YearMonth> range = getInclusiveRange(last.getAt().plusMonths(1), balance.getAt());
                for (YearMonth month: range) {
                    for (AmountType amountType: AmountType.values()) {
                        registeredChangeAtPeriod += root.calculateAmount(month, amountType);
                    }
                }
                long expectedChangeAtPeriod = balance.getAmount() - last.getAmount();
                // expectedChangeAtPeriod = registeredChangeAtPeriod + correction
                long correction = expectedChangeAtPeriod - registeredChangeAtPeriod;
                for (YearMonth month: range) {
                    InstantTransfer correctionItem = new InstantTransfer();
                    correctionItem.setAmountType(AmountType.CORRECTED);
                    correctionItem.setAmount(correction / range.size());
                    correctionItem.setAt(month.atDay(1));
                    correctionItem.setName("ХЗ");
                    correctionItem.setItemId(-1);
                    correctionItem.setParent(rootCorrectionItem);
                    correctionItem.setParentItemId(rootCorrectionItem.getItemId());
                    rootCorrectionItem.addChild(correctionItem);
                }
            }
            last = balance;
        }
        root.addChild(rootCorrectionItem);
    }

    private Collection<YearMonth> getInclusiveRange(YearMonth from, YearMonth to) {
        Collection<YearMonth> range = new ArrayList<>();
        for (YearMonth month = from; !month.isAfter(to); month = month.plusMonths(1)) {
            range.add(month);
        }
        return range;
    }

    public NavigableMap<YearMonth,Balance> getActualBalances() {
        final NavigableMap<YearMonth, Balance> map = new TreeMap<>();
        jdbc.query("select * from actual_balance", new RowCallbackHandler() {
            @Override
            public void processRow(ResultSet rs) throws SQLException {
                LocalDate at = rs.getDate("at").toLocalDate();
                YearMonth month = YearMonth.of(at.getYear(), at.getMonth());

                long amount = rs.getLong("amount");

                Balance balance = map.getOrDefault(month, new Balance());
                balance.setAt(month);
                balance.setAmount(balance.getAmount() + amount);

                map.put(month, balance);
            }
        });
        return map;
    }
}
