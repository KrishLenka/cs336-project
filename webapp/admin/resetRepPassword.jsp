<%@ page import="java.sql.*, db.ApplicationDB" %>
<%
String userType = (String) session.getAttribute("userType");
if (!"admin".equals(userType)) {
    response.sendRedirect("../login.jsp");
    return;
}

String empId = request.getParameter("empId");
String newPassword = request.getParameter("newPassword");

ApplicationDB db = new ApplicationDB();
Connection con = null;

try {
    con = db.getConnection();
    
    PreparedStatement ps = con.prepareStatement("UPDATE Staff SET password = ? WHERE emp_id = ?");
    ps.setString(1, newPassword);
    ps.setString(2, empId);
    ps.executeUpdate();
    
    response.sendRedirect("dashboard.jsp?msg=updated");
    
} catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect("editRep.jsp?id=" + empId + "&error=server");
} finally {
    if (con != null) db.closeConnection(con);
}
%>

