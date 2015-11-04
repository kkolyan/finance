package com.nplekhanov.finance;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.Collection;
import java.util.Collections;

/**
 * @author nplekhanov
 */
public class InstantTransfer extends Item {
    private LocalDate at;
    private long amount;
    private boolean planned;

    @Override
    public Collection<YearMonth> calculateRange() {
        return Collections.singleton(YearMonth.of(at.getYear(), at.getMonth()));
    }

    @Override
    public long calculateAmount(YearMonth month) {
        if (at.getYear() != month.getYear() || at.getMonth() != month.getMonth()) {
            return 0;
        }
        return amount;
    }

    public LocalDate getAt() {
        return at;
    }

    public void setAt(LocalDate at) {
        this.at = at;
    }

    public long getAmount() {
        return amount;
    }

    public void setAmount(long amount) {
        this.amount = amount;
    }

    public boolean isPlanned() {
        return planned;
    }

    public void setPlanned(boolean planned) {
        this.planned = planned;
    }

    @Override
    public String toString() {
        return "InstantTransfer{" +
                "at=" + at +
                ", amount=" + amount +
                ", planned=" + planned +
                "} " + super.toString();
    }
}
