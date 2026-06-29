<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.tikgate.model.*, com.tikgate.dao.*, com.tikgate.util.SecurityUtil, java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || user.getRoleId() != 2) {
        response.sendRedirect("../login.jsp");
        return;
    }
    EventDAO eventDAO = new EventDAO();
    List events = eventDAO.getActiveEvents();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TikGate - Customer Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --tg-orange: #ff6b00;
            --tg-ink: #111827;
            --tg-muted: #64748b;
            --tg-soft: #fff7ed;
            --tg-line: #f1e2d6;
        }

        body {
            background: #fffaf5;
            color: var(--tg-ink);
            font-family: Arial, sans-serif;
        }

        .main-content {
            margin-left: 0;
            padding: 0;
        }

        .customer-shell {
            padding: 24px;
        }

        .hero-carousel {
            border-radius: 18px;
            overflow: hidden;
            box-shadow: 0 18px 45px rgba(17, 24, 39, 0.12);
        }

        .hero-slide {
            min-height: 430px;
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
            isolation: isolate;
            background-size: cover;
            background-position: center;
        }

        .hero-slide::before {
            content: "";
            position: absolute;
            inset: 0;
            background: linear-gradient(90deg, rgba(9, 18, 34, 0.78), rgba(9, 18, 34, 0.42));
            z-index: -1;
        }

        .hero-football {
            background-image: url("<%= request.getContextPath() %>/assets/homepage-banner.png");
            background-position: center;
            background-size: cover;
        }

        .hero-finals {
            background-image: url("<%= request.getContextPath() %>/assets/homepage-app-slide.png");
            background-position: center;
            background-size: cover;
        }

        .hero-family {
            background:
                linear-gradient(135deg, rgba(255, 107, 0, 0.24), rgba(234, 179, 8, 0.22)),
                radial-gradient(circle at 70% 35%, rgba(255, 255, 255, 0.22) 0 10%, transparent 11%),
                linear-gradient(120deg, #7c2d12 0%, #c2410c 45%, #111827 100%);
        }

        .hero-content {
            width: min(780px, 90%);
            text-align: center;
            color: white;
            padding: 42px 20px;
        }

        .hero-kicker {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 8px 14px;
            border: 1px solid rgba(255,255,255,0.28);
            border-radius: 999px;
            font-size: 0.88rem;
            font-weight: 700;
            margin-bottom: 18px;
            backdrop-filter: blur(10px);
        }

        .hero-content h1 {
            font-size: clamp(2.1rem, 4vw, 4rem);
            font-weight: 800;
            line-height: 1.03;
            margin-bottom: 16px;
        }

        .hero-content p {
            color: rgba(255,255,255,0.86);
            font-size: 1.08rem;
            margin: 0 auto 28px;
            max-width: 620px;
        }

        .btn-find-event {
            background: var(--tg-orange);
            border: 0;
            color: white;
            border-radius: 999px;
            padding: 13px 26px;
            font-weight: 800;
            box-shadow: 0 12px 30px rgba(255, 107, 0, 0.32);
        }

        .btn-find-event:hover {
            background: #ea580c;
            color: white;
        }

        .section-heading {
            display: flex;
            justify-content: space-between;
            align-items: end;
            gap: 16px;
            margin: 34px 0 18px;
        }

        .section-heading h2 {
            font-weight: 800;
            margin: 0;
        }

        .section-heading p {
            color: var(--tg-muted);
            margin: 4px 0 0;
        }

        .event-grid {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 24px;
        }

        .event-card {
            border: 0;
            border-radius: 16px;
            overflow: hidden;
            background: white;
            box-shadow: 0 12px 34px rgba(17, 24, 39, 0.08);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .event-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 18px 42px rgba(17, 24, 39, 0.12);
        }

        .event-poster {
            height: 190px;
            background:
                linear-gradient(135deg, rgba(255, 107, 0, 0.24), rgba(22, 101, 52, 0.18)),
                linear-gradient(120deg, #14532d, #0f172a);
            position: relative;
        }

        .event-poster::after {
            content: "\f1e3";
            font-family: "Font Awesome 6 Free";
            font-weight: 900;
            position: absolute;
            right: 22px;
            bottom: 14px;
            color: rgba(255,255,255,0.35);
            font-size: 4rem;
        }

        .event-card:nth-child(4n+2) .event-poster {
            background:
                linear-gradient(135deg, rgba(255, 107, 0, 0.22), rgba(37, 99, 235, 0.18)),
                linear-gradient(120deg, #1d4ed8, #111827);
        }

        .event-card:nth-child(4n+3) .event-poster {
            background:
                linear-gradient(135deg, rgba(255, 107, 0, 0.24), rgba(234, 179, 8, 0.18)),
                linear-gradient(120deg, #b45309, #111827);
        }

        .event-card:nth-child(4n+4) .event-poster {
            background:
                linear-gradient(135deg, rgba(255, 107, 0, 0.2), rgba(20, 184, 166, 0.18)),
                linear-gradient(120deg, #0f766e, #111827);
        }

        .event-body {
            padding: 18px;
        }

        .event-date {
            color: #5b6f9b;
            font-size: 0.9rem;
            font-weight: 700;
        }

        .event-title {
            font-size: 1.05rem;
            font-weight: 800;
            min-height: 50px;
            margin: 8px 0;
        }

        .event-desc {
            color: var(--tg-muted);
            font-size: 0.92rem;
            min-height: 44px;
        }

        .event-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            padding: 0 18px 18px;
        }

        .event-price {
            font-size: 0.9rem;
            color: var(--tg-ink);
            font-weight: 800;
        }

        .btn-book {
            background: var(--tg-orange);
            color: white;
            border-radius: 999px;
            padding: 9px 18px;
            font-size: 0.9rem;
            font-weight: 800;
            text-decoration: none;
            white-space: nowrap;
        }

        .btn-book:hover {
            background: #ea580c;
            color: white;
        }

        @media (max-width: 1100px) {
            .event-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-width: 768px) {
            .customer-shell {
                padding: 16px;
            }

            .hero-slide {
                min-height: 360px;
            }

            .event-grid {
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
    <div class="customer-shell">
        <div id="eventHero" class="carousel slide hero-carousel" data-bs-ride="carousel">
            <div class="carousel-indicators">
                <button type="button" data-bs-target="#eventHero" data-bs-slide-to="0" class="active" aria-current="true" aria-label="Slide 1"></button>
                <button type="button" data-bs-target="#eventHero" data-bs-slide-to="1" aria-label="Slide 2"></button>
                <button type="button" data-bs-target="#eventHero" data-bs-slide-to="2" aria-label="Slide 3"></button>
            </div>
            <div class="carousel-inner">
                <div class="carousel-item active">
                    <section class="hero-slide hero-football">
                        <div class="hero-content">
                            <div class="hero-kicker"><i class="fas fa-bolt"></i> Live football tickets</div>
                            <h1>Book your next stadium moment.</h1>
                            <p>Find football matches, reserve your seat, and keep your digital ticket ready for match day.</p>
                            <a href="#events" class="btn btn-find-event"><i class="fas fa-magnifying-glass me-2"></i>Find Events</a>
                        </div>
                    </section>
                </div>
                <div class="carousel-item">
                    <section class="hero-slide hero-finals">
                        <div class="hero-content">
                            <div class="hero-kicker"><i class="fas fa-trophy"></i> Tournament finals</div>
                            <h1>Seats for the biggest nights.</h1>
                            <p>Browse upcoming fixtures and choose the section that fits your match-day plan.</p>
                            <a href="#events" class="btn btn-find-event"><i class="fas fa-magnifying-glass me-2"></i>Find Events</a>
                        </div>
                    </section>
                </div>
                <div class="carousel-item">
                    <section class="hero-slide hero-family">
                        <div class="hero-content">
                            <div class="hero-kicker"><i class="fas fa-ticket"></i> Easy digital entry</div>
                            <h1>From booking to gate, all in one place.</h1>
                            <p>Manage bookings, payment, and QR tickets from your TikGate customer dashboard.</p>
                            <a href="#events" class="btn btn-find-event"><i class="fas fa-magnifying-glass me-2"></i>Find Events</a>
                        </div>
                    </section>
                </div>
            </div>
            <button class="carousel-control-prev" type="button" data-bs-target="#eventHero" data-bs-slide="prev">
                <span class="carousel-control-prev-icon" aria-hidden="true"></span>
                <span class="visually-hidden">Previous</span>
            </button>
            <button class="carousel-control-next" type="button" data-bs-target="#eventHero" data-bs-slide="next">
                <span class="carousel-control-next-icon" aria-hidden="true"></span>
                <span class="visually-hidden">Next</span>
            </button>
        </div>

        <section id="events">
            <div class="section-heading">
                <div>
                    <h2>Find Events</h2>
                    <p>All available matches and stadium events are listed here.</p>
                </div>
                <a href="#events" class="btn btn-outline-dark rounded-pill px-4"><i class="fas fa-calendar-days me-2"></i><%= events.size() %> Events</a>
            </div>

            <div class="event-grid">
                <% for (int i = 0; i < events.size(); i++) {
                    Event e = (Event) events.get(i);
                    String description = e.getDescription() == null ? "Reserve your seat and get ready for match day." : e.getDescription();
                    if (description.length() > 86) {
                        description = description.substring(0, 83) + "...";
                    }
                %>
                <article class="event-card">
                    <div class="event-poster"></div>
                    <div class="event-body">
                        <div class="event-date"><i class="far fa-calendar me-1"></i><%= e.getEventDate() %> <span class="ms-2"><i class="far fa-clock me-1"></i><%= SecurityUtil.escapeHtml(e.getStartTime()) %></span></div>
                        <h3 class="event-title"><%= SecurityUtil.escapeHtml(e.getEventName()) %></h3>
                        <p class="event-desc"><%= SecurityUtil.escapeHtml(description) %></p>
                    </div>
                    <div class="event-footer">
                        <span class="event-price">From RM150.00</span>
                        <a href="bookEvent.jsp?id=<%= e.getEventId() %>" class="btn-book">Book Now</a>
                    </div>
                </article>
                <% } %>
            </div>
        </section>
    </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
