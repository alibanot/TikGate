package com.tikgate.servlet;

import com.tikgate.dao.EventDAO;
import com.tikgate.dao.TournamentDAO;
import com.tikgate.model.Event;
import com.tikgate.model.User;
import com.tikgate.util.SecurityUtil;
import com.tikgate.util.ValidationUtil;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;

@WebServlet("/admin/manageEvents")
public class ManageEventsServlet extends HttpServlet {
    private EventDAO eventDAO = new EventDAO();
    private TournamentDAO tournamentDAO = new TournamentDAO();

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            User user = SecurityUtil.currentUser(request);
            if (!SecurityUtil.canManageCatalog(user)) {
                response.sendRedirect(request.getContextPath() + "/login.jsp");
                return;
            }
            if (!SecurityUtil.isValidCsrf(request)) {
                redirectWithError(response, "Your session expired. Please try again.");
                return;
            }

            String name = ValidationUtil.clean(request.getParameter("name"));
            Integer tournamentId = ValidationUtil.parsePositiveInt(request.getParameter("tournamentId"));
            String dateValue = ValidationUtil.clean(request.getParameter("date"));
            String startTime = ValidationUtil.clean(request.getParameter("startTime"));
            String endTime = ValidationUtil.clean(request.getParameter("endTime"));
            String description = ValidationUtil.clean(request.getParameter("description"));

            if (!ValidationUtil.isSafeText(name, 2, 100)) {
                redirectWithError(response, "Event name must be 2 to 100 characters and cannot contain HTML tags.");
                return;
            }
            if (tournamentId == null || !tournamentDAO.tournamentExists(tournamentId)) {
                redirectWithError(response, "Please choose a valid tournament.");
                return;
            }
            if (!ValidationUtil.isValidTime(startTime) || !ValidationUtil.isValidTime(endTime) || !ValidationUtil.isEndAfterStart(startTime, endTime)) {
                redirectWithError(response, "Event end time must be after start time.");
                return;
            }
            if (!ValidationUtil.isBlank(description) && !ValidationUtil.isSafeText(description, 0, 255)) {
                redirectWithError(response, "Description cannot contain HTML tags and must be 255 characters or less.");
                return;
            }

            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
            dateFormat.setLenient(false);
            java.util.Date eventDate = dateFormat.parse(dateValue);
            if (!ValidationUtil.isTodayOrFuture(eventDate)) {
                redirectWithError(response, "Event date cannot be in the past.");
                return;
            }
            if (eventDAO.eventNameExists(tournamentId, name, eventDate)) {
                redirectWithError(response, "An event with this name and date already exists for the tournament.");
                return;
            }

            Event e = new Event();
            e.setEventName(name);
            e.setTournamentId(tournamentId);
            e.setEventDate(eventDate);
            e.setStartTime(startTime);
            e.setEndTime(endTime);
            e.setDescription(description);
            e.setStatus("ACTIVE");

            if (eventDAO.addEvent(e)) {
                response.sendRedirect("manageEvents.jsp?success=event_created");
            } else {
                redirectWithError(response, "Unable to add event.");
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            redirectWithError(response, "Error processing event request.");
        }
    }

    private void redirectWithError(HttpServletResponse response, String message) throws IOException {
        response.sendRedirect("manageEvents.jsp?error=" + URLEncoder.encode(message, "UTF-8"));
    }
}
