package com.tikgate.dao;

import com.tikgate.model.Booking;
import com.tikgate.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.Date;

public class BookingDAO {
    private SeatDAO seatDAO = new SeatDAO();

    public Booking getBookingById(int bookingId) {
        String sql = "SELECT * FROM BOOKING WHERE BOOKING_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, bookingId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapBooking(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public Booking getBookingByIdForUser(int bookingId, int userId) {
        String sql = "SELECT * FROM BOOKING WHERE BOOKING_ID = ? AND USER_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, bookingId);
            pstmt.setInt(2, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapBooking(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Booking> getBookingsByUser(int userId) {
        List<Booking> bookings = new ArrayList<>();
        String sql = "SELECT * FROM BOOKING WHERE USER_ID = ? ORDER BY BOOKING_DATE DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    bookings.add(mapBooking(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return bookings;
    }

    public boolean updateBookingStatus(int bookingId, String status) {
        String sql = "UPDATE BOOKING SET STATUS = ? WHERE BOOKING_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, status);
            pstmt.setInt(2, bookingId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public int createBooking(Booking booking, int seatId, double price) {
        return createBooking(booking, new int[] { seatId }, price);
    }

    public int createBooking(Booking booking, int[] seatIds, double pricePerSeat) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        PreparedStatement pstmtItem = null;
        ResultSet rs = null;
        try {
            if (seatIds == null || seatIds.length == 0 || pricePerSeat <= 0) {
                return -1;
            }

            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            Set<Integer> seenSeats = new HashSet<>();
            for (int i = 0; i < seatIds.length; i++) {
                if (!seenSeats.add(seatIds[i])) {
                    conn.rollback();
                    return -1;
                }
                if (!seatDAO.isSeatAvailable(conn, booking.getEventId(), seatIds[i])) {
                    conn.rollback();
                    return -2;
                }
            }

            int bookingId = nextBookingId(conn);

            // 1. Create Booking
            String bookSql = "INSERT INTO BOOKING (BOOKING_ID, USER_ID, EVENT_ID, BOOKING_DATE, TOTAL_AMOUNT, STATUS) " +
                              "VALUES (BOOKING_SEQ.NEXTVAL, ?, ?, ?, ?, ?)";
            bookSql = "INSERT INTO BOOKING (BOOKING_ID, USER_ID, EVENT_ID, BOOKING_DATE, TOTAL_AMOUNT, STATUS) VALUES (?, ?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(bookSql);
            pstmt.setInt(1, bookingId);
            pstmt.setInt(2, booking.getUserId());
            pstmt.setInt(3, booking.getEventId());
            pstmt.setDate(4, new java.sql.Date(new Date().getTime()));
            pstmt.setDouble(5, pricePerSeat * seatIds.length);
            pstmt.setString(6, "PENDING");
            pstmt.executeUpdate();

            if (bookingId > 0) {
                // 2. Create Booking Items (Seats)
                String itemSql = "INSERT INTO BOOKING_ITEM (BOOKING_ITEM_ID, BOOKING_ID, EVENT_ID, SEAT_ID, PRICE) " +
                                 "VALUES (BOOKING_ITEM_SEQ.NEXTVAL, ?, ?, ?, ?)";
                pstmtItem = conn.prepareStatement(itemSql);
                for (int i = 0; i < seatIds.length; i++) {
                    pstmtItem.setInt(1, bookingId);
                    pstmtItem.setInt(2, booking.getEventId());
                    pstmtItem.setInt(3, seatIds[i]);
                    pstmtItem.setDouble(4, pricePerSeat);
                    pstmtItem.addBatch();
                }
                pstmtItem.executeBatch();

                conn.commit();
                return bookingId;
            } else {
                conn.rollback();
            }
        } catch (SQLException e) {
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) {}
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
            if (pstmtItem != null) try { pstmtItem.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
        return -1;
    }

    public List<Integer> getBookingItemIds(int bookingId, Connection conn) throws SQLException {
        List<Integer> bookingItemIds = new ArrayList<>();
        String sql = "SELECT BOOKING_ITEM_ID FROM BOOKING_ITEM WHERE BOOKING_ID = ? ORDER BY BOOKING_ITEM_ID";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, bookingId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    bookingItemIds.add(rs.getInt("BOOKING_ITEM_ID"));
                }
            }
        }
        return bookingItemIds;
    }

    private int nextBookingId(Connection conn) throws SQLException {
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT BOOKING_SEQ.NEXTVAL FROM DUAL")) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        throw new SQLException("Unable to allocate booking id");
    }

    private Booking mapBooking(ResultSet rs) throws SQLException {
        Booking b = new Booking();
        b.setBookingId(rs.getInt("BOOKING_ID"));
        b.setUserId(rs.getInt("USER_ID"));
        b.setEventId(rs.getInt("EVENT_ID"));
        b.setBookingDate(rs.getDate("BOOKING_DATE"));
        b.setTotalAmount(rs.getDouble("TOTAL_AMOUNT"));
        b.setStatus(rs.getString("STATUS"));
        return b;
    }
}
