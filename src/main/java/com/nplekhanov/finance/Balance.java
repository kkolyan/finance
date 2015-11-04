package com.nplekhanov.finance;

import java.time.LocalDate;
import java.time.YearMonth;

/**
 * @author nplekhanov
 */
public class Balance {
    private YearMonth at;
    private long amount;

    public YearMonth getAt() {
        return at;
    }

    public void setAt(YearMonth at) {
        this.at = at;
    }

    public long getAmount() {
        return amount;
    }

    public void setAmount(long amount) {
        this.amount = amount;
    }
}
