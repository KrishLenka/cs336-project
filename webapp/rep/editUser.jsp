<%@ page import="java.sql.*, db.ApplicationDB" %>
<%-- 
    BuyMe Auction System - Edit User (Rep)
--%>
<%
String userType = (String) session.getAttribute("userType");
if (!"rep".equals(userType)) {
    response.sendRedirect("../login.jsp");
    return;
}

String userId = request.getParameter("id");
if (userId == null) {
    response.sendRedirect("users.jsp");
    return;
}
request.setAttribute("pageTitle", "Edit User");
String error = request.getParameter("error");
%>
<%@ include file="../includes/header.jsp" %>

<div class="container container-md">
    <div class="page-header">
        <h1 class="page-title">Edit User</h1>
    </div>
    
    <% if (error != null) { %>
        <div class="alert alert-error">An error occurred. Please try again.</div>
    <% } %>
    
    <%
    ApplicationDB db = new ApplicationDB();
    Connection con = null;
    try {
        con = db.getConnection();
        
        PreparedStatement ps = con.prepareStatement("SELECT * FROM User WHERE user_id = ?");
        ps.setString(1, userId);
        ResultSet rs = ps.executeQuery();
        
        if (rs.next()) {
    %>
    
    <div class="card">
        <form action="updateUser.jsp" method="POST">
            <input type="hidden" name="userId" value="<%= userId %>">
            
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Username</label>
                    <input type="text" class="form-input" value="<%= rs.getString("user_id") %>" disabled>
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
            
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label" for="phone">Phone</label>
                    <input type="tel" id="phone" name="phone" class="form-input" 
                           value="<%= rs.getString("phone") %>" required>
                </div>
                <div class="form-group">
                    <label class="form-label" for="isActive">Account Status</label>
                    <select id="isActive" name="isActive" class="form-select">
                        <option value="true" <%= rs.getBoolean("is_active") ? "selected" : "" %>>Active</option>
                        <option value="false" <%= !rs.getBoolean("is_active") ? "selected" : "" %>>Inactive</option>
                    </select>
                </div>
            </div>
            
            <div class="flex gap-2 mt-4">
                <button type="submit" class="btn btn-primary">Save Changes</button>
                <a href="users.jsp" class="btn btn-secondary">Cancel</a>
            </div>
        </form>
    </div>
    
    <div class="card mt-4">
        <h3>Reset Password</h3>
        <form action="doResetPassword.jsp" method="POST">
            <input type="hidden" name="userId" value="<%= userId %>">
            <div class="form-group">
                <label class="form-label" for="newPassword">New Password</label>
                <input type="password" id="newPassword" name="newPassword" class="form-input" 
                       minlength="6" required>
            </div>
            <button type="submit" class="btn btn-secondary" 
                    onclick="return confirm('Reset password for this user?')">Reset Password</button>
        </form>
    </div>
    
    <%
        } else {
            out.println("<div class='alert alert-error'>User not found.</div>");
        }
    } finally {
        if (con != null) db.closeConnection(con);
    }
    %>
    
    <div class="mt-3">
        <a href="users.jsp" class="btn btn-secondary">&larr; Back to Users</a>
    </div>
</div>

<%@ include file="../includes/footer.jsp" %>

