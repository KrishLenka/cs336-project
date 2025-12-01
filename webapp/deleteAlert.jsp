<%@ page import="java.sql.*, db.ApplicationDB" %>
<%
String currentUser = (String) session.getAttribute("user");
if (currentUser == null) {
    response.sendRedirect("login.jsp");
    return;
}

String alertIdParam = request.getParameter("alertId");
if (alertIdParam == null) {
    response.sendRedirect("alerts.jsp");
    return;
}

ApplicationDB db = new ApplicationDB();
Connection con = null;

try {
    con = db.getConnection();
    
    // Only allow deleting own alerts
    PreparedStatement ps = con.prepareStatement(
        "DELETE FROM Alert WHERE alert_id = ? AND buyer_id = ?");
    ps.setInt(1, Integer.parseInt(alertIdParam));
    ps.setString(2, currentUser);
    ps.executeUpdate();
    
    response.sendRedirect("alerts.jsp?msg=deleted");
    
} catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect("alerts.jsp?error=server");
} finally {
    if (con != null) db.closeConnection(con);
}
%>

