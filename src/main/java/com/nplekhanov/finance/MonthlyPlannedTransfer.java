package com.nplekhanov.finance;

import java.time.YearMonth;
import java.util.ArrayList;
import java.util.Collection;

/**
 * @author nplekhanov
 */
public class MonthlyPlannedTransfer extends Item {
    private YearMonth begin;
    private YearMonth end;
    private long amount;

    @Override
    public Collection<YearMonth> calculateRange() {
        Collection<YearMonth> range = new ArrayList<>();
        for (YearMonth m = begin; !m.isAfter(end); m = m.plusMonths(1)) {
            range.add(m);
        }
        return range;
    }

    @Override
    public long calculateAmount(YearMonth month, AmountType amountType) {
        if (amountType != AmountType.PLANNED) {
            return 0;
        }
        if (month.isAfter(end) || month.isBefore(begin)) {
            return 0;
        }
        return amount;
    }

    public YearMonth getBegin() {
        return begin;
    }

    public void setBegin(YearMonth begin) {
        this.begin = begin;
    }

    public YearMonth getEnd() {
        return end;
    }

    public void setEnd(YearMonth end) {
        this.end = end;
    }

    public long getAmount() {
        return amount;
    }

    public void setAmount(long amount) {
        this.amount = amount;
    }

    @Override
    public String toString() {
        return "MonthlyPlannedTransfer{" +
                "begin=" + begin +
                ", end=" + end +
                ", amount=" + amount +
                "} " + super.toString();
    }
}
