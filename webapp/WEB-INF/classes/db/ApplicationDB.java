package db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * BuyMe Auction System - Database Connection Handler
 * Provides connection management for MySQL database access.
 * 
 * @author Group 24 - CS 336 Fall 2025
 */
public class ApplicationDB {
    
    // Database configuration - update these for your environment
    private static final String DB_URL = "jdbc:mysql://localhost:3306/cs336project";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "Hello123";
    
    public ApplicationDB() {
        // Default constructor
    }
    
    /**
     * Creates and returns a new database connection.
     * Each request should get its own connection since HTTP is stateless.
     * 
     * @return Connection object to the MySQL database
     */
    public Connection getConnection() {
        Connection connection = null;
        
        try {
            // Load MySQL JDBC driver (5.1.x uses com.mysql.jdbc.Driver)
            Class.forName("com.mysql.jdbc.Driver").newInstance();
        } catch (InstantiationException | IllegalAccessException | ClassNotFoundException e) {
            System.err.println("Error loading MySQL driver: " + e.getMessage());
            e.printStackTrace();
        }
        
        try {
            // Create connection with configured credentials
            connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
        } catch (SQLException e) {
            System.err.println("Error connecting to database: " + e.getMessage());
            e.printStackTrace();
        }
        
        return connection;
    }
    
    /**
     * Safely closes a database connection.
     * Should be called in a finally block after database operations.
     * 
     * @param connection The connection to close
     */
    public void closeConnection(Connection connection) {
        if (connection != null) {
            try {
                connection.close();
            } catch (SQLException e) {
                System.err.println("Error closing connection: " + e.getMessage());
                e.printStackTrace();
            }
        }
    }
    
    /**
     * Test method to verify database connectivity.
     */
    public static void main(String[] args) {
        ApplicationDB appDB = new ApplicationDB();
        Connection connection = appDB.getConnection();
        
        if (connection != null) {
            System.out.println("Database connection successful!");
            System.out.println("Connection: " + connection);
            appDB.closeConnection(connection);
        } else {
            System.out.println("Failed to connect to database.");
        }
    }
}
