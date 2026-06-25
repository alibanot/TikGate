<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.tikgate.model.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || (user.getRoleId() != 3 && user.getRoleId() != 1)) {
        response.sendRedirect("../login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>TikGate - Ticket Verification</title>
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
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2>Ticket Verification</h2>
            <div class="text-muted">User: <%= user.getFullName() %></div>
        </div>

        <div class="row justify-content-center mt-5">
            <div class="col-md-6">
                <div class="card shadow-sm border-0">
                    <div class="card-body p-5 text-center">
                        <i class="fas fa-qrcode fa-5x text-primary mb-4"></i>
                        <h4 class="mb-4">Scan or Enter Ticket Code</h4>
                        <form action="verifyTicket" method="post">
                            <div class="input-group input-group-lg mb-3">
                                <input type="text" name="qrCode" class="form-control" placeholder="Enter QR Code" required autofocus>
                                <button class="btn btn-primary" type="submit">Verify</button>
                            </div>
                            <p class="text-muted small">Enter the unique code found on the customer's ticket.</p>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
