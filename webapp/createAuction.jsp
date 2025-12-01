<%@ page import="java.sql.*, db.ApplicationDB" %>
<%-- 
    BuyMe Auction System - Create Auction Handler
    Processes auction creation form and inserts item + auction records
--%>
<%
String currentUser = (String) session.getAttribute("user");
if (currentUser == null) {
    response.sendRedirect("login.jsp");
    return;
}

// Get form data
String title = request.getParameter("title");
String description = request.getParameter("description");
String categoryIdParam = request.getParameter("categoryId");
String condition = request.getParameter("condition");
String brand = request.getParameter("brand");
String model = request.getParameter("model");
String yearMadeParam = request.getParameter("yearMade");
String initialPriceParam = request.getParameter("initialPrice");
String incrementParam = request.getParameter("increment");
String minPriceParam = request.getParameter("minPrice");
String closeDateParam = request.getParameter("closeDate");

// Category-specific fields
String processor = request.getParameter("processor");
String ramParam = request.getParameter("ram");
String storageParam = request.getParameter("storage");
String screenSizeParam = request.getParameter("screenSize");
String carrier = request.getParameter("carrier");
String storageCapacity = request.getParameter("storageCapacity");
String color = request.getParameter("color");
String connectivity = request.getParameter("connectivity");
String batteryLifeParam = request.getParameter("batteryLife");
String platform = request.getParameter("platform");
String region = request.getParameter("region");


if (title == null || description == null || categoryIdParam == null || condition == null ||
    initialPriceParam == null || incrementParam == null || minPriceParam == null || closeDateParam == null ||
    title.trim().isEmpty() || description.trim().isEmpty() || closeDateParam.trim().isEmpty()) {
    response.sendRedirect("sell.jsp?error=invalid");
    return;
}


// Parse numeric values
int categoryId = 0;
int yearMade = 0;
double initialPrice = 0;
double increment = 0;
double minPrice = 0;
int ram = 0;
int storage = 0;
double screenSize = 0;
int batteryLife = 0;
Timestamp closeDate = null;

try {
    categoryId = Integer.parseInt(categoryIdParam);
    initialPrice = Double.parseDouble(initialPriceParam);
    increment = Double.parseDouble(incrementParam);
    minPrice = Double.parseDouble(minPriceParam);

    if (yearMadeParam != null && !yearMadeParam.isEmpty()) yearMade = Integer.parseInt(yearMadeParam);
    if (ramParam != null && !ramParam.isEmpty()) ram = Integer.parseInt(ramParam);
    if (storageParam != null && !storageParam.isEmpty()) storage = Integer.parseInt(storageParam);
    if (screenSizeParam != null && !screenSizeParam.isEmpty()) screenSize = Double.parseDouble(screenSizeParam);
    if (batteryLifeParam != null && !batteryLifeParam.isEmpty()) batteryLife = Integer.parseInt(batteryLifeParam);

    // HTML datetime-local sends: yyyy-MM-ddTHH:mm
    String closeDateStr = closeDateParam.replace("T", " ") + ":00"; // -> yyyy-MM-dd HH:mm:ss
    closeDate = Timestamp.valueOf(closeDateStr);

    // optional: require future date/time
    if (closeDate.before(new Timestamp(System.currentTimeMillis()))) {
        response.sendRedirect("sell.jsp?error=pastDate");
        return;
    }

} catch (NumberFormatException | IllegalArgumentException e) {
    response.sendRedirect("sell.jsp?error=invalid");
    return;
}


ApplicationDB db = new ApplicationDB();
Connection con = null;

try {
    con = db.getConnection();
    con.setAutoCommit(false);
    
    // Check if user is a seller
    PreparedStatement sellerCheck = con.prepareStatement("SELECT * FROM Seller WHERE seller_id = ?");
    sellerCheck.setString(1, currentUser);
    if (!sellerCheck.executeQuery().next()) {
        response.sendRedirect("sell.jsp?error=notSeller");
        return;
    }
    
    // Insert item
    PreparedStatement itemPs = con.prepareStatement(
        "INSERT INTO Item (item_title, item_description, item_condition, category_id, " +
        "brand, model, year_manufactured, processor, ram_gb, storage_gb, screen_size_inches, " +
        "carrier, storage_capacity, color, connectivity, battery_life_hours, platform, region) " +
        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        Statement.RETURN_GENERATED_KEYS);
    
    itemPs.setString(1, title.trim());
    itemPs.setString(2, description.trim());
    itemPs.setString(3, condition);
    itemPs.setInt(4, categoryId);
    itemPs.setString(5, brand != null && !brand.isEmpty() ? brand.trim() : null);
    itemPs.setString(6, model != null && !model.isEmpty() ? model.trim() : null);
    itemPs.setObject(7, yearMade > 0 ? yearMade : null);
    itemPs.setString(8, processor != null && !processor.isEmpty() ? processor.trim() : null);
    itemPs.setObject(9, ram > 0 ? ram : null);
    itemPs.setObject(10, storage > 0 ? storage : null);
    itemPs.setObject(11, screenSize > 0 ? screenSize : null);
    itemPs.setString(12, carrier != null && !carrier.isEmpty() ? carrier.trim() : null);
    itemPs.setString(13, storageCapacity != null && !storageCapacity.isEmpty() ? storageCapacity.trim() : null);
    itemPs.setString(14, color != null && !color.isEmpty() ? color.trim() : null);
    itemPs.setString(15, connectivity != null && !connectivity.isEmpty() ? connectivity : null);
    itemPs.setObject(16, batteryLife > 0 ? batteryLife : null);
    itemPs.setString(17, platform != null && !platform.isEmpty() ? platform.trim() : null);
    itemPs.setString(18, region != null && !region.isEmpty() ? region.trim() : null);
    
    itemPs.executeUpdate();
    
    // Get the generated item ID
    ResultSet keys = itemPs.getGeneratedKeys();
    if (!keys.next()) {
        throw new SQLException("Failed to get item ID");
    }
    int itemId = keys.getInt(1);
    
   
    // Insert auction
    PreparedStatement auctionPs = con.prepareStatement(
        "INSERT INTO Auction (item_id, seller_id, close_date, initial_price, increment_price, min_price) " +
        "VALUES (?, ?, ?, ?, ?, ?)",
        Statement.RETURN_GENERATED_KEYS);
    
    auctionPs.setInt(1, itemId);
    auctionPs.setString(2, currentUser);
    auctionPs.setTimestamp(3, closeDate);
    auctionPs.setDouble(4, initialPrice);
    auctionPs.setDouble(5, increment);
    auctionPs.setDouble(6, minPrice);
    
    auctionPs.executeUpdate();
    
    // Get auction ID
    ResultSet auctionKeys = auctionPs.getGeneratedKeys();
    int auctionId = 0;
    if (auctionKeys.next()) {
        auctionId = auctionKeys.getInt(1);
    }
    
    // Trigger alerts for matching buyers
    triggerAlerts(con, itemId, categoryId, brand, title);
    
    con.commit();
    
    // Redirect to the new auction page
    response.sendRedirect("auction.jsp?id=" + auctionId + "&msg=created");
    
} catch (Exception e) {
    if (con != null) {
        try { con.rollback(); } catch (SQLException ex) {}
    }
    e.printStackTrace();
    response.sendRedirect("sell.jsp?error=server");
} finally {
    if (con != null) {
        try { con.setAutoCommit(true); } catch (SQLException ex) {}
        db.closeConnection(con);
    }
}
%>

<%!
/**
 * Check alerts and notify buyers about matching new listings
 */
private void triggerAlerts(Connection con, int itemId, int categoryId, String brand, String title) throws SQLException {
    // Find matching alerts
    PreparedStatement alertPs = con.prepareStatement(
        "SELECT a.*, u.first_name FROM Alert a " +
        "JOIN User u ON a.buyer_id = u.user_id " +
        "WHERE a.is_active = TRUE AND (" +
        "  (a.category_id = ? OR a.category_id IN (SELECT parent_id FROM Category WHERE category_id = ?)) " +
        "  OR (a.brand IS NOT NULL AND ? LIKE CONCAT('%', a.brand, '%')) " +
        "  OR (a.keyword IS NOT NULL AND ? LIKE CONCAT('%', a.keyword, '%')) " +
        ")");
    alertPs.setInt(1, categoryId);
    alertPs.setInt(2, categoryId);
    alertPs.setString(3, brand != null ? brand : "");
    alertPs.setString(4, title);
    
    ResultSet alertRs = alertPs.executeQuery();
    
    while (alertRs.next()) {
        // Create notification for matching alert
        PreparedStatement notifyPs = con.prepareStatement(
            "INSERT INTO Notification (user_id, message, auction_id) " +
            "SELECT ?, ?, auction_id FROM Auction WHERE item_id = ?");
        notifyPs.setString(1, alertRs.getString("buyer_id"));
        notifyPs.setString(2, "New item matching your alert: " + title);
        notifyPs.setInt(3, itemId);
        notifyPs.executeUpdate();
    }
}
%>

