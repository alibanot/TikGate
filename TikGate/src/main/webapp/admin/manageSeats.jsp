<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.tikgate.model.*, com.tikgate.dao.*, com.tikgate.util.SecurityUtil, java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || (user.getRoleId() != 1 && user.getRoleId() != 3)) {
        response.sendRedirect("../login.jsp");
        return;
    }
    String csrfToken = SecurityUtil.ensureCsrfToken(request);
    SeatDAO seatDAO = new SeatDAO();
    List seats = seatDAO.getAllSeats();
%>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Seats - TikGate Admin</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
</head>
<body>
<jsp:include page="../includes/navbar.jsp" />
<div class="main-content">
<div class="container-fluid">
    <h2>Manage Seats</h2>
    <% if (request.getParameter("success") != null) { %>
        <div class="alert alert-success">Seat added successfully.</div>
    <% } %>
    <% if (request.getParameter("error") != null) { %>
        <div class="alert alert-danger"><%= SecurityUtil.escapeHtml(request.getParameter("error")) %></div>
    <% } %>
    <div class="card mb-4">
        <div class="card-body">
            <h5 class="card-title">Add New Seat</h5>
            <form action="manageSeats" method="post" class="form-inline">
                <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
                <input type="text" name="section" class="form-control mr-2" placeholder="Section (e.g. North)" maxlength="50" required>
                <input type="text" name="row" class="form-control mr-2" placeholder="Row" maxlength="10" pattern="[A-Za-z0-9]{1,10}" required>
                <input type="text" name="number" class="form-control mr-2" placeholder="Seat No" inputmode="numeric" pattern="[0-9]{1,4}" maxlength="4" required>
                <button type="submit" class="btn btn-primary">Add Seat</button>
            </form>
        </div>
    </div>
    <table class="table table-striped">
        <thead>
            <tr>
                <th>ID</th>
                <th>Section</th>
                <th>Row</th>
                <th>Number</th>
            </tr>
        </thead>
        <tbody>
            <% for (int i=0; i<seats.size(); i++) { 
                Seat s = (Seat) seats.get(i);
            %>
            <tr>
                <td><%= s.getSeatId() %></td>
                <td><%= SecurityUtil.escapeHtml(s.getSectionName()) %></td>
                <td><%= SecurityUtil.escapeHtml(s.getRowNo()) %></td>
                <td><%= SecurityUtil.escapeHtml(s.getSeatNumber()) %></td>
            </tr>
            <% } %>
        </tbody>
    </table>
</div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
