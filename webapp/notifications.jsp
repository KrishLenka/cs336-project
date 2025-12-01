<%@ page import="java.sql.*, db.ApplicationDB" %>
<%-- 
    BuyMe Auction System - Notifications Page
--%>
<%
String currentUser = (String) session.getAttribute("user");
if (currentUser == null) {
    response.sendRedirect("login.jsp");
    return;
}
request.setAttribute("pageTitle", "Notifications");
%>
<%@ include file="includes/header.jsp" %>

<div class="container container-md">
    <div class="page-header">
        <h1 class="page-title">Notifications</h1>
        <p class="page-subtitle">Your recent activity and alerts</p>
    </div>
    
    <%
    ApplicationDB db = new ApplicationDB();
    Connection con = null;
    try {
        con = db.getConnection();
        
        // Mark all as read
        if ("markread".equals(request.getParameter("action"))) {
            PreparedStatement markPs = con.prepareStatement(
                "UPDATE Notification SET is_read = TRUE WHERE user_id = ?");
            markPs.setString(1, currentUser);
            markPs.executeUpdate();
        }
        
        // Get notifications
        PreparedStatement ps = con.prepareStatement(
            "SELECT * FROM Notification WHERE user_id = ? ORDER BY created_at DESC LIMIT 50");
        ps.setString(1, currentUser);
        ResultSet rs = ps.executeQuery();
        
        // Count unread
        PreparedStatement countPs = con.prepareStatement(
            "SELECT COUNT(*) as unread FROM Notification WHERE user_id = ? AND is_read = FALSE");
        countPs.setString(1, currentUser);
        ResultSet countRs = countPs.executeQuery();
        int unreadCount = 0;
        if (countRs.next()) unreadCount = countRs.getInt("unread");
    %>
    
    <% if (unreadCount > 0) { %>
    <div class="flex-between mb-3">
        <span class="badge badge-primary"><%= unreadCount %> unread</span>
        <a href="notifications.jsp?action=markread" class="btn btn-sm btn-secondary">Mark All Read</a>
    </div>
    <% } %>
    
    <div class="card">
        <%
        boolean hasNotifications = false;
        while (rs.next()) {
            hasNotifications = true;
            boolean isRead = rs.getBoolean("is_read");
            int auctionId = rs.getInt("auction_id");
        %>
        <div class="bid-item" style="<%= !isRead ? "background: var(--bg-tertiary);" : "" %>">
            <div>
                <% if (!isRead) { %><span class="badge badge-primary" style="margin-right: 8px;">New</span><% } %>
                <%= rs.getString("message") %>
                <% if (auctionId > 0) { %>
                    <a href="auction.jsp?id=<%= auctionId %>" class="text-primary">[View Auction]</a>
                <% } %>
            </div>
            <span class="bid-time"><%= rs.getTimestamp("created_at") %></span>
        </div>
        <%
        }
        if (!hasNotifications) {
        %>
        <p class="text-center text-muted">No notifications yet.</p>
        <% } %>
    </div>
    
    <%
    } catch (Exception e) {
        out.println("<div class='alert alert-error'>Error: " + e.getMessage() + "</div>");
    } finally {
        if (con != null) db.closeConnection(con);
    }
    %>
</div>

<%@ include file="includes/footer.jsp" %>

