package com.tikgate.dao;

import com.tikgate.model.Ticket;
import com.tikgate.util.DBConnection;
import java.sql.*;
import java.util.Date;

public class TicketDAO {
    public boolean createTicket(Ticket ticket) {
        String sql = "INSERT INTO TICKET (TICKET_ID, BOOKING_ITEM_ID, QR_CODE, PDF_FILE, GENERATED_DATE, STATUS) " +
                     "VALUES (TICKET_SEQ.NEXTVAL, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, ticket.getBookingItemId());
            pstmt.setString(2, ticket.getQrCode());
            pstmt.setString(3, ticket.getPdfFile());
            pstmt.setDate(4, new java.sql.Date(new Date().getTime()));
            pstmt.setString(5, "VALID");
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public Ticket getTicketByBookingId(int bookingId) {
        String sql = "SELECT t.* FROM TICKET t " +
                     "JOIN BOOKING_ITEM bi ON t.BOOKING_ITEM_ID = bi.BOOKING_ITEM_ID " +
                     "WHERE bi.BOOKING_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, bookingId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    Ticket t = new Ticket();
                    t.setTicketId(rs.getInt("TICKET_ID"));
                    t.setBookingItemId(rs.getInt("BOOKING_ITEM_ID"));
                    t.setQrCode(rs.getString("QR_CODE"));
                    t.setPdfFile(rs.getString("PDF_FILE"));
                    t.setGeneratedDate(rs.getDate("GENERATED_DATE"));
                    t.setStatus(rs.getString("STATUS"));
                    return t;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public Ticket getTicketByQrCode(String qrCode) {
        String sql = "SELECT * FROM TICKET WHERE QR_CODE = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, qrCode);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    Ticket t = new Ticket();
                    t.setTicketId(rs.getInt("TICKET_ID"));
                    t.setBookingItemId(rs.getInt("BOOKING_ITEM_ID"));
                    t.setQrCode(rs.getString("QR_CODE"));
                    t.setPdfFile(rs.getString("PDF_FILE"));
                    t.setGeneratedDate(rs.getDate("GENERATED_DATE"));
                    t.setStatus(rs.getString("STATUS"));
                    return t;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateTicketStatus(int ticketId, String status) {
        String sql = "UPDATE TICKET SET STATUS = ? WHERE TICKET_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, status);
            pstmt.setInt(2, ticketId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
