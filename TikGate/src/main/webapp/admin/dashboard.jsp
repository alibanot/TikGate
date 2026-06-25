<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.tikgate.model.*, com.tikgate.dao.*, java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || user.getRoleId() != 1) {
        response.sendRedirect("../login.jsp");
        return;
    }
    ReportDAO reportDAO = new ReportDAO();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>TikGate - Admin Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; }
        .stat-card { border: none; border-radius: 10px; transition: 0.3s; }
        .stat-card:hover { transform: translateY(-5px); }
    </style>
</head>
<body>
<jsp:include page="../includes/navbar.jsp" />

<div class="main-content">
    <div class="container-fluid">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2>Admin Dashboard</h2>
            <div class="text-muted">Administrator: <%= user.getFullName() %></div>
        </div>

        <div class="row g-4">
            <div class="col-md-3">
                <div class="card stat-card bg-primary text-white shadow-sm">
                    <div class="card-body">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h6 class="card-title text-uppercase small">Total Users</h6>
                                <h2 class="mb-0"><%= reportDAO.getTotalUsers() %></h2>
                            </div>
                            <i class="fas fa-users fa-2x opacity-50"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card stat-card bg-success text-white shadow-sm">
                    <div class="card-body">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h6 class="card-title text-uppercase small">Active Events</h6>
                                <h2 class="mb-0"><%= reportDAO.getActiveEventsCount() %></h2>
                            </div>
                            <i class="fas fa-calendar-alt fa-2x opacity-50"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card stat-card bg-warning text-dark shadow-sm">
                    <div class="card-body">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h6 class="card-title text-uppercase small">Tickets Sold</h6>
                                <h2 class="mb-0"><%= reportDAO.getTicketsSoldCount() %></h2>
                            </div>
                            <i class="fas fa-ticket-alt fa-2x opacity-50"></i>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card stat-card bg-danger text-white shadow-sm">
                    <div class="card-body">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h6 class="card-title text-uppercase small">Total Revenue</h6>
                                <h2 class="mb-0">$<%= reportDAO.getTotalRevenue() %></h2>
                            </div>
                            <i class="fas fa-dollar-sign fa-2x opacity-50"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row mt-5">
            <div class="col-md-8">
                <div class="card shadow-sm border-0">
                    <div class="card-header bg-white">
                        <h5 class="mb-0">Quick Actions</h5>
                    </div>
                    <div class="card-body">
                        <div class="row g-3 text-center">
                            <div class="col-4">
                                <a href="manageEvents.jsp" class="btn btn-outline-primary w-100 py-3">
                                    <i class="fas fa-plus-circle d-block mb-2 fs-4"></i> Add Event
                                </a>
                            </div>
                            <div class="col-4">
                                <a href="manageUsers.jsp" class="btn btn-outline-success w-100 py-3">
                                    <i class="fas fa-user-plus d-block mb-2 fs-4"></i> Add User
                                </a>
                            </div>
                            <div class="col-4">
                                <a href="reports.jsp" class="btn btn-outline-info w-100 py-3">
                                    <i class="fas fa-file-invoice-dollar d-block mb-2 fs-4"></i> View Sales
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
