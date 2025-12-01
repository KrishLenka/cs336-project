<%@ page import="java.sql.*, db.ApplicationDB" %>
<%
String currentUser = (String) session.getAttribute("user");
if (currentUser == null) {
    response.sendRedirect("login.jsp");
    return;
}

String currentPassword = request.getParameter("currentPassword");
String newPassword = request.getParameter("newPassword");
String confirmPassword = request.getParameter("confirmPassword");

if (!newPassword.equals(confirmPassword)) {
    response.sendRedirect("profile.jsp?error=mismatch");
    return;
}

ApplicationDB db = new ApplicationDB();
Connection con = null;

try {
    con = db.getConnection();
    
    // Verify current password
    PreparedStatement checkPs = con.prepareStatement(
        "SELECT * FROM User WHERE user_id = ? AND password = ?");
    checkPs.setString(1, currentUser);
    checkPs.setString(2, currentPassword);
    
    if (!checkPs.executeQuery().next()) {
        response.sendRedirect("profile.jsp?error=wrongpassword");
        return;
    }
    
    // Update password
    PreparedStatement ps = con.prepareStatement(
        "UPDATE User SET password = ? WHERE user_id = ?");
    ps.setString(1, newPassword);
    ps.setString(2, currentUser);
    ps.executeUpdate();
    
    response.sendRedirect("profile.jsp?msg=updated");
    
} catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect("profile.jsp?error=server");
} finally {
    if (con != null) db.closeConnection(con);
}
%>

