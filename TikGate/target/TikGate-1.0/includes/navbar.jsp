<%@ page import="com.tikgate.model.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
    String contextPath = request.getContextPath();
    String currentRole = (currentUser != null) ? (currentUser.getRoleId() == 1 ? "ADMIN" : (currentUser.getRoleId() == 3 ? "STAFF" : "CUSTOMER")) : "";
    
    String homeUrl = contextPath + "/index.jsp";
    if (currentUser != null) {
        if (currentUser.getRoleId() == 1) homeUrl = contextPath + "/admin/dashboard.jsp";
        else if (currentUser.getRoleId() == 3) homeUrl = contextPath + "/staff/verification.jsp";
        else if (currentUser.getRoleId() == 2) homeUrl = contextPath + "/customer/dashboard.jsp";
    }
%>
<style>
    .sidebar {
        height: 100vh;
        width: 250px;
        position: fixed;
        top: 0;
        left: 0;
        background-color: #2c3e50;
        color: white;
        padding-top: 20px;
        z-index: 1000;
        transition: 0.3s;
    }
    .sidebar-brand {
        padding: 15px 25px;
        font-size: 24px;
        font-weight: bold;
        color: white;
        text-decoration: none;
        display: block;
        text-align: center;
    }
    .sidebar-brand:hover {
        color: #ecf0f1;
    }
    .sidebar a.nav-link {
        padding: 12px 25px;
        text-decoration: none;
        font-size: 16px;
        color: #bdc3c7;
        display: block;
        transition: 0.3s;
    }
    .sidebar a.nav-link:hover {
        color: white;
        background-color: #34495e;
    }
    .sidebar a.nav-link.active {
        color: white;
        background-color: #3498db;
    }
    .sidebar a.nav-link i {
        margin-right: 10px;
        width: 20px;
        text-align: center;
    }
    .main-content {
        margin-left: 250px;
        padding: 20px;
        transition: 0.3s;
    }
    @media (max-width: 768px) {
        .sidebar {
            width: 0;
            overflow: hidden;
        }
        .main-content {
            margin-left: 0;
        }
    }
</style>

<div class="sidebar">
    <a class="sidebar-brand" href="<%= homeUrl %>">
        <img src="<%= contextPath %>/assets/logo.png" alt="TikGate" height="40" class="mb-2 d-block mx-auto">
        TikGate
    </a>
    <hr class="mx-3">
    
    <% if (currentUser != null) { %>
        <div class="px-3 mb-3 small text-uppercase text-muted">Menu</div>
        
        <% if (currentUser.getRoleId() == 1 || currentUser.getRoleId() == 3) { // Admin or Staff %>
            <a class="nav-link" href="<%= contextPath %>/<%= currentUser.getRoleId() == 1 ? "admin" : "staff" %>/dashboard.jsp">
                <i class="fas fa-tachometer-alt"></i> Dashboard
            </a>
            <a class="nav-link" href="<%= contextPath %>/admin/manageEvents.jsp">
                <i class="fas fa-calendar-check"></i> Events
            </a>
            <a class="nav-link" href="<%= contextPath %>/admin/manageTournaments.jsp">
                <i class="fas fa-trophy"></i> Tournaments
            </a>
            <a class="nav-link" href="<%= contextPath %>/admin/manageCategories.jsp">
                <i class="fas fa-list"></i> Categories
            </a>
            <a class="nav-link" href="<%= contextPath %>/admin/manageSeats.jsp">
                <i class="fas fa-chair"></i> Seats
            </a>
            <% if (currentUser.getRoleId() == 1) { %>
                <a class="nav-link" href="<%= contextPath %>/admin/manageUsers.jsp">
                    <i class="fas fa-users"></i> Users
                </a>
                <a class="nav-link" href="<%= contextPath %>/admin/reports.jsp">
                    <i class="fas fa-chart-line"></i> Reports
                </a>
            <% } %>
            <a class="nav-link" href="<%= contextPath %>/staff/verification.jsp">
                <i class="fas fa-qrcode"></i> Verify Ticket
            </a>
        <% } else if (currentUser.getRoleId() == 2) { // Customer %>
            <a class="nav-link" href="<%= contextPath %>/customer/dashboard.jsp">
                <i class="fas fa-home"></i> Dashboard
            </a>
            <a class="nav-link" href="<%= contextPath %>/customer/bookings.jsp">
                <i class="fas fa-ticket-alt"></i> My Bookings
            </a>
        <% } %>
        
        <div class="mt-auto position-absolute bottom-0 w-100 pb-3">
            <hr class="mx-3">
            <div class="px-3 mb-2 small text-muted">Logged in as:</div>
            <div class="px-3 mb-3 fw-bold"><%= currentUser.getFullName() %></div>
            <a class="nav-link text-danger" href="<%= contextPath %>/logout">
                <i class="fas fa-sign-out-alt"></i> Logout
            </a>
        </div>
    <% } else { %>
        <a class="nav-link" href="<%= contextPath %>/login.jsp">
            <i class="fas fa-sign-in-alt"></i> Login
        </a>
        <a class="nav-link" href="<%= contextPath %>/register.jsp">
            <i class="fas fa-user-plus"></i> Register
        </a>
    <% } %>
</div>
