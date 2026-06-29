package com.tikgate.dao;

import com.tikgate.util.DBConnection;
import java.sql.*;
import java.util.Date;

public class TicketVerificationDAO {
    public boolean recordVerification(int ticketId, int verifiedBy, String result) {
        return recordVerification(Integer.valueOf(ticketId), verifiedBy, result);
    }

    public boolean recordVerification(Integer ticketId, int verifiedBy, String result) {
        String sql = "INSERT INTO TICKET_VERIFICATION (VERIFICATION_ID, TICKET_ID, VERIFIED_BY, VERIFIED_DATE, RESULT) " +
                     "VALUES (VERIFICATION_SEQ.NEXTVAL, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            bindVerification(pstmt, ticketId, verifiedBy, result);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean recordVerification(Connection conn, Integer ticketId, int verifiedBy, String result) throws SQLException {
        String sql = "INSERT INTO TICKET_VERIFICATION (VERIFICATION_ID, TICKET_ID, VERIFIED_BY, VERIFIED_DATE, RESULT) " +
                     "VALUES (VERIFICATION_SEQ.NEXTVAL, ?, ?, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            bindVerification(pstmt, ticketId, verifiedBy, result);
            return pstmt.executeUpdate() > 0;
        }
    }

    private void bindVerification(PreparedStatement pstmt, Integer ticketId, int verifiedBy, String result) throws SQLException {
        if (ticketId == null) {
            pstmt.setNull(1, Types.INTEGER);
        } else {
            pstmt.setInt(1, ticketId);
        }
        pstmt.setInt(2, verifiedBy);
        pstmt.setTimestamp(3, new java.sql.Timestamp(new Date().getTime()));
        pstmt.setString(4, result);
    }
}
