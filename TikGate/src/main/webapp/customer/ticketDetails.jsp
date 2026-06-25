<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.tikgate.model.*, com.tikgate.dao.*, java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || user.getRoleId() != 2) {
        response.sendRedirect("../login.jsp");
        return;
    }
    String qrCode = request.getParameter("qrCode");
    TicketDAO ticketDAO = new TicketDAO();
    Ticket ticket = ticketDAO.getTicketByQrCode(qrCode);
    if (ticket == null) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Your Ticket - TikGate</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; }
        .ticket-card { max-width: 500px; border-radius: 15px; overflow: hidden; margin: 0 auto; }
        .qr-placeholder { background: #eee; height: 200px; width: 200px; margin: 0 auto; display: flex; align-items: center; justify-content: center; border: 1px dashed #ccc; }
    </style>
</head>
<body>
<jsp:include page="../includes/navbar.jsp" />

<div class="main-content">
    <div class="container-fluid mt-5 text-center">
        <div class="card ticket-card shadow-sm border-0">
            <div class="card-header bg-primary text-white p-4">
                <h3 class="mb-0"><i class="fas fa-ticket-alt me-2"></i>Electronic Ticket</h3>
            </div>
            <div class="card-body p-5">
                <div class="mb-4">
                    <% 
                        String qrPath = request.getContextPath() + "/tickets/" + ticket.getQrCode() + ".png";
                        String realPath = getServletContext().getRealPath("/tickets/" + ticket.getQrCode() + ".png");
                        java.io.File qrFile = new java.io.File(realPath);
                        if (qrFile.exists()) {
                    %>
                        <img src="<%= qrPath %>" alt="QR Code" class="img-fluid border p-2" style="width: 200px;">
                    <% } else { %>
                        <div class="qr-placeholder flex-column">
                            <i class="fas fa-qrcode fa-3x text-muted mb-2"></i>
                            <span class="text-muted small">QR Code: <%= ticket.getQrCode() %></span>
                        </div>
                    <% } %>
                </div>
                
                <div class="row text-start mt-4">
                    <div class="col-6 mb-3">
                        <label class="text-muted small d-block">Ticket ID</label>
                        <span class="fw-bold"><%= ticket.getQrCode() %></span>
                    </div>
                    <div class="col-6 mb-3">
                        <label class="text-muted small d-block">Status</label>
                        <span class="badge <%= ticket.getStatus().equals("VALID") ? "bg-success" : "bg-danger" %>"><%= ticket.getStatus() %></span>
                    </div>
                    <div class="col-12 mb-3">
                        <label class="text-muted small d-block">Generated On</label>
                        <span class="fw-bold"><%= ticket.getGeneratedDate() %></span>
                    </div>
                </div>
                
                <hr class="my-4">
                <div class="d-grid gap-2">
                    <a href="dashboard.jsp" class="btn btn-outline-primary">Back to Dashboard</a>
                    <button onclick="window.print()" class="btn btn-primary"><i class="fas fa-print me-2"></i>Print Ticket</button>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
