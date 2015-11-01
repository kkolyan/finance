package com.nplekhanov.finance;

import java.util.ArrayList;
import java.util.List;

/**
 * @author nplekhanov
 */
public class ItemReference {
    private List<Item> path = new ArrayList<>();
    private Item item;

    public ItemReference(List<Item> path, Item item) {
        this.path = path;
        this.item = item;
    }

    public List<Item> getPath() {
        return path;
    }

    public Item getItem() {
        return item;
    }
}