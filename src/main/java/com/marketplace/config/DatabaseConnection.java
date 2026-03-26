package com.marketplace.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;


public class DatabaseConnection {

    private static DatabaseConnection instance;

    private static final String DEFAULT_URL = "jdbc:mysql://localhost:3306/marketplace";
    private static final String DEFAULT_USER = "root";
    private static final String DEFAULT_PASSWORD = "0909480911aA@";
    private Connection connection;
    private String url;
    private String user;
    private String password;

    private DatabaseConnection() {
        this.url = DEFAULT_URL;
        this.user = DEFAULT_USER;
        this.password = DEFAULT_PASSWORD;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("MySQL JDBC Driver đã được load thành công!");
        } catch (ClassNotFoundException e) {
            System.err.println("Không tìm thấy MySQL JDBC Driver!");
            e.printStackTrace();
        }
    }

    public static synchronized DatabaseConnection getInstance() {
        if (instance == null) {
            instance = new DatabaseConnection();
        }
        return instance;
    }

    public Connection getConnection() throws SQLException {
        if (connection == null || connection.isClosed()) {
            try {
                connection = DriverManager.getConnection(url, user, password);
                System.out.println("Kết nối database thành công!");
            } catch (SQLException e) {
                System.err.println("Lỗi khi kết nối database!");
                System.err.println("URL: " + url);
                System.err.println("User: " + user);
                e.printStackTrace();
                throw e;
            }
        }
        return connection;
    }

    public boolean testConnection() {
        try {
            Connection conn = getConnection();
            return conn != null && !conn.isClosed() && conn.isValid(5);
        } catch (SQLException e) {
            System.err.println("Test connection thất bại!");
            e.printStackTrace();
            return false;
        }
    }

    public void closeConnection() {
        if (connection != null) {
            try {
                connection.close();
                System.out.println("Đã đóng kết nối database");
            } catch (SQLException e) {
                System.err.println("Lỗi khi đóng connection!");
                e.printStackTrace();
            }
        }
    }

    public String getDatabaseInfo() {
        try {
            Connection conn = getConnection();
            return "Database: " + conn.getMetaData().getDatabaseProductName() + " " +
                   conn.getMetaData().getDatabaseProductVersion() +
                   "\nURL: " + url;
        } catch (SQLException e) {
            return "Không thể lấy thông tin database";
        }
    }

    public static void main(String[] args) {
        System.out.println("=== Test DatabaseConnection ===");
        DatabaseConnection dbConn = DatabaseConnection.getInstance();
        if (dbConn.testConnection()) {
            System.out.println("✓ Kết nối database thành công!");
            System.out.println(dbConn.getDatabaseInfo());
        } else {
            System.out.println("✗ Kết nối database thất bại!");
        }
        dbConn.closeConnection();
    }
}
