package com.tikgate.dao;

import com.tikgate.model.Seat;
import com.tikgate.util.DBConnection;
import com.tikgate.util.ValidationUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SeatDAO {
    public List<Seat> getAllSeats() {
        List<Seat> seats = new ArrayList<>();
        String sql = "SELECT * FROM SEAT ORDER BY SECTION_NAME, ROW_NO, SEAT_NUMBER";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                seats.add(new Seat(
                    rs.getInt("SEAT_ID"),
                    rs.getString("SECTION_NAME"),
                    rs.getString("ROW_NO"),
                    rs.getString("SEAT_NUMBER")
                ));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return seats;
    }

    public boolean isSeatAvailable(int eventId, int seatId) {
        try (Connection conn = DBConnection.getConnection()) {
            return isSeatAvailable(conn, eventId, seatId);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean isSeatAvailable(Connection conn, int eventId, int seatId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM BOOKING_ITEM bi " +
                     "JOIN BOOKING b ON bi.BOOKING_ID = b.BOOKING_ID " +
                     "WHERE b.EVENT_ID = ? AND bi.SEAT_ID = ? AND b.STATUS != 'CANCELLED'";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, eventId);
            pstmt.setInt(2, seatId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) == 0;
                }
            }
        }
        return false;
    }

    public boolean addSeat(Seat seat) {
        String sql = "INSERT INTO SEAT (SEAT_ID, SECTION_NAME, ROW_NO, SEAT_NUMBER) VALUES (SEAT_SEQ.NEXTVAL, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, ValidationUtil.clean(seat.getSectionName()));
            pstmt.setString(2, ValidationUtil.clean(seat.getRowNo()).toUpperCase());
            pstmt.setString(3, ValidationUtil.clean(seat.getSeatNumber()));
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean seatExists(int seatId) {
        String sql = "SELECT COUNT(*) FROM SEAT WHERE SEAT_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, seatId);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public Seat getSeatById(int seatId) {
        String sql = "SELECT * FROM SEAT WHERE SEAT_ID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, seatId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return new Seat(
                        rs.getInt("SEAT_ID"),
                        rs.getString("SECTION_NAME"),
                        rs.getString("ROW_NO"),
                        rs.getString("SEAT_NUMBER")
                    );
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean duplicateSeatExists(String section, String row, String number) {
        String sql = "SELECT COUNT(*) FROM SEAT WHERE LOWER(SECTION_NAME) = LOWER(?) AND LOWER(ROW_NO) = LOWER(?) AND SEAT_NUMBER = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, ValidationUtil.clean(section));
            pstmt.setString(2, ValidationUtil.clean(row));
            pstmt.setString(3, ValidationUtil.clean(number));
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
