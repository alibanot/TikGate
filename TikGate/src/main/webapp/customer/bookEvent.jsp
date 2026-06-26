<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.tikgate.model.*, com.tikgate.dao.*, java.util.*" %>
<%!
    private String renderSeatSection(String sectionName, String sectionCode, Map sectionRows, SeatDAO seatDAO, int eventId) {
        StringBuilder html = new StringBuilder();
        html.append("<section class=\"seat-section\">");
        html.append("<div class=\"section-heading\"><strong>").append(sectionCode).append("</strong><span>").append(sectionName).append("</span></div>");

        Map rows = (Map) sectionRows.get(sectionName);
        if (rows == null || rows.isEmpty()) {
            html.append("<div class=\"empty-section\">No seats</div>");
            html.append("</section>");
            return html.toString();
        }

        int renderedRows = 0;
        Iterator rowIterator = rows.keySet().iterator();
        while (rowIterator.hasNext() && renderedRows < 3) {
            String rowNo = (String) rowIterator.next();
            List rowSeats = (List) rows.get(rowNo);
            html.append("<div class=\"seat-row\">");
            html.append("<span class=\"row-name\">Row ").append(rowNo).append("</span>");
            html.append("<div class=\"seat-dots\">");

            for (int i = 0; i < rowSeats.size(); i++) {
                Seat s = (Seat) rowSeats.get(i);
                boolean available = seatDAO.isSeatAvailable(eventId, s.getSeatId());
                String label = s.getRowNo() + s.getSeatNumber();
                html.append("<label class=\"seat-label").append(available ? "" : " seat-booked").append("\" title=\"")
                    .append(sectionName).append(" | Row ").append(s.getRowNo()).append(" Seat ").append(s.getSeatNumber()).append("\">");
                if (available) {
                    html.append("<input type=\"checkbox\" name=\"seatIds\" value=\"").append(s.getSeatId())
                        .append("\" class=\"seat-input\" data-seat=\"").append(sectionCode).append(" ").append(label).append("\">");
                }
                html.append("<span class=\"seat-face\">").append(label).append("</span>");
                html.append("</label>");
            }

            html.append("</div></div>");
            renderedRows++;
        }

        html.append("</section>");
        return html.toString();
    }
%>
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
    Map sectionRows = new LinkedHashMap();
    for (int i = 0; i < seats.size(); i++) {
        Seat s = (Seat) seats.get(i);
        String section = s.getSectionName();
        String row = s.getRowNo();
        if (!sectionRows.containsKey(section)) {
            sectionRows.put(section, new LinkedHashMap());
        }
        Map rows = (Map) sectionRows.get(section);
        if (!rows.containsKey(row)) {
            rows.put(row, new ArrayList());
        }
        ((List) rows.get(row)).add(s);
    }

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

    double ticketPrice = 150.00;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TikGate - Book Event</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --tg-orange: #ff6b00;
            --tg-ink: #111827;
            --tg-muted: #64748b;
            --tg-field: #2f8f3a;
            --tg-seat: #f8fafc;
            --tg-selected: #facc15;
            --tg-booked: #92400e;
            --tg-blue: #2446ff;
        }

        body {
            background: #fffaf5;
            color: var(--tg-ink);
        }

        .booking-header {
            display: flex;
            justify-content: space-between;
            align-items: end;
            gap: 18px;
            margin-bottom: 18px;
        }

        .booking-header h1 {
            font-size: clamp(1.5rem, 2.4vw, 2.15rem);
            font-weight: 900;
            margin: 0;
        }

        .booking-header p {
            color: var(--tg-muted);
            margin: 6px 0 0;
        }

        .stadium-card,
        .summary-card {
            border: 0;
            border-radius: 18px;
            box-shadow: 0 18px 42px rgba(17, 24, 39, 0.08);
            overflow: hidden;
        }

        .stadium-card .card-header {
            background: white;
            border-bottom: 1px solid #f1e2d6;
            padding: 16px 20px;
        }

        .stadium-wrap {
            background: #ffffff;
            border: 1px solid #e5e7eb;
            border-radius: 24px;
            max-width: 820px;
            margin: 0 auto;
            padding: 18px;
        }

        .stadium-map {
            position: relative;
            display: grid;
            grid-template-columns: 178px minmax(260px, 1fr) 178px;
            grid-template-rows: auto 220px auto;
            grid-template-areas:
                ". north ."
                "west pitch east"
                ". south .";
            gap: 12px;
            align-items: center;
        }

        .pitch {
            grid-area: pitch;
            min-height: 218px;
            border: 10px solid var(--tg-blue);
            border-radius: 18px;
            background:
                linear-gradient(90deg, rgba(255,255,255,0.12) 1px, transparent 1px),
                linear-gradient(0deg, rgba(255,255,255,0.12) 1px, transparent 1px),
                repeating-linear-gradient(90deg, #2f8f3a 0 28px, #277d34 28px 56px);
            background-size: 48px 48px, 48px 48px, auto;
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            text-align: center;
            box-shadow: inset 0 0 0 2px rgba(255,255,255,0.35);
        }

        .pitch strong {
            font-size: clamp(1.35rem, 3vw, 2.5rem);
            letter-spacing: 0.16em;
            text-transform: uppercase;
            text-shadow: 0 2px 10px rgba(0,0,0,0.35);
        }

        .north-zone { grid-area: north; }
        .south-zone { grid-area: south; }
        .east-zone { grid-area: east; }
        .west-zone { grid-area: west; }

        .seat-zone {
            display: grid;
            gap: 8px;
        }

        .seat-section {
            background: #f8fafc;
            border: 1px solid #e5e7eb;
            border-radius: 14px;
            padding: 8px;
            box-shadow: inset 0 0 0 1px rgba(255,255,255,0.7);
        }

        .section-heading {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 8px;
            margin-bottom: 7px;
            font-size: 0.72rem;
            text-transform: uppercase;
        }

        .section-heading strong {
            color: white;
            background: var(--tg-orange);
            border-radius: 999px;
            padding: 4px 8px;
            letter-spacing: 0.04em;
        }

        .section-heading span {
            color: var(--tg-muted);
            font-weight: 800;
        }

        .seat-row {
            display: grid;
            grid-template-columns: 44px 1fr;
            align-items: center;
            gap: 6px;
            margin-bottom: 5px;
        }

        .seat-row:last-child {
            margin-bottom: 0;
        }

        .row-name {
            color: var(--tg-muted);
            font-size: 0.7rem;
            font-weight: 900;
            text-align: right;
            white-space: nowrap;
        }

        .seat-dots {
            display: flex;
            flex-wrap: wrap;
            gap: 5px;
        }

        .seat-label {
            margin: 0;
            position: relative;
        }

        .seat-input {
            position: absolute;
            opacity: 0;
            pointer-events: none;
        }

        .seat-face {
            width: 26px;
            height: 24px;
            border-radius: 7px 7px 9px 9px;
            background: var(--tg-seat);
            color: #172554;
            border: 1px solid #d1d5db;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.56rem;
            font-weight: 900;
            line-height: 1;
            cursor: pointer;
            box-shadow: inset 0 -3px 0 rgba(15, 23, 42, 0.1);
            transition: transform 0.15s ease, background 0.15s ease, border-color 0.15s ease;
        }

        .seat-face:hover {
            transform: translateY(-2px);
            border-color: var(--tg-orange);
        }

        .seat-input:checked + .seat-face {
            background: var(--tg-selected);
            border-color: #f59e0b;
            color: #422006;
            transform: translateY(-2px);
        }

        .seat-booked .seat-face {
            background: var(--tg-booked);
            color: #fff7ed;
            cursor: not-allowed;
            opacity: 0.78;
        }

        .seat-booked .seat-face:hover {
            transform: none;
            border-color: #d1d5db;
        }

        .empty-section {
            color: var(--tg-muted);
            font-size: 0.8rem;
            text-align: center;
            padding: 12px;
        }

        .legend-row {
            display: flex;
            flex-wrap: wrap;
            justify-content: center;
            gap: 16px;
            margin-top: 16px;
        }

        .legend-item {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            color: var(--tg-muted);
            font-weight: 800;
            font-size: 0.85rem;
        }

        .legend-box {
            width: 18px;
            height: 18px;
            border-radius: 6px;
            border: 1px solid #d1d5db;
        }

        .summary-card {
            position: sticky;
            top: 92px;
        }

        .summary-card .card-header {
            background: #111827;
            color: white;
            border-bottom: 0;
            padding: 18px;
        }

        .summary-list {
            display: flex;
            flex-direction: column;
            gap: 8px;
            min-height: 44px;
            max-height: 170px;
            overflow: auto;
            padding: 12px;
            background: #fff7ed;
            border-radius: 12px;
            color: #9a3412;
            font-size: 0.9rem;
            font-weight: 800;
        }

        .summary-total {
            color: #0d6efd;
            font-size: 2rem;
            font-weight: 900;
        }

        .btn-pay {
            background: var(--tg-orange);
            border: 0;
            color: white;
            border-radius: 999px;
            font-weight: 900;
            padding: 12px 24px;
        }

        .btn-pay:hover {
            background: #ea580c;
            color: white;
        }

        @media (max-width: 991px) {
            .booking-header {
                align-items: start;
                flex-direction: column;
            }

            .stadium-map {
                grid-template-columns: 1fr;
                grid-template-rows: auto;
                grid-template-areas:
                    "north"
                    "west"
                    "pitch"
                    "east"
                    "south";
            }

            .pitch {
                min-height: 180px;
            }

            .summary-card {
                position: static;
                margin-top: 18px;
            }
        }
    </style>
</head>
<body>
<jsp:include page="../includes/navbar.jsp" />

<div class="main-content">
    <div class="container-fluid">
        <div class="booking-header">
            <div>
                <h1>Choose Your Seats</h1>
                <p><%= event.getEventName() %> | <%= event.getEventDate() %> | <%= event.getStartTime() %></p>
            </div>
            <span class="badge rounded-pill text-bg-dark px-3 py-2"><i class="fas fa-ticket me-1"></i> RM<%= String.format("%.2f", ticketPrice) %> per seat</span>
        </div>

        <% if (request.getParameter("error") != null) { %>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <%= "seat_taken".equals(request.getParameter("error")) ? "Sorry, one of those seats was just taken. Please choose again." : "Booking failed. Please try again." %>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <% } %>

        <form action="../bookTicket" method="post" id="bookingForm">
            <input type="hidden" name="eventId" value="<%= eventId %>">
            <input type="hidden" name="price" value="<%= String.format("%.2f", ticketPrice) %>">

            <div class="row g-4">
                <div class="col-xl-9">
                    <div class="card stadium-card">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <div>
                                <h5 class="mb-1 fw-bold">Stadium Seat Map</h5>
                                <div class="text-muted small">Compact view: North/South have 3 longer rows, East/West stay compact.</div>
                            </div>
                            <a href="dashboard.jsp" class="btn btn-outline-secondary rounded-pill">Back</a>
                        </div>
                        <div class="card-body bg-light p-3 p-lg-4">
                            <div class="stadium-wrap">
                                <div class="stadium-map">
                                    <div class="seat-zone north-zone">
                                        <%= renderSeatSection("North", "N1", sectionRows, seatDAO, eventId) %>
                                    </div>

                                    <div class="seat-zone west-zone">
                                        <%= renderSeatSection("West", "W1", sectionRows, seatDAO, eventId) %>
                                    </div>

                                    <div class="pitch">
                                        <strong>The Pitch</strong>
                                    </div>

                                    <div class="seat-zone east-zone">
                                        <%= renderSeatSection("East", "E1", sectionRows, seatDAO, eventId) %>
                                    </div>

                                    <div class="seat-zone south-zone">
                                        <%= renderSeatSection("South", "S1", sectionRows, seatDAO, eventId) %>
                                    </div>
                                </div>

                                <div class="legend-row">
                                    <div class="legend-item"><span class="legend-box" style="background:#f8fafc;"></span> Available</div>
                                    <div class="legend-item"><span class="legend-box" style="background:#facc15;"></span> Selected</div>
                                    <div class="legend-item"><span class="legend-box" style="background:#92400e;"></span> Booked</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-xl-3">
                    <div class="card summary-card">
                        <div class="card-header">
                            <h5 class="mb-0 fw-bold">Booking Summary</h5>
                        </div>
                        <div class="card-body">
                            <div class="mb-3">
                                <label class="text-muted small d-block">Event Name</label>
                                <span class="fw-bold fs-5"><%= event.getEventName() %></span>
                            </div>
                            <div class="mb-3">
                                <label class="text-muted small d-block">Tournament</label>
                                <span class="fw-bold"><%= tourName %></span>
                            </div>
                            <hr>
                            <div class="mb-3">
                                <label class="text-muted small d-block">Date & Time</label>
                                <span class="fw-bold"><i class="far fa-calendar-alt me-1"></i> <%= event.getEventDate() %></span><br>
                                <span class="fw-bold"><i class="far fa-clock me-1"></i> <%= event.getStartTime() %></span>
                            </div>
                            <hr>
                            <div class="mb-3">
                                <label class="text-muted small d-block">Selected Seats</label>
                                <div class="summary-list" id="selectedSeats">No seats selected</div>
                            </div>
                            <div class="d-flex justify-content-between mb-2">
                                <span class="text-muted">Quantity</span>
                                <strong><span id="seatCount">0</span> seat(s)</strong>
                            </div>
                            <div class="d-flex justify-content-between mb-3">
                                <span class="text-muted">Price per seat</span>
                                <strong>RM<%= String.format("%.2f", ticketPrice) %></strong>
                            </div>
                            <label class="text-muted small d-block">Total Amount</label>
                            <div class="summary-total mb-4">RM<span id="totalAmount">0.00</span></div>
                            <div class="alert alert-info small border-0" id="seatHelp">
                                <i class="fas fa-info-circle me-1"></i> Select at least one seat to proceed.
                            </div>
                            <div class="d-grid gap-2">
                                <button type="submit" class="btn btn-pay btn-lg" id="submitBooking" disabled>
                                    Proceed to Payment
                                </button>
                                <a href="dashboard.jsp" class="btn btn-outline-secondary rounded-pill">Cancel</a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    const ticketPrice = <%= String.format(java.util.Locale.US, "%.2f", ticketPrice) %>;
    const bookingForm = document.getElementById('bookingForm');
    const selectedSeats = document.getElementById('selectedSeats');
    const seatCount = document.getElementById('seatCount');
    const totalAmount = document.getElementById('totalAmount');
    const submitBooking = document.getElementById('submitBooking');
    const seatHelp = document.getElementById('seatHelp');
    const seatInputs = Array.from(document.querySelectorAll('.seat-input'));

    function updateSummary() {
        const checkedSeats = seatInputs.filter(input => input.checked);
        seatCount.textContent = checkedSeats.length;
        totalAmount.textContent = (checkedSeats.length * ticketPrice).toFixed(2);
        submitBooking.disabled = checkedSeats.length === 0;

        if (checkedSeats.length === 0) {
            selectedSeats.textContent = 'No seats selected';
            seatHelp.className = 'alert alert-info small border-0';
            seatHelp.innerHTML = '<i class="fas fa-info-circle me-1"></i> Select at least one seat to proceed.';
            return;
        }

        selectedSeats.innerHTML = checkedSeats
            .map(input => '<span><i class="fas fa-chair me-1"></i>' + input.dataset.seat + '</span>')
            .join('');
        seatHelp.className = 'alert alert-success small border-0';
        seatHelp.innerHTML = '<i class="fas fa-check-circle me-1"></i> Ready for payment.';
    }

    seatInputs.forEach(input => input.addEventListener('change', updateSummary));

    bookingForm.addEventListener('submit', function(event) {
        if (!seatInputs.some(input => input.checked)) {
            event.preventDefault();
            seatHelp.className = 'alert alert-warning small border-0';
            seatHelp.innerHTML = '<i class="fas fa-exclamation-circle me-1"></i> Please choose at least one seat.';
        }
    });

    updateSummary();
</script>
</body>
</html>
