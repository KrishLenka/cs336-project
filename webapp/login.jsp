<%@ page import="java.sql.*, db.ApplicationDB" %>
<%-- 
    BuyMe Auction System - Login Page
    Handles login for users, customer reps, and admins
--%>
<% request.setAttribute("pageTitle", "Login"); %>
<%@ include file="includes/header.jsp" %>

<%
// If already logged in, redirect to appropriate dashboard
if (session.getAttribute("user") != null) {
    String userType = (String) session.getAttribute("userType");
    if ("admin".equals(userType)) {
        response.sendRedirect("admin/dashboard.jsp");
    } else if ("rep".equals(userType)) {
        response.sendRedirect("rep/dashboard.jsp");
    } else {
        response.sendRedirect("index.jsp");
    }
    return;
}

String error = request.getParameter("error");
String success = request.getParameter("success");
%>

<div class="container container-sm">
    <div class="page-header">
        <h1 class="page-title">Welcome Back</h1>
        <p class="page-subtitle">Sign in to your BuyMe account</p>
    </div>
    
    <% if (error != null) { %>
        <div class="alert alert-error">
            <% if ("invalid".equals(error)) { %>
                Invalid username or password. Please try again.
            <% } else if ("logout".equals(error)) { %>
                You have been logged out.
            <% } else { %>
                An error occurred. Please try again.
            <% } %>
        </div>
    <% } %>
    
    <% if (success != null) { %>
        <div class="alert alert-success">
            <% if ("registered".equals(success)) { %>
                Account created successfully! Please sign in.
            <% } %>
        </div>
    <% } %>
    
    <div class="card">
        <form action="authenticate.jsp" method="POST">
            <div class="form-group">
                <label class="form-label" for="username">Username</label>
                <input type="text" id="username" name="username" class="form-input" 
                       placeholder="Enter your username" required autofocus>
            </div>
            
            <div class="form-group">
                <label class="form-label" for="password">Password</label>
                <input type="password" id="password" name="password" class="form-input" 
                       placeholder="Enter your password" required>
            </div>
            
            <div class="form-group">
                <label class="form-label" for="userType">Account Type</label>
                <select id="userType" name="userType" class="form-select">
                    <option value="user">Regular User</option>
                    <option value="rep">Customer Representative</option>
                    <option value="admin">Administrator</option>
                </select>
            </div>
            
            <button type="submit" class="btn btn-primary btn-block btn-lg">Sign In</button>
        </form>
    </div>
    
    <div class="text-center mt-3">
        <p>Don't have an account? <a href="register.jsp">Create one here</a></p>
    </div>
</div>

<%@ include file="includes/footer.jsp" %>
