<%@ page import="java.sql.*, db.ApplicationDB" %>
<%-- 
    BuyMe Auction System - Set Automatic Bid Handler
    Sets up automatic bidding for a user on an auction
--%>
<%
String currentUser = (String) session.getAttribute("user");
if (currentUser == null) {
    response.sendRedirect("login.jsp");
    return;
}

String auctionIdParam = request.getParameter("auctionId");
String maxBidParam = request.getParameter("maxBid");

if (auctionIdParam == null || maxBidParam == null) {
    response.sendRedirect("browse.jsp");
    return;
}

int auctionId = 0;
double maxBid = 0;

try {
    auctionId = Integer.parseInt(auctionIdParam);
    maxBid = Double.parseDouble(maxBidParam);
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
        "SELECT * FROM Auction WHERE auction_id = ?");
    auctionPs.setInt(1, auctionId);
    ResultSet auctionRs = auctionPs.executeQuery();
    
    if (!auctionRs.next()) {
        response.sendRedirect("browse.jsp?error=notfound");
        return;
    }
    
    // Check auction is active
    if (!auctionRs.getBoolean("is_active") || 
        auctionRs.getTimestamp("close_date").before(new Timestamp(System.currentTimeMillis()))) {
        response.sendRedirect("auction.jsp?id=" + auctionId + "&error=closed");
        return;
    }
    
    // Check max bid is valid
    double currentHighBid = auctionRs.getDouble("current_high_bid");
    double initialPrice = auctionRs.getDouble("initial_price");
    double increment = auctionRs.getDouble("increment_price");
    double minBid = currentHighBid > 0 ? currentHighBid + increment : initialPrice;
    
    if (maxBid < minBid) {
        response.sendRedirect("auction.jsp?id=" + auctionId + "&error=low");
        return;
    }
    
    // Check if auto-bid already exists
    PreparedStatement checkPs = con.prepareStatement(
        "SELECT * FROM AutoBidSetting WHERE auction_id = ? AND buyer_id = ?");
    checkPs.setInt(1, auctionId);
    checkPs.setString(2, currentUser);
    ResultSet checkRs = checkPs.executeQuery();
    
    if (checkRs.next()) {
        // Update existing auto-bid
        PreparedStatement updatePs = con.prepareStatement(
            "UPDATE AutoBidSetting SET max_bid_amount = ?, is_active = TRUE WHERE auction_id = ? AND buyer_id = ?");
        updatePs.setDouble(1, maxBid);
        updatePs.setInt(2, auctionId);
        updatePs.setString(3, currentUser);
        updatePs.executeUpdate();
    } else {
        // Insert new auto-bid
        PreparedStatement insertPs = con.prepareStatement(
            "INSERT INTO AutoBidSetting (auction_id, buyer_id, max_bid_amount) VALUES (?, ?, ?)");
        insertPs.setInt(1, auctionId);
        insertPs.setString(2, currentUser);
        insertPs.setDouble(3, maxBid);
        insertPs.executeUpdate();
    }
    
    // If no current bid, or if user can beat current bid, place initial auto-bid
    String currentHighBidder = auctionRs.getString("high_bidder_id");
    if (currentHighBidder == null || !currentHighBidder.equals(currentUser)) {
        double bidAmount = Math.min(minBid, maxBid);
        
        // Place the initial auto-bid
        PreparedStatement bidPs = con.prepareStatement(
            "INSERT INTO Bid (auction_id, buyer_id, bid_amount, is_auto_bid, max_auto_bid) " +
            "VALUES (?, ?, ?, TRUE, ?)");
        bidPs.setInt(1, auctionId);
        bidPs.setString(2, currentUser);
        bidPs.setDouble(3, bidAmount);
        bidPs.setDouble(4, maxBid);
        bidPs.executeUpdate();
        
        // Update auction
        PreparedStatement auctionUpdatePs = con.prepareStatement(
            "UPDATE Auction SET current_high_bid = ?, high_bidder_id = ? WHERE auction_id = ?");
        auctionUpdatePs.setDouble(1, bidAmount);
        auctionUpdatePs.setString(2, currentUser);
        auctionUpdatePs.setInt(3, auctionId);
        auctionUpdatePs.executeUpdate();
        
        // Notify previous high bidder
        if (currentHighBidder != null) {
            PreparedStatement notifyPs = con.prepareStatement(
                "INSERT INTO Notification (user_id, message, auction_id) VALUES (?, ?, ?)");
            notifyPs.setString(1, currentHighBidder);
            notifyPs.setString(2, "You have been outbid on auction #" + auctionId);
            notifyPs.setInt(3, auctionId);
            notifyPs.executeUpdate();
        }
    }
    
    con.commit();
    response.sendRedirect("auction.jsp?id=" + auctionId + "&msg=autobid");
    
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

