<%@ page import="java.sql.*, db.ApplicationDB" %>
<%-- 
    BuyMe Auction System - Auction Close Processor
    This should be called periodically (or can be triggered manually by admin)
    to close ended auctions and process winners
--%>
<%
// This can be called by admin or run as a scheduled task
String userType = (String) session.getAttribute("userType");

ApplicationDB db = new ApplicationDB();
Connection con = null;

int processedCount = 0;
int salesCreated = 0;

try {
    con = db.getConnection();
    con.setAutoCommit(false);
    
    // Find all auctions that have ended but not been processed
    PreparedStatement findPs = con.prepareStatement(
        "SELECT a.*, i.item_id, b.shipping_address, b.default_card " +
        "FROM Auction a " +
        "LEFT JOIN Buyer b ON a.high_bidder_id = b.buyer_id " +
        "JOIN Item i ON a.item_id = i.item_id " +
        "WHERE a.is_active = TRUE AND a.is_closed = FALSE AND a.close_date <= NOW()");
    ResultSet rs = findPs.executeQuery();
    
    while (rs.next()) {
        int auctionId = rs.getInt("auction_id");
        int itemId = rs.getInt("item_id");
        String sellerId = rs.getString("seller_id");
        String highBidderId = rs.getString("high_bidder_id");
        double currentBid = rs.getDouble("current_high_bid");
        double minPrice = rs.getDouble("min_price");
        String shippingAddress = rs.getString("shipping_address");
        String cardNumber = rs.getString("default_card");
        
        processedCount++;
        
        // Check if reserve price was met and there was a bidder
        if (highBidderId != null && currentBid >= minPrice) {
            // Winner! Create a sale record
            PreparedStatement salePs = con.prepareStatement(
                "INSERT INTO Sale (auction_id, item_id, buyer_id, seller_id, final_price, " +
                "shipping_address, payment_card) VALUES (?, ?, ?, ?, ?, ?, ?)");
            salePs.setInt(1, auctionId);
            salePs.setInt(2, itemId);
            salePs.setString(3, highBidderId);
            salePs.setString(4, sellerId);
            salePs.setDouble(5, currentBid);
            salePs.setString(6, shippingAddress != null ? shippingAddress : "");
            salePs.setString(7, cardNumber != null ? cardNumber : "");
            salePs.executeUpdate();
            
            // Update auction with winner info
            PreparedStatement winnerPs = con.prepareStatement(
                "UPDATE Auction SET is_closed = TRUE, winner_id = ?, final_price = ? WHERE auction_id = ?");
            winnerPs.setString(1, highBidderId);
            winnerPs.setDouble(2, currentBid);
            winnerPs.setInt(3, auctionId);
            winnerPs.executeUpdate();
            
            // Update seller earnings
            PreparedStatement earningsPs = con.prepareStatement(
                "UPDATE Seller SET earnings = earnings + ? WHERE seller_id = ?");
            earningsPs.setDouble(1, currentBid);
            earningsPs.setString(2, sellerId);
            earningsPs.executeUpdate();
            
            // Notify winner
            PreparedStatement notifyWinnerPs = con.prepareStatement(
                "INSERT INTO Notification (user_id, message, auction_id) VALUES (?, ?, ?)");
            notifyWinnerPs.setString(1, highBidderId);
            notifyWinnerPs.setString(2, "Congratulations! You won auction #" + auctionId + " for $" + String.format("%.2f", currentBid));
            notifyWinnerPs.setInt(3, auctionId);
            notifyWinnerPs.executeUpdate();
            
            // Notify seller
            PreparedStatement notifySellerPs = con.prepareStatement(
                "INSERT INTO Notification (user_id, message, auction_id) VALUES (?, ?, ?)");
            notifySellerPs.setString(1, sellerId);
            notifySellerPs.setString(2, "Your auction #" + auctionId + " sold for $" + String.format("%.2f", currentBid));
            notifySellerPs.setInt(3, auctionId);
            notifySellerPs.executeUpdate();
            
            salesCreated++;
            
        } else {
            // No winner - reserve not met or no bids
            PreparedStatement closePs = con.prepareStatement(
                "UPDATE Auction SET is_closed = TRUE WHERE auction_id = ?");
            closePs.setInt(1, auctionId);
            closePs.executeUpdate();
            
            // Notify seller
            PreparedStatement notifyPs = con.prepareStatement(
                "INSERT INTO Notification (user_id, message, auction_id) VALUES (?, ?, ?)");
            notifyPs.setString(1, sellerId);
            if (highBidderId == null) {
                notifyPs.setString(2, "Your auction #" + auctionId + " ended with no bids.");
            } else {
                notifyPs.setString(2, "Your auction #" + auctionId + " ended but the reserve price was not met.");
            }
            notifyPs.setInt(3, auctionId);
            notifyPs.executeUpdate();
            
            // If there was a high bidder who didn't meet reserve, notify them
            if (highBidderId != null) {
                PreparedStatement notifyBidderPs = con.prepareStatement(
                    "INSERT INTO Notification (user_id, message, auction_id) VALUES (?, ?, ?)");
                notifyBidderPs.setString(1, highBidderId);
                notifyBidderPs.setString(2, "Auction #" + auctionId + " ended but the reserve price was not met.");
                notifyBidderPs.setInt(3, auctionId);
                notifyBidderPs.executeUpdate();
            }
        }
    }
    
    con.commit();
    
} catch (Exception e) {
    if (con != null) {
        try { con.rollback(); } catch (SQLException ex) {}
    }
    e.printStackTrace();
    out.println("<div class='alert alert-error'>Error processing auctions: " + e.getMessage() + "</div>");
} finally {
    if (con != null) {
        try { con.setAutoCommit(true); } catch (SQLException ex) {}
        db.closeConnection(con);
    }
}

// If called directly (e.g., by admin), show results
if ("admin".equals(userType)) {
%>
<%@ include file="includes/header.jsp" %>
<div class="container container-sm">
    <div class="page-header">
        <h1 class="page-title">Auction Processing Complete</h1>
    </div>
    
    <div class="card text-center">
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-value"><%= processedCount %></div>
                <div class="stat-label">Auctions Processed</div>
            </div>
            <div class="stat-card">
                <div class="stat-value"><%= salesCreated %></div>
                <div class="stat-label">Sales Created</div>
            </div>
        </div>
        
        <a href="admin/dashboard.jsp" class="btn btn-primary mt-3">Back to Dashboard</a>
    </div>
</div>
<%@ include file="includes/footer.jsp" %>
<%
} else {
    // If called programmatically, just output JSON or redirect
    response.setContentType("application/json");
    out.println("{\"processed\": " + processedCount + ", \"sales\": " + salesCreated + "}");
}
%>

