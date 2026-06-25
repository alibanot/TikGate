package com.tikgate.servlet;

import com.tikgate.dao.EventDAO;
import com.tikgate.model.Event;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.text.SimpleDateFormat;

@WebServlet("/admin/manageEvents")
public class ManageEventsServlet extends HttpServlet {
    private EventDAO eventDAO = new EventDAO();

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            Event e = new Event();
            e.setEventName(request.getParameter("name"));
            e.setTournamentId(Integer.parseInt(request.getParameter("tournamentId")));
            e.setEventDate(new SimpleDateFormat("yyyy-MM-dd").parse(request.getParameter("date")));
            e.setStartTime(request.getParameter("startTime"));
            e.setEndTime(request.getParameter("endTime"));
            e.setDescription(request.getParameter("description"));
            e.setStatus("ACTIVE");

            if (eventDAO.addEvent(e)) {
                response.sendRedirect("manageEvents.jsp?success=true");
            } else {
                response.sendRedirect("manageEvents.jsp?error=true");
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            response.sendRedirect("manageEvents.jsp?error=exception");
        }
    }
}
