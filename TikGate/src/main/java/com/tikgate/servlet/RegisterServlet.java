package com.tikgate.servlet;

import com.tikgate.dao.UserDAO;
import com.tikgate.model.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = new User();
        String roleParam = request.getParameter("roleId");
        int roleId = (roleParam != null) ? Integer.parseInt(roleParam) : 2;
        user.setRoleId(roleId);
        user.setUsername(request.getParameter("username"));
        user.setPassword(request.getParameter("password"));
        user.setFullName(request.getParameter("fullName"));
        user.setEmail(request.getParameter("email"));
        user.setPhone(request.getParameter("phone"));

        String redirect = request.getParameter("redirect");

        if (userDAO.register(user)) {
            if (redirect != null) {
                response.sendRedirect(redirect + "?success=true");
            } else {
                response.sendRedirect("login.jsp?registered=true");
            }
        } else {
            if (redirect != null) {
                response.sendRedirect(redirect + "?error=true");
            } else {
                request.setAttribute("error", "Registration failed");
                request.getRequestDispatcher("register.jsp").forward(request, response);
            }
        }
    }
}
