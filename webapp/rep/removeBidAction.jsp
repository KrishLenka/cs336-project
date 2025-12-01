<%@ page import="java.sql.*, db.ApplicationDB" %>
<%-- 
    BuyMe Auction System - Remove Bid Handler (Rep)
    Removes a bid and updates auction high bid accordingly
--%>
<%
String userType = (String) session.getAttribute("userType");
if (!"rep".equals(userType)) {
    response.sendRedirect("../login.jsp");
    return;
}

String bidIdParam = request.getParameter("bidId");
String auctionIdParam = request.getParameter("auctionId");

if (bidIdParam == null || auctionIdParam == null) {
    response.sendRedirect("auctions.jsp");
    return;
}

int bidId = Integer.parseInt(bidIdParam);
int auctionId = Integer.parseInt(auctionIdParam);

ApplicationDB db = new ApplicationDB();
Connection con = null;

try {
    con = db.getConnection();
    con.setAutoCommit(false);
    
    // Get bid info before deleting
    PreparedStatement bidPs = con.prepareStatement(
        "SELECT * FROM Bid WHERE bid_id = ? AND auction_id = ?");
    bidPs.setInt(1, bidId);
    bidPs.setInt(2, auctionId);
    ResultSet bidRs = bidPs.executeQuery();
    
    if (bidRs.next()) {
        String buyerId = bidRs.getString("buyer_id");
        double bidAmount = bidRs.getDouble("bid_amount");
        
        // Delete the bid
        PreparedStatement deletePs = con.prepareStatement(
            "DELETE FROM Bid WHERE bid_id = ? AND auction_id = ?");
        deletePs.setInt(1, bidId);
        deletePs.setInt(2, auctionId);
        deletePs.executeUpdate();
        
        // Find new highest bid
        PreparedStatement newHighPs = con.prepareStatement(
            "SELECT buyer_id, bid_amount FROM Bid WHERE auction_id = ? ORDER BY bid_amount DESC LIMIT 1");
        newHighPs.setInt(1, auctionId);
        ResultSet newHighRs = newHighPs.executeQuery();
        
        // Update auction with new high bid
        if (newHighRs.next()) {
            PreparedStatement updatePs = con.prepareStatement(
                "UPDATE Auction SET current_high_bid = ?, high_bidder_id = ? WHERE auction_id = ?");
            updatePs.setDouble(1, newHighRs.getDouble("bid_amount"));
            updatePs.setString(2, newHighRs.getString("buyer_id"));
            updatePs.setInt(3, auctionId);
            updatePs.executeUpdate();
        } else {
            // No more bids - reset to initial state
            PreparedStatement resetPs = con.prepareStatement(
                "UPDATE Auction SET current_high_bid = 0, high_bidder_id = NULL WHERE auction_id = ?");
            resetPs.setInt(1, auctionId);
            resetPs.executeUpdate();
        }
        
        // Notify the bidder
        PreparedStatement notifyPs = con.prepareStatement(
            "INSERT INTO Notification (user_id, message, auction_id) VALUES (?, ?, ?)");
        notifyPs.setString(1, buyerId);
        notifyPs.setString(2, "Your bid of $" + String.format("%.2f", bidAmount) + " on auction #" + auctionId + " has been removed by a customer representative.");
        notifyPs.setInt(3, auctionId);
        notifyPs.executeUpdate();
    }
    
    con.commit();
    response.sendRedirect("editAuction.jsp?id=" + auctionId + "&msg=bidremoved");
    
} catch (Exception e) {
    if (con != null) {
        try { con.rollback(); } catch (SQLException ex) {}
    }
    e.printStackTrace();
    response.sendRedirect("editAuction.jsp?id=" + auctionId + "&error=server");
} finally {
    if (con != null) {
        try { con.setAutoCommit(true); } catch (SQLException ex) {}
        db.closeConnection(con);
    }
}
%>

