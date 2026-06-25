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
        
        // In a real system, we'd process the actual payment here.
        // We need to find the BOOKING_ITEM_ID for this BOOKING_ID
        int bookingItemId = -1;
        String findItemSql = "SELECT BOOKING_ITEM_ID FROM BOOKING_ITEM WHERE BOOKING_ID = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(findItemSql)) {
            pstmt.setInt(1, bookingId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    bookingItemId = rs.getInt("BOOKING_ITEM_ID");
                }
            }
            
            if (bookingItemId != -1) {
                // Update booking status to PAID
                String updateStatusSql = "UPDATE BOOKING SET STATUS = 'PAID' WHERE BOOKING_ID = ?";
                try (PreparedStatement updatePstmt = conn.prepareStatement(updateStatusSql)) {
                    updatePstmt.setInt(1, bookingId);
                    updatePstmt.executeUpdate();
                }

                Ticket ticket = new Ticket();
                ticket.setBookingItemId(bookingItemId);
                String qrCode = UUID.randomUUID().toString();
                ticket.setQrCode(qrCode);
                String pdfFileName = "ticket_" + bookingId + ".pdf";
                ticket.setPdfFile(pdfFileName);
                ticket.setGeneratedDate(new Date());
                ticket.setStatus("VALID");

                if (ticketDAO.createTicket(ticket)) {
                    // Generate QR and PDF
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
                    response.sendRedirect("customer/ticketDetails.jsp?qrCode=" + qrCode);
                } else {
                    response.sendRedirect("customer/payment.jsp?bookingId=" + bookingId + "&error=ticket_creation_failed");
                }
            } else {
                response.sendRedirect("customer/payment.jsp?bookingId=" + bookingId + "&error=booking_not_found");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("customer/payment.jsp?bookingId=" + bookingId + "&error=database_error");
        }
    }
}
