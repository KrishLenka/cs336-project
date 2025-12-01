<%@ page import="java.sql.*, db.ApplicationDB" %>
<%
String currentUser = (String) session.getAttribute("user");
if (currentUser == null) {
    response.sendRedirect("login.jsp");
    return;
}

String email = request.getParameter("email");
String firstName = request.getParameter("firstName");
String lastName = request.getParameter("lastName");
String phone = request.getParameter("phone");
String shippingAddress = request.getParameter("shippingAddress");
String cardNumber = request.getParameter("cardNumber");

ApplicationDB db = new ApplicationDB();
Connection con = null;

try {
    con = db.getConnection();
    
    // Update user info
    PreparedStatement ps = con.prepareStatement(
        "UPDATE User SET email = ?, first_name = ?, last_name = ?, phone = ? WHERE user_id = ?");
    ps.setString(1, email);
    ps.setString(2, firstName);
    ps.setString(3, lastName);
    ps.setString(4, phone);
    ps.setString(5, currentUser);
    ps.executeUpdate();
    
    // Update buyer info if applicable
    if (shippingAddress != null && cardNumber != null) {
        PreparedStatement buyerPs = con.prepareStatement(
            "UPDATE Buyer SET shipping_address = ?, default_card = ? WHERE buyer_id = ?");
        buyerPs.setString(1, shippingAddress);
        buyerPs.setString(2, cardNumber);
        buyerPs.setString(3, currentUser);
        buyerPs.executeUpdate();
    }
    
    // Update session
    session.setAttribute("userName", firstName + " " + lastName);
    
    response.sendRedirect("profile.jsp?msg=updated");
    
} catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect("profile.jsp?error=server");
} finally {
    if (con != null) db.closeConnection(con);
}
%>

