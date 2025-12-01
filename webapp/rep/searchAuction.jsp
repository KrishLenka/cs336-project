<%@ page import="java.sql.*, db.ApplicationDB" %>
<%
String userType = (String) session.getAttribute("userType");
if (!"rep".equals(userType)) {
    response.sendRedirect("../login.jsp");
    return;
}

String query = request.getParameter("query");
if (query == null || query.trim().isEmpty()) {
    response.sendRedirect("auctions.jsp");
    return;
}
request.setAttribute("pageTitle", "Search Auctions");
%>
<%@ include file="../includes/header.jsp" %>

<div class="container">
    <div class="page-header">
        <h1 class="page-title">Search Results: "<%= query %>"</h1>
    </div>
    
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
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    ApplicationDB db = new ApplicationDB();
                    Connection con = null;
                    try {
                        con = db.getConnection();
                        
                        // Try to parse as auction ID first
                        String sql;
                        PreparedStatement ps;
                        
                        try {
                            int auctionId = Integer.parseInt(query.trim());
                            sql = "SELECT a.*, i.item_title, u.first_name, u.last_name " +
                                  "FROM Auction a JOIN Item i ON a.item_id = i.item_id " +
                                  "JOIN User u ON a.seller_id = u.user_id WHERE a.auction_id = ?";
                            ps = con.prepareStatement(sql);
                            ps.setInt(1, auctionId);
                        } catch (NumberFormatException e) {
                            sql = "SELECT a.*, i.item_title, u.first_name, u.last_name " +
                                  "FROM Auction a JOIN Item i ON a.item_id = i.item_id " +
                                  "JOIN User u ON a.seller_id = u.user_id WHERE i.item_title LIKE ?";
                            ps = con.prepareStatement(sql);
                            ps.setString(1, "%" + query.trim() + "%");
                        }
                        
                        ResultSet rs = ps.executeQuery();
                        boolean found = false;
                        
                        while (rs.next()) {
                            found = true;
                            boolean isActive = rs.getBoolean("is_active");
                            Timestamp closeDate = rs.getTimestamp("close_date");
                            boolean hasEnded = closeDate.before(new Timestamp(System.currentTimeMillis()));
                    %>
                    <tr>
                        <td>#<%= rs.getInt("auction_id") %></td>
                        <td><%= rs.getString("item_title") %></td>
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
                        <td>
                            <a href="editAuction.jsp?id=<%= rs.getInt("auction_id") %>" class="btn btn-sm btn-secondary">Manage</a>
                        </td>
                    </tr>
                    <%
                        }
                        if (!found) {
                    %>
                    <tr><td colspan="6" class="text-center text-muted">No auctions found matching "<%= query %>"</td></tr>
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

