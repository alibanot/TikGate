<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>TikGate - Register</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body { background: linear-gradient(135deg, #2c3e50 0%, #3498db 100%); height: 100vh; display: flex; align-items: center; justify-content: center; }
        .register-card { width: 500px; border: none; border-radius: 15px; box-shadow: 0 15px 35px rgba(0,0,0,0.2); }
        .btn-primary { background-color: #3498db; border: none; padding: 12px; font-weight: bold; }
    </style>
</head>
<body>

<div class="card register-card p-4">
    <div class="text-center mb-4">
        <h3 class="fw-bold text-dark">Create Account</h3>
        <p class="text-muted">Join TikGate today</p>
    </div>

    <form action="register" method="post">
        <div class="row">
            <div class="col-md-6 mb-3">
                <label class="form-label text-muted small fw-bold">Full Name</label>
                <input type="text" name="fullName" class="form-control bg-light border-0" placeholder="John Doe" required>
            </div>
            <div class="col-md-6 mb-3">
                <label class="form-label text-muted small fw-bold">Username</label>
                <input type="text" name="username" class="form-control bg-light border-0" placeholder="johndoe" required>
            </div>
        </div>
        <div class="mb-3">
            <label class="form-label text-muted small fw-bold">Email Address</label>
            <input type="email" name="email" class="form-control bg-light border-0" placeholder="john@example.com" required>
        </div>
        <div class="mb-3">
            <label class="form-label text-muted small fw-bold">Phone Number</label>
            <input type="text" name="phone" class="form-control bg-light border-0" placeholder="0123456789" required>
        </div>
        <div class="mb-4">
            <label class="form-label text-muted small fw-bold">Password</label>
            <input type="password" name="password" class="form-control bg-light border-0" placeholder="••••••••" required>
        </div>
        <div class="d-grid mb-3">
            <button type="submit" class="btn btn-primary">Create Account</button>
        </div>
        <div class="text-center">
            <p class="small text-muted mb-0">Already have an account? <a href="login.jsp" class="text-decoration-none fw-bold">Sign In</a></p>
        </div>
    </form>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
