<%@ page import="java.sql.*, db.ApplicationDB" %>
<%
String userType = (String) session.getAttribute("userType");
if (!"rep".equals(userType)) {
    response.sendRedirect("../login.jsp");
    return;
}

String userId = request.getParameter("userId");
String newPassword = request.getParameter("newPassword");

if (userId == null || newPassword == null || newPassword.length() < 6) {
    response.sendRedirect("editUser.jsp?id=" + userId + "&error=invalid");
    return;
}

ApplicationDB db = new ApplicationDB();
Connection con = null;

try {
    con = db.getConnection();
    
    PreparedStatement ps = con.prepareStatement("UPDATE User SET password = ? WHERE user_id = ?");
    ps.setString(1, newPassword);
    ps.setString(2, userId);
    ps.executeUpdate();
    
    response.sendRedirect("users.jsp?msg=updated");
    
} catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect("editUser.jsp?id=" + userId + "&error=server");
} finally {
    if (con != null) db.closeConnection(con);
}
%>

