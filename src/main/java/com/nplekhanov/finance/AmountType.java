package com.nplekhanov.finance;

/**
 * @author nplekhanov
 */
public enum AmountType {
    /**
     * real transfer in the past
     */
    ACTUAL,

    /**
     * real transfer in the future
     */
    PLANNED,

    /**
     * probable transfer in the future
     */
    ESTIMATED,

    /**
     * implicit (not registered) real transfer in the past
     */
    CORRECTED
}
