package com.tikgate.servlet;

import com.tikgate.dao.TicketDAO;
import com.tikgate.dao.TicketVerificationDAO;
import com.tikgate.model.Ticket;
import com.tikgate.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/staff/verifyTicket")
public class VerifyTicketServlet extends HttpServlet {
    private TicketDAO ticketDAO = new TicketDAO();
    private TicketVerificationDAO verificationDAO = new TicketVerificationDAO();

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String qrCode = request.getParameter("qrCode");
        HttpSession session = request.getSession();
        User staff = (User) session.getAttribute("user");

        if (staff == null) {
            response.sendRedirect("../login.jsp");
            return;
        }

        Ticket ticket = ticketDAO.getTicketByQrCode(qrCode);
        String result = "FAILED";
        String message;

        if (ticket != null) {
            if ("VALID".equals(ticket.getStatus())) {
                result = "SUCCESS";
                message = "Ticket is VALID. Entry permitted.";
                ticketDAO.updateTicketStatus(ticket.getTicketId(), "USED");
            } else if ("USED".equals(ticket.getStatus())) {
                message = "Ticket has ALREADY BEEN USED.";
            } else {
                message = "Ticket is INVALID.";
            }
            verificationDAO.recordVerification(ticket.getTicketId(), staff.getUserId(), result);
        } else {
            message = "Ticket NOT FOUND.";
        }

        request.setAttribute("message", message);
        request.setAttribute("result", result);
        request.getRequestDispatcher("verificationResult.jsp").forward(request, response);
    }
}
