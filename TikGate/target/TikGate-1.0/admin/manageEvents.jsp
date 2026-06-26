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
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Events - TikGate Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --tg-orange: #ff6b00;
            --tg-ink: #111827;
            --tg-muted: #64748b;
            --tg-soft: #fff7ed;
            --tg-line: #f1e2d6;
            --tg-blue: #0f2f75;
        }

        body {
            background:
                radial-gradient(circle at 12% 10%, rgba(255, 107, 0, 0.10), transparent 28%),
                linear-gradient(135deg, #fffaf5 0%, #eef5ff 100%);
            color: var(--tg-ink);
            min-height: 100vh;
        }

        .admin-shell {
            padding: 22px 4px 48px;
        }

        .page-heading {
            display: flex;
            justify-content: space-between;
            align-items: end;
            gap: 16px;
            margin-bottom: 18px;
        }

        .page-heading h1 {
            font-size: clamp(1.8rem, 3vw, 2.6rem);
            font-weight: 900;
            margin: 0;
        }

        .page-heading p {
            color: var(--tg-muted);
            margin: 6px 0 0;
        }

        .stat-chip {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: white;
            border: 1px solid var(--tg-line);
            border-radius: 999px;
            padding: 10px 14px;
            color: #9a3412;
            font-weight: 900;
            box-shadow: 0 12px 26px rgba(17, 24, 39, 0.06);
            white-space: nowrap;
        }

        .admin-card {
            border: 0;
            border-radius: 20px;
            box-shadow: 0 18px 42px rgba(17, 24, 39, 0.08);
            overflow: hidden;
            background: white;
        }

        .form-card-header {
            background: linear-gradient(135deg, var(--tg-blue), #111827);
            color: white;
            padding: 20px 22px;
        }

        .form-card-header h2 {
            font-size: 1.25rem;
            font-weight: 900;
            margin: 0;
        }

        .form-card-header p {
            color: rgba(255,255,255,0.72);
            margin: 4px 0 0;
        }

        .form-label {
            font-weight: 800;
            color: #1f2937;
        }

        .form-control,
        .form-select {
            min-height: 48px;
            border-radius: 12px;
            border-color: #dbe3ef;
            font-weight: 700;
        }

        textarea.form-control {
            min-height: 96px;
        }

        .form-control:focus,
        .form-select:focus {
            border-color: var(--tg-orange);
            box-shadow: 0 0 0 0.2rem rgba(255, 107, 0, 0.14);
        }

        .btn-add-event {
            background: var(--tg-orange);
            border: 0;
            color: white;
            border-radius: 999px;
            font-weight: 900;
            min-height: 48px;
            padding: 0 24px;
        }

        .btn-add-event:hover {
            background: #ea580c;
            color: white;
        }

        .events-table-card {
            margin-top: 24px;
        }

        .table-toolbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            padding: 18px 22px;
            border-bottom: 1px solid #eef2f7;
        }

        .table-toolbar h2 {
            font-size: 1.2rem;
            font-weight: 900;
            margin: 0;
        }

        .table {
            margin: 0;
            vertical-align: middle;
        }

        .table thead th {
            background: #f8fafc;
            color: var(--tg-muted);
            font-size: 0.78rem;
            text-transform: uppercase;
            letter-spacing: 0.04em;
            border-bottom: 1px solid #eef2f7;
            padding: 14px 18px;
        }

        .table tbody td {
            padding: 16px 18px;
            border-color: #eef2f7;
        }

        .event-name {
            font-weight: 900;
        }

        .event-sub {
            color: var(--tg-muted);
            font-size: 0.86rem;
        }

        .status-pill {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            border-radius: 999px;
            padding: 7px 10px;
            background: rgba(16, 185, 129, 0.14);
            color: #047857;
            font-size: 0.75rem;
            font-weight: 900;
            text-transform: uppercase;
        }

        @media (max-width: 768px) {
            .page-heading,
            .table-toolbar {
                align-items: start;
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
<jsp:include page="../includes/navbar.jsp" />

<main class="main-content">
    <div class="container-fluid admin-shell">
        <div class="page-heading">
            <div>
                <h1>Manage Events</h1>
                <p>Create match events, assign tournaments, and keep event listings ready for customers.</p>
            </div>
            <span class="stat-chip"><i class="fas fa-calendar-check"></i><%= events.size() %> Events</span>
        </div>

        <% if (request.getParameter("success") != null) { %>
            <div class="alert alert-success border-0 shadow-sm">Event added successfully!</div>
        <% } %>
        <% if (request.getParameter("error") != null) { %>
            <div class="alert alert-danger border-0 shadow-sm">Error processing event: <%= request.getParameter("error") %></div>
        <% } %>

        <section class="admin-card">
            <div class="form-card-header">
                <h2><i class="fas fa-plus-circle me-2"></i>Add New Event</h2>
                <p>Fill in the event details customers will see on the booking page.</p>
            </div>
            <div class="card-body p-4">
                <form action="manageEvents" method="post">
                    <div class="row g-3">
                        <div class="col-lg-6">
                            <label class="form-label">Event Name</label>
                            <input type="text" name="name" class="form-control" placeholder="e.g. Champions League Final" required>
                        </div>
                        <div class="col-lg-3">
                            <label class="form-label">Category</label>
                            <select id="categorySelect" class="form-select" onchange="filterTournaments()">
                                <option value="">Select Category</option>
                                <% for (int i = 0; i < categories.size(); i++) {
                                    Category c = (Category) categories.get(i); %>
                                    <option value="<%= c.getCategoryId() %>"><%= c.getCategoryName() %></option>
                                <% } %>
                            </select>
                        </div>
                        <div class="col-lg-3">
                            <label class="form-label">Tournament</label>
                            <select name="tournamentId" id="tournamentSelect" class="form-select" required>
                                <option value="">Select Tournament</option>
                                <% for (int i = 0; i < tournaments.size(); i++) {
                                    Tournament t = (Tournament) tournaments.get(i); %>
                                    <option value="<%= t.getTournamentId() %>" data-category="<%= t.getCategoryId() %>"><%= t.getTournamentName() %></option>
                                <% } %>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Date</label>
                            <input type="date" name="date" class="form-control" required>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Start Time</label>
                            <input type="time" name="startTime" class="form-control" required>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">End Time</label>
                            <input type="time" name="endTime" class="form-control" required>
                        </div>
                        <div class="col-12">
                            <label class="form-label">Description</label>
                            <textarea name="description" class="form-control" placeholder="Short description shown to customers"></textarea>
                        </div>
                    </div>
                    <div class="d-flex justify-content-end mt-4">
                        <button type="submit" class="btn btn-add-event"><i class="fas fa-save me-2"></i>Add Event</button>
                    </div>
                </form>
            </div>
        </section>

        <section class="admin-card events-table-card">
            <div class="table-toolbar">
                <div>
                    <h2>Event List</h2>
                    <div class="text-muted small">All events currently stored in TikGate.</div>
                </div>
            </div>
            <div class="table-responsive">
                <table class="table">
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
                        <% for (int i = 0; i < events.size(); i++) {
                            Event e = (Event) events.get(i);
                            Tournament eventTour = null;
                            for (int j = 0; j < tournaments.size(); j++) {
                                Tournament t = (Tournament) tournaments.get(j);
                                if (t.getTournamentId() == e.getTournamentId()) {
                                    eventTour = t;
                                    break;
                                }
                            }
                        %>
                        <tr>
                            <td class="fw-bold">#<%= e.getEventId() %></td>
                            <td>
                                <div class="event-name"><%= e.getEventName() %></div>
                                <div class="event-sub"><%= e.getStartTime() %> - <%= e.getEndTime() %></div>
                            </td>
                            <td><%= eventTour != null ? eventTour.getTournamentName() : "N/A" %></td>
                            <td><%= e.getEventDate() %></td>
                            <td><span class="status-pill"><i class="fas fa-circle-check"></i><%= e.getStatus() %></span></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </section>
    </div>
</main>

<script>
function filterTournaments() {
    var categoryId = document.getElementById('categorySelect').value;
    var tournamentSelect = document.getElementById('tournamentSelect');
    var options = tournamentSelect.options;

    for (var i = 0; i < options.length; i++) {
        if (options[i].value === "") continue;
        if (categoryId === "" || options[i].getAttribute('data-category') === categoryId) {
            options[i].hidden = false;
        } else {
            options[i].hidden = true;
        }
    }
    tournamentSelect.value = "";
}
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
