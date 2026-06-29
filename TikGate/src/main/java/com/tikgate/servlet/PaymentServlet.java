package com.tikgate.servlet;

import com.tikgate.dao.BookingDAO;
import com.tikgate.dao.PaymentDAO;
import com.tikgate.dao.TicketDAO;
import com.tikgate.model.Booking;
import com.tikgate.model.Ticket;
import com.tikgate.model.User;
import com.tikgate.util.QRGenerator;
import com.tikgate.util.PDFGenerator;
import com.tikgate.util.SecurityUtil;
import com.tikgate.util.ValidationUtil;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.File;
import java.io.IOException;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.UUID;
import java.sql.*;
import com.tikgate.util.DBConnection;

@WebServlet("/processPayment")
public class PaymentServlet extends HttpServlet {
    private TicketDAO ticketDAO = new TicketDAO();
    private BookingDAO bookingDAO = new BookingDAO();
    private PaymentDAO paymentDAO = new PaymentDAO();

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = SecurityUtil.currentUser(request);
        if (!SecurityUtil.isCustomer(user)) {
            response.sendRedirect("login.jsp");
            return;
        }
        if (!SecurityUtil.isValidCsrf(request)) {
            response.sendRedirect("customer/dashboard.jsp?error=session_expired");
            return;
        }

        Integer bookingIdValue = ValidationUtil.parsePositiveInt(request.getParameter("bookingId"));
        if (bookingIdValue == null) {
            response.sendRedirect("customer/dashboard.jsp?error=invalid_booking");
            return;
        }

        int bookingId = bookingIdValue;
        Booking booking = bookingDAO.getBookingByIdForUser(bookingId, user.getUserId());
        if (booking == null) {
            response.sendRedirect("customer/dashboard.jsp?error=booking_not_found");
            return;
        }
        if ("PAID".equals(booking.getStatus())) {
            Ticket existingTicket = ticketDAO.getTicketByBookingId(bookingId);
            if (existingTicket != null) {
                response.sendRedirect("customer/ticketDetails.jsp?qrCode=" + URLEncoder.encode(existingTicket.getQrCode(), "UTF-8"));
            } else {
                response.sendRedirect("customer/bookings.jsp?error=already_paid");
            }
            return;
        }
        if (!"PENDING".equals(booking.getStatus())) {
            response.sendRedirect("customer/payment.jsp?bookingId=" + bookingId + "&error=invalid_booking_status");
            return;
        }

        String paymentMethod = ValidationUtil.clean(request.getParameter("paymentMethod"));
        if (!ValidationUtil.isAllowedPaymentMethod(paymentMethod)) {
            redirectPayment(response, bookingId, "invalid_payment_method");
            return;
        }
        if (!validatePaymentFields(request)) {
            redirectPayment(response, bookingId, "invalid_payment_details");
            return;
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            int updated = markBookingPaid(conn, bookingId, user.getUserId());
            if (updated != 1) {
                conn.rollback();
                redirectPayment(response, bookingId, "invalid_booking_status");
                return;
            }

            paymentDAO.createPayment(conn, bookingId, paymentMethod, booking.getTotalAmount());
            List<TicketContext> contexts = getTicketContexts(conn, bookingId);
            if (contexts.isEmpty()) {
                conn.rollback();
                redirectPayment(response, bookingId, "no_booking_items");
                return;
            }

            String path = getServletContext().getRealPath("/") + "tickets" + File.separator;
            File directory = new File(path);
            if (!directory.exists()) {
                directory.mkdirs();
            }

            String firstQrCode = null;
            for (TicketContext context : contexts) {
                if (ticketDAO.getTicketByBookingItemId(conn, context.bookingItemId) != null) {
                    continue;
                }
                String qrCode = UUID.randomUUID().toString();
                String pdfFileName = "ticket_" + bookingId + "_" + context.bookingItemId + ".pdf";
                String ticketInfo = buildTicketInfo(qrCode, bookingId, user, context);
                QRGenerator.generateQRCodeImage(qrCode, 200, 200, path + qrCode + ".png");
                PDFGenerator.generateTicketPDF(ticketInfo, path + pdfFileName);

                Ticket ticket = new Ticket();
                ticket.setBookingItemId(context.bookingItemId);
                ticket.setQrCode(qrCode);
                ticket.setPdfFile(pdfFileName);
                ticket.setGeneratedDate(new Date());
                ticket.setStatus("VALID");
                ticketDAO.createTicket(conn, ticket);

                if (firstQrCode == null) {
                    firstQrCode = qrCode;
                }
            }

            if (firstQrCode == null) {
                Ticket existingTicket = ticketDAO.getTicketByBookingId(bookingId);
                firstQrCode = existingTicket != null ? existingTicket.getQrCode() : null;
            }

            if (firstQrCode == null) {
                conn.rollback();
                redirectPayment(response, bookingId, "ticket_creation_failed");
                return;
            }

            conn.commit();
            response.sendRedirect("customer/ticketDetails.jsp?qrCode=" + URLEncoder.encode(firstQrCode, "UTF-8"));
        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException rollbackEx) { rollbackEx.printStackTrace(); }
            }
            e.printStackTrace();
            redirectPayment(response, bookingId, "payment_failed");
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException closeEx) { closeEx.printStackTrace(); }
            }
        }
    }

    private boolean validatePaymentFields(HttpServletRequest request) {
        return ValidationUtil.isValidCardNumber(request.getParameter("cardNumber"))
            && ValidationUtil.isValidExpiry(request.getParameter("expiry"))
            && ValidationUtil.isValidCvv(request.getParameter("cvv"));
    }

    private int markBookingPaid(Connection conn, int bookingId, int userId) throws SQLException {
        String sql = "UPDATE BOOKING SET STATUS = 'PAID' WHERE BOOKING_ID = ? AND USER_ID = ? AND STATUS = 'PENDING'";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, bookingId);
            pstmt.setInt(2, userId);
            return pstmt.executeUpdate();
        }
    }

    private List<TicketContext> getTicketContexts(Connection conn, int bookingId) throws SQLException {
        List<TicketContext> contexts = new ArrayList<>();
        String sql = "SELECT bi.BOOKING_ITEM_ID, bi.PRICE, s.SECTION_NAME, s.ROW_NO, s.SEAT_NUMBER, " +
                     "e.EVENT_NAME, e.EVENT_DATE, e.START_TIME " +
                     "FROM BOOKING_ITEM bi " +
                     "JOIN SEAT s ON bi.SEAT_ID = s.SEAT_ID " +
                     "JOIN BOOKING b ON bi.BOOKING_ID = b.BOOKING_ID " +
                     "JOIN EVENT e ON b.EVENT_ID = e.EVENT_ID " +
                     "WHERE bi.BOOKING_ID = ? ORDER BY bi.BOOKING_ITEM_ID";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, bookingId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    TicketContext context = new TicketContext();
                    context.bookingItemId = rs.getInt("BOOKING_ITEM_ID");
                    context.price = rs.getDouble("PRICE");
                    context.sectionName = rs.getString("SECTION_NAME");
                    context.rowNo = rs.getString("ROW_NO");
                    context.seatNumber = rs.getString("SEAT_NUMBER");
                    context.eventName = rs.getString("EVENT_NAME");
                    context.eventDate = rs.getDate("EVENT_DATE");
                    context.startTime = rs.getString("START_TIME");
                    contexts.add(context);
                }
            }
        }
        return contexts;
    }

    private String buildTicketInfo(String qrCode, int bookingId, User user, TicketContext context) {
        String date = context.eventDate == null ? "N/A" : new SimpleDateFormat("yyyy-MM-dd").format(context.eventDate);
        return "Ticket ID: " + qrCode +
            "\nBooking ID: " + bookingId +
            "\nCustomer: " + user.getFullName() +
            "\nEvent: " + context.eventName +
            "\nDate: " + date +
            "\nStart Time: " + context.startTime +
            "\nSeat: " + context.sectionName + " Row " + context.rowNo + " Seat " + context.seatNumber +
            "\nPrice: RM" + String.format(java.util.Locale.US, "%.2f", context.price);
    }

    private void redirectPayment(HttpServletResponse response, int bookingId, String error) throws IOException {
        response.sendRedirect("customer/payment.jsp?bookingId=" + bookingId + "&error=" + URLEncoder.encode(error, "UTF-8"));
    }

    private static class TicketContext {
        int bookingItemId;
        double price;
        String sectionName;
        String rowNo;
        String seatNumber;
        String eventName;
        java.sql.Date eventDate;
        String startTime;
    }
}
