<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Verification Result - TikGate</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
</head>
<body>
<jsp:include page="../includes/navbar.jsp" />
<div class="main-content">
<div class="container-fluid mt-5 text-center">
    <div class="card mx-auto" style="max-width: 500px;">
        <div class="card-body">
            <h3>Verification Result</h3>
            <hr>
            <div class="alert alert-info">
                <%= request.getAttribute("message") %>
            </div>
            <a href="verification.jsp" class="btn btn-primary">Scan Another Ticket</a>
        </div>
    </div>
</div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
