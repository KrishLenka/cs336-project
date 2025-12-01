<%@ page import="java.sql.*, db.ApplicationDB" %>
<%
String userType = (String) session.getAttribute("userType");
if (!"rep".equals(userType)) {
    response.sendRedirect("../login.jsp");
    return;
}

String repId = (String) session.getAttribute("empId");
String questionIdParam = request.getParameter("questionId");
String responseText = request.getParameter("response");

if (questionIdParam == null || responseText == null || responseText.trim().isEmpty()) {
    response.sendRedirect("questions.jsp");
    return;
}

int questionId = Integer.parseInt(questionIdParam);

ApplicationDB db = new ApplicationDB();
Connection con = null;

try {
    con = db.getConnection();
    
    // Update question with response
    PreparedStatement ps = con.prepareStatement(
        "UPDATE Question SET response = ?, responded_by = ?, is_resolved = TRUE, resolved_at = NOW() " +
        "WHERE question_id = ?");
    ps.setString(1, responseText.trim());
    ps.setString(2, repId);
    ps.setInt(3, questionId);
    ps.executeUpdate();
    
    // Notify user
    PreparedStatement userPs = con.prepareStatement("SELECT user_id FROM Question WHERE question_id = ?");
    userPs.setInt(1, questionId);
    ResultSet userRs = userPs.executeQuery();
    
    if (userRs.next()) {
        PreparedStatement notifyPs = con.prepareStatement(
            "INSERT INTO Notification (user_id, message) VALUES (?, ?)");
        notifyPs.setString(1, userRs.getString("user_id"));
        notifyPs.setString(2, "Your question has been answered by our support team.");
        notifyPs.executeUpdate();
    }
    
    response.sendRedirect("questions.jsp");
    
} catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect("answerQuestion.jsp?id=" + questionId + "&error=server");
} finally {
    if (con != null) db.closeConnection(con);
}
%>

