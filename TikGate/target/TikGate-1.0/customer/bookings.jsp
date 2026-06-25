<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.tikgate.model.*, com.tikgate.dao.*, java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || user.getRoleId() != 2) {
        response.sendRedirect("../login.jsp");
        return;
    }
    BookingDAO bookingDAO = new BookingDAO();
    List bookings = bookingDAO.getBookingsByUser(user.getUserId());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>TikGate - My Bookings</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; }
    </style>
</head>
<body>
<jsp:include page="../includes/navbar.jsp" />

<div class="main-content">
<div class="container-fluid">
    <h2 class="mb-4">My Bookings</h2>
    
    <% if (bookings == null || bookings.isEmpty()) { %>
        <div class="card shadow-sm border-0">
            <div class="card-body text-center py-5">
                <i class="fas fa-ticket-alt fa-4x text-muted mb-3"></i>
                <h4>No bookings found</h4>
                <p class="text-muted">You haven't booked any tickets yet.</p>
                <a href="dashboard.jsp" class="btn btn-primary mt-2">Explore Events</a>
            </div>
        </div>
    <% } else { %>
        <div class="row g-4">
            <% for (int i=0; i<bookings.size(); i++) { 
                Booking b = (Booking) bookings.get(i);
                EventDAO eventDAO = new EventDAO();
                Event event = eventDAO.getEventById(b.getEventId());
                TicketDAO ticketDAO = new TicketDAO();
                Ticket ticket = ticketDAO.getTicketByBookingId(b.getBookingId());
            %>
            <div class="col-md-6 col-lg-4">
                <div class="card shadow-sm h-100 border-0">
                    <div class="card-header bg-white border-0 d-flex justify-content-between align-items-center pt-3">
                        <span class="badge <%= "PAID".equals(b.getStatus()) ? "bg-success" : "bg-warning" %>"><%= b.getStatus() %></span>
                        <small class="text-muted">ID: #<%= b.getBookingId() %></small>
                    </div>
                    <div class="card-body">
                        <h5 class="card-title fw-bold"><%= event != null ? event.getEventName() : "Unknown Event" %></h5>
                        <p class="text-muted mb-2"><i class="far fa-calendar-alt me-2"></i><%= event != null ? event.getEventDate() : "N/A" %></p>
                        <p class="fw-bold text-primary fs-5 mb-0">$<%= b.getTotalAmount() %></p>
                    </div>
                    <div class="card-footer bg-white border-0 pb-3">
                        <% if ("PAID".equals(b.getStatus()) && ticket != null) { %>
                            <a href="ticketDetails.jsp?qrCode=<%= ticket.getQrCode() %>" class="btn btn-outline-primary w-100">View Ticket</a>
                        <% } else if ("PENDING".equals(b.getStatus())) { %>
                            <a href="payment.jsp?bookingId=<%= b.getBookingId() %>" class="btn btn-primary w-100">Pay Now</a>
                        <% } %>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
    <% } %>
</div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
