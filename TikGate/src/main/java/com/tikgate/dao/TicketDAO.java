package com.tikgate.dao;

import com.tikgate.model.Ticket;
import com.tikgate.util.DBConnection;
import java.sql.*;
import java.util.Date;
import java.util.List;

public class TicketDAO {
    public boolean createTicket(Ticket ticket) {
        String sql = "INSERT INTO TICKET (TICKET_ID, BOOKING_ITEM_ID, QR_CODE, PDF_FILE, GENERATED_DATE, STATUS) " +
                     "VALUES (TICKET_SEQ.NEXTVAL, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            return bindAndCreateTicket(pstmt, ticket);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean createTicket(Connection conn, Ticket ticket) throws SQLException {
        String sql = "INSERT INTO TICKET (TICKET_ID, BOOKING_ITEM_ID, QR_CODE, PDF_FILE, GENERATED_DATE, STATUS) " +
                     "VALUES (TICKET_SEQ.NEXTVAL, ?, ?, ?, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            return bindAndCreateTicket(pstmt, ticket);
        }
    }

    public Ticket getTicketByBookingId(int bookingId) {
        String sql = "SELECT t.* FROM TICKET t " +
                     "JOIN BOOKING_ITEM bi ON t.BOOKING_ITEM_ID = bi.BOOKING_ITEM_ID " +
                     "WHERE bi.BOOKING_ID = ? ORDER BY t.TICKET_ID";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, bookingId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapTicket(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Ticket> getTicketsByBookingId(int bookingId) {
        List<Ticket> tickets = new java.util.ArrayList<>();
        String sql = "SELECT t.* FROM TICKET t " +
                     "JOIN BOOKING_ITEM bi ON t.BOOKING_ITEM_ID = bi.BOOKING_ITEM_ID " +
                     "WHERE bi.BOOKING_ID = ? ORDER BY t.TICKET_ID";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, bookingId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    tickets.add(mapTicket(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return tickets;
    }

    public Ticket getTicketByQrCode(String qrCode) {
        String sql = "SELECT * FROM TICKET WHERE QR_CODE = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, qrCode);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapTicket(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public Ticket getTicketByQrCodeForUser(String qrCode, int userId) {
        String sql = "SELECT t.* FROM TICKET t " +
                     "JOIN BOOKING_ITEM bi ON t.BOOKING_ITEM_ID = bi.BOOKING_ITEM_ID " +
                     "JOIN BOOKING b ON bi.BOOKING_ID = b.BOOKING_ID " +
                     "WHERE t.QR_CODE = ? AND b.USER_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, qrCode);
            pstmt.setInt(2, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapTicket(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public Ticket getTicketByBookingItemId(Connection conn, int bookingItemId) throws SQLException {
        String sql = "SELECT * FROM TICKET WHERE BOOKING_ITEM_ID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, bookingItemId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapTicket(rs);
                }
            }
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

    public boolean markTicketUsedIfValid(int ticketId) {
        String sql = "UPDATE TICKET SET STATUS = 'USED' WHERE TICKET_ID = ? AND STATUS = 'VALID'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, ticketId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean markTicketUsedIfValid(Connection conn, int ticketId) throws SQLException {
        String sql = "UPDATE TICKET SET STATUS = 'USED' WHERE TICKET_ID = ? AND STATUS = 'VALID'";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, ticketId);
            return pstmt.executeUpdate() > 0;
        }
    }

    private boolean bindAndCreateTicket(PreparedStatement pstmt, Ticket ticket) throws SQLException {
        pstmt.setInt(1, ticket.getBookingItemId());
        pstmt.setString(2, ticket.getQrCode());
        pstmt.setString(3, ticket.getPdfFile());
        pstmt.setDate(4, new java.sql.Date(new Date().getTime()));
        pstmt.setString(5, "VALID");
        return pstmt.executeUpdate() > 0;
    }

    private Ticket mapTicket(ResultSet rs) throws SQLException {
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
