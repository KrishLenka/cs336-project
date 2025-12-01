<%@ page import="java.sql.*, db.ApplicationDB" %>
<%
String userType = (String) session.getAttribute("userType");
if (!"rep".equals(userType)) {
    response.sendRedirect("../login.jsp");
    return;
}

String userId = request.getParameter("userId");
String newPassword = request.getParameter("newPassword");

if (userId == null || newPassword == null || userId.trim().isEmpty() || newPassword.length() < 6) {
    response.sendRedirect("resetPassword.jsp?error=invalid");
    return;
}

ApplicationDB db = new ApplicationDB();
Connection con = null;

try {
    con = db.getConnection();
    
    // Check if user exists
    PreparedStatement checkPs = con.prepareStatement("SELECT user_id FROM User WHERE user_id = ?");
    checkPs.setString(1, userId.trim());
    if (!checkPs.executeQuery().next()) {
        response.sendRedirect("resetPassword.jsp?error=notfound");
        return;
    }
    
    // Update password
    PreparedStatement ps = con.prepareStatement("UPDATE User SET password = ? WHERE user_id = ?");
    ps.setString(1, newPassword);
    ps.setString(2, userId.trim());
    ps.executeUpdate();
    
    response.sendRedirect("resetPassword.jsp?msg=success");
    
} catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect("resetPassword.jsp?error=server");
} finally {
    if (con != null) db.closeConnection(con);
}
%>

