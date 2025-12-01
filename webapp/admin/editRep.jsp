<%@ page import="java.sql.*, db.ApplicationDB" %>
<%-- 
    BuyMe Auction System - Edit Rep Account (Admin)
--%>
<%
String userType = (String) session.getAttribute("userType");
if (!"admin".equals(userType)) {
    response.sendRedirect("../login.jsp");
    return;
}

String empId = request.getParameter("id");
if (empId == null) {
    response.sendRedirect("dashboard.jsp");
    return;
}
request.setAttribute("pageTitle", "Edit Rep");
%>
<%@ include file="../includes/header.jsp" %>

<div class="container container-md">
    <%
    ApplicationDB db = new ApplicationDB();
    Connection con = null;
    try {
        con = db.getConnection();
        
        PreparedStatement ps = con.prepareStatement(
            "SELECT s.* FROM Staff s JOIN CustomerRep cr ON s.emp_id = cr.emp_id WHERE s.emp_id = ?");
        ps.setString(1, empId);
        ResultSet rs = ps.executeQuery();
        
        if (rs.next()) {
    %>
    
    <div class="page-header">
        <h1 class="page-title">Edit Rep: <%= empId %></h1>
    </div>
    
    <div class="card">
        <form action="updateRep.jsp" method="POST">
            <input type="hidden" name="empId" value="<%= empId %>">
            
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Employee ID</label>
                    <input type="text" class="form-input" value="<%= empId %>" disabled>
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
            
            <div class="flex gap-2 mt-4">
                <button type="submit" class="btn btn-primary">Save Changes</button>
                <a href="dashboard.jsp" class="btn btn-secondary">Cancel</a>
            </div>
        </form>
    </div>
    
    <div class="card mt-4">
        <h3>Reset Password</h3>
        <form action="resetRepPassword.jsp" method="POST">
            <input type="hidden" name="empId" value="<%= empId %>">
            <div class="form-group">
                <label class="form-label" for="newPassword">New Password</label>
                <input type="password" id="newPassword" name="newPassword" class="form-input" 
                       minlength="6" required>
            </div>
            <button type="submit" class="btn btn-secondary">Reset Password</button>
        </form>
    </div>
    
    <div class="card mt-4">
        <h3 class="text-error">Delete Account</h3>
        <p class="text-muted">This action cannot be undone.</p>
        <form action="deleteRep.jsp" method="POST">
            <input type="hidden" name="empId" value="<%= empId %>">
            <button type="submit" class="btn btn-danger" 
                    onclick="return confirm('Are you sure you want to delete this rep account?')">
                Delete Rep Account
            </button>
        </form>
    </div>
    
    <%
        } else {
            out.println("<div class='alert alert-error'>Rep not found.</div>");
        }
    } finally {
        if (con != null) db.closeConnection(con);
    }
    %>
    
    <div class="mt-3">
        <a href="dashboard.jsp" class="btn btn-secondary">&larr; Back to Dashboard</a>
    </div>
</div>

<%@ include file="../includes/footer.jsp" %>

