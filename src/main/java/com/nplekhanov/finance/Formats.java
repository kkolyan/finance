package com.nplekhanov.finance;

import java.time.format.DateTimeFormatter;

/**
 * @author nplekhanov
 */
public class Formats {
    public static final String DATE_TIME_PATTERN = "yyyy-MM-dd";
    public static DateTimeFormatter DATE_TIME = DateTimeFormatter.ofPattern(DATE_TIME_PATTERN);
}
