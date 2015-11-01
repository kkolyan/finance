package com.nplekhanov.finance;

import java.time.YearMonth;
import java.util.Collection;

/**
 * @author nplekhanov
 */
public abstract class Transfer {
    private long itemId;
    private long amount;

    public long getItemId() {
        return itemId;
    }

    public void setItemId(long itemId) {
        this.itemId = itemId;
    }

    public long getAmount() {
        return amount;
    }

    public void setAmount(long amount) {
        this.amount = amount;
    }

    public abstract Collection<YearMonth> getRange();
}
