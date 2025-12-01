<%@ page import="java.sql.*, db.ApplicationDB" %>
<%-- 
    BuyMe Auction System - Create Customer Rep Account (Admin)
--%>
<%
String userType = (String) session.getAttribute("userType");
if (!"admin".equals(userType)) {
    response.sendRedirect("../login.jsp");
    return;
}
request.setAttribute("pageTitle", "Create Rep Account");
String error = request.getParameter("error");
%>
<%@ include file="../includes/header.jsp" %>

<div class="container container-md">
    <div class="page-header">
        <h1 class="page-title">Create Customer Rep Account</h1>
    </div>
    
    <% if (error != null) { %>
        <div class="alert alert-error">
            <% if ("exists".equals(error)) { %>Employee ID already exists.<% } %>
            <% if ("invalid".equals(error)) { %>Please fill in all fields correctly.<% } %>
            <% else { %>An error occurred. Please try again.<% } %>
        </div>
    <% } %>
    
    <div class="card">
        <form action="doCreateRep.jsp" method="POST">
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label" for="empId">Employee ID *</label>
                    <input type="text" id="empId" name="empId" class="form-input" 
                           pattern="[a-zA-Z0-9_]{3,15}" required>
                    <span class="form-hint">3-15 characters, alphanumeric</span>
                </div>
                <div class="form-group">
                    <label class="form-label" for="password">Password *</label>
                    <input type="password" id="password" name="password" class="form-input" 
                           minlength="6" required>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label" for="firstName">First Name *</label>
                    <input type="text" id="firstName" name="firstName" class="form-input" required>
                </div>
                <div class="form-group">
                    <label class="form-label" for="lastName">Last Name *</label>
                    <input type="text" id="lastName" name="lastName" class="form-input" required>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label" for="email">Email *</label>
                    <input type="email" id="email" name="email" class="form-input" required>
                </div>
                <div class="form-group">
                    <label class="form-label" for="phone">Phone *</label>
                    <input type="tel" id="phone" name="phone" class="form-input" required>
                </div>
            </div>
            
            <div class="form-group">
                <label class="form-label" for="dob">Date of Birth *</label>
                <input type="date" id="dob" name="dob" class="form-input" required>
            </div>
            
            <div class="flex gap-2 mt-4">
                <button type="submit" class="btn btn-primary">Create Account</button>
                <a href="dashboard.jsp" class="btn btn-secondary">Cancel</a>
            </div>
        </form>
    </div>
</div>

<%@ include file="../includes/footer.jsp" %>

