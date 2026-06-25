<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>TikGate - Login</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body { background: linear-gradient(135deg, #2c3e50 0%, #3498db 100%); height: 100vh; display: flex; align-items: center; justify-content: center; }
        .login-card { width: 400px; border: none; border-radius: 15px; box-shadow: 0 15px 35px rgba(0,0,0,0.2); }
        .btn-primary { background-color: #3498db; border: none; padding: 12px; font-weight: bold; }
        .btn-primary:hover { background-color: #2980b9; }
    </style>
</head>
<body>

<div class="card login-card p-4">
    <div class="text-center mb-4">
        <img src="assets/logo.png" alt="TikGate Logo" style="max-width: 180px;">
        <h3 class="mt-3 fw-bold text-dark">Welcome Back</h3>
        <p class="text-muted">Sign in to your TikGate account</p>
    </div>

    <% if (request.getParameter("error") != null) { %>
        <div class="alert alert-danger text-center py-2 small">Invalid username or password</div>
    <% } %>

    <form action="login" method="post">
        <div class="mb-3">
            <label class="form-label text-muted small uppercase fw-bold">Username</label>
            <div class="input-group">
                <span class="input-group-text bg-light border-0"><i class="fas fa-user text-muted"></i></span>
                <input type="text" name="username" class="form-control bg-light border-0" placeholder="Enter username" required>
            </div>
        </div>
        <div class="mb-4">
            <label class="form-label text-muted small uppercase fw-bold">Password</label>
            <div class="input-group">
                <span class="input-group-text bg-light border-0"><i class="fas fa-lock text-muted"></i></span>
                <input type="password" name="password" class="form-control bg-light border-0" placeholder="Enter password" required>
            </div>
        </div>
        <div class="d-grid mb-3">
            <button type="submit" class="btn btn-primary">Sign In</button>
        </div>
        <div class="text-center">
            <p class="small text-muted mb-0">Don't have an account? <a href="register.jsp" class="text-decoration-none fw-bold">Register Now</a></p>
        </div>
    </form>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
