<%@ page import="java.sql.*, db.ApplicationDB" %>
<%
String userType = (String) session.getAttribute("userType");
if (!"rep".equals(userType)) {
    response.sendRedirect("../login.jsp");
    return;
}

String userId = request.getParameter("userId");
String email = request.getParameter("email");
String firstName = request.getParameter("firstName");
String lastName = request.getParameter("lastName");
String phone = request.getParameter("phone");
boolean isActive = "true".equals(request.getParameter("isActive"));

ApplicationDB db = new ApplicationDB();
Connection con = null;

try {
    con = db.getConnection();
    
    PreparedStatement ps = con.prepareStatement(
        "UPDATE User SET email = ?, first_name = ?, last_name = ?, phone = ?, is_active = ? " +
        "WHERE user_id = ?");
    ps.setString(1, email);
    ps.setString(2, firstName);
    ps.setString(3, lastName);
    ps.setString(4, phone);
    ps.setBoolean(5, isActive);
    ps.setString(6, userId);
    ps.executeUpdate();
    
    response.sendRedirect("users.jsp?msg=updated");
    
} catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect("editUser.jsp?id=" + userId + "&error=server");
} finally {
    if (con != null) db.closeConnection(con);
}
%>

