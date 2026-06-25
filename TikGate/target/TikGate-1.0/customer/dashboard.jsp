<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.tikgate.model.*, com.tikgate.dao.*, java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || user.getRoleId() != 2) {
        response.sendRedirect("../login.jsp");
        return;
    }
    EventDAO eventDAO = new EventDAO();
    List events = eventDAO.getAllEvents();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>TikGate - Customer Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; }
        .event-card { transition: 0.3s; border: none; }
        .event-card:hover { transform: translateY(-5px); box-shadow: 0 10px 20px rgba(0,0,0,0.1); }
    </style>
</head>
<body>
<jsp:include page="../includes/navbar.jsp" />

<div class="main-content">
    <div class="container-fluid">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2>Welcome, <%= user.getFullName() %>!</h2>
            <div class="text-muted">
                <i class="far fa-calendar-alt me-1"></i> <%= new java.util.Date() %>
            </div>
        </div>

        <h4 class="mb-3">Upcoming Events</h4>
        <div class="row row-cols-1 row-cols-md-3 g-4">
            <% for (int i=0; i<events.size(); i++) { 
                Event e = (Event) events.get(i);
            %>
            <div class="col">
                <div class="card h-100 event-card shadow-sm">
                    <div class="card-body">
                        <h5 class="card-title text-primary"><%= e.getEventName() %></h5>
                        <p class="card-text text-muted small"><%= e.getDescription() %></p>
                        <div class="mb-2">
                            <span class="badge bg-info text-dark"><i class="far fa-calendar me-1"></i> <%= e.getEventDate() %></span>
                            <span class="badge bg-light text-dark"><i class="far fa-clock me-1"></i> <%= e.getStartTime() %></span>
                        </div>
                    </div>
                    <div class="card-footer bg-white border-top-0 d-grid">
                        <a href="bookEvent.jsp?id=<%= e.getEventId() %>" class="btn btn-primary">Book Now</a>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
