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
    int totalBookings = bookings == null ? 0 : bookings.size();
    int pendingCount = 0;
    int paidCount = 0;
    double totalSpent = 0.0;
    if (bookings != null) {
        for (int i = 0; i < bookings.size(); i++) {
            Booking b = (Booking) bookings.get(i);
            if ("PAID".equals(b.getStatus())) {
                paidCount++;
                totalSpent += b.getTotalAmount();
            } else if ("PENDING".equals(b.getStatus())) {
                pendingCount++;
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TikGate - My Bookings</title>
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
                radial-gradient(circle at 15% 8%, rgba(255, 107, 0, 0.11), transparent 28%),
                linear-gradient(135deg, #fffaf5 0%, #eef5ff 100%);
            color: var(--tg-ink);
            min-height: 100vh;
        }

        .bookings-shell {
            padding: 24px 4px 48px;
        }

        .bookings-hero {
            background:
                linear-gradient(135deg, rgba(15, 47, 117, 0.92), rgba(17, 24, 39, 0.96)),
                url("<%= request.getContextPath() %>/assets/homepage-banner.png");
            background-size: cover;
            background-position: center;
            border-radius: 22px;
            color: white;
            padding: 30px;
            box-shadow: 0 22px 54px rgba(17, 24, 39, 0.15);
            margin-bottom: 24px;
        }

        .bookings-hero h1 {
            font-size: clamp(1.8rem, 3vw, 3rem);
            font-weight: 900;
            margin: 0;
        }

        .bookings-hero p {
            color: rgba(255,255,255,0.78);
            max-width: 640px;
            margin: 8px 0 0;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 14px;
            margin-top: 24px;
        }

        .stat-tile {
            background: rgba(255,255,255,0.12);
            border: 1px solid rgba(255,255,255,0.22);
            border-radius: 16px;
            padding: 16px;
            backdrop-filter: blur(10px);
        }

        .stat-tile span {
            display: block;
            color: rgba(255,255,255,0.72);
            font-size: 0.8rem;
            font-weight: 800;
            text-transform: uppercase;
        }

        .stat-tile strong {
            display: block;
            font-size: 1.65rem;
            line-height: 1.1;
            margin-top: 4px;
        }

        .section-heading {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 14px;
            margin: 28px 0 16px;
        }

        .section-heading h2 {
            font-weight: 900;
            margin: 0;
        }

        .booking-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 20px;
        }

        .booking-card {
            border: 0;
            border-radius: 18px;
            overflow: hidden;
            background: white;
            box-shadow: 0 16px 38px rgba(17, 24, 39, 0.08);
            transition: transform 0.18s ease, box-shadow 0.18s ease;
        }

        .booking-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 22px 48px rgba(17, 24, 39, 0.12);
        }

        .booking-cover {
            height: 112px;
            background:
                linear-gradient(135deg, rgba(255, 107, 0, 0.2), rgba(15, 47, 117, 0.34)),
                linear-gradient(120deg, #0f2f75, #111827);
            position: relative;
            color: white;
            padding: 18px;
        }

        .booking-cover::after {
            content: "\f1e3";
            font-family: "Font Awesome 6 Free";
            font-weight: 900;
            position: absolute;
            right: 20px;
            bottom: 8px;
            font-size: 3.8rem;
            color: rgba(255,255,255,0.18);
        }

        .status-pill {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            border-radius: 999px;
            padding: 7px 11px;
            font-size: 0.75rem;
            font-weight: 900;
            text-transform: uppercase;
        }

        .status-paid {
            background: rgba(16, 185, 129, 0.16);
            color: #047857;
        }

        .status-pending {
            background: rgba(250, 204, 21, 0.22);
            color: #92400e;
        }

        .booking-id {
            color: rgba(255,255,255,0.78);
            font-weight: 800;
            position: relative;
            z-index: 1;
        }

        .booking-body {
            padding: 18px;
        }

        .booking-title {
            font-size: 1.1rem;
            font-weight: 900;
            min-height: 48px;
            margin-bottom: 12px;
        }

        .booking-meta {
            display: grid;
            gap: 9px;
            color: var(--tg-muted);
            font-weight: 700;
            font-size: 0.92rem;
            margin-bottom: 16px;
        }

        .booking-meta i {
            width: 18px;
            color: var(--tg-orange);
        }

        .amount-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-top: 1px solid #eef2f7;
            padding-top: 14px;
            margin-top: 12px;
        }

        .amount-row span {
            color: var(--tg-muted);
            font-weight: 800;
            font-size: 0.85rem;
        }

        .amount-row strong {
            color: #0d6efd;
            font-size: 1.35rem;
            font-weight: 900;
        }

        .booking-action {
            padding: 0 18px 18px;
        }

        .btn-booking-primary,
        .btn-booking-outline {
            border-radius: 999px;
            min-height: 44px;
            font-weight: 900;
        }

        .btn-booking-primary {
            background: var(--tg-orange);
            border: 0;
            color: white;
        }

        .btn-booking-primary:hover {
            background: #ea580c;
            color: white;
        }

        .btn-booking-outline {
            border: 1px solid var(--tg-orange);
            color: var(--tg-orange);
            background: white;
        }

        .btn-booking-outline:hover {
            background: var(--tg-soft);
            color: var(--tg-orange);
        }

        .empty-state {
            background: white;
            border: 1px solid var(--tg-line);
            border-radius: 20px;
            padding: 56px 20px;
            text-align: center;
            box-shadow: 0 16px 38px rgba(17, 24, 39, 0.08);
        }

        .empty-state i {
            color: var(--tg-orange);
            font-size: 3.6rem;
            margin-bottom: 18px;
        }

        @media (max-width: 1100px) {
            .booking-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-width: 768px) {
            .bookings-hero {
                padding: 22px;
            }

            .stats-grid,
            .booking-grid {
                grid-template-columns: 1fr;
            }

            .section-heading {
                align-items: start;
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
<jsp:include page="../includes/navbar.jsp" />

<main class="main-content">
    <div class="container-fluid bookings-shell">
        <section class="bookings-hero">
            <div class="d-flex flex-wrap justify-content-between gap-3 align-items-start">
                <div>
                    <h1>My Bookings</h1>
                    <p>Track pending payments, open your paid tickets, and keep every stadium booking in one place.</p>
                </div>
                <a href="dashboard.jsp#events" class="btn btn-light rounded-pill px-4 fw-bold"><i class="fas fa-magnifying-glass me-2"></i>Find Events</a>
            </div>

            <div class="stats-grid">
                <div class="stat-tile">
                    <span>Total Bookings</span>
                    <strong><%= totalBookings %></strong>
                </div>
                <div class="stat-tile">
                    <span>Pending Payment</span>
                    <strong><%= pendingCount %></strong>
                </div>
                <div class="stat-tile">
                    <span>Paid Amount</span>
                    <strong>RM<%= String.format("%.2f", totalSpent) %></strong>
                </div>
            </div>
        </section>

        <% if (bookings == null || bookings.isEmpty()) { %>
            <div class="empty-state">
                <i class="fas fa-ticket-alt"></i>
                <h3 class="fw-bold">No bookings found</h3>
                <p class="text-muted mb-4">You have not booked any tickets yet.</p>
                <a href="dashboard.jsp#events" class="btn btn-booking-primary px-4">Explore Events</a>
            </div>
        <% } else { %>
            <div class="section-heading">
                <div>
                    <h2>Recent Bookings</h2>
                    <p class="text-muted mb-0">Newest bookings appear first.</p>
                </div>
            </div>

            <div class="booking-grid">
                <% for (int i = 0; i < bookings.size(); i++) {
                    Booking b = (Booking) bookings.get(i);
                    EventDAO eventDAO = new EventDAO();
                    Event event = eventDAO.getEventById(b.getEventId());
                    TicketDAO ticketDAO = new TicketDAO();
                    Ticket ticket = ticketDAO.getTicketByBookingId(b.getBookingId());
                    boolean paid = "PAID".equals(b.getStatus());
                %>
                <article class="booking-card">
                    <div class="booking-cover">
                        <div class="d-flex justify-content-between align-items-start">
                            <span class="status-pill <%= paid ? "status-paid" : "status-pending" %>">
                                <i class="fas <%= paid ? "fa-check-circle" : "fa-clock" %>"></i>
                                <%= b.getStatus() %>
                            </span>
                            <span class="booking-id">#<%= b.getBookingId() %></span>
                        </div>
                    </div>
                    <div class="booking-body">
                        <h3 class="booking-title"><%= event != null ? event.getEventName() : "Unknown Event" %></h3>
                        <div class="booking-meta">
                            <div><i class="far fa-calendar-alt"></i><%= event != null ? event.getEventDate() : "N/A" %></div>
                            <div><i class="far fa-clock"></i><%= event != null ? event.getStartTime() : "N/A" %></div>
                            <div><i class="fas fa-receipt"></i>Booked on <%= b.getBookingDate() %></div>
                        </div>
                        <div class="amount-row">
                            <span>Total</span>
                            <strong>RM<%= String.format("%.2f", b.getTotalAmount()) %></strong>
                        </div>
                    </div>
                    <div class="booking-action">
                        <% if (paid && ticket != null) { %>
                            <a href="ticketDetails.jsp?qrCode=<%= ticket.getQrCode() %>" class="btn btn-booking-outline w-100">
                                <i class="fas fa-qrcode me-2"></i>View Ticket
                            </a>
                        <% } else if ("PENDING".equals(b.getStatus())) { %>
                            <a href="payment.jsp?bookingId=<%= b.getBookingId() %>" class="btn btn-booking-primary w-100">
                                <i class="fas fa-lock me-2"></i>Pay Now
                            </a>
                        <% } else { %>
                            <button class="btn btn-secondary w-100 rounded-pill" disabled>No Action Available</button>
                        <% } %>
                    </div>
                </article>
                <% } %>
            </div>
        <% } %>
    </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
