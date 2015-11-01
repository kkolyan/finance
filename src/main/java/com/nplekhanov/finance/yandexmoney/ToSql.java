package com.nplekhanov.finance.yandexmoney;

import java.io.File;
import java.io.FileNotFoundException;
import java.text.DecimalFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;

/**
 * @author nplekhanov
 */
public class ToSql {
    public static void main(String[] args) throws FileNotFoundException {
        Scanner scanner = new Scanner(new File("yandexmoney/history-31.10.2015-23_33.csv"));
        List<String> lines = new ArrayList<>();
        while (scanner.hasNextLine()) {
            lines.add(scanner.nextLine());
        }
        lines = lines.subList(5, lines.size());

        for (String line: lines) {
            String[] fields = line.split(";");
            boolean plus = fields[0].equals("+");
            LocalDateTime time = LocalDateTime.parse(fields[1], DateTimeFormatter.ofPattern("dd.MM.yyyy HH:mm:ss"));
            double summ = Double.parseDouble(fields[2].replace(",", "."));
            String place = fields[5];

            System.out.printf("insert into ym (at, amount, place) values ('%s', %s, '%s');\n",
                    DateTimeFormatter.ofPattern("yyyy.MM.dd HH:mm:ss").format(time),
                    (long) ((plus ? 1 : -1) * summ),
                    place.replace("'", "''"));
        }
    }
}
