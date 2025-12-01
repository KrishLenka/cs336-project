<%@ page import="java.sql.*, db.ApplicationDB" %>
<%-- 
    BuyMe Auction System - Edit Auction (Rep)
    Allows customer reps to manage auctions and remove bids
--%>
<%
String userType = (String) session.getAttribute("userType");
if (!"rep".equals(userType)) {
    response.sendRedirect("../login.jsp");
    return;
}

String auctionIdParam = request.getParameter("id");
if (auctionIdParam == null) {
    response.sendRedirect("auctions.jsp");
    return;
}
int auctionId = Integer.parseInt(auctionIdParam);
request.setAttribute("pageTitle", "Manage Auction");
String message = request.getParameter("msg");
%>
<%@ include file="../includes/header.jsp" %>

<div class="container container-md">
    <div class="page-header">
        <h1 class="page-title">Manage Auction #<%= auctionId %></h1>
    </div>
    
    <% if (message != null) { %>
        <div class="alert alert-success">
            <% if ("bidremoved".equals(message)) { %>Bid removed successfully.<% } %>
        </div>
    <% } %>
    
    <%
    ApplicationDB db = new ApplicationDB();
    Connection con = null;
    try {
        con = db.getConnection();
        
        PreparedStatement ps = con.prepareStatement(
            "SELECT a.*, i.item_title, i.item_description, u.first_name, u.last_name, u.user_id as seller_id " +
            "FROM Auction a " +
            "JOIN Item i ON a.item_id = i.item_id " +
            "JOIN User u ON a.seller_id = u.user_id " +
            "WHERE a.auction_id = ?");
        ps.setInt(1, auctionId);
        ResultSet rs = ps.executeQuery();
        
        if (rs.next()) {
    %>
    
    <!-- Auction Info -->
    <div class="card">
        <h3>Auction Details</h3>
        <table style="width: 100%;">
            <tr><td class="text-muted">Item</td><td><%= rs.getString("item_title") %></td></tr>
            <tr><td class="text-muted">Seller</td><td><%= rs.getString("first_name") %> <%= rs.getString("last_name") %> (<%= rs.getString("seller_id") %>)</td></tr>
            <tr><td class="text-muted">Current Bid</td><td class="text-primary">$<%= String.format("%.2f", rs.getDouble("current_high_bid")) %></td></tr>
            <tr><td class="text-muted">Initial Price</td><td>$<%= String.format("%.2f", rs.getDouble("initial_price")) %></td></tr>
            <tr><td class="text-muted">Reserve Price</td><td>$<%= String.format("%.2f", rs.getDouble("min_price")) %></td></tr>
            <tr><td class="text-muted">Status</td><td>
                <% if (!rs.getBoolean("is_active")) { %>
                    <span class="badge badge-error">Removed</span>
                <% } else if (rs.getTimestamp("close_date").before(new Timestamp(System.currentTimeMillis()))) { %>
                    <span class="badge badge-warning">Ended</span>
                <% } else { %>
                    <span class="badge badge-success">Active</span>
                <% } %>
            </td></tr>
            <tr><td class="text-muted">Closes</td><td><%= rs.getTimestamp("close_date") %></td></tr>
        </table>
        
        <% if (rs.getBoolean("is_active")) { %>
        <div class="mt-4">
            <form action="removeAuction.jsp" method="POST" style="display:inline;">
                <input type="hidden" name="auctionId" value="<%= auctionId %>">
                <button type="submit" class="btn btn-danger" 
                        onclick="return confirm('Remove this auction? This action cannot be undone.')">
                    Remove Auction (Illegal/Violation)
                </button>
            </form>
        </div>
        <% } %>
    </div>
    
    <!-- Bid Management -->
    <div class="card mt-4">
        <h3>Bid History - Remove Bids</h3>
        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>Bid ID</th>
                        <th>Bidder</th>
                        <th>Amount</th>
                        <th>Time</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    PreparedStatement bidPs = con.prepareStatement(
                        "SELECT b.*, u.first_name, u.last_name FROM Bid b " +
                        "JOIN User u ON b.buyer_id = u.user_id " +
                        "WHERE b.auction_id = ? ORDER BY b.bid_time DESC");
                    bidPs.setInt(1, auctionId);
                    ResultSet bidRs = bidPs.executeQuery();
                    
                    boolean hasBids = false;
                    while (bidRs.next()) {
                        hasBids = true;
                    %>
                    <tr>
                        <td>#<%= bidRs.getInt("bid_id") %></td>
                        <td><%= bidRs.getString("first_name") %> <%= bidRs.getString("last_name") %></td>
                        <td class="text-primary">$<%= String.format("%.2f", bidRs.getDouble("bid_amount")) %></td>
                        <td class="text-muted"><%= bidRs.getTimestamp("bid_time") %></td>
                        <td>
                            <form action="removeBidAction.jsp" method="POST" style="display:inline;">
                                <input type="hidden" name="bidId" value="<%= bidRs.getInt("bid_id") %>">
                                <input type="hidden" name="auctionId" value="<%= auctionId %>">
                                <button type="submit" class="btn btn-sm btn-danger" 
                                        onclick="return confirm('Remove this bid?')">Remove</button>
                            </form>
                        </td>
                    </tr>
                    <% }
                    if (!hasBids) { %>
                    <tr><td colspan="5" class="text-center text-muted">No bids</td></tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
    
    <%
        } else {
            out.println("<div class='alert alert-error'>Auction not found.</div>");
        }
    } finally {
        if (con != null) db.closeConnection(con);
    }
    %>
    
    <div class="mt-3">
        <a href="auctions.jsp" class="btn btn-secondary">&larr; Back to Auctions</a>
    </div>
</div>

<%@ include file="../includes/footer.jsp" %>

