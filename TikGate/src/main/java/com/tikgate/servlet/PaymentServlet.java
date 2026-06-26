package com.tikgate.servlet;

import com.tikgate.dao.TicketDAO;
import com.tikgate.model.Ticket;
import com.tikgate.util.QRGenerator;
import com.tikgate.util.PDFGenerator;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.File;
import java.io.IOException;
import java.util.Date;
import java.util.UUID;
import java.sql.*;
import com.tikgate.util.DBConnection;

@WebServlet("/processPayment")
public class PaymentServlet extends HttpServlet {
    private TicketDAO ticketDAO = new TicketDAO();

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String bookingIdStr = request.getParameter("bookingId");
        if (bookingIdStr == null || bookingIdStr.isEmpty()) {
            response.sendRedirect("customer/dashboard.jsp");
            return;
        }
        
        int bookingId = Integer.parseInt(bookingIdStr);
        
        String findItemSql = "SELECT BOOKING_ITEM_ID FROM BOOKING_ITEM WHERE BOOKING_ID = ? ORDER BY BOOKING_ITEM_ID";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(findItemSql)) {
            pstmt.setInt(1, bookingId);
            try (ResultSet rs = pstmt.executeQuery()) {            
                // Update booking status to PAID
                String updateStatusSql = "UPDATE BOOKING SET STATUS = 'PAID' WHERE BOOKING_ID = ?";
                try (PreparedStatement updatePstmt = conn.prepareStatement(updateStatusSql)) {
                    updatePstmt.setInt(1, bookingId);
                    updatePstmt.executeUpdate();
                }

                String firstQrCode = null;
                int ticketCount = 0;

                while (rs.next()) {
                    int bookingItemId = rs.getInt("BOOKING_ITEM_ID");
                    Ticket ticket = new Ticket();
                    ticket.setBookingItemId(bookingItemId);
                    String qrCode = UUID.randomUUID().toString();
                    ticket.setQrCode(qrCode);
                    String pdfFileName = "ticket_" + bookingId + "_" + bookingItemId + ".pdf";
                    ticket.setPdfFile(pdfFileName);
                    ticket.setGeneratedDate(new Date());
                    ticket.setStatus("VALID");

                    if (ticketDAO.createTicket(ticket)) {
                        if (firstQrCode == null) {
                            firstQrCode = qrCode;
                        }
                        ticketCount++;
                        try {
                            String path = getServletContext().getRealPath("/") + "tickets" + File.separator;
                            File directory = new File(path);
                            if (!directory.exists()) {
                                directory.mkdirs();
                            }
                            QRGenerator.generateQRCodeImage(qrCode, 200, 200, path + qrCode + ".png");
                            PDFGenerator.generateTicketPDF("Ticket ID: " + qrCode + "\nBooking ID: " + bookingId, path + pdfFileName);
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                }

                if (ticketCount > 0) {
                    response.sendRedirect("customer/ticketDetails.jsp?qrCode=" + firstQrCode);
                } else {
                    response.sendRedirect("customer/payment.jsp?bookingId=" + bookingId + "&error=ticket_creation_failed");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("customer/payment.jsp?bookingId=" + bookingId + "&error=database_error");
        }
    }
}
