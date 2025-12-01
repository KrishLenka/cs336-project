<%@ page import="java.sql.*, db.ApplicationDB" %>
<%-- 
    BuyMe Auction System - Full Bid History Page
--%>
<%
String auctionIdParam = request.getParameter("auction");
if (auctionIdParam == null) {
    response.sendRedirect("browse.jsp");
    return;
}
int auctionId = Integer.parseInt(auctionIdParam);
request.setAttribute("pageTitle", "Bid History");
%>
<%@ include file="includes/header.jsp" %>

<div class="container container-md">
    <%
    ApplicationDB db = new ApplicationDB();
    Connection con = null;
    try {
        con = db.getConnection();
        
        // Get auction info
        PreparedStatement auctionPs = con.prepareStatement(
            "SELECT a.*, i.item_title FROM Auction a " +
            "JOIN Item i ON a.item_id = i.item_id WHERE a.auction_id = ?");
        auctionPs.setInt(1, auctionId);
        ResultSet auctionRs = auctionPs.executeQuery();
        
        if (auctionRs.next()) {
    %>
    
    <div class="page-header">
        <h1 class="page-title">Bid History</h1>
        <p class="page-subtitle">
            <a href="auction.jsp?id=<%= auctionId %>"><%= auctionRs.getString("item_title") %></a>
        </p>
    </div>
    
    <div class="card">
        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Bidder</th>
                        <th>Amount</th>
                        <th>Type</th>
                        <th>Time</th>
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
                    
                    int count = 0;
                    while (bidRs.next()) {
                        count++;
                        // Anonymize bidder name
                        String bidderName = bidRs.getString("first_name").charAt(0) + "***";
                    %>
                    <tr>
                        <td><%= count %></td>
                        <td><%= bidderName %></td>
                        <td class="text-primary">$<%= String.format("%.2f", bidRs.getDouble("bid_amount")) %></td>
                        <td>
                            <% if (bidRs.getBoolean("is_auto_bid")) { %>
                                <span class="badge badge-info">Auto</span>
                            <% } else { %>
                                <span class="badge badge-secondary">Manual</span>
                            <% } %>
                        </td>
                        <td class="text-muted"><%= bidRs.getTimestamp("bid_time") %></td>
                    </tr>
                    <% }
                    if (count == 0) { %>
                    <tr><td colspan="5" class="text-center text-muted">No bids yet</td></tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
    
    <div class="mt-3">
        <a href="auction.jsp?id=<%= auctionId %>" class="btn btn-secondary">&larr; Back to Auction</a>
    </div>
    
    <%
        } else {
            out.println("<div class='alert alert-error'>Auction not found.</div>");
        }
    } catch (Exception e) {
        out.println("<div class='alert alert-error'>Error: " + e.getMessage() + "</div>");
    } finally {
        if (con != null) db.closeConnection(con);
    }
    %>
</div>

<%@ include file="includes/footer.jsp" %>

