<%@ page import="com.tikgate.model.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
    String contextPath = request.getContextPath();
    String currentRole = (currentUser != null) ? (currentUser.getRoleId() == 1 ? "ADMIN" : (currentUser.getRoleId() == 3 ? "STAFF" : "CUSTOMER")) : "";

    String homeUrl = contextPath + "/index.jsp";
    if (currentUser != null) {
        if (currentUser.getRoleId() == 1) homeUrl = contextPath + "/admin/dashboard.jsp";
        else if (currentUser.getRoleId() == 3) homeUrl = contextPath + "/staff/verification.jsp";
        else if (currentUser.getRoleId() == 2) homeUrl = contextPath + "/customer/dashboard.jsp";
    }
%>
<style>
    .top-app-nav {
        position: sticky;
        top: 0;
        z-index: 1030;
        background: rgba(255, 255, 255, 0.96);
        border-bottom: 1px solid #f1e2d6;
        box-shadow: 0 8px 26px rgba(17, 24, 39, 0.06);
        backdrop-filter: blur(12px);
    }

    .top-app-nav .navbar-brand {
        color: #ff6b00;
        font-weight: 900;
        letter-spacing: -0.02em;
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .top-app-nav .navbar-brand img {
        height: 34px;
        width: auto;
    }

    .top-app-nav .nav-link {
        color: #111827;
        font-weight: 700;
        border-radius: 999px;
        padding: 10px 14px;
    }

    .top-app-nav .nav-link:hover,
    .top-app-nav .nav-link.active {
        color: #ff6b00;
        background: #fff7ed;
    }

    .top-search-link {
        min-width: min(460px, 40vw);
        border: 1px solid #f1e2d6;
        background: #fff7ed;
        color: #1f2a44;
        border-radius: 999px;
        padding: 11px 18px;
        text-decoration: none;
        display: flex;
        align-items: center;
        gap: 10px;
        font-weight: 700;
    }

    .top-search-link:hover {
        color: #ff6b00;
        border-color: #ffb47a;
    }

    .logout-pill {
        background: #ff6b00;
        color: white !important;
        border-radius: 999px;
        padding-left: 18px !important;
        padding-right: 18px !important;
    }

    .logout-pill:hover {
        background: #ea580c !important;
        color: white !important;
    }

    .main-content {
        margin-left: 0;
        padding: 20px;
        transition: 0.3s;
    }

    @media (max-width: 991px) {
        .top-search-link {
            min-width: 100%;
            margin: 12px 0;
        }
    }
</style>

<nav class="navbar navbar-expand-lg top-app-nav">
    <div class="container-fluid px-4">
        <a class="navbar-brand" href="<%= homeUrl %>">
            <img src="<%= contextPath %>/assets/logo.png" alt="TikGate">
            <span>TikGate</span>
        </a>

        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#topNavigation" aria-controls="topNavigation" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="topNavigation">
            <% if (currentUser != null && currentUser.getRoleId() == 2) { %>
                <a class="top-search-link mx-lg-4" href="<%= contextPath %>/customer/dashboard.jsp#events">
                    <i class="fas fa-magnifying-glass"></i>
                    <span>Find Events</span>
                </a>
            <% } %>

            <ul class="navbar-nav ms-auto align-items-lg-center gap-lg-2">
                <% if (currentUser != null) { %>
                    <% if (currentUser.getRoleId() == 1 || currentUser.getRoleId() == 3) { %>
                        <li class="nav-item">
                            <a class="nav-link" href="<%= contextPath %>/<%= currentUser.getRoleId() == 1 ? "admin" : "staff" %>/dashboard.jsp">
                                <i class="fas fa-tachometer-alt me-1"></i>Dashboard
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="<%= contextPath %>/admin/manageEvents.jsp">
                                <i class="fas fa-calendar-check me-1"></i>Events
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="<%= contextPath %>/admin/manageTournaments.jsp">
                                <i class="fas fa-trophy me-1"></i>Tournaments
                            </a>
                        </li>
                        <% if (currentUser.getRoleId() == 1) { %>
                            <li class="nav-item">
                                <a class="nav-link" href="<%= contextPath %>/admin/reports.jsp">
                                    <i class="fas fa-chart-line me-1"></i>Reports
                                </a>
                            </li>
                        <% } %>
                        <li class="nav-item">
                            <a class="nav-link" href="<%= contextPath %>/staff/verification.jsp">
                                <i class="fas fa-qrcode me-1"></i>Verify
                            </a>
                        </li>
                    <% } else if (currentUser.getRoleId() == 2) { %>
                        <li class="nav-item">
                            <a class="nav-link" href="<%= contextPath %>/customer/dashboard.jsp">
                                <i class="fas fa-house me-1"></i>Home
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="<%= contextPath %>/customer/bookings.jsp">
                                <i class="fas fa-ticket-alt me-1"></i>My Bookings
                            </a>
                        </li>
                    <% } %>
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                            <i class="fas fa-user-circle me-1"></i><%= currentUser.getFullName() %>
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end">
                            <li><span class="dropdown-item-text small text-muted"><%= currentRole %></span></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item text-danger" href="<%= contextPath %>/logout"><i class="fas fa-sign-out-alt me-2"></i>Logout</a></li>
                        </ul>
                    </li>
                <% } else { %>
                    <li class="nav-item">
                        <a class="nav-link" href="<%= contextPath %>/login.jsp">Login</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link logout-pill" href="<%= contextPath %>/register.jsp">Register</a>
                    </li>
                <% } %>
            </ul>
        </div>
    </div>
</nav>
