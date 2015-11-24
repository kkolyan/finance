package com.nplekhanov.finance;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.Scanner;

/**
 * @author nplekhanov
 */
@Service
public class Backup {

    @Value("${dataSource.url}")
    private String url;

    @Value("${dataSource.user}")
    private String username;

    @Value("${dataSource.password}")
    private String password;

    public void backup() {
        String dump = createDump("");

        System.out.println(dump);
    }

    public String createDump(String encoding) {
        try {
            String commandTemplate = String.format("mysqldump --user=%s --password=%s --host=$1 $2", username, password);
            String command = url.split("\\?", 2)[0].replaceAll("jdbc\\:mysql\\:\\/\\/(.+)\\:3306\\/(.+)", commandTemplate);
            Process process = Runtime.getRuntime().exec(command);
            Scanner scanner = new Scanner(process.getInputStream(), encoding);
            String s = "";
            while (scanner.hasNextLine()) {
                s += scanner.nextLine() + "\n";
            }
            return s;
        } catch (IOException e) {
            throw new IllegalStateException(e);
        }
    }
}
