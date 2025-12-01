<%@ page import="java.sql.*, db.ApplicationDB" %>
<%-- 
    BuyMe Auction System - Create Alert Handler
--%>
<%
String currentUser = (String) session.getAttribute("user");
if (currentUser == null) {
    response.sendRedirect("login.jsp");
    return;
}

String categoryIdParam = request.getParameter("categoryId");
String keyword = request.getParameter("keyword");
String brand = request.getParameter("brand");
String minPriceParam = request.getParameter("minPrice");
String maxPriceParam = request.getParameter("maxPrice");

ApplicationDB db = new ApplicationDB();
Connection con = null;

try {
    con = db.getConnection();
    
    // Check if user is a buyer
    PreparedStatement buyerCheck = con.prepareStatement("SELECT * FROM Buyer WHERE buyer_id = ?");
    buyerCheck.setString(1, currentUser);
    if (!buyerCheck.executeQuery().next()) {
        response.sendRedirect("alerts.jsp?error=notBuyer");
        return;
    }
    
    PreparedStatement ps = con.prepareStatement(
        "INSERT INTO Alert (buyer_id, category_id, keyword, brand, min_price, max_price) " +
        "VALUES (?, ?, ?, ?, ?, ?)");
    
    ps.setString(1, currentUser);
    
    if (categoryIdParam != null && !categoryIdParam.isEmpty()) {
        ps.setInt(2, Integer.parseInt(categoryIdParam));
    } else {
        ps.setNull(2, java.sql.Types.INTEGER);
    }
    
    ps.setString(3, keyword != null && !keyword.isEmpty() ? keyword.trim() : null);
    ps.setString(4, brand != null && !brand.isEmpty() ? brand.trim() : null);
    
    if (minPriceParam != null && !minPriceParam.isEmpty()) {
        ps.setDouble(5, Double.parseDouble(minPriceParam));
    } else {
        ps.setNull(5, java.sql.Types.DECIMAL);
    }
    
    if (maxPriceParam != null && !maxPriceParam.isEmpty()) {
        ps.setDouble(6, Double.parseDouble(maxPriceParam));
    } else {
        ps.setNull(6, java.sql.Types.DECIMAL);
    }
    
    ps.executeUpdate();
    
    response.sendRedirect("alerts.jsp?msg=created");
    
} catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect("alerts.jsp?error=server");
} finally {
    if (con != null) db.closeConnection(con);
}
%>

