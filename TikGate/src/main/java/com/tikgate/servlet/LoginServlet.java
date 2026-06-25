package com.tikgate.servlet;

import com.tikgate.dao.UserDAO;
import com.tikgate.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        User user = userDAO.login(username, password);
        if (user != null) {
            HttpSession session = request.getSession();
            session.setAttribute("user", user);
            if (user.getRoleId() == 1) { // Admin
                response.sendRedirect("admin/dashboard.jsp");
            } else if (user.getRoleId() == 2) { // Customer
                response.sendRedirect("customer/dashboard.jsp");
            } else { // Staff
                response.sendRedirect("staff/verification.jsp");
            }
        } else {
            request.setAttribute("error", "Invalid username or password");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}
