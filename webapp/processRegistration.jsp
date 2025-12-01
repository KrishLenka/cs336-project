<%@ page import="java.sql.*, db.ApplicationDB" %>
<%-- 
    BuyMe Auction System - Registration Handler
    Processes user registration form and creates accounts
--%>
<%
// Get form parameters
String username = request.getParameter("username");
String password = request.getParameter("password");
String confirmPassword = request.getParameter("confirmPassword");
String email = request.getParameter("email");
String phone = request.getParameter("phone");
String firstName = request.getParameter("firstName");
String lastName = request.getParameter("lastName");
String dob = request.getParameter("dob");
boolean isBuyer = "true".equals(request.getParameter("isBuyer"));
boolean isSeller = "true".equals(request.getParameter("isSeller"));
String shippingAddress = request.getParameter("shippingAddress");
String cardNumber = request.getParameter("cardNumber");

// Validate required fields
if (username == null || password == null || email == null || phone == null ||
    firstName == null || lastName == null || dob == null ||
    username.trim().isEmpty() || password.trim().isEmpty()) {
    response.sendRedirect("register.jsp?error=invalid");
    return;
}

// Check password match
if (!password.equals(confirmPassword)) {
    response.sendRedirect("register.jsp?error=password");
    return;
}

// Must be either buyer or seller (or both)
if (!isBuyer && !isSeller) {
    response.sendRedirect("register.jsp?error=invalid");
    return;
}

// If buyer, validate buyer fields
if (isBuyer && (shippingAddress == null || cardNumber == null ||
    shippingAddress.trim().isEmpty() || cardNumber.trim().isEmpty())) {
    response.sendRedirect("register.jsp?error=invalid");
    return;
}

ApplicationDB db = new ApplicationDB();
Connection con = null;

try {
    con = db.getConnection();
    con.setAutoCommit(false); // Start transaction
    
    // Check if username or email already exists
    PreparedStatement checkPs = con.prepareStatement(
        "SELECT user_id FROM User WHERE user_id = ? OR email = ?");
    checkPs.setString(1, username.trim());
    checkPs.setString(2, email.trim());
    ResultSet checkRs = checkPs.executeQuery();
    
    if (checkRs.next()) {
        response.sendRedirect("register.jsp?error=exists");
        return;
    }
    
    // Insert into User table
    PreparedStatement userPs = con.prepareStatement(
        "INSERT INTO User (user_id, password, email, phone, first_name, last_name, dob) " +
        "VALUES (?, ?, ?, ?, ?, ?, ?)");
    userPs.setString(1, username.trim());
    userPs.setString(2, password); // In production, this should be hashed
    userPs.setString(3, email.trim());
    userPs.setString(4, phone.trim());
    userPs.setString(5, firstName.trim());
    userPs.setString(6, lastName.trim());
    userPs.setDate(7, java.sql.Date.valueOf(dob));
    userPs.executeUpdate();
    
    // If buyer, insert into Buyer table
    if (isBuyer) {
        PreparedStatement buyerPs = con.prepareStatement(
            "INSERT INTO Buyer (buyer_id, shipping_address, default_card) VALUES (?, ?, ?)");
        buyerPs.setString(1, username.trim());
        buyerPs.setString(2, shippingAddress.trim());
        buyerPs.setString(3, cardNumber.trim());
        buyerPs.executeUpdate();
    }
    
    // If seller, insert into Seller table
    if (isSeller) {
        PreparedStatement sellerPs = con.prepareStatement(
            "INSERT INTO Seller (seller_id, earnings, rating, total_ratings) VALUES (?, 0.00, 0.00, 0)");
        sellerPs.setString(1, username.trim());
        sellerPs.executeUpdate();
    }
    
    con.commit(); // Commit transaction
    
    // Redirect to login with success message
    response.sendRedirect("login.jsp?success=registered");
    
} catch (Exception e) {
    if (con != null) {
        try { con.rollback(); } catch (SQLException ex) {}
    }
    e.printStackTrace();
    response.sendRedirect("register.jsp?error=server");
} finally {
    if (con != null) {
        try { con.setAutoCommit(true); } catch (SQLException ex) {}
        db.closeConnection(con);
    }
}
%>

