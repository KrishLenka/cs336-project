<%@ page import="java.sql.*, db.ApplicationDB" %>
<%-- 
    BuyMe Auction System - Browse Auctions Page
    Displays all active auctions with filtering and sorting options
--%>
<% request.setAttribute("pageTitle", "Browse"); %>
<%@ include file="includes/header.jsp" %>

<%
// Get filter parameters
String categoryParam = request.getParameter("category");
String sortParam = request.getParameter("sort");
String conditionParam = request.getParameter("condition");
String brandParam = request.getParameter("brand");

int categoryId = 0;
if (categoryParam != null && !categoryParam.isEmpty()) {
    try { categoryId = Integer.parseInt(categoryParam); } catch (NumberFormatException e) {}
}

// Default sort
if (sortParam == null || sortParam.isEmpty()) sortParam = "ending";
%>

<div class="container">
    <div class="page-header">
        <h1 class="page-title">Browse Auctions</h1>
        <p class="page-subtitle">Find your next electronics deal</p>
    </div>
    
    <div class="layout-sidebar">
        <!-- Sidebar Filters -->
        <aside class="sidebar">
            <form action="browse.jsp" method="GET">
                <!-- Category Filter -->
                <div class="filter-section">
                    <h4 class="filter-title">Category</h4>
                    <select name="category" class="form-select" onchange="this.form.submit()">
                        <option value="">All Categories</option>
                        <%
                        ApplicationDB dbCat = new ApplicationDB();
                        Connection conCat = null;
                        try {
                            conCat = dbCat.getConnection();
                            // Get main categories (parent_id IS NULL or parent_id = 1)
                            Statement stmtCat = conCat.createStatement();
                            ResultSet rsCat = stmtCat.executeQuery(
                                "SELECT category_id, category_name, parent_id FROM Category ORDER BY category_id");
                            while (rsCat.next()) {
                                int catId = rsCat.getInt("category_id");
                                String catName = rsCat.getString("category_name");
                                int parentId = rsCat.getInt("parent_id");
                                String indent = "";
                                if (parentId > 0 && parentId != 1) indent = "&nbsp;&nbsp;&nbsp;&nbsp;";
                                else if (parentId == 1) indent = "&nbsp;&nbsp;";
                                String selected = (catId == categoryId) ? "selected" : "";
                        %>
                        <option value="<%= catId %>" <%= selected %>><%= indent %><%= catName %></option>
                        <%
                            }
                        } finally {
                            if (conCat != null) dbCat.closeConnection(conCat);
                        }
                        %>
                    </select>
                </div>
                
                <!-- Sort Options -->
                <div class="filter-section">
                    <h4 class="filter-title">Sort By</h4>
                    <div class="radio-group">
                        <label class="radio-label">
                            <input type="radio" name="sort" value="ending" <%= "ending".equals(sortParam) ? "checked" : "" %> onchange="this.form.submit()">
                            Ending Soon
                        </label>
                        <label class="radio-label">
                            <input type="radio" name="sort" value="newest" <%= "newest".equals(sortParam) ? "checked" : "" %> onchange="this.form.submit()">
                            Newest First
                        </label>
                        <label class="radio-label">
                            <input type="radio" name="sort" value="price_low" <%= "price_low".equals(sortParam) ? "checked" : "" %> onchange="this.form.submit()">
                            Price: Low to High
                        </label>
                        <label class="radio-label">
                            <input type="radio" name="sort" value="price_high" <%= "price_high".equals(sortParam) ? "checked" : "" %> onchange="this.form.submit()">
                            Price: High to Low
                        </label>
                        <label class="radio-label">
                            <input type="radio" name="sort" value="bids" <%= "bids".equals(sortParam) ? "checked" : "" %> onchange="this.form.submit()">
                            Most Bids
                        </label>
                    </div>
                </div>
                
                <!-- Condition Filter -->
                <div class="filter-section">
                    <h4 class="filter-title">Condition</h4>
                    <div class="checkbox-group">
                        <label class="checkbox-label">
                            <input type="checkbox" name="condition" value="New" <%= "New".equals(conditionParam) ? "checked" : "" %> onchange="this.form.submit()">
                            New
                        </label>
                        <label class="checkbox-label">
                            <input type="checkbox" name="condition" value="Like New" <%= "Like New".equals(conditionParam) ? "checked" : "" %> onchange="this.form.submit()">
                            Like New
                        </label>
                        <label class="checkbox-label">
                            <input type="checkbox" name="condition" value="Very Good" <%= "Very Good".equals(conditionParam) ? "checked" : "" %> onchange="this.form.submit()">
                            Very Good
                        </label>
                        <label class="checkbox-label">
                            <input type="checkbox" name="condition" value="Good" <%= "Good".equals(conditionParam) ? "checked" : "" %> onchange="this.form.submit()">
                            Good
                        </label>
                    </div>
                </div>
                
                <a href="browse.jsp" class="btn btn-secondary btn-block">Clear Filters</a>
            </form>
        </aside>
        
        <!-- Main Content -->
        <div class="main-content">
            <div class="auction-grid">
                <%
                ApplicationDB db = new ApplicationDB();
                Connection con = null;
                try {
                    con = db.getConnection();
                    
                    // Build query with filters
                    StringBuilder sql = new StringBuilder();
                    sql.append("SELECT a.*, i.item_title, i.item_condition, i.brand, i.model, ");
                    sql.append("c.category_name, u.first_name as seller_name, ");
                    sql.append("(SELECT COUNT(*) FROM Bid b WHERE b.auction_id = a.auction_id) as bid_count ");
                    sql.append("FROM Auction a ");
                    sql.append("JOIN Item i ON a.item_id = i.item_id ");
                    sql.append("JOIN Category c ON i.category_id = c.category_id ");
                    sql.append("JOIN User u ON a.seller_id = u.user_id ");
                    sql.append("WHERE a.is_active = TRUE AND a.close_date > NOW() ");
                    
                    // Category filter (include subcategories)
                    if (categoryId > 0) {
                        sql.append("AND (i.category_id = ? OR i.category_id IN ");
                        sql.append("(SELECT category_id FROM Category WHERE parent_id = ? OR ");
                        sql.append("parent_id IN (SELECT category_id FROM Category WHERE parent_id = ?))) ");
                    }
                    
                    // Condition filter
                    if (conditionParam != null && !conditionParam.isEmpty()) {
                        sql.append("AND i.item_condition = ? ");
                    }
                    
                    // Sort order
                    switch (sortParam) {
                        case "newest":
                            sql.append("ORDER BY a.start_date DESC");
                            break;
                        case "price_low":
                            sql.append("ORDER BY CASE WHEN a.current_high_bid > 0 THEN a.current_high_bid ELSE a.initial_price END ASC");
                            break;
                        case "price_high":
                            sql.append("ORDER BY CASE WHEN a.current_high_bid > 0 THEN a.current_high_bid ELSE a.initial_price END DESC");
                            break;
                        case "bids":
                            sql.append("ORDER BY bid_count DESC");
                            break;
                        default: // ending
                            sql.append("ORDER BY a.close_date ASC");
                    }
                    
                    PreparedStatement ps = con.prepareStatement(sql.toString());
                    int paramIndex = 1;
                    
                    if (categoryId > 0) {
                        ps.setInt(paramIndex++, categoryId);
                        ps.setInt(paramIndex++, categoryId);
                        ps.setInt(paramIndex++, categoryId);
                    }
                    if (conditionParam != null && !conditionParam.isEmpty()) {
                        ps.setString(paramIndex++, conditionParam);
                    }
                    
                    ResultSet rs = ps.executeQuery();
                    int count = 0;
                    
                    while (rs.next()) {
                        count++;
                        String title = rs.getString("item_title");
                        String brand = rs.getString("brand");
                        String model = rs.getString("model");
                        String category = rs.getString("category_name");
                        String condition = rs.getString("item_condition");
                        String sellerName = rs.getString("seller_name");
                        double currentBid = rs.getDouble("current_high_bid");
                        double initialPrice = rs.getDouble("initial_price");
                        Timestamp closeDate = rs.getTimestamp("close_date");
                        int auctionId = rs.getInt("auction_id");
                        int bidCount = rs.getInt("bid_count");
                %>
                <a href="auction.jsp?id=<%= auctionId %>" class="auction-card" style="text-decoration:none;">
                    <div class="auction-image">&#128230;</div>
                    <div class="auction-content">
                        <div class="auction-category"><%= category %></div>
                        <div class="auction-title"><%= title %></div>
                        <div class="auction-seller">
                            <span class="badge badge-info"><%= condition %></span>
                            <% if (brand != null) { %><span class="text-muted"> &middot; <%= brand %></span><% } %>
                        </div>
                        <div class="flex-between mt-2">
                            <span class="text-muted"><%= bidCount %> bid<%= bidCount != 1 ? "s" : "" %></span>
                            <span class="text-muted">by <%= sellerName %></span>
                        </div>
                        <div class="auction-price">
                            <span class="current-bid">$<%= String.format("%.2f", currentBid > 0 ? currentBid : initialPrice) %></span>
                            <span class="time-left" data-close-time="<%= closeDate %>">Loading...</span>
                        </div>
                    </div>
                </a>
                <%
                    }
                    
                    if (count == 0) {
                %>
                <div class="card text-center" style="grid-column: 1 / -1;">
                    <h3>No auctions found</h3>
                    <p>Try adjusting your filters or check back later for new listings.</p>
                </div>
                <%
                    }
                } catch (Exception e) {
                    out.println("<div class='alert alert-error'>Error loading auctions: " + e.getMessage() + "</div>");
                    e.printStackTrace();
                } finally {
                    if (con != null) db.closeConnection(con);
                }
                %>
            </div>
        </div>
    </div>
</div>

<%@ include file="includes/footer.jsp" %>

