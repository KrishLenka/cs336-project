<%@ page import="java.sql.*, db.ApplicationDB" %>
<%
String userType = (String) session.getAttribute("userType");
if (!"admin".equals(userType)) {
    response.sendRedirect("../login.jsp");
    return;
}

String adminId = (String) session.getAttribute("empId");
String empId = request.getParameter("empId");
String password = request.getParameter("password");
String firstName = request.getParameter("firstName");
String lastName = request.getParameter("lastName");
String email = request.getParameter("email");
String phone = request.getParameter("phone");
String dob = request.getParameter("dob");

// Validate
if (empId == null || password == null || firstName == null || lastName == null ||
    email == null || phone == null || dob == null ||
    empId.trim().isEmpty() || password.trim().isEmpty()) {
    response.sendRedirect("createRep.jsp?error=invalid");
    return;
}

ApplicationDB db = new ApplicationDB();
Connection con = null;

try {
    con = db.getConnection();
    con.setAutoCommit(false);
    
    // Check if emp_id exists
    PreparedStatement checkPs = con.prepareStatement("SELECT emp_id FROM Staff WHERE emp_id = ?");
    checkPs.setString(1, empId.trim());
    if (checkPs.executeQuery().next()) {
        response.sendRedirect("createRep.jsp?error=exists");
        return;
    }
    
    // Insert into Staff
    PreparedStatement staffPs = con.prepareStatement(
        "INSERT INTO Staff (emp_id, password, email, phone, first_name, last_name, dob) " +
        "VALUES (?, ?, ?, ?, ?, ?, ?)");
    staffPs.setString(1, empId.trim());
    staffPs.setString(2, password);
    staffPs.setString(3, email.trim());
    staffPs.setString(4, phone.trim());
    staffPs.setString(5, firstName.trim());
    staffPs.setString(6, lastName.trim());
    staffPs.setDate(7, java.sql.Date.valueOf(dob));
    staffPs.executeUpdate();
    
    // Insert into CustomerRep
    PreparedStatement repPs = con.prepareStatement(
        "INSERT INTO CustomerRep (emp_id, created_by) VALUES (?, ?)");
    repPs.setString(1, empId.trim());
    repPs.setString(2, adminId);
    repPs.executeUpdate();
    
    con.commit();
    response.sendRedirect("dashboard.jsp?msg=repcreated");
    
} catch (Exception e) {
    if (con != null) {
        try { con.rollback(); } catch (SQLException ex) {}
    }
    e.printStackTrace();
    response.sendRedirect("createRep.jsp?error=server");
} finally {
    if (con != null) {
        try { con.setAutoCommit(true); } catch (SQLException ex) {}
        db.closeConnection(con);
    }
}
%>

