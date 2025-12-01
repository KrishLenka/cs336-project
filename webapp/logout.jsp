<%-- 
    BuyMe Auction System - Logout Handler
    Invalidates the session and redirects to login
--%>
<%
// Invalidate the session
session.invalidate();

// Redirect to login page
response.sendRedirect("login.jsp?error=logout");
%>
