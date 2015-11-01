package com.nplekhanov.finance;

/**
 * @author nplekhanov
 */
public class Escaping {
    public static String safeHtml(Object value) {
        return value.toString()
                .replace("\"", "&quot;")
                .replace("<", "&lt;")
                .replace(">", "&gt;");
    }
}
