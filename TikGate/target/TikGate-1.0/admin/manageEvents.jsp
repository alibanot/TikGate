<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.tikgate.model.*, com.tikgate.dao.*, java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || (user.getRoleId() != 1 && user.getRoleId() != 3)) {
        response.sendRedirect("../login.jsp");
        return;
    }
    EventDAO eventDAO = new EventDAO();
    CategoryDAO categoryDAO = new CategoryDAO();
    TournamentDAO tournamentDAO = new TournamentDAO();
    List events = eventDAO.getAllEvents();
    List categories = categoryDAO.getAllCategories();
    List tournaments = tournamentDAO.getAllTournaments();
%>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Events - TikGate Admin</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
</head>
<body>
<jsp:include page="../includes/navbar.jsp" />
<div class="main-content">
<div class="container-fluid">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2>Manage Events</h2>
    </div>

    <% if (request.getParameter("success") != null) { %>
        <div class="alert alert-success">Event added successfully!</div>
    <% } %>
    <% if (request.getParameter("error") != null) { %>
        <div class="alert alert-danger">Error processing event: <%= request.getParameter("error") %></div>
    <% } %>

    <div class="card mb-4">
        <div class="card-body">
            <h5 class="card-title">Add New Event</h5>
            <form action="manageEvents" method="post">
                <div class="form-row">
                    <div class="form-group col-md-6">
                        <label>Event Name</label>
                        <input type="text" name="name" class="form-control" required>
                    </div>
                    <div class="form-group col-md-3">
                        <label>Category</label>
                        <select id="categorySelect" class="form-control" onchange="filterTournaments()">
                            <option value="">Select Category</option>
                            <% for(int i=0; i<categories.size(); i++) { 
                                Category c = (Category) categories.get(i); %>
                                <option value="<%= c.getCategoryId() %>"><%= c.getCategoryName() %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="form-group col-md-3">
                        <label>Tournament</label>
                        <select name="tournamentId" id="tournamentSelect" class="form-control" required>
                            <option value="">Select Tournament</option>
                            <% for(int i=0; i<tournaments.size(); i++) { 
                                Tournament t = (Tournament) tournaments.get(i); %>
                                <option value="<%= t.getTournamentId() %>" data-category="<%= t.getCategoryId() %>"><%= t.getTournamentName() %></option>
                            <% } %>
                        </select>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group col-md-4">
                        <label>Date</label>
                        <input type="date" name="date" class="form-control" required>
                    </div>
                    <div class="form-group col-md-4">
                        <label>Start Time</label>
                        <input type="time" name="startTime" class="form-control" required>
                    </div>
                    <div class="form-group col-md-4">
                        <label>End Time</label>
                        <input type="time" name="endTime" class="form-control" required>
                    </div>
                </div>
                <div class="form-group">
                    <label>Description</label>
                    <textarea name="description" class="form-control"></textarea>
                </div>
                <button type="submit" class="btn btn-primary">Add Event</button>
            </form>
        </div>
    </div>
    <table class="table table-striped">
        <thead>
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Tournament</th>
                <th>Date</th>
                <th>Status</th>
            </tr>
        </thead>
        <tbody>
            <% for (int i=0; i<events.size(); i++) { 
                Event e = (Event) events.get(i);
                Tournament eventTour = null;
                for (int j=0; j<tournaments.size(); j++) {
                    Tournament t = (Tournament) tournaments.get(j);
                    if (t.getTournamentId() == e.getTournamentId()) {
                        eventTour = t;
                        break;
                    }
                }
            %>
            <tr>
                <td><%= e.getEventId() %></td>
                <td><%= e.getEventName() %></td>
                <td><%= eventTour != null ? eventTour.getTournamentName() : "N/A" %></td>
                <td><%= e.getEventDate() %></td>
                <td><span class="badge badge-success"><%= e.getStatus() %></span></td>
            </tr>
            <% } %>
        </tbody>
    </table>
</div>
</div>
<script>
function filterTournaments() {
    var categoryId = document.getElementById('categorySelect').value;
    var tournamentSelect = document.getElementById('tournamentSelect');
    var options = tournamentSelect.options;
    
    for (var i = 0; i < options.length; i++) {
        if (options[i].value === "") continue;
        if (categoryId === "" || options[i].getAttribute('data-category') === categoryId) {
            options[i].style.display = 'block';
        } else {
            options[i].style.display = 'none';
        }
    }
    tournamentSelect.value = "";
}
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
