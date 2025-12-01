<%@ page import="java.sql.*, db.ApplicationDB" %>
<%-- 
    BuyMe Auction System - Auction Management (Rep)
--%>
<%
String userType = (String) session.getAttribute("userType");
if (!"rep".equals(userType)) {
    response.sendRedirect("../login.jsp");
    return;
}
request.setAttribute("pageTitle", "Manage Auctions");
String message = request.getParameter("msg");
%>
<%@ include file="../includes/header.jsp" %>

<div class="container">
    <div class="page-header">
        <h1 class="page-title">Auction Management</h1>
    </div>
    
    <% if (message != null) { %>
        <div class="alert alert-success">
            <% if ("removed".equals(message)) { %>Auction removed successfully.<% } %>
            <% if ("bidremoved".equals(message)) { %>Bid removed successfully.<% } %>
        </div>
    <% } %>
    
    <div class="card">
        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Item</th>
                        <th>Seller</th>
                        <th>Current Bid</th>
                        <th>Status</th>
                        <th>Ends</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    ApplicationDB db = new ApplicationDB();
                    Connection con = null;
                    try {
                        con = db.getConnection();
                        
                        Statement stmt = con.createStatement();
                        ResultSet rs = stmt.executeQuery(
                            "SELECT a.*, i.item_title, u.first_name, u.last_name " +
                            "FROM Auction a " +
                            "JOIN Item i ON a.item_id = i.item_id " +
                            "JOIN User u ON a.seller_id = u.user_id " +
                            "ORDER BY a.start_date DESC LIMIT 50");
                        
                        while (rs.next()) {
                            boolean isActive = rs.getBoolean("is_active");
                            Timestamp closeDate = rs.getTimestamp("close_date");
                            boolean hasEnded = closeDate.before(new Timestamp(System.currentTimeMillis()));
                    %>
                    <tr>
                        <td>#<%= rs.getInt("auction_id") %></td>
                        <td>
                            <a href="../auction.jsp?id=<%= rs.getInt("auction_id") %>">
                                <%= rs.getString("item_title") %>
                            </a>
                        </td>
                        <td><%= rs.getString("first_name") %> <%= rs.getString("last_name") %></td>
                        <td class="text-primary">$<%= String.format("%.2f", rs.getDouble("current_high_bid")) %></td>
                        <td>
                            <% if (!isActive) { %>
                                <span class="badge badge-error">Removed</span>
                            <% } else if (hasEnded) { %>
                                <span class="badge badge-warning">Ended</span>
                            <% } else { %>
                                <span class="badge badge-success">Active</span>
                            <% } %>
                        </td>
                        <td class="text-muted"><%= closeDate %></td>
                        <td>
                            <a href="editAuction.jsp?id=<%= rs.getInt("auction_id") %>" class="btn btn-sm btn-secondary">Manage</a>
                        </td>
                    </tr>
                    <% }
                    } finally {
                        if (con != null) db.closeConnection(con);
                    }
                    %>
                </tbody>
            </table>
        </div>
    </div>
    
    <div class="mt-3">
        <a href="dashboard.jsp" class="btn btn-secondary">&larr; Back to Dashboard</a>
    </div>
</div>

<%@ include file="../includes/footer.jsp" %>

