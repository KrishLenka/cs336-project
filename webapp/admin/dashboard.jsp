<%@ page import="java.sql.*, db.ApplicationDB" %>
<%-- 
    BuyMe Auction System - Admin Dashboard
    Provides admin functions: rep management and sales reports
--%>
<%
// Check if user is admin
String userType = (String) session.getAttribute("userType");
if (!"admin".equals(userType)) {
    response.sendRedirect("../login.jsp");
    return;
}
request.setAttribute("pageTitle", "Admin Dashboard");
%>
<%@ include file="../includes/header.jsp" %>

<div class="container">
    <div class="page-header">
        <h1 class="page-title">Admin Dashboard</h1>
        <p class="page-subtitle">Welcome, <%= session.getAttribute("userName") %></p>
    </div>
    
    <!-- Quick Stats -->
    <div class="stats-grid">
        <%
        ApplicationDB db = new ApplicationDB();
        Connection con = null;
        try {
            con = db.getConnection();
            Statement stmt = con.createStatement();
            
            // Total revenue
            ResultSet rs = stmt.executeQuery("SELECT COALESCE(SUM(final_price), 0) as total FROM Sale");
            double totalRevenue = rs.next() ? rs.getDouble("total") : 0;
            
            // Total sales count
            rs = stmt.executeQuery("SELECT COUNT(*) as count FROM Sale");
            int salesCount = rs.next() ? rs.getInt("count") : 0;
            
            // Customer reps
            rs = stmt.executeQuery("SELECT COUNT(*) as count FROM CustomerRep");
            int repCount = rs.next() ? rs.getInt("count") : 0;
            
            // Active auctions
            rs = stmt.executeQuery("SELECT COUNT(*) as count FROM Auction WHERE is_active = TRUE AND close_date > NOW()");
            int activeAuctions = rs.next() ? rs.getInt("count") : 0;
        %>
        <div class="stat-card">
            <div class="stat-value">$<%= String.format("%.2f", totalRevenue) %></div>
            <div class="stat-label">Total Revenue</div>
        </div>
        <div class="stat-card">
            <div class="stat-value"><%= salesCount %></div>
            <div class="stat-label">Completed Sales</div>
        </div>
        <div class="stat-card">
            <div class="stat-value"><%= repCount %></div>
            <div class="stat-label">Customer Reps</div>
        </div>
        <div class="stat-card">
            <div class="stat-value"><%= activeAuctions %></div>
            <div class="stat-label">Active Auctions</div>
        </div>
        <%
        } finally {
            if (con != null) db.closeConnection(con);
        }
        %>
    </div>
    
    <div class="dashboard-grid">
        <!-- Rep Management -->
        <div class="col-6">
            <div class="card">
                <div class="card-header">
                    <h3 class="card-title">Customer Representative Management</h3>
                </div>
                
                <a href="createRep.jsp" class="btn btn-primary mb-3">+ Create New Rep Account</a>
                
                <h4>Current Representatives</h4>
                <div class="table-wrapper">
                    <table>
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Name</th>
                                <th>Email</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                            ApplicationDB db2 = new ApplicationDB();
                            Connection con2 = null;
                            try {
                                con2 = db2.getConnection();
                                Statement stmt2 = con2.createStatement();
                                ResultSet rs2 = stmt2.executeQuery(
                                    "SELECT s.* FROM Staff s JOIN CustomerRep cr ON s.emp_id = cr.emp_id");
                                
                                while (rs2.next()) {
                            %>
                            <tr>
                                <td><%= rs2.getString("emp_id") %></td>
                                <td><%= rs2.getString("first_name") %> <%= rs2.getString("last_name") %></td>
                                <td><%= rs2.getString("email") %></td>
                                <td>
                                    <a href="editRep.jsp?id=<%= rs2.getString("emp_id") %>" 
                                       class="btn btn-sm btn-secondary">Edit</a>
                                </td>
                            </tr>
                            <% }
                            } finally {
                                if (con2 != null) db2.closeConnection(con2);
                            }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        
        <!-- Quick Reports -->
        <div class="col-6">
            <div class="card">
                <div class="card-header">
                    <h3 class="card-title">Sales Reports</h3>
                </div>
                
                <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 0.5rem;">
                    <a href="reports.jsp?type=total" class="btn btn-secondary btn-sm">Total Earnings</a>
                    <a href="reports.jsp?type=item" class="btn btn-secondary btn-sm">By Item</a>
                    <a href="reports.jsp?type=itemtype" class="btn btn-secondary btn-sm">By Item Type</a>
                    <a href="reports.jsp?type=user" class="btn btn-secondary btn-sm">By End-User</a>
                    <a href="reports.jsp?type=bestselling" class="btn btn-secondary btn-sm">Best-Selling</a>
                    <a href="reports.jsp?type=bestbuyers" class="btn btn-secondary btn-sm">Best Buyers</a>
                </div>
                
                <h4 class="mt-4">System Actions</h4>
                <a href="../closeAuctions.jsp" class="btn btn-primary">Process Ended Auctions</a>
                <p class="form-hint">Closes ended auctions, determines winners, and creates sales records</p>
            </div>
        </div>
        
        <!-- Recent Sales -->
        <div class="col-12">
            <div class="card">
                <div class="card-header">
                    <h3 class="card-title">Recent Sales</h3>
                </div>
                
                <div class="table-wrapper">
                    <table>
                        <thead>
                            <tr>
                                <th>Sale ID</th>
                                <th>Item</th>
                                <th>Buyer</th>
                                <th>Seller</th>
                                <th>Price</th>
                                <th>Date</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                            ApplicationDB db3 = new ApplicationDB();
                            Connection con3 = null;
                            try {
                                con3 = db3.getConnection();
                                Statement stmt3 = con3.createStatement();
                                ResultSet rs3 = stmt3.executeQuery(
                                    "SELECT s.*, i.item_title, " +
                                    "bu.first_name as buyer_first, bu.last_name as buyer_last, " +
                                    "su.first_name as seller_first, su.last_name as seller_last " +
                                    "FROM Sale s " +
                                    "JOIN Item i ON s.item_id = i.item_id " +
                                    "JOIN User bu ON s.buyer_id = bu.user_id " +
                                    "JOIN User su ON s.seller_id = su.user_id " +
                                    "ORDER BY s.sale_date DESC LIMIT 10");
                                
                                boolean hasSales = false;
                                while (rs3.next()) {
                                    hasSales = true;
                            %>
                            <tr>
                                <td>#<%= rs3.getInt("sale_id") %></td>
                                <td><%= rs3.getString("item_title") %></td>
                                <td><%= rs3.getString("buyer_first") %> <%= rs3.getString("buyer_last") %></td>
                                <td><%= rs3.getString("seller_first") %> <%= rs3.getString("seller_last") %></td>
                                <td class="text-success">$<%= String.format("%.2f", rs3.getDouble("final_price")) %></td>
                                <td class="text-muted"><%= rs3.getTimestamp("sale_date") %></td>
                            </tr>
                            <%
                                }
                                if (!hasSales) {
                            %>
                            <tr><td colspan="6" class="text-center text-muted">No sales yet</td></tr>
                            <% }
                            } finally {
                                if (con3 != null) db3.closeConnection(con3);
                            }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<%@ include file="../includes/footer.jsp" %>

