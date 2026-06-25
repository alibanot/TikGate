<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.tikgate.model.*, com.tikgate.dao.*, java.util.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || user.getRoleId() != 2) {
        response.sendRedirect("../login.jsp");
        return;
    }
    String idParam = request.getParameter("id");
    if (idParam == null) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
    int eventId = Integer.parseInt(idParam);
    EventDAO eventDAO = new EventDAO();
    Event event = eventDAO.getEventById(eventId);
    if (event == null) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
    SeatDAO seatDAO = new SeatDAO();
    List<Seat> seats = seatDAO.getAllSeats();
    
    // Group seats by section - Using compatible syntax
    Map sectionSeats = new LinkedHashMap();
    for (int i = 0; i < seats.size(); i++) {
        Seat s = (Seat) seats.get(i);
        String section = s.getSectionName();
        if (!sectionSeats.containsKey(section)) {
            sectionSeats.put(section, new ArrayList());
        }
        List sectionList = (List) sectionSeats.get(section);
        sectionList.add(s);
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>TikGate - Book Event</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; }
        .stadium-container { 
            background: #1a472a; 
            padding: 40px; 
            border-radius: 50px; 
            position: relative; 
            margin: 20px auto; 
            border: 5px solid #2d5a3f;
            max-width: 900px;
            color: white;
        }
        .stadium-field { 
            background: #2e7d32; 
            height: 250px; 
            border: 2px solid rgba(255,255,255,0.3); 
            border-radius: 10px; 
            display: flex; 
            align-items: center; 
            justify-content: center; 
            color: white; 
            font-weight: bold; 
            text-transform: uppercase; 
            letter-spacing: 5px; 
            margin: 20px 60px;
            font-size: 2rem;
        }
        .seat-block { 
            display: inline-block; 
            width: 25px; 
            height: 25px; 
            margin: 3px; 
            border-radius: 5px; 
            cursor: pointer; 
            position: relative; 
        }
        .seat-available { background-color: #fff; border: 1px solid #ddd; }
        .seat-available:hover { background-color: #f1c40f; border-color: #f39c12; }
        .seat-taken { background-color: #8b4513; cursor: not-allowed; border: 1px solid #5d2e0d; }
        .seat-radio { position: absolute; opacity: 0; cursor: pointer; height: 100%; width: 100%; top: 0; left: 0; margin: 0; z-index: 2; }
        .seat-radio:checked + .seat-visual { background-color: #f1c40f; border: 2px solid #f39c12; }
        .seat-visual { position: absolute; top: 0; left: 0; height: 100%; width: 100%; border-radius: 5px; transition: 0.2s; }
        
        .section-north { position: absolute; right: 20px; top: 50%; transform: translateY(-50%); display: flex; flex-direction: column; align-items: center; }
        .section-south { position: absolute; left: 20px; top: 50%; transform: translateY(-50%); display: flex; flex-direction: column; align-items: center; }
        .section-east { width: 100%; display: flex; flex-direction: column; align-items: center; margin-bottom: 10px; }
        .section-west { width: 100%; display: flex; flex-direction: column; align-items: center; margin-top: 10px; }
        
        .section-label { font-weight: bold; margin: 5px; font-size: 0.9rem; text-transform: uppercase; }
        .vertical-label { writing-mode: vertical-rl; text-orientation: mixed; }
        
        .legend-item { display: inline-flex; align-items: center; margin-right: 20px; }
        .legend-box { width: 20px; height: 20px; border-radius: 3px; margin-right: 8px; }
    </style>
</head>
<body>
<jsp:include page="../includes/navbar.jsp" />

<div class="main-content">
    <div class="container-fluid">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2>Book Ticket: <%= event.getEventName() %></h2>
            <span class="badge bg-primary fs-6"><%= event.getEventDate() %></span>
        </div>

        <% if (request.getParameter("error") != null) { %>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <%= "seat_taken".equals(request.getParameter("error")) ? "Sorry, that seat was just taken. Please choose another." : "Booking failed. Please try again." %>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <% } %>

        <div class="row">
            <div class="col-lg-9">
                <div class="card shadow-sm border-0">
                    <div class="card-header bg-white">
                        <h5 class="mb-0">Select Your Seat</h5>
                    </div>
                    <div class="card-body bg-light">
                        <form action="../bookTicket" method="post" id="bookingForm">
                            <input type="hidden" name="eventId" value="<%= eventId %>">
                            <input type="hidden" name="price" value="150.00">
                            
                            <div class="stadium-container">
                                <!-- East Section (Top) -->
                                <div class="section-east">
                                    <span class="section-label">Section: East</span>
                                    <div class="d-flex flex-wrap justify-content-center">
                                        <% 
                                            List eastSeats = (List) sectionSeats.get("East");
                                            if (eastSeats == null) eastSeats = new ArrayList();
                                            for (int i = 0; i < eastSeats.size(); i++) {
                                                Seat s = (Seat) eastSeats.get(i);
                                                boolean available = seatDAO.isSeatAvailable(eventId, s.getSeatId());
                                        %>
                                            <div class="seat-block <%= available ? "seat-available" : "seat-taken" %>" title="Section East | Row <%= s.getRowNo() %> Seat <%= s.getSeatNumber() %>">
                                                <% if (available) { %>
                                                    <input type="radio" name="seatId" value="<%= s.getSeatId() %>" class="seat-radio" required>
                                                    <div class="seat-visual"></div>
                                                <% } %>
                                            </div>
                                        <% } %>
                                    </div>
                                    <div class="seat-block seat-available mt-1" style="cursor: default;"></div>
                                </div>

                                <div class="position-relative">
                                    <!-- South Section (Left) -->
                                    <div class="section-south">
                                        <span class="section-label vertical-label">Section: South</span>
                                        <% 
                                            List southSeats = (List) sectionSeats.get("South");
                                            if (southSeats == null) southSeats = new ArrayList();
                                            for (int i = 0; i < southSeats.size(); i++) {
                                                Seat s = (Seat) southSeats.get(i);
                                                boolean available = seatDAO.isSeatAvailable(eventId, s.getSeatId());
                                        %>
                                            <div class="seat-block <%= available ? "seat-available" : "seat-taken" %>" title="Section South | Row <%= s.getRowNo() %> Seat <%= s.getSeatNumber() %>">
                                                <% if (available) { %>
                                                    <input type="radio" name="seatId" value="<%= s.getSeatId() %>" class="seat-radio" required>
                                                    <div class="seat-visual"></div>
                                                <% } %>
                                            </div>
                                        <% } %>
                                    </div>

                                    <!-- The Pitch -->
                                    <div class="stadium-field">The Pitch</div>

                                    <!-- North Section (Right) -->
                                    <div class="section-north">
                                        <span class="section-label vertical-label">Section: North</span>
                                        <% 
                                            List northSeats = (List) sectionSeats.get("North");
                                            if (northSeats == null) northSeats = new ArrayList();
                                            for (int i = 0; i < northSeats.size(); i++) {
                                                Seat s = (Seat) northSeats.get(i);
                                                boolean available = seatDAO.isSeatAvailable(eventId, s.getSeatId());
                                        %>
                                            <div class="seat-block <%= available ? "seat-available" : "seat-taken" %>" title="Section North | Row <%= s.getRowNo() %> Seat <%= s.getSeatNumber() %>">
                                                <% if (available) { %>
                                                    <input type="radio" name="seatId" value="<%= s.getSeatId() %>" class="seat-radio" required>
                                                    <div class="seat-visual"></div>
                                                <% } %>
                                            </div>
                                        <% } %>
                                    </div>
                                </div>

                                <!-- West Section (Bottom) -->
                                <div class="section-west">
                                    <div class="seat-block seat-available mb-1" style="cursor: default;"></div>
                                    <span class="section-label">Section: West</span>
                                    <div class="d-flex flex-wrap justify-content-center">
                                        <% 
                                            List westSeats = (List) sectionSeats.get("West");
                                            if (westSeats == null) westSeats = new ArrayList();
                                            for (int i = 0; i < westSeats.size(); i++) {
                                                Seat s = (Seat) westSeats.get(i);
                                                boolean available = seatDAO.isSeatAvailable(eventId, s.getSeatId());
                                        %>
                                            <div class="seat-block <%= available ? "seat-available" : "seat-taken" %>" title="Section West | Row <%= s.getRowNo() %> Seat <%= s.getSeatNumber() %>">
                                                <% if (available) { %>
                                                    <input type="radio" name="seatId" value="<%= s.getSeatId() %>" class="seat-radio" required>
                                                    <div class="seat-visual"></div>
                                                <% } %>
                                            </div>
                                        <% } %>
                                    </div>
                                </div>
                                
                                <!-- Legend -->
                                <div class="mt-5 text-center">
                                    <div class="legend-item">
                                        <div class="legend-box" style="background-color: #fff; border: 1px solid #ddd;"></div>
                                        <span>Available</span>
                                    </div>
                                    <div class="legend-item">
                                        <div class="legend-box" style="background-color: #f1c40f;"></div>
                                        <span>Selected</span>
                                    </div>
                                    <div class="legend-item">
                                        <div class="legend-box" style="background-color: #8b4513;"></div>
                                        <span>Booked</span>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="mt-4 d-grid gap-2 d-md-flex justify-content-md-end">
                                <a href="dashboard.jsp" class="btn btn-outline-secondary px-4">Cancel</a>
                                <button type="submit" class="btn btn-primary px-5 btn-lg shadow-sm">Proceed to Payment</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
            
            <div class="col-lg-3">
                <div class="card shadow-sm border-0 h-100">
                    <div class="card-header bg-white">
                        <h5 class="mb-0">Event Summary</h5>
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <label class="text-muted small d-block">Event Name</label>
                            <span class="fw-bold fs-5"><%= event.getEventName() %></span>
                        </div>
                        <div class="mb-3">
                            <label class="text-muted small d-block">Tournament</label>
                            <% 
                                TournamentDAO tourDAO = new TournamentDAO();
                                List allTours = tourDAO.getAllTournaments();
                                String tourName = "General";
                                for (int i = 0; i < allTours.size(); i++) {
                                    Tournament t = (Tournament) allTours.get(i);
                                    if (t.getTournamentId() == event.getTournamentId()) {
                                        tourName = t.getTournamentName();
                                        break;
                                    }
                                }
                            %>
                            <span class="fw-bold"><%= tourName %></span>
                        </div>
                        <hr>
                        <div class="mb-3">
                            <label class="text-muted small d-block">Date & Time</label>
                            <span class="fw-bold"><i class="far fa-calendar-alt me-1"></i> <%= event.getEventDate() %></span><br>
                            <span class="fw-bold"><i class="far fa-clock me-1"></i> <%= event.getStartTime() %></span>
                        </div>
                        <hr>
                        <div class="mb-4">
                            <label class="text-muted small d-block">Ticket Price</label>
                            <span class="fw-bold text-primary fs-4">$150.00</span>
                        </div>
                        <div class="alert alert-info small border-0">
                            <i class="fas fa-info-circle me-1"></i> Please select a seat from the stadium layout to proceed.
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
