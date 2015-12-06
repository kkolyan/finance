package com.nplekhanov.finance;

/**
 * @author nplekhanov
 */
public class Escaping {
    public static String safeHtml(Object value) {
        if (value == null) {
            return "null";
        }
        return value.toString()
                .replace("\"", "&quot;")
                .replace("<", "&lt;")
                .replace(">", "&gt;");
    }
}
