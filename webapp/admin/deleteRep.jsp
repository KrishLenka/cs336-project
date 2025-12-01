<%@ page import="java.sql.*, db.ApplicationDB" %>
<%
String userType = (String) session.getAttribute("userType");
if (!"admin".equals(userType)) {
    response.sendRedirect("../login.jsp");
    return;
}

String empId = request.getParameter("empId");

ApplicationDB db = new ApplicationDB();
Connection con = null;

try {
    con = db.getConnection();
    
    // Delete from Staff (will cascade to CustomerRep)
    PreparedStatement ps = con.prepareStatement("DELETE FROM Staff WHERE emp_id = ?");
    ps.setString(1, empId);
    ps.executeUpdate();
    
    response.sendRedirect("dashboard.jsp?msg=deleted");
    
} catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect("editRep.jsp?id=" + empId + "&error=server");
} finally {
    if (con != null) db.closeConnection(con);
}
%>

