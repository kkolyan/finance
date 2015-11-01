package com.nplekhanov.finance;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.Collection;
import java.util.Collections;

/**
 * @author nplekhanov
 */
public class InstantTransfer extends Transfer {
    private LocalDate date;

    public LocalDate getDate() {
        return date;
    }

    public void setDate(LocalDate date) {
        this.date = date;
    }

    @Override
    public Collection<YearMonth> getRange() {
        return Collections.singleton(YearMonth.of(date.getYear(), date.getMonth()));
    }

    @Override
    public String toString() {
        return "InstantTransfer{" +
                "date=" + date +
                ", amount=" + getAmount() +
                '}';
    }
}
