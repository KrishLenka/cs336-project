<%@ page import="java.sql.*, db.ApplicationDB" %>
<%-- 
    BuyMe Auction System - Customer Representative Dashboard
    Allows reps to manage users, auctions, and answer questions
--%>
<%
// Check if user is a customer rep
String userType = (String) session.getAttribute("userType");
if (!"rep".equals(userType)) {
    response.sendRedirect("../login.jsp");
    return;
}
String repId = (String) session.getAttribute("empId");
request.setAttribute("pageTitle", "Rep Dashboard");
%>
<%@ include file="../includes/header.jsp" %>

<div class="container">
    <div class="page-header">
        <h1 class="page-title">Customer Rep Dashboard</h1>
        <p class="page-subtitle">Welcome, <%= session.getAttribute("userName") %></p>
    </div>
    
    <!-- Quick Stats -->
    <div class="stats-grid">
        <%
        ApplicationDB db = new ApplicationDB();
        Connection con = null;
        try {
            con = db.getConnection();
            
            // Open questions
            Statement stmt = con.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT COUNT(*) as count FROM Question WHERE is_resolved = FALSE");
            int openQuestions = rs.next() ? rs.getInt("count") : 0;
            
            // Active auctions
            rs = stmt.executeQuery("SELECT COUNT(*) as count FROM Auction WHERE is_active = TRUE AND close_date > NOW()");
            int activeAuctions = rs.next() ? rs.getInt("count") : 0;
            
            // Active users
            rs = stmt.executeQuery("SELECT COUNT(*) as count FROM User WHERE is_active = TRUE");
            int activeUsers = rs.next() ? rs.getInt("count") : 0;
        %>
        <div class="stat-card">
            <div class="stat-value"><%= openQuestions %></div>
            <div class="stat-label">Open Questions</div>
        </div>
        <div class="stat-card">
            <div class="stat-value"><%= activeAuctions %></div>
            <div class="stat-label">Active Auctions</div>
        </div>
        <div class="stat-card">
            <div class="stat-value"><%= activeUsers %></div>
            <div class="stat-label">Active Users</div>
        </div>
        <%
        } finally {
            if (con != null) db.closeConnection(con);
        }
        %>
    </div>
    
    <div class="dashboard-grid">
        <!-- User Management -->
        <div class="col-6">
            <div class="card">
                <div class="card-header">
                    <h3 class="card-title">User Management</h3>
                </div>
                
                <form action="searchUser.jsp" method="GET" class="mb-3">
                    <div class="form-row">
                        <div class="form-group" style="flex: 2;">
                            <input type="text" name="query" class="form-input" placeholder="Search by username or email">
                        </div>
                        <div class="form-group">
                            <button type="submit" class="btn btn-primary">Search</button>
                        </div>
                    </div>
                </form>
                
                <div class="flex gap-2">
                    <a href="users.jsp" class="btn btn-secondary btn-sm">View All Users</a>
                    <a href="resetPassword.jsp" class="btn btn-secondary btn-sm">Reset Password</a>
                </div>
            </div>
        </div>
        
        <!-- Auction Management -->
        <div class="col-6">
            <div class="card">
                <div class="card-header">
                    <h3 class="card-title">Auction Management</h3>
                </div>
                
                <form action="searchAuction.jsp" method="GET" class="mb-3">
                    <div class="form-row">
                        <div class="form-group" style="flex: 2;">
                            <input type="text" name="query" class="form-input" placeholder="Search by auction ID or title">
                        </div>
                        <div class="form-group">
                            <button type="submit" class="btn btn-primary">Search</button>
                        </div>
                    </div>
                </form>
                
                <div class="flex gap-2">
                    <a href="auctions.jsp" class="btn btn-secondary btn-sm">View All Auctions</a>
                    <a href="removeBid.jsp" class="btn btn-secondary btn-sm">Remove Bid</a>
                </div>
            </div>
        </div>
        
        <!-- Open Questions -->
        <div class="col-12">
            <div class="card">
                <div class="card-header">
                    <h3 class="card-title">Open Customer Questions</h3>
                </div>
                
                <div class="table-wrapper">
                    <table>
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>User</th>
                                <th>Subject</th>
                                <th>Created</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                            ApplicationDB db2 = new ApplicationDB();
                            Connection con2 = null;
                            try {
                                con2 = db2.getConnection();
                                PreparedStatement ps = con2.prepareStatement(
                                    "SELECT q.*, u.first_name, u.last_name FROM Question q " +
                                    "JOIN User u ON q.user_id = u.user_id " +
                                    "WHERE q.is_resolved = FALSE ORDER BY q.created_at ASC LIMIT 10");
                                ResultSet rs2 = ps.executeQuery();
                                
                                boolean hasQuestions = false;
                                while (rs2.next()) {
                                    hasQuestions = true;
                            %>
                            <tr>
                                <td>#<%= rs2.getInt("question_id") %></td>
                                <td><%= rs2.getString("first_name") %> <%= rs2.getString("last_name") %></td>
                                <td><%= rs2.getString("subject") %></td>
                                <td class="text-muted"><%= rs2.getTimestamp("created_at") %></td>
                                <td>
                                    <a href="answerQuestion.jsp?id=<%= rs2.getInt("question_id") %>" 
                                       class="btn btn-sm btn-primary">Answer</a>
                                </td>
                            </tr>
                            <%
                                }
                                if (!hasQuestions) {
                            %>
                            <tr><td colspan="5" class="text-center text-muted">No open questions</td></tr>
                            <% }
                            } finally {
                                if (con2 != null) db2.closeConnection(con2);
                            }
                            %>
                        </tbody>
                    </table>
                </div>
                
                <div class="mt-3">
                    <a href="questions.jsp" class="btn btn-secondary btn-sm">View All Questions</a>
                </div>
            </div>
        </div>
    </div>
</div>

<%@ include file="../includes/footer.jsp" %>

