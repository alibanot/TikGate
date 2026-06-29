package com.tikgate.servlet;

import com.tikgate.dao.CategoryDAO;
import com.tikgate.dao.TournamentDAO;
import com.tikgate.model.Tournament;
import com.tikgate.model.User;
import com.tikgate.util.SecurityUtil;
import com.tikgate.util.ValidationUtil;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.net.URLEncoder;

@WebServlet("/admin/manageTournaments")
public class ManageTournamentsServlet extends HttpServlet {
    private TournamentDAO tournamentDAO = new TournamentDAO();
    private CategoryDAO categoryDAO = new CategoryDAO();

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
            String description = ValidationUtil.clean(request.getParameter("description"));
            Integer categoryId = ValidationUtil.parsePositiveInt(request.getParameter("categoryId"));

            if (!ValidationUtil.isSafeText(name, 2, 100)) {
                redirectWithError(response, "Tournament name must be 2 to 100 characters and cannot contain HTML tags.");
                return;
            }
            if (!ValidationUtil.isBlank(description) && !ValidationUtil.isSafeText(description, 0, 255)) {
                redirectWithError(response, "Description cannot contain HTML tags and must be 255 characters or less.");
                return;
            }
            if (categoryId == null || !categoryDAO.categoryExists(categoryId)) {
                redirectWithError(response, "Please choose a valid category.");
                return;
            }
            if (tournamentDAO.tournamentNameExists(categoryId, name)) {
                redirectWithError(response, "Tournament already exists for this category.");
                return;
            }

            Tournament t = new Tournament();
            t.setTournamentName(name);
            t.setDescription(description);
            t.setCategoryId(categoryId);
            
            if (tournamentDAO.addTournament(t)) {
                response.sendRedirect("manageTournaments.jsp?success=tournament_created");
            } else {
                redirectWithError(response, "Unable to add tournament.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            redirectWithError(response, "Error processing tournament request.");
        }
    }

    private void redirectWithError(HttpServletResponse response, String message) throws IOException {
        response.sendRedirect("manageTournaments.jsp?error=" + URLEncoder.encode(message, "UTF-8"));
    }
}
