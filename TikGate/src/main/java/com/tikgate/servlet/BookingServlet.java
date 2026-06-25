package com.tikgate.servlet;

import com.tikgate.dao.BookingDAO;
import com.tikgate.dao.SeatDAO;
import com.tikgate.model.Booking;
import com.tikgate.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/bookTicket")
public class BookingServlet extends HttpServlet {
    private BookingDAO bookingDAO = new BookingDAO();
    private SeatDAO seatDAO = new SeatDAO();

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            String eventIdStr = request.getParameter("eventId");
            String seatIdStr = request.getParameter("seatId");
            String priceStr = request.getParameter("price");

            if (eventIdStr == null || seatIdStr == null || priceStr == null) {
                response.sendRedirect("customer/dashboard.jsp?error=missing_params");
                return;
            }

            int eventId = Integer.parseInt(eventIdStr);
            int seatId = Integer.parseInt(seatIdStr);
            double price = Double.parseDouble(priceStr);

            if (!seatDAO.isSeatAvailable(eventId, seatId)) {
                response.sendRedirect("customer/bookEvent.jsp?id=" + eventId + "&error=seat_taken");
                return;
            }

            Booking booking = new Booking();
            booking.setUserId(user.getUserId());
            booking.setEventId(eventId);
            
            int bookingId = bookingDAO.createBooking(booking, seatId, price);
            
            if (bookingId > 0) {
                response.sendRedirect("customer/payment.jsp?bookingId=" + bookingId);
            } else {
                response.sendRedirect("customer/bookEvent.jsp?id=" + eventId + "&error=booking_failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("customer/dashboard.jsp?error=internal_error");
        }
    }
}
