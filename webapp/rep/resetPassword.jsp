<%@ page import="java.sql.*, db.ApplicationDB" %>
<%
String userType = (String) session.getAttribute("userType");
if (!"rep".equals(userType)) {
    response.sendRedirect("../login.jsp");
    return;
}
request.setAttribute("pageTitle", "Reset Password");
String message = request.getParameter("msg");
String error = request.getParameter("error");
%>
<%@ include file="../includes/header.jsp" %>

<div class="container container-sm">
    <div class="page-header">
        <h1 class="page-title">Reset User Password</h1>
    </div>
    
    <% if ("success".equals(message)) { %>
        <div class="alert alert-success">Password reset successfully!</div>
    <% } %>
    <% if ("notfound".equals(error)) { %>
        <div class="alert alert-error">User not found.</div>
    <% } %>
    
    <div class="card">
        <form action="doResetPasswordByUsername.jsp" method="POST">
            <div class="form-group">
                <label class="form-label" for="userId">Username</label>
                <input type="text" id="userId" name="userId" class="form-input" required>
            </div>
            <div class="form-group">
                <label class="form-label" for="newPassword">New Password</label>
                <input type="password" id="newPassword" name="newPassword" class="form-input" minlength="6" required>
            </div>
            <button type="submit" class="btn btn-primary">Reset Password</button>
        </form>
    </div>
    
    <div class="mt-3">
        <a href="dashboard.jsp" class="btn btn-secondary">&larr; Back to Dashboard</a>
    </div>
</div>

<%@ include file="../includes/footer.jsp" %>

