package com.tikgate.servlet;

import com.tikgate.dao.TicketDAO;
import com.tikgate.dao.TicketVerificationDAO;
import com.tikgate.model.Ticket;
import com.tikgate.model.User;
import com.tikgate.util.DBConnection;
import com.tikgate.util.SecurityUtil;
import com.tikgate.util.ValidationUtil;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;

@WebServlet("/staff/verifyTicket")
public class VerifyTicketServlet extends HttpServlet {
    private TicketDAO ticketDAO = new TicketDAO();
    private TicketVerificationDAO verificationDAO = new TicketVerificationDAO();

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String qrCode = ValidationUtil.clean(request.getParameter("qrCode"));
        User staff = SecurityUtil.currentUser(request);

        if (!SecurityUtil.isStaffOrAdmin(staff)) {
            response.sendRedirect("../login.jsp");
            return;
        }
        if (!SecurityUtil.isValidCsrf(request)) {
            forwardResult(request, response, "FAILED", "Your session expired. Please try again.");
            return;
        }

        if (!ValidationUtil.isValidQrCode(qrCode)) {
            verificationDAO.recordVerification(null, staff.getUserId(), "FAILED");
            forwardResult(request, response, "FAILED", "Invalid ticket code format.");
            return;
        }

        Ticket ticket = ticketDAO.getTicketByQrCode(qrCode);
        String result = "FAILED";
        String message;

        if (ticket == null) {
            verificationDAO.recordVerification(null, staff.getUserId(), result);
            forwardResult(request, response, result, "Ticket NOT FOUND.");
            return;
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            if ("VALID".equals(ticket.getStatus())) {
                if (ticketDAO.markTicketUsedIfValid(conn, ticket.getTicketId())) {
                    result = "SUCCESS";
                    message = "Ticket is VALID. Entry permitted.";
                } else {
                    message = "Ticket has ALREADY BEEN USED.";
                }
            } else if ("USED".equals(ticket.getStatus())) {
                message = "Ticket has ALREADY BEEN USED.";
            } else {
                message = "Ticket is INVALID.";
            }
            verificationDAO.recordVerification(conn, ticket.getTicketId(), staff.getUserId(), result);
            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException rollbackEx) { rollbackEx.printStackTrace(); }
            }
            e.printStackTrace();
            message = "Ticket verification failed. Please try again.";
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException closeEx) { closeEx.printStackTrace(); }
            }
        }

        forwardResult(request, response, result, message);
    }

    private void forwardResult(HttpServletRequest request, HttpServletResponse response, String result, String message) throws ServletException, IOException {
        request.setAttribute("message", message);
        request.setAttribute("result", result);
        request.getRequestDispatcher("verificationResult.jsp").forward(request, response);
    }
}
