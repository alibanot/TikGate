package com.tikgate.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Date;

public class PaymentDAO {
    public boolean createPayment(Connection conn, int bookingId, String paymentMethod, double amount) throws SQLException {
        String sql = "INSERT INTO PAYMENT (PAYMENT_ID, BOOKING_ID, PAYMENT_DATE, PAYMENT_METHOD, AMOUNT, PAYMENT_STATUS) " +
                     "VALUES (PAYMENT_SEQ.NEXTVAL, ?, ?, ?, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, bookingId);
            pstmt.setTimestamp(2, new java.sql.Timestamp(new Date().getTime()));
            pstmt.setString(3, paymentMethod);
            pstmt.setDouble(4, amount);
            pstmt.setString(5, "SUCCESS");
            return pstmt.executeUpdate() > 0;
        }
    }
}
