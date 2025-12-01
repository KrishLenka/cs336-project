<%@ page import="java.sql.*, db.ApplicationDB" %>
<%-- 
    BuyMe Auction System - Place Bid Handler
    Processes manual bids and triggers automatic bidding for other users
--%>
<%
// Check if user is logged in
String currentUser = (String) session.getAttribute("user");
if (currentUser == null) {
    response.sendRedirect("login.jsp?error=login");
    return;
}

// Get bid parameters
String auctionIdParam = request.getParameter("auctionId");
String bidAmountParam = request.getParameter("bidAmount");

if (auctionIdParam == null || bidAmountParam == null) {
    response.sendRedirect("browse.jsp");
    return;
}

int auctionId = 0;
double bidAmount = 0;

try {
    auctionId = Integer.parseInt(auctionIdParam);
    bidAmount = Double.parseDouble(bidAmountParam);
} catch (NumberFormatException e) {
    response.sendRedirect("auction.jsp?id=" + auctionIdParam + "&error=invalid");
    return;
}

ApplicationDB db = new ApplicationDB();
Connection con = null;

try {
    con = db.getConnection();
    con.setAutoCommit(false);
    
    // Check if user is a buyer
    PreparedStatement buyerCheck = con.prepareStatement("SELECT * FROM Buyer WHERE buyer_id = ?");
    buyerCheck.setString(1, currentUser);
    if (!buyerCheck.executeQuery().next()) {
        response.sendRedirect("auction.jsp?id=" + auctionId + "&error=buyer");
        return;
    }
    
    // Get auction details
    PreparedStatement auctionPs = con.prepareStatement(
        "SELECT * FROM Auction WHERE auction_id = ? FOR UPDATE");
    auctionPs.setInt(1, auctionId);
    ResultSet auctionRs = auctionPs.executeQuery();
    
    if (!auctionRs.next()) {
        response.sendRedirect("browse.jsp?error=notfound");
        return;
    }
    
    // Check if auction is still active
    Timestamp closeDate = auctionRs.getTimestamp("close_date");
    boolean isActive = auctionRs.getBoolean("is_active");
    if (!isActive || closeDate.before(new Timestamp(System.currentTimeMillis()))) {
        response.sendRedirect("auction.jsp?id=" + auctionId + "&error=closed");
        return;
    }
    
    // Get current bid info
    double currentHighBid = auctionRs.getDouble("current_high_bid");
    double initialPrice = auctionRs.getDouble("initial_price");
    double increment = auctionRs.getDouble("increment_price");
    String currentHighBidder = auctionRs.getString("high_bidder_id");
    String sellerId = auctionRs.getString("seller_id");
    
    // Check seller isn't bidding on own item
    if (sellerId.equals(currentUser)) {
        response.sendRedirect("auction.jsp?id=" + auctionId + "&error=seller");
        return;
    }
    
    // Calculate minimum bid
    double minBid = currentHighBid > 0 ? currentHighBid + increment : initialPrice;
    
    // Validate bid amount
    if (bidAmount < minBid) {
        response.sendRedirect("auction.jsp?id=" + auctionId + "&error=low");
        return;
    }
    
    // Place the bid
    PreparedStatement bidPs = con.prepareStatement(
        "INSERT INTO Bid (auction_id, buyer_id, bid_amount, is_auto_bid) VALUES (?, ?, ?, FALSE)");
    bidPs.setInt(1, auctionId);
    bidPs.setString(2, currentUser);
    bidPs.setDouble(3, bidAmount);
    bidPs.executeUpdate();
    
    // Update auction with new high bid
    PreparedStatement updatePs = con.prepareStatement(
        "UPDATE Auction SET current_high_bid = ?, high_bidder_id = ? WHERE auction_id = ?");
    updatePs.setDouble(1, bidAmount);
    updatePs.setString(2, currentUser);
    updatePs.setInt(3, auctionId);
    updatePs.executeUpdate();
    
    // Notify previous high bidder if they were outbid
    if (currentHighBidder != null && !currentHighBidder.equals(currentUser)) {
        PreparedStatement notifyPs = con.prepareStatement(
            "INSERT INTO Notification (user_id, message, auction_id) VALUES (?, ?, ?)");
        notifyPs.setString(1, currentHighBidder);
        notifyPs.setString(2, "You have been outbid on auction #" + auctionId + ". New high bid: $" + String.format("%.2f", bidAmount));
        notifyPs.setInt(3, auctionId);
        notifyPs.executeUpdate();
    }
    
    // Process automatic bids from other users
    processAutoBids(con, auctionId, currentUser, bidAmount, increment);
    
    con.commit();
    
    response.sendRedirect("auction.jsp?id=" + auctionId + "&msg=bid");
    
} catch (Exception e) {
    if (con != null) {
        try { con.rollback(); } catch (SQLException ex) {}
    }
    e.printStackTrace();
    response.sendRedirect("auction.jsp?id=" + auctionId + "&error=server");
} finally {
    if (con != null) {
        try { con.setAutoCommit(true); } catch (SQLException ex) {}
        db.closeConnection(con);
    }
}
%>

<%!
/**
 * Process automatic bids from other users after a manual bid is placed.
 * Implements the automatic bidding feature where users set a max amount
 * and the system bids incrementally for them.
 */
private void processAutoBids(Connection con, int auctionId, String manualBidder, 
                             double currentBid, double increment) throws SQLException {
    // Get all active auto-bid settings for this auction (excluding the manual bidder)
    PreparedStatement autoBidPs = con.prepareStatement(
        "SELECT * FROM AutoBidSetting WHERE auction_id = ? AND buyer_id != ? " +
        "AND is_active = TRUE AND max_bid_amount > ? ORDER BY max_bid_amount DESC, created_at ASC");
    autoBidPs.setInt(1, auctionId);
    autoBidPs.setString(2, manualBidder);
    autoBidPs.setDouble(3, currentBid);
    ResultSet autoBidRs = autoBidPs.executeQuery();
    
    if (!autoBidRs.next()) {
        return; // No active auto-bids that can beat the current bid
    }
    
    // Get the highest auto-bidder who can outbid
    String topAutoBidder = autoBidRs.getString("buyer_id");
    double topMaxBid = autoBidRs.getDouble("max_bid_amount");
    
    // Calculate the auto-bid amount (just enough to beat current + increment, or max)
    double autoBidAmount = Math.min(currentBid + increment, topMaxBid);
    
    // If auto-bid can beat current bid
    if (autoBidAmount > currentBid) {
        // Place automatic bid
        PreparedStatement placeBidPs = con.prepareStatement(
            "INSERT INTO Bid (auction_id, buyer_id, bid_amount, is_auto_bid, max_auto_bid) " +
            "VALUES (?, ?, ?, TRUE, ?)");
        placeBidPs.setInt(1, auctionId);
        placeBidPs.setString(2, topAutoBidder);
        placeBidPs.setDouble(3, autoBidAmount);
        placeBidPs.setDouble(4, topMaxBid);
        placeBidPs.executeUpdate();
        
        // Update auction
        PreparedStatement updatePs = con.prepareStatement(
            "UPDATE Auction SET current_high_bid = ?, high_bidder_id = ? WHERE auction_id = ?");
        updatePs.setDouble(1, autoBidAmount);
        updatePs.setString(2, topAutoBidder);
        updatePs.setInt(3, auctionId);
        updatePs.executeUpdate();
        
        // Notify the manual bidder they were outbid
        PreparedStatement notifyPs = con.prepareStatement(
            "INSERT INTO Notification (user_id, message, auction_id) VALUES (?, ?, ?)");
        notifyPs.setString(1, manualBidder);
        notifyPs.setString(2, "Your bid was outbid by automatic bidding on auction #" + auctionId);
        notifyPs.setInt(3, auctionId);
        notifyPs.executeUpdate();
        
        // If there are competing auto-bidders, process them too
        if (autoBidRs.next()) {
            String secondAutoBidder = autoBidRs.getString("buyer_id");
            double secondMaxBid = autoBidRs.getDouble("max_bid_amount");
            
            // Auto-bid war between auto-bidders
            processAutoBidWar(con, auctionId, topAutoBidder, topMaxBid, 
                             secondAutoBidder, secondMaxBid, autoBidAmount, increment);
        }
    } else {
        // Auto-bid max is reached, notify the user
        PreparedStatement notifyPs = con.prepareStatement(
            "INSERT INTO Notification (user_id, message, auction_id) VALUES (?, ?, ?)");
        notifyPs.setString(1, topAutoBidder);
        notifyPs.setString(2, "Your automatic bid limit was reached on auction #" + auctionId);
        notifyPs.setInt(3, auctionId);
        notifyPs.executeUpdate();
        
        // Deactivate the auto-bid
        PreparedStatement deactivatePs = con.prepareStatement(
            "UPDATE AutoBidSetting SET is_active = FALSE WHERE auction_id = ? AND buyer_id = ?");
        deactivatePs.setInt(1, auctionId);
        deactivatePs.setString(2, topAutoBidder);
        deactivatePs.executeUpdate();
    }
}

/**
 * Handle automatic bidding war between two auto-bidders
 */
private void processAutoBidWar(Connection con, int auctionId, 
                               String bidder1, double max1,
                               String bidder2, double max2,
                               double currentBid, double increment) throws SQLException {
    // The bidder with higher max wins, at the opponent's max + increment (or their own max)
    String winner;
    double winningBid;
    String loser;
    
    if (max1 > max2) {
        winner = bidder1;
        winningBid = Math.min(max2 + increment, max1);
        loser = bidder2;
    } else if (max2 > max1) {
        winner = bidder2;
        winningBid = Math.min(max1 + increment, max2);
        loser = bidder1;
    } else {
        // Tie - first auto-bidder wins (bidder1 was first in our query)
        winner = bidder1;
        winningBid = max1;
        loser = bidder2;
    }
    
    // Place the winning bid
    PreparedStatement placeBidPs = con.prepareStatement(
        "INSERT INTO Bid (auction_id, buyer_id, bid_amount, is_auto_bid) VALUES (?, ?, ?, TRUE)");
    placeBidPs.setInt(1, auctionId);
    placeBidPs.setString(2, winner);
    placeBidPs.setDouble(3, winningBid);
    placeBidPs.executeUpdate();
    
    // Update auction
    PreparedStatement updatePs = con.prepareStatement(
        "UPDATE Auction SET current_high_bid = ?, high_bidder_id = ? WHERE auction_id = ?");
    updatePs.setDouble(1, winningBid);
    updatePs.setString(2, winner);
    updatePs.setInt(3, auctionId);
    updatePs.executeUpdate();
    
    // Notify loser
    PreparedStatement notifyPs = con.prepareStatement(
        "INSERT INTO Notification (user_id, message, auction_id) VALUES (?, ?, ?)");
    notifyPs.setString(1, loser);
    notifyPs.setString(2, "Your automatic bid limit was exceeded on auction #" + auctionId);
    notifyPs.setInt(3, auctionId);
    notifyPs.executeUpdate();
    
    // Deactivate loser's auto-bid
    PreparedStatement deactivatePs = con.prepareStatement(
        "UPDATE AutoBidSetting SET is_active = FALSE WHERE auction_id = ? AND buyer_id = ?");
    deactivatePs.setInt(1, auctionId);
    deactivatePs.setString(2, loser);
    deactivatePs.executeUpdate();
}
%>

