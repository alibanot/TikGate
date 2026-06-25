package com.tikgate.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    // Updated for Oracle Database 23ai with user provided credentials
    private static final String URL = "jdbc:oracle:thin:@localhost:1521/FREEPDB1"; 
    private static final String USER = "group4";
    private static final String PASS = "abc123";

    static {
        try {
            Class.forName("oracle.jdbc.OracleDriver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASS);
    }
}
