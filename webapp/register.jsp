<%@ page import="java.sql.*, db.ApplicationDB" %>
<%-- 
    BuyMe Auction System - Registration Page
    Allows new users to create buyer/seller accounts
--%>
<% request.setAttribute("pageTitle", "Register"); %>
<%@ include file="includes/header.jsp" %>

<%
// If already logged in, redirect
if (session.getAttribute("user") != null) {
    response.sendRedirect("index.jsp");
    return;
}

String error = request.getParameter("error");
%>

<div class="container container-md">
    <div class="page-header">
        <h1 class="page-title">Create Your Account</h1>
        <p class="page-subtitle">Join BuyMe to buy and sell electronics</p>
    </div>
    
    <% if (error != null) { %>
        <div class="alert alert-error">
            <% if ("exists".equals(error)) { %>
                Username or email already exists. Please choose different ones.
            <% } else if ("password".equals(error)) { %>
                Passwords do not match. Please try again.
            <% } else if ("invalid".equals(error)) { %>
                Please fill in all required fields correctly.
            <% } else { %>
                An error occurred. Please try again.
            <% } %>
        </div>
    <% } %>
    
    <div class="card">
        <div class="card-header">
            <h3 class="card-title">Account Information</h3>
        </div>
        
        <form action="processRegistration.jsp" method="POST">
            <!-- Basic Info -->
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
                    <label class="form-label" for="username">Username *</label>
                    <input type="text" id="username" name="username" class="form-input" 
                           pattern="[a-zA-Z0-9_]{3,15}" required>
                    <span class="form-hint">3-15 characters, letters, numbers, underscore only</span>
                </div>
                <div class="form-group">
                    <label class="form-label" for="email">Email Address *</label>
                    <input type="email" id="email" name="email" class="form-input" required>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label" for="password">Password *</label>
                    <input type="password" id="password" name="password" class="form-input" 
                           minlength="6" required>
                    <span class="form-hint">Minimum 6 characters</span>
                </div>
                <div class="form-group">
                    <label class="form-label" for="confirmPassword">Confirm Password *</label>
                    <input type="password" id="confirmPassword" name="confirmPassword" class="form-input" required>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label" for="phone">Phone Number *</label>
                    <input type="tel" id="phone" name="phone" class="form-input" required>
                </div>
                <div class="form-group">
                    <label class="form-label" for="dob">Date of Birth *</label>
                    <input type="date" id="dob" name="dob" class="form-input" required>
                </div>
            </div>
            
            <!-- Account Type Selection -->
            <div class="form-group">
                <label class="form-label">I want to:</label>
                <div class="checkbox-group">
                    <label class="checkbox-label">
                        <input type="checkbox" name="isBuyer" value="true" checked>
                        Buy items (Buyer account)
                    </label>
                    <label class="checkbox-label">
                        <input type="checkbox" name="isSeller" value="true" checked>
                        Sell items (Seller account)
                    </label>
                </div>
                <span class="form-hint">You can be both a buyer and a seller</span>
            </div>
            
            <!-- Buyer Info (shown if buyer selected) -->
            <div id="buyerFields">
                <h4 class="mt-4 mb-2">Buyer Information</h4>
                <div class="form-group">
                    <label class="form-label" for="shippingAddress">Shipping Address *</label>
                    <textarea id="shippingAddress" name="shippingAddress" class="form-textarea" 
                              rows="2" placeholder="Street, City, State, ZIP"></textarea>
                </div>
                <div class="form-group">
                    <label class="form-label" for="cardNumber">Default Payment Card *</label>
                    <input type="text" id="cardNumber" name="cardNumber" class="form-input" 
                           placeholder="Card number (for demo purposes)">
                    <span class="form-hint">For demonstration only - not real payment processing</span>
                </div>
            </div>
            
            <div class="mt-4">
                <button type="submit" class="btn btn-primary btn-block btn-lg">Create Account</button>
            </div>
        </form>
    </div>
    
    <div class="text-center mt-3">
        <p>Already have an account? <a href="login.jsp">Sign in here</a></p>
    </div>
</div>

<script>
// Toggle buyer fields visibility based on checkbox
document.querySelector('input[name="isBuyer"]').addEventListener('change', function() {
    document.getElementById('buyerFields').style.display = this.checked ? 'block' : 'none';
    const inputs = document.querySelectorAll('#buyerFields input, #buyerFields textarea');
    inputs.forEach(input => input.required = this.checked);
});
</script>

<%@ include file="includes/footer.jsp" %>

