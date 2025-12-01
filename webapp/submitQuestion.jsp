<%@ page import="java.sql.*, db.ApplicationDB" %>
<%
String currentUser = (String) session.getAttribute("user");
if (currentUser == null) {
    response.sendRedirect("login.jsp");
    return;
}

String subject = request.getParameter("subject");
String message = request.getParameter("message");

if (subject == null || message == null || subject.trim().isEmpty() || message.trim().isEmpty()) {
    response.sendRedirect("askQuestion.jsp?error=invalid");
    return;
}

ApplicationDB db = new ApplicationDB();
Connection con = null;

try {
    con = db.getConnection();
    
    PreparedStatement ps = con.prepareStatement(
        "INSERT INTO Question (user_id, subject, message) VALUES (?, ?, ?)");
    ps.setString(1, currentUser);
    ps.setString(2, subject.trim());
    ps.setString(3, message.trim());
    ps.executeUpdate();
    
    response.sendRedirect("askQuestion.jsp?msg=sent");
    
} catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect("askQuestion.jsp?error=server");
} finally {
    if (con != null) db.closeConnection(con);
}
%>

