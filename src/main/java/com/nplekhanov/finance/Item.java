package com.nplekhanov.finance;

import java.time.Month;
import java.time.Year;
import java.time.YearMonth;
import java.util.*;

/**
 * @author nplekhanov
 */
public class Item {
    private long itemId;
    private Long parentItemId;
    private String name;
    private Collection<Item> children = new ArrayList<>();
    private Collection<Transfer> transfers = new ArrayList<>();
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

    public List<Item> explore(Collection<String> names) {
        List<Item> paths = new ArrayList<>();

        paths.add(this);

        if (names.contains(name)) {
            for (Item child: children) {
                paths.addAll(child.explore(names));
            }
        }
        return paths;
    }

    public Collection<YearMonth> calculateRange() {
        Collection<YearMonth> range = new TreeSet<>();
        for (Item child: children) {
            range.addAll(child.calculateRange());
        }
        for (Transfer transfer: transfers) {
            range.addAll(transfer.getRange());
        }
        return range;
    }

    public long calculateAmount(YearMonth month) {
        long amount = 0;
        for (Item item: children) {
            amount += item.calculateAmount(month);
        }
        for (Transfer transfer: transfers) {
            if (transfer.getRange().contains(month)) {
                amount+= transfer.getAmount();
            }
        }
        return amount;
    }

    public long calculateAmount(Year year) {
        long amount = 0;
        for (Month month: Month.values()) {
            amount +=calculateAmount(year.atMonth(month));
        }
        return amount;
    }

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

    public Collection<Transfer> getTransfers() {
        return transfers;
    }

    public void setTransfers(Collection<Transfer> transfers) {
        this.transfers = transfers;
    }

    public Collection<Item> getChildren() {
        return children;
    }

    public void setChildren(Collection<Item> children) {
        this.children = children;
    }

    public Item getParent() {
        return parent;
    }

    public void setParent(Item parent) {
        this.parent = parent;
    }

    @Override
    public String toString() {
        return "Item{" +
                "itemId=" + itemId +
                ", parentItemId=" + parentItemId +
                ", name='" + name + '\'' +
                ", children=" + children +
                ", transfers=" + transfers +
                '}';
    }
}
