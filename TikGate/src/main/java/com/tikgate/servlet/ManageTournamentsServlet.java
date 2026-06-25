package com.tikgate.servlet;

import com.tikgate.dao.TournamentDAO;
import com.tikgate.model.Tournament;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/manageTournaments")
public class ManageTournamentsServlet extends HttpServlet {
    private TournamentDAO tournamentDAO = new TournamentDAO();

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            String name = request.getParameter("name");
            String description = request.getParameter("description");
            String categoryIdStr = request.getParameter("categoryId");
            
            if (name == null || categoryIdStr == null) {
                response.sendRedirect("manageTournaments.jsp?error=missing_params");
                return;
            }

            Tournament t = new Tournament();
            t.setTournamentName(name);
            t.setDescription(description);
            t.setCategoryId(Integer.parseInt(categoryIdStr));
            
            if (tournamentDAO.addTournament(t)) {
                response.sendRedirect("manageTournaments.jsp?success=true");
            } else {
                response.sendRedirect("manageTournaments.jsp?error=true");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("manageTournaments.jsp?error=exception");
        }
    }
}
