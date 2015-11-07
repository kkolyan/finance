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
    private AmountType amountType;

    @Override
    public Collection<YearMonth> calculateRange() {
        return Collections.singleton(YearMonth.of(at.getYear(), at.getMonth()));
    }

    @Override
    public long calculateAmount(YearMonth month, AmountType amountType) {
        if (this.amountType != amountType) {
            return 0;
        }
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

    public AmountType getAmountType() {
        return amountType;
    }

    public void setAmountType(AmountType amountType) {
        this.amountType = amountType;
    }

    @Override
    public String toString() {
        return "InstantTransfer{" +
                "at=" + at +
                ", amount=" + amount +
                ", amountType=" + amountType +
                "} " + super.toString();
    }
}
