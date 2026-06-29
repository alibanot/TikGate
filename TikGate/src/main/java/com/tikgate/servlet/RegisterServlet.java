package com.tikgate.servlet;

import com.tikgate.dao.UserDAO;
import com.tikgate.model.User;
import com.tikgate.util.SecurityUtil;
import com.tikgate.util.ValidationUtil;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.net.URLEncoder;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String redirect = request.getParameter("redirect");
        boolean adminCreate = "admin/manageUsers.jsp".equals(redirect);
        User currentUser = SecurityUtil.currentUser(request);

        if (!SecurityUtil.isValidCsrf(request)) {
            handleError(request, response, adminCreate, "Your session expired. Please try again.");
            return;
        }

        if (redirect != null && !adminCreate) {
            handleError(request, response, false, "Invalid registration request.");
            return;
        }

        if (adminCreate && !SecurityUtil.isAdmin(currentUser)) {
            response.sendRedirect("login.jsp");
            return;
        }

        String username = ValidationUtil.clean(request.getParameter("username"));
        String password = ValidationUtil.clean(request.getParameter("password"));
        String fullName = ValidationUtil.clean(request.getParameter("fullName"));
        String email = ValidationUtil.clean(request.getParameter("email")).toLowerCase();
        String phone = ValidationUtil.clean(request.getParameter("phone"));
        int roleId = SecurityUtil.ROLE_CUSTOMER;

        if (adminCreate) {
            Integer requestedRole = ValidationUtil.parsePositiveInt(request.getParameter("roleId"));
            if (requestedRole == null || requestedRole < SecurityUtil.ROLE_ADMIN || requestedRole > SecurityUtil.ROLE_STAFF) {
                handleError(request, response, true, "Please choose a valid role.");
                return;
            }
            roleId = requestedRole;
        }

        String validationError = validateUserInput(username, password, fullName, email, phone);
        if (validationError != null) {
            handleError(request, response, adminCreate, validationError);
            return;
        }

        if (userDAO.usernameExists(username)) {
            handleError(request, response, adminCreate, "Username is already taken.");
            return;
        }
        if (userDAO.emailExists(email)) {
            handleError(request, response, adminCreate, "Email address is already registered.");
            return;
        }

        User user = new User();
        user.setRoleId(roleId);
        user.setUsername(username);
        user.setPassword(password);
        user.setFullName(fullName);
        user.setEmail(email);
        user.setPhone(phone);

        if (userDAO.register(user)) {
            response.sendRedirect(adminCreate ? "admin/manageUsers.jsp?success=user_created" : "login.jsp?registered=true");
        } else {
            handleError(request, response, adminCreate, "Registration failed. Please check the details and try again.");
        }
    }

    private String validateUserInput(String username, String password, String fullName, String email, String phone) {
        if (!ValidationUtil.isValidFullName(fullName)) {
            return "Full name must be 2 to 100 characters and cannot contain HTML tags.";
        }
        if (!ValidationUtil.isValidUsername(username)) {
            return "Username must be 3 to 30 characters and use only letters, numbers, or underscore.";
        }
        if (!ValidationUtil.isValidEmail(email)) {
            return "Please enter a valid email address.";
        }
        if (!ValidationUtil.isValidPhone(phone)) {
            return "Phone number must contain digits only and be 10 to 15 digits long.";
        }
        if (!ValidationUtil.isValidPassword(password)) {
            return "Password must be 8 to 72 characters and include at least one letter and one number.";
        }
        return null;
    }

    private void handleError(HttpServletRequest request, HttpServletResponse response, boolean adminCreate, String message) throws ServletException, IOException {
        if (adminCreate) {
            response.sendRedirect("admin/manageUsers.jsp?error=" + URLEncoder.encode(message, "UTF-8"));
            return;
        }
        request.setAttribute("error", message);
        request.setAttribute("fullName", ValidationUtil.clean(request.getParameter("fullName")));
        request.setAttribute("username", ValidationUtil.clean(request.getParameter("username")));
        request.setAttribute("email", ValidationUtil.clean(request.getParameter("email")));
        request.setAttribute("phone", ValidationUtil.clean(request.getParameter("phone")));
        request.getRequestDispatcher("register.jsp").forward(request, response);
    }
}
