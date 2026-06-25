package com.tikgate.servlet;

import com.tikgate.dao.SeatDAO;
import com.tikgate.model.Seat;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/manageSeats")
public class ManageSeatsServlet extends HttpServlet {
    private SeatDAO seatDAO = new SeatDAO();

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Seat s = new Seat();
        s.setSectionName(request.getParameter("section"));
        s.setRowNo(request.getParameter("row"));
        s.setSeatNumber(request.getParameter("number"));
        
        seatDAO.addSeat(s);
        response.sendRedirect("manageSeats.jsp");
    }
}
