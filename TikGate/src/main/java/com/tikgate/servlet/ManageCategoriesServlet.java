package com.tikgate.servlet;

import com.tikgate.dao.CategoryDAO;
import com.tikgate.model.Category;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/manageCategories")
public class ManageCategoriesServlet extends HttpServlet {
    private CategoryDAO categoryDAO = new CategoryDAO();

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        
        Category c = new Category();
        c.setCategoryName(name);
        c.setDescription(description);
        
        categoryDAO.addCategory(c);
        response.sendRedirect("manageCategories.jsp");
    }
}
