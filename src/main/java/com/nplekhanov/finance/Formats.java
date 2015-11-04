package com.nplekhanov.finance;

import java.time.format.DateTimeFormatter;

/**
 * @author nplekhanov
 */
public class Formats {
    public static final String YEAR_MONTH_PATTERN = "yyyy-MM";
    public static final String DATE_TIME_PATTERN = "yyyy-MM-dd";
    public static DateTimeFormatter DATE_TIME = DateTimeFormatter.ofPattern(DATE_TIME_PATTERN);
    public static DateTimeFormatter YEAR_MONTH = DateTimeFormatter.ofPattern(YEAR_MONTH_PATTERN);
}
