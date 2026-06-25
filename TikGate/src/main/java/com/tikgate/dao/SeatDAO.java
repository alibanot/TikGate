package com.tikgate.dao;

import com.tikgate.model.Seat;
import com.tikgate.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SeatDAO {
    public List<Seat> getAllSeats() {
        List<Seat> seats = new ArrayList<>();
        String sql = "SELECT * FROM SEAT";
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
        String sql = "SELECT COUNT(*) FROM BOOKING_ITEM bi " +
                     "JOIN BOOKING b ON bi.BOOKING_ID = b.BOOKING_ID " +
                     "WHERE b.EVENT_ID = ? AND bi.SEAT_ID = ? AND b.STATUS != 'CANCELLED'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, eventId);
            pstmt.setInt(2, seatId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) == 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean addSeat(Seat seat) {
        String sql = "INSERT INTO SEAT (SEAT_ID, SECTION_NAME, ROW_NO, SEAT_NUMBER) VALUES (SEAT_SEQ.NEXTVAL, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, seat.getSectionName());
            pstmt.setString(2, seat.getRowNo());
            pstmt.setString(3, seat.getSeatNumber());
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
