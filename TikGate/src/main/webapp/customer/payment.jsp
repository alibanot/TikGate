<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.tikgate.model.*, com.tikgate.dao.*" %>
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
    int bookingIdInt = Integer.parseInt(bookingId);
    BookingDAO bookingDAO = new BookingDAO();
    Booking booking = bookingDAO.getBookingById(bookingIdInt);
    double totalAmount = booking != null ? booking.getTotalAmount() : 0.00;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TikGate - Payment</title>
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
                radial-gradient(circle at 18% 12%, rgba(255, 107, 0, 0.12), transparent 28%),
                linear-gradient(135deg, #fffaf5 0%, #eef5ff 100%);
            color: var(--tg-ink);
            min-height: 100vh;
        }

        .payment-shell {
            max-width: 920px;
            margin: 22px auto;
        }

        .gateway-card {
            border: 0;
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 24px 70px rgba(17, 24, 39, 0.14);
            background: white;
        }

        .gateway-left {
            background:
                linear-gradient(145deg, rgba(15, 47, 117, 0.92), rgba(17, 24, 39, 0.96)),
                url("<%= request.getContextPath() %>/assets/homepage-app-slide.png");
            background-size: cover;
            background-position: center;
            color: white;
            padding: 24px;
            min-height: 100%;
            position: relative;
        }

        .gateway-left::after {
            content: "";
            position: absolute;
            inset: 0;
            background: linear-gradient(180deg, transparent, rgba(0,0,0,0.18));
            pointer-events: none;
        }

        .gateway-left > * {
            position: relative;
            z-index: 1;
        }

        .secure-pill {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 7px 11px;
            border-radius: 999px;
            background: rgba(255,255,255,0.12);
            border: 1px solid rgba(255,255,255,0.22);
            font-weight: 800;
            font-size: 0.86rem;
            margin-bottom: 18px;
        }

        .gateway-left h1 {
            font-size: 2rem;
            font-weight: 900;
            line-height: 1.05;
            margin-bottom: 10px;
        }

        .gateway-left p {
            color: rgba(255,255,255,0.78);
            margin-bottom: 22px;
            font-size: 0.92rem;
        }

        .amount-box {
            background: rgba(255,255,255,0.12);
            border: 1px solid rgba(255,255,255,0.22);
            border-radius: 16px;
            padding: 16px;
            backdrop-filter: blur(12px);
        }

        .amount-box label {
            color: rgba(255,255,255,0.72);
            font-size: 0.82rem;
            text-transform: uppercase;
            font-weight: 800;
        }

        .amount-box strong {
            display: block;
            font-size: 2rem;
            line-height: 1;
            margin-top: 8px;
        }

        .gateway-main {
            padding: 24px 28px;
        }

        .gateway-title {
            display: flex;
            justify-content: space-between;
            gap: 16px;
            align-items: start;
            margin-bottom: 16px;
        }

        .gateway-title h2 {
            font-size: 1.75rem;
            font-weight: 900;
            margin: 0;
        }

        .booking-chip {
            background: var(--tg-soft);
            color: #9a3412;
            border: 1px solid var(--tg-line);
            border-radius: 999px;
            padding: 7px 11px;
            font-weight: 900;
            white-space: nowrap;
        }

        .method-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 12px;
            margin-bottom: 14px;
        }

        .method-option {
            border: 1px solid #e5e7eb;
            border-radius: 14px;
            padding: 11px 12px;
            font-weight: 900;
            display: flex;
            align-items: center;
            gap: 10px;
            cursor: pointer;
            background: #fff;
        }

        .method-option input {
            accent-color: var(--tg-orange);
        }

        .method-option:has(input:checked) {
            border-color: var(--tg-orange);
            background: var(--tg-soft);
        }

        .form-label {
            font-weight: 800;
            color: #1f2937;
        }

        .form-control,
        .form-select {
            min-height: 44px;
            border-radius: 12px;
            border-color: #dbe3ef;
            font-weight: 700;
        }

        .form-control:focus,
        .form-select:focus {
            border-color: var(--tg-orange);
            box-shadow: 0 0 0 0.2rem rgba(255, 107, 0, 0.14);
        }

        .card-preview {
            border-radius: 16px;
            background: linear-gradient(135deg, #111827, #0f2f75);
            color: white;
            padding: 18px;
            margin: 14px 0 16px;
            min-height: 124px;
            box-shadow: 0 18px 42px rgba(15, 47, 117, 0.25);
        }

        .card-preview-number {
            letter-spacing: 0.12em;
            font-size: 1.05rem;
            margin-top: 20px;
            font-weight: 800;
        }

        .pay-button {
            min-height: 48px;
            border: 0;
            border-radius: 999px;
            background: var(--tg-orange);
            color: white;
            font-weight: 900;
            box-shadow: 0 14px 32px rgba(255, 107, 0, 0.25);
        }

        .pay-button:hover {
            background: #ea580c;
            color: white;
        }

        .fine-print {
            color: var(--tg-muted);
            font-size: 0.82rem;
            text-align: center;
            margin-top: 10px;
        }

        @media (max-width: 768px) {
            .payment-shell {
                margin: 14px auto;
            }

            .gateway-left,
            .gateway-main {
                padding: 20px;
            }

            .method-grid {
                grid-template-columns: 1fr;
            }

            .gateway-title {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
<jsp:include page="../includes/navbar.jsp" />

<main class="main-content">
    <div class="container-fluid">
        <div class="payment-shell">
            <% if (error != null) { %>
                <div class="alert alert-danger border-0 shadow-sm"><%= error.replace("_", " ") %></div>
            <% } %>

            <div class="gateway-card">
                <div class="row g-0">
                    <div class="col-lg-5">
                        <aside class="gateway-left h-100">
                            <div class="secure-pill"><i class="fas fa-shield-halved"></i> Mock secure gateway</div>
                            <h1>Complete your TikGate payment.</h1>
                            <p>This is a simulated payment gateway for testing your booking flow. No real card will be charged.</p>

                            <div class="amount-box mb-3">
                                <label>Total payable</label>
                                <strong>RM<%= String.format("%.2f", totalAmount) %></strong>
                            </div>

                            <div class="d-flex justify-content-between small text-white-50">
                                <span>Booking #<%= bookingId %></span>
                                <span><%= booking != null ? booking.getStatus() : "PENDING" %></span>
                            </div>
                        </aside>
                    </div>

                    <div class="col-lg-7">
                        <section class="gateway-main">
                            <div class="gateway-title">
                                <div>
                                    <h2>Payment Method</h2>
                                    <p class="text-muted mb-0 small">Choose any option below to continue the mock checkout.</p>
                                </div>
                                <div class="booking-chip">#<%= bookingId %></div>
                            </div>

                            <form action="../processPayment" method="post">
                                <input type="hidden" name="bookingId" value="<%= bookingId %>">

                                <div class="method-grid">
                                    <label class="method-option">
                                        <input type="radio" name="paymentMethod" value="Credit Card" checked>
                                        <i class="fas fa-credit-card"></i>
                                        Card
                                    </label>
                                    <label class="method-option">
                                        <input type="radio" name="paymentMethod" value="Online Banking">
                                        <i class="fas fa-building-columns"></i>
                                        FPX
                                    </label>
                                    <label class="method-option">
                                        <input type="radio" name="paymentMethod" value="E-Wallet">
                                        <i class="fas fa-wallet"></i>
                                        Wallet
                                    </label>
                                </div>

                                <div class="card-preview">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <strong>TikGate Pay</strong>
                                        <i class="fas fa-wifi"></i>
                                    </div>
                                    <div class="card-preview-number" id="cardPreview">XXXX XXXX XXXX XXXX</div>
                                    <div class="d-flex justify-content-between mt-3 small text-white-50">
                                        <span><%= user.getFullName() %></span>
                                        <span id="expiryPreview">MM/YY</span>
                                    </div>
                                </div>

                                <div class="mb-2">
                                    <label class="form-label">Card Number</label>
                                    <input type="text" class="form-control" id="cardNumber" placeholder="4242 4242 4242 4242" inputmode="numeric" maxlength="19" required>
                                </div>

                                <div class="row g-2">
                                    <div class="col-md-6">
                                        <label class="form-label">Expiry</label>
                                        <input type="text" class="form-control" id="expiry" placeholder="MM/YY" maxlength="5" required>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label">CVV</label>
                                        <input type="password" class="form-control" placeholder="123" maxlength="4" inputmode="numeric" required>
                                    </div>
                                </div>

                                <button type="submit" class="btn pay-button w-100 mt-3">
                                    <i class="fas fa-lock me-2"></i>Pay RM<%= String.format("%.2f", totalAmount) %>
                                </button>
                                <div class="fine-print">Mock payment only. Use any test card details to continue.</div>
                            </form>
                        </section>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    const cardNumber = document.getElementById('cardNumber');
    const cardPreview = document.getElementById('cardPreview');
    const expiry = document.getElementById('expiry');
    const expiryPreview = document.getElementById('expiryPreview');

    cardNumber.addEventListener('input', function () {
        const digits = cardNumber.value.replace(/\D/g, '').slice(0, 16);
        cardNumber.value = digits.replace(/(.{4})/g, '$1 ').trim();
        cardPreview.textContent = cardNumber.value || 'XXXX XXXX XXXX XXXX';
    });

    expiry.addEventListener('input', function () {
        const digits = expiry.value.replace(/\D/g, '').slice(0, 4);
        expiry.value = digits.length > 2 ? digits.slice(0, 2) + '/' + digits.slice(2) : digits;
        expiryPreview.textContent = expiry.value || 'MM/YY';
    });
</script>
</body>
</html>
