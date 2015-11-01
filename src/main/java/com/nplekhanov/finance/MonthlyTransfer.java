package com.nplekhanov.finance;

import java.time.YearMonth;
import java.util.ArrayList;
import java.util.Collection;

/**
 * @author nplekhanov
 */
public class MonthlyTransfer extends Transfer {
    private YearMonth begin;
    private YearMonth end;

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

    @Override
    public Collection<YearMonth> getRange() {
        Collection<YearMonth> range = new ArrayList<>();
        for (YearMonth m = begin; !m.isAfter(end); m = m.plusMonths(1)) {
            range.add(m);
        }
        return range;
    }

    @Override
    public String toString() {
        return "MonthlyTransfer{" +
                "begin=" + begin +
                ", end=" + end +
                ", amount=" + getAmount() +
                '}';
    }
}
