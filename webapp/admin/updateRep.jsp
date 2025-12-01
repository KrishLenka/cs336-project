<%@ page import="java.sql.*, db.ApplicationDB" %>
<%
String userType = (String) session.getAttribute("userType");
if (!"admin".equals(userType)) {
    response.sendRedirect("../login.jsp");
    return;
}

String empId = request.getParameter("empId");
String email = request.getParameter("email");
String firstName = request.getParameter("firstName");
String lastName = request.getParameter("lastName");
String phone = request.getParameter("phone");

ApplicationDB db = new ApplicationDB();
Connection con = null;

try {
    con = db.getConnection();
    
    PreparedStatement ps = con.prepareStatement(
        "UPDATE Staff SET email = ?, first_name = ?, last_name = ?, phone = ? WHERE emp_id = ?");
    ps.setString(1, email);
    ps.setString(2, firstName);
    ps.setString(3, lastName);
    ps.setString(4, phone);
    ps.setString(5, empId);
    ps.executeUpdate();
    
    response.sendRedirect("dashboard.jsp?msg=updated");
    
} catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect("editRep.jsp?id=" + empId + "&error=server");
} finally {
    if (con != null) db.closeConnection(con);
}
%>

