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
    TournamentDAO tournamentDAO = new TournamentDAO();
    List tournaments = tournamentDAO.getAllTournaments();
%>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Tournaments - TikGate</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
</head>
<body>
<jsp:include page="../includes/navbar.jsp" />
<div class="main-content">
<div class="container-fluid">
    <h2>Manage Tournaments</h2>

    <% if (request.getParameter("success") != null) { %>
        <div class="alert alert-success">Tournament added successfully!</div>
    <% } %>
    <% if (request.getParameter("error") != null) { %>
        <div class="alert alert-danger"><%= SecurityUtil.escapeHtml(request.getParameter("error")) %></div>
    <% } %>

    <div class="card mb-4">
        <div class="card-body">
            <h5 class="card-title">Add New Tournament</h5>
            <form action="manageTournaments" method="post" class="form-row align-items-center">
                <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
                <div class="col-md-3 mb-2">
                    <input type="text" name="name" class="form-control" placeholder="Tournament Name" maxlength="100" required>
                </div>
                <div class="col-md-4 mb-2">
                    <input type="text" name="description" class="form-control" placeholder="Description" maxlength="255">
                </div>
                <div class="col-md-3 mb-2">
                    <select name="categoryId" class="form-control" required>
                        <option value="">Select Category</option>
                        <% for(int i=0; i<categories.size(); i++) { 
                            Category c = (Category) categories.get(i); %>
                            <option value="<%= c.getCategoryId() %>"><%= SecurityUtil.escapeHtml(c.getCategoryName()) %></option>
                        <% } %>
                    </select>
                </div>
                <div class="col-md-2 mb-2">
                    <button type="submit" class="btn btn-primary w-100">Add</button>
                </div>
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
            <% for (int i=0; i<tournaments.size(); i++) { 
                Tournament t = (Tournament) tournaments.get(i);
            %>
            <tr>
                <td><%= t.getTournamentId() %></td>
                <td><%= SecurityUtil.escapeHtml(t.getTournamentName()) %></td>
                <td><%= SecurityUtil.escapeHtml(t.getDescription()) %></td>
            </tr>
            <% } %>
        </tbody>
    </table>
</div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
