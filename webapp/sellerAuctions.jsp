<%@ page import="java.sql.*, db.ApplicationDB" %>
<%-- 
    BuyMe Auction System - Seller's Auctions Page
    View all auctions by a specific seller
--%>
<%
String sellerId = request.getParameter("seller");
if (sellerId == null || sellerId.isEmpty()) {
    response.sendRedirect("browse.jsp");
    return;
}
request.setAttribute("pageTitle", "Seller Auctions");
%>
<%@ include file="includes/header.jsp" %>

<div class="container">
    <%
    ApplicationDB db = new ApplicationDB();
    Connection con = null;
    try {
        con = db.getConnection();
        
        // Get seller info
        PreparedStatement sellerPs = con.prepareStatement(
            "SELECT u.first_name, u.last_name, s.rating, s.total_ratings, s.earnings " +
            "FROM User u JOIN Seller s ON u.user_id = s.seller_id WHERE u.user_id = ?");
        sellerPs.setString(1, sellerId);
        ResultSet sellerRs = sellerPs.executeQuery();
        
        if (sellerRs.next()) {
            String sellerName = sellerRs.getString("first_name") + " " + sellerRs.getString("last_name").charAt(0) + ".";
            double rating = sellerRs.getDouble("rating");
            int totalRatings = sellerRs.getInt("total_ratings");
    %>
    
    <div class="page-header">
        <h1 class="page-title">Auctions by <%= sellerName %></h1>
        <p class="page-subtitle">
            <% if (totalRatings > 0) { %>
                Rating: <%= String.format("%.1f", rating) %>/5.0 (<%= totalRatings %> reviews)
            <% } else { %>
                New Seller
            <% } %>
        </p>
    </div>
    
    <h2 class="mb-3">Active Auctions</h2>
    <div class="auction-grid">
        <%
        PreparedStatement auctionPs = con.prepareStatement(
            "SELECT a.*, i.item_title, i.item_condition, i.brand, c.category_name, " +
            "(SELECT COUNT(*) FROM Bid b WHERE b.auction_id = a.auction_id) as bid_count " +
            "FROM Auction a " +
            "JOIN Item i ON a.item_id = i.item_id " +
            "JOIN Category c ON i.category_id = c.category_id " +
            "WHERE a.seller_id = ? AND a.is_active = TRUE AND a.close_date > NOW() " +
            "ORDER BY a.close_date ASC");
        auctionPs.setString(1, sellerId);
        ResultSet auctionRs = auctionPs.executeQuery();
        
        boolean hasAuctions = false;
        while (auctionRs.next()) {
            hasAuctions = true;
            double currentBid = auctionRs.getDouble("current_high_bid");
            double initialPrice = auctionRs.getDouble("initial_price");
        %>
        <a href="auction.jsp?id=<%= auctionRs.getInt("auction_id") %>" class="auction-card" style="text-decoration:none;">
            <div class="auction-image">&#128230;</div>
            <div class="auction-content">
                <div class="auction-category"><%= auctionRs.getString("category_name") %></div>
                <div class="auction-title"><%= auctionRs.getString("item_title") %></div>
                <div class="auction-seller">
                    <span class="badge badge-info"><%= auctionRs.getString("item_condition") %></span>
                    <span class="text-muted"><%= auctionRs.getInt("bid_count") %> bids</span>
                </div>
                <div class="auction-price">
                    <span class="current-bid">$<%= String.format("%.2f", currentBid > 0 ? currentBid : initialPrice) %></span>
                    <span class="time-left" data-close-time="<%= auctionRs.getTimestamp("close_date") %>">Loading...</span>
                </div>
            </div>
        </a>
        <% }
        if (!hasAuctions) { %>
        <div class="card text-center" style="grid-column: 1 / -1;">
            <p class="text-muted">No active auctions from this seller.</p>
        </div>
        <% } %>
    </div>
    
    <%
        } else {
            out.println("<div class='alert alert-error'>Seller not found.</div>");
        }
    } catch (Exception e) {
        out.println("<div class='alert alert-error'>Error: " + e.getMessage() + "</div>");
    } finally {
        if (con != null) db.closeConnection(con);
    }
    %>
</div>

<%@ include file="includes/footer.jsp" %>

