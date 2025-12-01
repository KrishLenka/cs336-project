<%@ page import="java.sql.*, db.ApplicationDB" %>
<%-- 
    BuyMe Auction System - Authentication Handler
    Validates login credentials for users, customer reps, and admins
--%>
<%
String username = request.getParameter("username");
String password = request.getParameter("password");
String userType = request.getParameter("userType");

// Validate input
if (username == null || password == null || userType == null ||
    username.trim().isEmpty() || password.trim().isEmpty()) {
    response.sendRedirect("login.jsp?error=invalid");
    return;
}

username = username.trim();
password = password.trim();

ApplicationDB db = new ApplicationDB();
Connection con = null;

try {
    con = db.getConnection();
    PreparedStatement ps;
    ResultSet rs;
    
    if ("admin".equals(userType)) {
        // Check admin credentials
        ps = con.prepareStatement(
            "SELECT s.* FROM Staff s " +
            "JOIN Admin a ON s.emp_id = a.emp_id " +
            "WHERE s.emp_id = ? AND s.password = ?");
        ps.setString(1, username);
        ps.setString(2, password);
        rs = ps.executeQuery();
        
        if (rs.next()) {
            session.setAttribute("user", username);
            session.setAttribute("userType", "admin");
            session.setAttribute("userName", rs.getString("first_name") + " " + rs.getString("last_name"));
            session.setAttribute("empId", rs.getString("emp_id"));
            response.sendRedirect("admin/dashboard.jsp");
            return;
        }
        
    } else if ("rep".equals(userType)) {
        // Check customer rep credentials
        ps = con.prepareStatement(
            "SELECT s.* FROM Staff s " +
            "JOIN CustomerRep cr ON s.emp_id = cr.emp_id " +
            "WHERE s.emp_id = ? AND s.password = ?");
        ps.setString(1, username);
        ps.setString(2, password);
        rs = ps.executeQuery();
        
        if (rs.next()) {
            session.setAttribute("user", username);
            session.setAttribute("userType", "rep");
            session.setAttribute("userName", rs.getString("first_name") + " " + rs.getString("last_name"));
            session.setAttribute("empId", rs.getString("emp_id"));
            response.sendRedirect("rep/dashboard.jsp");
            return;
        }
        
    } else {
        // Check regular user credentials
        ps = con.prepareStatement(
            "SELECT * FROM User WHERE user_id = ? AND password = ? AND is_active = TRUE");
        ps.setString(1, username);
        ps.setString(2, password);
        rs = ps.executeQuery();
        
        if (rs.next()) {
            session.setAttribute("user", username);
            session.setAttribute("userType", "user");
            session.setAttribute("userName", rs.getString("first_name") + " " + rs.getString("last_name"));
            session.setAttribute("userId", rs.getString("user_id"));
            session.setAttribute("userEmail", rs.getString("email"));
            
            // Check if user is a buyer
            PreparedStatement buyerPs = con.prepareStatement(
                "SELECT * FROM Buyer WHERE buyer_id = ?");
            buyerPs.setString(1, username);
            ResultSet buyerRs = buyerPs.executeQuery();
            session.setAttribute("isBuyer", buyerRs.next());
            
            // Check if user is a seller
            PreparedStatement sellerPs = con.prepareStatement(
                "SELECT * FROM Seller WHERE seller_id = ?");
            sellerPs.setString(1, username);
            ResultSet sellerRs = sellerPs.executeQuery();
            session.setAttribute("isSeller", sellerRs.next());
            
            response.sendRedirect("index.jsp");
            return;
        }
    }
    
    // If we get here, credentials were invalid
    response.sendRedirect("login.jsp?error=invalid");
    
} catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect("login.jsp?error=server");
} finally {
    if (con != null) db.closeConnection(con);
}
%>

