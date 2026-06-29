package com.tikgate.servlet;

import com.tikgate.dao.SeatDAO;
import com.tikgate.model.Seat;
import com.tikgate.model.User;
import com.tikgate.util.SecurityUtil;
import com.tikgate.util.ValidationUtil;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.net.URLEncoder;

@WebServlet("/admin/manageSeats")
public class ManageSeatsServlet extends HttpServlet {
    private SeatDAO seatDAO = new SeatDAO();

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = SecurityUtil.currentUser(request);
        if (!SecurityUtil.canManageCatalog(user)) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        if (!SecurityUtil.isValidCsrf(request)) {
            redirectWithError(response, "Your session expired. Please try again.");
            return;
        }

        String section = ValidationUtil.clean(request.getParameter("section"));
        String row = ValidationUtil.clean(request.getParameter("row")).toUpperCase();
        String number = ValidationUtil.clean(request.getParameter("number"));

        if (!ValidationUtil.isSafeText(section, 1, 50)) {
            redirectWithError(response, "Section is required and cannot contain HTML tags.");
            return;
        }
        if (!row.matches("^[A-Z0-9]{1,10}$")) {
            redirectWithError(response, "Row must use 1 to 10 letters or numbers.");
            return;
        }
        if (!number.matches("^[0-9]{1,4}$")) {
            redirectWithError(response, "Seat number must contain digits only.");
            return;
        }
        if (seatDAO.duplicateSeatExists(section, row, number)) {
            redirectWithError(response, "That seat already exists.");
            return;
        }

        Seat s = new Seat();
        s.setSectionName(section);
        s.setRowNo(row);
        s.setSeatNumber(number);

        if (seatDAO.addSeat(s)) {
            response.sendRedirect("manageSeats.jsp?success=seat_created");
        } else {
            redirectWithError(response, "Unable to add seat.");
        }
    }

    private void redirectWithError(HttpServletResponse response, String message) throws IOException {
        response.sendRedirect("manageSeats.jsp?error=" + URLEncoder.encode(message, "UTF-8"));
    }
}
