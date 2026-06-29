package com.tikgate.servlet;

import com.tikgate.dao.CategoryDAO;
import com.tikgate.model.Category;
import com.tikgate.model.User;
import com.tikgate.util.SecurityUtil;
import com.tikgate.util.ValidationUtil;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.net.URLEncoder;

@WebServlet("/admin/manageCategories")
public class ManageCategoriesServlet extends HttpServlet {
    private CategoryDAO categoryDAO = new CategoryDAO();

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
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

        if (!ValidationUtil.isSafeText(name, 2, 100)) {
            redirectWithError(response, "Category name must be 2 to 100 characters and cannot contain HTML tags.");
            return;
        }
        if (!ValidationUtil.isBlank(description) && !ValidationUtil.isSafeText(description, 0, 255)) {
            redirectWithError(response, "Description cannot contain HTML tags and must be 255 characters or less.");
            return;
        }
        if (categoryDAO.categoryNameExists(name)) {
            redirectWithError(response, "Category already exists.");
            return;
        }

        Category c = new Category();
        c.setCategoryName(name);
        c.setDescription(description);

        if (categoryDAO.addCategory(c)) {
            response.sendRedirect("manageCategories.jsp?success=category_created");
        } else {
            redirectWithError(response, "Unable to add category.");
        }
    }

    private void redirectWithError(HttpServletResponse response, String message) throws IOException {
        response.sendRedirect("manageCategories.jsp?error=" + URLEncoder.encode(message, "UTF-8"));
    }
}
