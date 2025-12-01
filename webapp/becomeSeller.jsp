<%@ page import="java.sql.*, db.ApplicationDB" %>
<%
String currentUser = (String) session.getAttribute("user");
if (currentUser == null) {
    response.sendRedirect("login.jsp");
    return;
}

ApplicationDB db = new ApplicationDB();
Connection con = null;

try {
    con = db.getConnection();
    
    PreparedStatement ps = con.prepareStatement(
        "INSERT INTO Seller (seller_id, earnings, rating, total_ratings) VALUES (?, 0.00, 0.00, 0)");
    ps.setString(1, currentUser);
    ps.executeUpdate();
    
    session.setAttribute("isSeller", true);
    response.sendRedirect("profile.jsp?msg=updated");
    
} catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect("profile.jsp?error=server");
} finally {
    if (con != null) db.closeConnection(con);
}
%>

