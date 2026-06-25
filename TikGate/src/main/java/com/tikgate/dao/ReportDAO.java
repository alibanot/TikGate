package com.tikgate.dao;

import com.tikgate.util.DBConnection;
import java.sql.*;
import java.util.HashMap;
import java.util.Map;

public class ReportDAO {
    
    public int getTotalUsers() {
        String sql = "SELECT COUNT(*) FROM USERS";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int getActiveEventsCount() {
        String sql = "SELECT COUNT(*) FROM EVENT WHERE STATUS = 'ACTIVE'";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int getTicketsSoldCount() {
        String sql = "SELECT COUNT(*) FROM TICKET";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public double getTotalRevenue() {
        String sql = "SELECT SUM(TOTAL_AMOUNT) FROM BOOKING WHERE STATUS = 'PAID'";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) return rs.getDouble(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }

    public Map<String, Object> getDashboardStats() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalUsers", getTotalUsers());
        stats.put("totalEvents", getActiveEventsCount());
        stats.put("totalTickets", getTicketsSoldCount());
        stats.put("totalRevenue", getTotalRevenue());
        return stats;
    }
}
