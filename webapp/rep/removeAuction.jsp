<%@ page import="java.sql.*, db.ApplicationDB" %>
<%
String userType = (String) session.getAttribute("userType");
if (!"rep".equals(userType)) {
    response.sendRedirect("../login.jsp");
    return;
}

String auctionIdParam = request.getParameter("auctionId");
if (auctionIdParam == null) {
    response.sendRedirect("auctions.jsp");
    return;
}

int auctionId = Integer.parseInt(auctionIdParam);

ApplicationDB db = new ApplicationDB();
Connection con = null;

try {
    con = db.getConnection();
    
    // Mark auction as inactive (don't delete - keep for records)
    PreparedStatement ps = con.prepareStatement(
        "UPDATE Auction SET is_active = FALSE, is_closed = TRUE WHERE auction_id = ?");
    ps.setInt(1, auctionId);
    ps.executeUpdate();
    
    // Notify seller
    PreparedStatement sellerPs = con.prepareStatement(
        "SELECT seller_id FROM Auction WHERE auction_id = ?");
    sellerPs.setInt(1, auctionId);
    ResultSet sellerRs = sellerPs.executeQuery();
    
    if (sellerRs.next()) {
        PreparedStatement notifyPs = con.prepareStatement(
            "INSERT INTO Notification (user_id, message, auction_id) VALUES (?, ?, ?)");
        notifyPs.setString(1, sellerRs.getString("seller_id"));
        notifyPs.setString(2, "Your auction #" + auctionId + " has been removed by a customer representative.");
        notifyPs.setInt(3, auctionId);
        notifyPs.executeUpdate();
    }
    
    response.sendRedirect("auctions.jsp?msg=removed");
    
} catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect("editAuction.jsp?id=" + auctionId + "&error=server");
} finally {
    if (con != null) db.closeConnection(con);
}
%>

