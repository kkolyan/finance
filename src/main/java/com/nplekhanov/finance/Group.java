package com.nplekhanov.finance;

import java.time.YearMonth;
import java.util.*;

/**
 * @author nplekhanov
 */
public class Group extends Item {
    private Collection<Item> children = new ArrayList<>();

    @Override
    public Collection<YearMonth> calculateRange() {
        Collection<YearMonth> range = new TreeSet<>();
        for (Item child: children) {
            range.addAll(child.calculateRange());
        }
        return range;
    }

    @Override
    public long calculateAmount(YearMonth month) {
        long amount = 0;
        for (Item item: children) {
            amount += item.calculateAmount(month);
        }
        return amount;
    }

    public List<? extends Item> explore(Collection<Long> itemIds) {
        List<Item> paths = new ArrayList<>();

        paths.add(this);

        if (itemIds.contains(getItemId())) {
            for (Item child: children) {
                if (child instanceof Group) {
                    paths.addAll(((Group) child).explore(itemIds));
                } else {
                    paths.add(child);
                }
            }
        }
        return paths;
    }

    @Override
    public void addChild(Item child) {
        children.add(child);
    }

    public Collection<Item> getChildren() {
        return Collections.unmodifiableCollection(children);
    }

    @Override
    public String toString() {
        return "Group{"+super.toString() + " " +
                "children=" + children +
                "}";
    }
}
