<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.tikgate.model.*, com.tikgate.dao.*, java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || (user.getRoleId() != 1 && user.getRoleId() != 3)) {
        response.sendRedirect("../login.jsp");
        return;
    }
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
    <div class="card mb-4">
        <div class="card-body">
            <h5 class="card-title">Add New Seat</h5>
            <form action="manageSeats" method="post" class="form-inline">
                <input type="text" name="section" class="form-control mr-2" placeholder="Section (e.g. A)" required>
                <input type="text" name="row" class="form-control mr-2" placeholder="Row" required>
                <input type="text" name="number" class="form-control mr-2" placeholder="Seat No" required>
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
                <td><%= s.getSectionName() %></td>
                <td><%= s.getRowNo() %></td>
                <td><%= s.getSeatNumber() %></td>
            </tr>
            <% } %>
        </tbody>
    </table>
</div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
