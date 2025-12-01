<%@ page import="java.sql.*, db.ApplicationDB" %>
<%-- 
    BuyMe Auction System - My Auctions Page
    Shows user's selling and buying activity
--%>
<%
String currentUser = (String) session.getAttribute("user");
if (currentUser == null) {
    response.sendRedirect("login.jsp");
    return;
}
request.setAttribute("pageTitle", "My Auctions");
%>
<%@ include file="includes/header.jsp" %>

<div class="container">
    <div class="page-header">
        <h1 class="page-title">My Auctions</h1>
        <p class="page-subtitle">Manage your buying and selling activity</p>
    </div>
    
    <!-- Tabs -->
    <div class="tabs">
        <a href="?tab=bidding" class="tab <%= !"selling".equals(request.getParameter("tab")) ? "active" : "" %>">My Bids</a>
        <a href="?tab=selling" class="tab <%= "selling".equals(request.getParameter("tab")) ? "active" : "" %>">My Listings</a>
    </div>
    
    <%
    ApplicationDB db = new ApplicationDB();
    Connection con = null;
    try {
        con = db.getConnection();
        
        if ("selling".equals(request.getParameter("tab"))) {
            // Show seller's auctions
    %>
    
    <div class="flex-between mb-3">
        <h2>My Listings</h2>
        <a href="sell.jsp" class="btn btn-primary">+ Create New Listing</a>
    </div>
    
    <!-- Active Listings -->
    <h3 class="mt-4">Active Listings</h3>
    <div class="table-wrapper">
        <table>
            <thead>
                <tr>
                    <th>Item</th>
                    <th>Current Bid</th>
                    <th>Bids</th>
                    <th>Time Left</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <%
                PreparedStatement activePs = con.prepareStatement(
                    "SELECT a.*, i.item_title, " +
                    "(SELECT COUNT(*) FROM Bid b WHERE b.auction_id = a.auction_id) as bid_count " +
                    "FROM Auction a JOIN Item i ON a.item_id = i.item_id " +
                    "WHERE a.seller_id = ? AND a.is_active = TRUE AND a.close_date > NOW() " +
                    "ORDER BY a.close_date ASC");
                activePs.setString(1, currentUser);
                ResultSet activeRs = activePs.executeQuery();
                
                boolean hasActive = false;
                while (activeRs.next()) {
                    hasActive = true;
                    double currentBid = activeRs.getDouble("current_high_bid");
                    double initialPrice = activeRs.getDouble("initial_price");
                %>
                <tr>
                    <td>
                        <a href="auction.jsp?id=<%= activeRs.getInt("auction_id") %>">
                            <%= activeRs.getString("item_title") %>
                        </a>
                    </td>
                    <td class="text-primary">$<%= String.format("%.2f", currentBid > 0 ? currentBid : initialPrice) %></td>
                    <td><%= activeRs.getInt("bid_count") %></td>
                    <td>
                        <span class="time-left" data-close-time="<%= activeRs.getTimestamp("close_date") %>">Loading...</span>
                    </td>
                    <td>
                        <a href="auction.jsp?id=<%= activeRs.getInt("auction_id") %>" class="btn btn-sm btn-secondary">View</a>
                    </td>
                </tr>
                <% }
                if (!hasActive) { %>
                <tr><td colspan="5" class="text-center text-muted">No active listings</td></tr>
                <% } %>
            </tbody>
        </table>
    </div>
    
    <!-- Past Listings -->
    <h3 class="mt-4">Past Listings</h3>
    <div class="table-wrapper">
        <table>
            <thead>
                <tr>
                    <th>Item</th>
                    <th>Final Price</th>
                    <th>Status</th>
                    <th>Ended</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <%
                PreparedStatement pastPs = con.prepareStatement(
                    "SELECT a.*, i.item_title FROM Auction a " +
                    "JOIN Item i ON a.item_id = i.item_id " +
                    "WHERE a.seller_id = ? AND (a.is_closed = TRUE OR a.close_date <= NOW()) " +
                    "ORDER BY a.close_date DESC LIMIT 20");
                pastPs.setString(1, currentUser);
                ResultSet pastRs = pastPs.executeQuery();
                
                boolean hasPast = false;
                while (pastRs.next()) {
                    hasPast = true;
                    String winner = pastRs.getString("winner_id");
                    double finalPrice = pastRs.getDouble("final_price");
                    boolean sold = winner != null;
                %>
                <tr>
                    <td><a href="auction.jsp?id=<%= pastRs.getInt("auction_id") %>"><%= pastRs.getString("item_title") %></a></td>
                    <td><%= sold ? "$" + String.format("%.2f", finalPrice) : "-" %></td>
                    <td>
                        <% if (sold) { %>
                            <span class="badge badge-success">Sold</span>
                        <% } else { %>
                            <span class="badge badge-warning">Not Sold</span>
                        <% } %>
                    </td>
                    <td class="text-muted"><%= pastRs.getTimestamp("close_date") %></td>
                    <td><a href="auction.jsp?id=<%= pastRs.getInt("auction_id") %>" class="btn btn-sm btn-secondary">View</a></td>
                </tr>
                <% }
                if (!hasPast) { %>
                <tr><td colspan="5" class="text-center text-muted">No past listings</td></tr>
                <% } %>
            </tbody>
        </table>
    </div>
    
    <%
        } else {
            // Show buyer's bids
    %>
    
    <h2>My Bids</h2>
    
    <!-- Active Bids -->
    <h3 class="mt-4">Currently Bidding On</h3>
    <div class="table-wrapper">
        <table>
            <thead>
                <tr>
                    <th>Item</th>
                    <th>Your Bid</th>
                    <th>Current High</th>
                    <th>Status</th>
                    <th>Time Left</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <%
                PreparedStatement biddingPs = con.prepareStatement(
                    "SELECT DISTINCT a.*, i.item_title, " +
                    "(SELECT MAX(bid_amount) FROM Bid WHERE auction_id = a.auction_id AND buyer_id = ?) as my_max_bid " +
                    "FROM Auction a " +
                    "JOIN Item i ON a.item_id = i.item_id " +
                    "JOIN Bid b ON a.auction_id = b.auction_id " +
                    "WHERE b.buyer_id = ? AND a.is_active = TRUE AND a.close_date > NOW() " +
                    "ORDER BY a.close_date ASC");
                biddingPs.setString(1, currentUser);
                biddingPs.setString(2, currentUser);
                ResultSet biddingRs = biddingPs.executeQuery();
                
                boolean hasBids = false;
                while (biddingRs.next()) {
                    hasBids = true;
                    double myBid = biddingRs.getDouble("my_max_bid");
                    double highBid = biddingRs.getDouble("current_high_bid");
                    String highBidder = biddingRs.getString("high_bidder_id");
                    boolean isWinning = currentUser.equals(highBidder);
                %>
                <tr>
                    <td><a href="auction.jsp?id=<%= biddingRs.getInt("auction_id") %>"><%= biddingRs.getString("item_title") %></a></td>
                    <td>$<%= String.format("%.2f", myBid) %></td>
                    <td class="text-primary">$<%= String.format("%.2f", highBid) %></td>
                    <td>
                        <% if (isWinning) { %>
                            <span class="badge badge-success">Winning</span>
                        <% } else { %>
                            <span class="badge badge-warning">Outbid</span>
                        <% } %>
                    </td>
                    <td><span class="time-left" data-close-time="<%= biddingRs.getTimestamp("close_date") %>">Loading...</span></td>
                    <td>
                        <a href="auction.jsp?id=<%= biddingRs.getInt("auction_id") %>" class="btn btn-sm <%= isWinning ? "btn-secondary" : "btn-primary" %>">
                            <%= isWinning ? "View" : "Bid Again" %>
                        </a>
                    </td>
                </tr>
                <% }
                if (!hasBids) { %>
                <tr><td colspan="6" class="text-center text-muted">No active bids</td></tr>
                <% } %>
            </tbody>
        </table>
    </div>
    
    <!-- Won Auctions -->
    <h3 class="mt-4">Won Auctions</h3>
    <div class="table-wrapper">
        <table>
            <thead>
                <tr>
                    <th>Item</th>
                    <th>Final Price</th>
                    <th>Won Date</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <%
                PreparedStatement wonPs = con.prepareStatement(
                    "SELECT a.*, i.item_title FROM Auction a " +
                    "JOIN Item i ON a.item_id = i.item_id " +
                    "WHERE a.winner_id = ? ORDER BY a.close_date DESC LIMIT 20");
                wonPs.setString(1, currentUser);
                ResultSet wonRs = wonPs.executeQuery();
                
                boolean hasWon = false;
                while (wonRs.next()) {
                    hasWon = true;
                %>
                <tr>
                    <td><a href="auction.jsp?id=<%= wonRs.getInt("auction_id") %>"><%= wonRs.getString("item_title") %></a></td>
                    <td class="text-success">$<%= String.format("%.2f", wonRs.getDouble("final_price")) %></td>
                    <td class="text-muted"><%= wonRs.getTimestamp("close_date") %></td>
                    <td><a href="auction.jsp?id=<%= wonRs.getInt("auction_id") %>" class="btn btn-sm btn-secondary">View</a></td>
                </tr>
                <% }
                if (!hasWon) { %>
                <tr><td colspan="4" class="text-center text-muted">No won auctions yet</td></tr>
                <% } %>
            </tbody>
        </table>
    </div>
    
    <%
        }
    } catch (Exception e) {
        out.println("<div class='alert alert-error'>Error: " + e.getMessage() + "</div>");
        e.printStackTrace();
    } finally {
        if (con != null) db.closeConnection(con);
    }
    %>
</div>

<%@ include file="includes/footer.jsp" %>

