<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.tikgate.model.*, com.tikgate.dao.*, java.util.Map" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || user.getRoleId() != 1) {
        response.sendRedirect("../login.jsp");
        return;
    }
    ReportDAO reportDAO = new ReportDAO();
    Map stats = reportDAO.getDashboardStats();
    
    Object totalUsers = stats.get("totalUsers");
    if (totalUsers == null) totalUsers = 0;
    
    Object totalEvents = stats.get("totalEvents");
    if (totalEvents == null) totalEvents = 0;
    
    Object totalTickets = stats.get("totalTickets");
    if (totalTickets == null) totalTickets = 0;
    
    Object totalRevenue = stats.get("totalRevenue");
    if (totalRevenue == null) totalRevenue = 0.0;
%>
<!DOCTYPE html>
<html>
<head>
    <title>Reports - TikGate Admin</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
</head>
<body>
<jsp:include page="../includes/navbar.jsp" />
<div class="main-content">
<div class="container-fluid">
    <h2>System Reports & Statistics</h2>
    <hr>
    <div class="row">
        <div class="col-md-3">
            <div class="card text-white bg-primary mb-3">
                <div class="card-header">Total Users</div>
                <div class="card-body">
                    <h3 class="card-title"><%= totalUsers %></h3>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card text-white bg-success mb-3">
                <div class="card-header">Active Events</div>
                <div class="card-body">
                    <h3 class="card-title"><%= totalEvents %></h3>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card text-white bg-info mb-3">
                <div class="card-header">Tickets Sold</div>
                <div class="card-body">
                    <h3 class="card-title"><%= totalTickets %></h3>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card text-white bg-warning mb-3">
                <div class="card-header">Total Revenue</div>
                <div class="card-body">
                    <h3 class="card-title">$<%= String.format("%.2f", (Double)totalRevenue) %></h3>
                </div>
            </div>
        </div>
    </div>
</div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
