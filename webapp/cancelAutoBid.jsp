<%@ page import="java.sql.*, db.ApplicationDB" %>
<%-- 
    BuyMe Auction System - Cancel Auto-Bid Handler
--%>
<%
String currentUser = (String) session.getAttribute("user");
if (currentUser == null) {
    response.sendRedirect("login.jsp");
    return;
}

String auctionIdParam = request.getParameter("auctionId");
if (auctionIdParam == null) {
    response.sendRedirect("browse.jsp");
    return;
}

int auctionId = Integer.parseInt(auctionIdParam);

ApplicationDB db = new ApplicationDB();
Connection con = null;

try {
    con = db.getConnection();
    
    PreparedStatement ps = con.prepareStatement(
        "UPDATE AutoBidSetting SET is_active = FALSE WHERE auction_id = ? AND buyer_id = ?");
    ps.setInt(1, auctionId);
    ps.setString(2, currentUser);
    ps.executeUpdate();
    
    response.sendRedirect("auction.jsp?id=" + auctionId + "&msg=autobid_cancelled");
    
} catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect("auction.jsp?id=" + auctionId + "&error=server");
} finally {
    if (con != null) db.closeConnection(con);
}
%>

