package com.tikgate.servlet;

import com.tikgate.dao.BookingDAO;
import com.tikgate.dao.EventDAO;
import com.tikgate.dao.SeatDAO;
import com.tikgate.model.Booking;
import com.tikgate.model.Event;
import com.tikgate.model.User;
import com.tikgate.util.PricingUtil;
import com.tikgate.util.SecurityUtil;
import com.tikgate.util.ValidationUtil;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.HashSet;
import java.util.Set;

@WebServlet("/bookTicket")
public class BookingServlet extends HttpServlet {
    private BookingDAO bookingDAO = new BookingDAO();
    private SeatDAO seatDAO = new SeatDAO();
    private EventDAO eventDAO = new EventDAO();

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

        try {
            Integer eventIdValue = ValidationUtil.parsePositiveInt(request.getParameter("eventId"));
            String[] seatIdValues = request.getParameterValues("seatIds");

            if (seatIdValues == null) {
                String legacySeatId = request.getParameter("seatId");
                if (legacySeatId != null) {
                    seatIdValues = new String[] { legacySeatId };
                }
            }

            if (eventIdValue == null || seatIdValues == null || seatIdValues.length == 0) {
                response.sendRedirect("customer/dashboard.jsp?error=missing_params");
                return;
            }

            int eventId = eventIdValue;
            Event event = eventDAO.getEventById(eventId);
            if (event == null || !"ACTIVE".equals(event.getStatus())) {
                response.sendRedirect("customer/dashboard.jsp?error=event_unavailable");
                return;
            }
            if (seatIdValues.length > 10) {
                response.sendRedirect("customer/bookEvent.jsp?id=" + eventId + "&error=too_many_seats");
                return;
            }

            double price = PricingUtil.getTicketPrice();
            int[] seatIds = new int[seatIdValues.length];
            Set<Integer> seenSeats = new HashSet<>();

            for (int i = 0; i < seatIdValues.length; i++) {
                Integer seatId = ValidationUtil.parsePositiveInt(seatIdValues[i]);
                if (seatId == null || !seenSeats.add(seatId) || !seatDAO.seatExists(seatId)) {
                    response.sendRedirect("customer/bookEvent.jsp?id=" + eventId + "&error=invalid_seat");
                    return;
                }
                seatIds[i] = seatId;
                if (!seatDAO.isSeatAvailable(eventId, seatIds[i])) {
                    response.sendRedirect("customer/bookEvent.jsp?id=" + eventId + "&error=seat_taken");
                    return;
                }
            }

            Booking booking = new Booking();
            booking.setUserId(user.getUserId());
            booking.setEventId(eventId);
            
            int bookingId = bookingDAO.createBooking(booking, seatIds, price);
            
            if (bookingId > 0) {
                response.sendRedirect("customer/payment.jsp?bookingId=" + bookingId);
            } else if (bookingId == -2) {
                response.sendRedirect("customer/bookEvent.jsp?id=" + eventId + "&error=seat_taken");
            } else {
                response.sendRedirect("customer/bookEvent.jsp?id=" + eventId + "&error=booking_failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("customer/dashboard.jsp?error=internal_error");
        }
    }
}
