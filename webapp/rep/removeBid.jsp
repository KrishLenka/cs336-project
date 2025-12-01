<%@ page import="java.sql.*, db.ApplicationDB" %>
<%
String userType = (String) session.getAttribute("userType");
if (!"rep".equals(userType)) {
    response.sendRedirect("../login.jsp");
    return;
}
request.setAttribute("pageTitle", "Remove Bid");
String message = request.getParameter("msg");
%>
<%@ include file="../includes/header.jsp" %>

<div class="container container-sm">
    <div class="page-header">
        <h1 class="page-title">Remove a Bid</h1>
        <p class="page-subtitle">Enter the auction ID to manage its bids</p>
    </div>
    
    <% if ("removed".equals(message)) { %>
        <div class="alert alert-success">Bid removed successfully!</div>
    <% } %>
    
    <div class="card">
        <form action="editAuction.jsp" method="GET">
            <div class="form-group">
                <label class="form-label" for="id">Auction ID</label>
                <input type="number" id="id" name="id" class="form-input" min="1" required>
            </div>
            <button type="submit" class="btn btn-primary">View Auction Bids</button>
        </form>
    </div>
    
    <div class="mt-3">
        <a href="dashboard.jsp" class="btn btn-secondary">&larr; Back to Dashboard</a>
    </div>
</div>

<%@ include file="../includes/footer.jsp" %>

