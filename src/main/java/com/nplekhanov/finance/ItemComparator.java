package com.nplekhanov.finance;

import java.util.Comparator;

public class ItemComparator implements Comparator<Item> {
    @Override
    public int compare(Item o1, Item o2) {
        if (o1 instanceof InstantTransfer) {
            if (o2 instanceof InstantTransfer) {
                return ((InstantTransfer) o1).getAt().compareTo(((InstantTransfer) o2).getAt());
            }
            if (o2 instanceof MonthlyPlannedTransfer) {
                return -1;
            }
            if (o2 instanceof Group) {
                return -1;
            }
            throw new IllegalStateException();
        }
        if (o1 instanceof MonthlyPlannedTransfer) {
            if (o2 instanceof MonthlyPlannedTransfer) {
                return ((MonthlyPlannedTransfer) o1).getBegin().compareTo(((MonthlyPlannedTransfer) o2).getBegin());
            }
            if (o2 instanceof Group) {
                return -1;
            }
        }
        if (o1 instanceof Group) {
            if (o2 instanceof Group) {
                return o1.getName().compareTo(o2.getName());
            }
        }
        return -compare(o2, o1);
    }
}