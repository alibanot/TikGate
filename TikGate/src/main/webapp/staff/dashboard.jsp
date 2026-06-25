<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.tikgate.model.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || user.getRoleId() != 3) {
        response.sendRedirect("../login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>TikGate - Staff Dashboard</title>
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
            <h2>Staff Dashboard</h2>
            <div class="text-muted">Staff: <%= user.getFullName() %></div>
        </div>

        <div class="row">
            <div class="col-md-6">
                <div class="card stat-card shadow-sm bg-primary text-white mb-4">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <h5 class="card-title">Ticket Verification</h5>
                                <p class="card-text">Scan and verify customer tickets.</p>
                            </div>
                            <i class="fas fa-qrcode fa-3x opacity-50"></i>
                        </div>
                        <a href="verification.jsp" class="btn btn-light btn-sm mt-3">Go to Verification</a>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="card stat-card shadow-sm bg-success text-white mb-4">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <h5 class="card-title">Event Management</h5>
                                <p class="card-text">Create and manage stadium events.</p>
                            </div>
                            <i class="fas fa-calendar-alt fa-3x opacity-50"></i>
                        </div>
                        <a href="../admin/manageEvents.jsp" class="btn btn-light btn-sm mt-3">Manage Events</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
