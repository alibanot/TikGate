<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.tikgate.model.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || user.getRoleId() != 2) {
        response.sendRedirect("../login.jsp");
        return;
    }
    String bookingId = request.getParameter("bookingId");
    if (bookingId == null || bookingId.isEmpty()) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html>
<head>
    <title>TikGate - Payment</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
</head>
<body>
<jsp:include page="../includes/navbar.jsp" />
<div class="main-content">
<div class="container-fluid mt-5">
    <div class="row justify-content-center">
        <div class="col-md-6">
            <div class="card">
                <div class="card-header bg-success text-white">
                    <h4 class="mb-0">Payment Processing</h4>
                </div>
                <div class="card-body">
                    <% if (error != null) { %>
                        <div class="alert alert-danger"><%= error.replace("_", " ") %></div>
                    <% } %>
                    <p>Booking ID: <strong>#<%= bookingId %></strong></p>
                    <form action="../processPayment" method="post">
                        <input type="hidden" name="bookingId" value="<%= bookingId %>">
                        <div class="form-group">
                            <label>Payment Method</label>
                            <select name="paymentMethod" class="form-control">
                                <option value="Credit Card">Credit Card</option>
                                <option value="Debit Card">Debit Card</option>
                                <option value="PayPal">PayPal</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Card Number</label>
                            <input type="text" class="form-control" placeholder="XXXX-XXXX-XXXX-XXXX" required>
                        </div>
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Expiry</label>
                                    <input type="text" class="form-control" placeholder="MM/YY" required>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>CVV</label>
                                    <input type="text" class="form-control" placeholder="123" required>
                                </div>
                            </div>
                        </div>
                        <button type="submit" class="btn btn-success btn-block">Pay Now</button>
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
