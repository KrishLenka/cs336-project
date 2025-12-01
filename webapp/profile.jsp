<%@ page import="java.sql.*, db.ApplicationDB" %>
<%-- 
    BuyMe Auction System - User Profile Page
--%>
<%
String currentUser = (String) session.getAttribute("user");
if (currentUser == null) {
    response.sendRedirect("login.jsp");
    return;
}
request.setAttribute("pageTitle", "My Profile");
String message = request.getParameter("msg");
%>
<%@ include file="includes/header.jsp" %>

<div class="container container-md">
    <div class="page-header">
        <h1 class="page-title">My Profile</h1>
    </div>
    
    <% if (message != null) { %>
        <div class="alert alert-success">Profile updated successfully!</div>
    <% } %>
    
    <%
    ApplicationDB db = new ApplicationDB();
    Connection con = null;
    try {
        con = db.getConnection();
        
        PreparedStatement ps = con.prepareStatement("SELECT * FROM User WHERE user_id = ?");
        ps.setString(1, currentUser);
        ResultSet rs = ps.executeQuery();
        
        if (rs.next()) {
            // Check buyer/seller status
            PreparedStatement buyerPs = con.prepareStatement("SELECT * FROM Buyer WHERE buyer_id = ?");
            buyerPs.setString(1, currentUser);
            ResultSet buyerRs = buyerPs.executeQuery();
            boolean isBuyer = buyerRs.next();
            String shippingAddress = isBuyer ? buyerRs.getString("shipping_address") : "";
            String cardNumber = isBuyer ? buyerRs.getString("default_card") : "";
            
            PreparedStatement sellerPs = con.prepareStatement("SELECT * FROM Seller WHERE seller_id = ?");
            sellerPs.setString(1, currentUser);
            ResultSet sellerRs = sellerPs.executeQuery();
            boolean isSeller = sellerRs.next();
    %>
    
    <div class="card">
        <div class="card-header">
            <h3 class="card-title">Account Information</h3>
        </div>
        
        <form action="updateProfile.jsp" method="POST">
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Username</label>
                    <input type="text" class="form-input" value="<%= currentUser %>" disabled>
                </div>
                <div class="form-group">
                    <label class="form-label" for="email">Email</label>
                    <input type="email" id="email" name="email" class="form-input" 
                           value="<%= rs.getString("email") %>" required>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label" for="firstName">First Name</label>
                    <input type="text" id="firstName" name="firstName" class="form-input" 
                           value="<%= rs.getString("first_name") %>" required>
                </div>
                <div class="form-group">
                    <label class="form-label" for="lastName">Last Name</label>
                    <input type="text" id="lastName" name="lastName" class="form-input" 
                           value="<%= rs.getString("last_name") %>" required>
                </div>
            </div>
            
            <div class="form-group">
                <label class="form-label" for="phone">Phone</label>
                <input type="tel" id="phone" name="phone" class="form-input" 
                       value="<%= rs.getString("phone") %>" required>
            </div>
            
            <% if (isBuyer) { %>
            <h4 class="mt-4 mb-2">Buyer Information</h4>
            <div class="form-group">
                <label class="form-label" for="shippingAddress">Shipping Address</label>
                <textarea id="shippingAddress" name="shippingAddress" class="form-textarea"><%= shippingAddress %></textarea>
            </div>
            <div class="form-group">
                <label class="form-label" for="cardNumber">Default Payment Card</label>
                <input type="text" id="cardNumber" name="cardNumber" class="form-input" value="<%= cardNumber %>">
            </div>
            <% } %>
            
            <button type="submit" class="btn btn-primary mt-4">Save Changes</button>
        </form>
    </div>
    
    <div class="card mt-4">
        <h3>Change Password</h3>
        <form action="changePassword.jsp" method="POST">
            <div class="form-group">
                <label class="form-label" for="currentPassword">Current Password</label>
                <input type="password" id="currentPassword" name="currentPassword" class="form-input" required>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label" for="newPassword">New Password</label>
                    <input type="password" id="newPassword" name="newPassword" class="form-input" minlength="6" required>
                </div>
                <div class="form-group">
                    <label class="form-label" for="confirmPassword">Confirm New Password</label>
                    <input type="password" id="confirmPassword" name="confirmPassword" class="form-input" required>
                </div>
            </div>
            <button type="submit" class="btn btn-secondary">Change Password</button>
        </form>
    </div>
    
    <div class="card mt-4">
        <h3>Account Type</h3>
        <p>
            <% if (isBuyer) { %><span class="badge badge-info">Buyer</span> <% } %>
            <% if (isSeller) { %><span class="badge badge-success">Seller</span> <% } %>
        </p>
        <% if (!isSeller) { %>
        <form action="becomeSeller.jsp" method="POST">
            <p class="text-muted">Want to sell items? Become a seller!</p>
            <button type="submit" class="btn btn-secondary">Become a Seller</button>
        </form>
        <% } %>
        <% if (!isBuyer) { %>
        <form action="becomeBuyer.jsp" method="POST">
            <p class="text-muted">Want to buy items? Create a buyer profile!</p>
            <button type="submit" class="btn btn-secondary">Become a Buyer</button>
        </form>
        <% } %>
    </div>
    
    <%
        }
    } catch (Exception e) {
        out.println("<div class='alert alert-error'>Error: " + e.getMessage() + "</div>");
    } finally {
        if (con != null) db.closeConnection(con);
    }
    %>
</div>

<%@ include file="includes/footer.jsp" %>

