<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.tikgate.model.*, com.tikgate.dao.*, com.tikgate.util.SecurityUtil, java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || (user.getRoleId() != 1 && user.getRoleId() != 3)) {
        response.sendRedirect("../login.jsp");
        return;
    }
    String csrfToken = SecurityUtil.ensureCsrfToken(request);
    CategoryDAO categoryDAO = new CategoryDAO();
    List categories = categoryDAO.getAllCategories();
%>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Categories - TikGate</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
</head>
<body>
<jsp:include page="../includes/navbar.jsp" />
<div class="main-content">
<div class="container-fluid">
    <h2>Manage Categories</h2>
    <% if (request.getParameter("success") != null) { %>
        <div class="alert alert-success">Category added successfully.</div>
    <% } %>
    <% if (request.getParameter("error") != null) { %>
        <div class="alert alert-danger"><%= SecurityUtil.escapeHtml(request.getParameter("error")) %></div>
    <% } %>
    <div class="card mb-4">
        <div class="card-body">
            <h5 class="card-title">Add New Category</h5>
            <form action="manageCategories" method="post" class="form-inline">
                <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
                <input type="text" name="name" class="form-control mr-2" placeholder="Category Name" maxlength="100" required>
                <input type="text" name="description" class="form-control mr-2" placeholder="Description" maxlength="255">
                <button type="submit" class="btn btn-primary">Add</button>
            </form>
        </div>
    </div>
    <table class="table table-striped">
        <thead>
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Description</th>
            </tr>
        </thead>
        <tbody>
            <% for (int i=0; i<categories.size(); i++) { 
                Category c = (Category) categories.get(i);
            %>
            <tr>
                <td><%= c.getCategoryId() %></td>
                <td><%= SecurityUtil.escapeHtml(c.getCategoryName()) %></td>
                <td><%= SecurityUtil.escapeHtml(c.getDescription()) %></td>
            </tr>
            <% } %>
        </tbody>
    </table>
</div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
