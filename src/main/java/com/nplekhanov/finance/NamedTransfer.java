package com.nplekhanov.finance;

/**
 * @author nplekhanov
 */
public class NamedTransfer {
    private String name;
    private InstantTransfer transfer;

    public void setName(String name) {
        this.name = name;
    }

    public void setTransfer(InstantTransfer transfer) {
        this.transfer = transfer;
    }

    public String getName() {
        return name;
    }

    public InstantTransfer getTransfer() {
        return transfer;
    }
}
