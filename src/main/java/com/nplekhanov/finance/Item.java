package com.nplekhanov.finance;

import java.time.YearMonth;
import java.util.*;

/**
 * @author nplekhanov
 */
public abstract class Item {
    private long itemId;
    private Long parentItemId;
    private String name;
    private Item parent;

    public List<Item> getPath() {
        List<Item> path = new ArrayList<>();
        if (parent != null) {
            path.add(parent);
            path.addAll(parent.getPath());
        }
        return path;
    }

    public String getPathAsString(String delimiter) {
        if (parent == null) {
            return name;
        }
        return parent.getPathAsString(delimiter) + delimiter + name;
    }

    public abstract Collection<YearMonth> calculateRange();

    public abstract long calculateAmount(YearMonth month);

    public long getItemId() {
        return itemId;
    }

    public void setItemId(long itemId) {
        this.itemId = itemId;
    }

    public Long getParentItemId() {
        return parentItemId;
    }

    public void setParentItemId(Long parentItemId) {
        this.parentItemId = parentItemId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Item getParent() {
        return parent;
    }

    public void setParent(Item parent) {
        this.parent = parent;
    }

    @Override
    public String toString() {
        return "{" +
                "itemId=" + itemId +
                ", parentItemId=" + parentItemId +
                ", name='" + name + '\'' +
//                ", parent=" + parent +
                '}';
    }

    public void addChild(Item child) {
        throw new IllegalStateException("can't add child "+child+" to item " + this);
    }

}
