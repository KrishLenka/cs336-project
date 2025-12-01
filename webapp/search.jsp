<%@ page import="java.sql.*, db.ApplicationDB" %>
<%-- 
    BuyMe Auction System - Advanced Search Page
    Provides comprehensive search functionality with multiple criteria
--%>
<% request.setAttribute("pageTitle", "Search"); %>
<%@ include file="includes/header.jsp" %>

<%
// Get search parameters
String keyword = request.getParameter("keyword");
String categoryParam = request.getParameter("category");
String minPriceParam = request.getParameter("minPrice");
String maxPriceParam = request.getParameter("maxPrice");
String conditionParam = request.getParameter("condition");
String brandParam = request.getParameter("brand");
String sellerParam = request.getParameter("seller");
String sortParam = request.getParameter("sort");

int categoryId = 0;
double minPrice = 0;
double maxPrice = Double.MAX_VALUE;

if (categoryParam != null && !categoryParam.isEmpty()) {
    try { categoryId = Integer.parseInt(categoryParam); } catch (NumberFormatException e) {}
}
if (minPriceParam != null && !minPriceParam.isEmpty()) {
    try { minPrice = Double.parseDouble(minPriceParam); } catch (NumberFormatException e) {}
}
if (maxPriceParam != null && !maxPriceParam.isEmpty()) {
    try { maxPrice = Double.parseDouble(maxPriceParam); } catch (NumberFormatException e) {}
}
if (sortParam == null) sortParam = "relevance";
%>

<div class="container">
    <div class="page-header">
        <h1 class="page-title">Search Auctions</h1>
        <p class="page-subtitle">Find exactly what you're looking for</p>
    </div>
    
    <!-- Search Form -->
    <div class="card mb-4">
        <form action="search.jsp" method="GET" class="search-form">
            <div class="form-row">
                <div class="form-group" style="flex: 2;">
                    <label class="form-label" for="keyword">Keywords</label>
                    <input type="text" id="keyword" name="keyword" class="form-input" 
                           placeholder="Search by title, description, brand, model..."
                           value="<%= keyword != null ? keyword : "" %>">
                </div>
                <div class="form-group">
                    <label class="form-label" for="category">Category</label>
                    <select id="category" name="category" class="form-select">
                        <option value="">All Categories</option>
                        <%
                        ApplicationDB dbCat = new ApplicationDB();
                        Connection conCat = null;
                        try {
                            conCat = dbCat.getConnection();
                            Statement stmtCat = conCat.createStatement();
                            ResultSet rsCat = stmtCat.executeQuery(
                                "SELECT category_id, category_name, parent_id FROM Category ORDER BY category_id");
                            while (rsCat.next()) {
                                int catId = rsCat.getInt("category_id");
                                String catName = rsCat.getString("category_name");
                                int parentId = rsCat.getInt("parent_id");
                                String indent = "";
                                if (parentId > 0 && parentId != 1) indent = "-- ";
                                else if (parentId == 1) indent = "- ";
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
            </div>
            
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label" for="minPrice">Min Price ($)</label>
                    <input type="number" id="minPrice" name="minPrice" class="form-input" 
                           min="0" step="0.01" value="<%= minPriceParam != null ? minPriceParam : "" %>">
                </div>
                <div class="form-group">
                    <label class="form-label" for="maxPrice">Max Price ($)</label>
                    <input type="number" id="maxPrice" name="maxPrice" class="form-input" 
                           min="0" step="0.01" value="<%= maxPriceParam != null ? maxPriceParam : "" %>">
                </div>
                <div class="form-group">
                    <label class="form-label" for="condition">Condition</label>
                    <select id="condition" name="condition" class="form-select">
                        <option value="">Any Condition</option>
                        <option value="New" <%= "New".equals(conditionParam) ? "selected" : "" %>>New</option>
                        <option value="Like New" <%= "Like New".equals(conditionParam) ? "selected" : "" %>>Like New</option>
                        <option value="Very Good" <%= "Very Good".equals(conditionParam) ? "selected" : "" %>>Very Good</option>
                        <option value="Good" <%= "Good".equals(conditionParam) ? "selected" : "" %>>Good</option>
                        <option value="Acceptable" <%= "Acceptable".equals(conditionParam) ? "selected" : "" %>>Acceptable</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label" for="brand">Brand</label>
                    <input type="text" id="brand" name="brand" class="form-input" 
                           placeholder="e.g., Apple, Samsung"
                           value="<%= brandParam != null ? brandParam : "" %>">
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label" for="seller">Seller Username</label>
                    <input type="text" id="seller" name="seller" class="form-input" 
                           placeholder="Search by seller"
                           value="<%= sellerParam != null ? sellerParam : "" %>">
                </div>
                <div class="form-group">
                    <label class="form-label" for="sort">Sort By</label>
                    <select id="sort" name="sort" class="form-select">
                        <option value="relevance" <%= "relevance".equals(sortParam) ? "selected" : "" %>>Relevance</option>
                        <option value="ending" <%= "ending".equals(sortParam) ? "selected" : "" %>>Ending Soon</option>
                        <option value="newest" <%= "newest".equals(sortParam) ? "selected" : "" %>>Newest First</option>
                        <option value="price_low" <%= "price_low".equals(sortParam) ? "selected" : "" %>>Price: Low to High</option>
                        <option value="price_high" <%= "price_high".equals(sortParam) ? "selected" : "" %>>Price: High to Low</option>
                    </select>
                </div>
                <div class="form-group" style="display: flex; align-items: flex-end;">
                    <button type="submit" class="btn btn-primary">Search</button>
                </div>
            </div>
        </form>
    </div>
    
    <!-- Search Results -->
    <%
    // Only show results if there's at least one search parameter
    boolean hasSearch = (keyword != null && !keyword.isEmpty()) ||
                        categoryId > 0 ||
                        (minPriceParam != null && !minPriceParam.isEmpty()) ||
                        (maxPriceParam != null && !maxPriceParam.isEmpty()) ||
                        (conditionParam != null && !conditionParam.isEmpty()) ||
                        (brandParam != null && !brandParam.isEmpty()) ||
                        (sellerParam != null && !sellerParam.isEmpty());
    
    if (hasSearch) {
    %>
    <h2 class="mb-3">Search Results</h2>
    <div class="auction-grid">
        <%
        ApplicationDB db = new ApplicationDB();
        Connection con = null;
        try {
            con = db.getConnection();
            
            // Build dynamic query
            StringBuilder sql = new StringBuilder();
            sql.append("SELECT a.*, i.item_title, i.item_description, i.item_condition, ");
            sql.append("i.brand, i.model, c.category_name, u.first_name as seller_name, u.user_id as seller_id, ");
            sql.append("(SELECT COUNT(*) FROM Bid b WHERE b.auction_id = a.auction_id) as bid_count ");
            sql.append("FROM Auction a ");
            sql.append("JOIN Item i ON a.item_id = i.item_id ");
            sql.append("JOIN Category c ON i.category_id = c.category_id ");
            sql.append("JOIN User u ON a.seller_id = u.user_id ");
            sql.append("WHERE a.is_active = TRUE AND a.close_date > NOW() ");
            
            // Keyword search (searches title, description, brand, model)
            if (keyword != null && !keyword.isEmpty()) {
                sql.append("AND (i.item_title LIKE ? OR i.item_description LIKE ? ");
                sql.append("OR i.brand LIKE ? OR i.model LIKE ?) ");
            }
            
            // Category filter (include subcategories)
            if (categoryId > 0) {
                sql.append("AND (i.category_id = ? OR i.category_id IN ");
                sql.append("(SELECT category_id FROM Category WHERE parent_id = ? OR ");
                sql.append("parent_id IN (SELECT category_id FROM Category WHERE parent_id = ?))) ");
            }
            
            // Price range
            if (minPriceParam != null && !minPriceParam.isEmpty()) {
                sql.append("AND (CASE WHEN a.current_high_bid > 0 THEN a.current_high_bid ELSE a.initial_price END) >= ? ");
            }
            if (maxPriceParam != null && !maxPriceParam.isEmpty()) {
                sql.append("AND (CASE WHEN a.current_high_bid > 0 THEN a.current_high_bid ELSE a.initial_price END) <= ? ");
            }
            
            // Condition
            if (conditionParam != null && !conditionParam.isEmpty()) {
                sql.append("AND i.item_condition = ? ");
            }
            
            // Brand
            if (brandParam != null && !brandParam.isEmpty()) {
                sql.append("AND i.brand LIKE ? ");
            }
            
            // Seller
            if (sellerParam != null && !sellerParam.isEmpty()) {
                sql.append("AND u.user_id LIKE ? ");
            }
            
            // Sort
            switch (sortParam) {
                case "ending":
                    sql.append("ORDER BY a.close_date ASC");
                    break;
                case "newest":
                    sql.append("ORDER BY a.start_date DESC");
                    break;
                case "price_low":
                    sql.append("ORDER BY CASE WHEN a.current_high_bid > 0 THEN a.current_high_bid ELSE a.initial_price END ASC");
                    break;
                case "price_high":
                    sql.append("ORDER BY CASE WHEN a.current_high_bid > 0 THEN a.current_high_bid ELSE a.initial_price END DESC");
                    break;
                default: // relevance - by keyword match (simple implementation)
                    sql.append("ORDER BY a.close_date ASC");
            }
            
            PreparedStatement ps = con.prepareStatement(sql.toString());
            int paramIndex = 1;
            
            if (keyword != null && !keyword.isEmpty()) {
                String searchPattern = "%" + keyword + "%";
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
            }
            if (categoryId > 0) {
                ps.setInt(paramIndex++, categoryId);
                ps.setInt(paramIndex++, categoryId);
                ps.setInt(paramIndex++, categoryId);
            }
            if (minPriceParam != null && !minPriceParam.isEmpty()) {
                ps.setDouble(paramIndex++, minPrice);
            }
            if (maxPriceParam != null && !maxPriceParam.isEmpty()) {
                ps.setDouble(paramIndex++, maxPrice);
            }
            if (conditionParam != null && !conditionParam.isEmpty()) {
                ps.setString(paramIndex++, conditionParam);
            }
            if (brandParam != null && !brandParam.isEmpty()) {
                ps.setString(paramIndex++, "%" + brandParam + "%");
            }
            if (sellerParam != null && !sellerParam.isEmpty()) {
                ps.setString(paramIndex++, "%" + sellerParam + "%");
            }
            
            ResultSet rs = ps.executeQuery();
            int count = 0;
            
            while (rs.next()) {
                count++;
                String title = rs.getString("item_title");
                String brand = rs.getString("brand");
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
            <h3>No results found</h3>
            <p>Try adjusting your search criteria or browse our <a href="browse.jsp">active auctions</a>.</p>
        </div>
        <%
            } else {
        %>
        <div class="text-muted" style="grid-column: 1 / -1; text-align: center;">
            Found <%= count %> result<%= count != 1 ? "s" : "" %>
        </div>
        <%
            }
        } catch (Exception e) {
            out.println("<div class='alert alert-error'>Error searching: " + e.getMessage() + "</div>");
            e.printStackTrace();
        } finally {
            if (con != null) db.closeConnection(con);
        }
        %>
    </div>
    <%
    } else {
    %>
    <div class="card text-center">
        <h3>Enter search criteria above</h3>
        <p>Use the form to search for items by keywords, category, price range, and more.</p>
    </div>
    <%
    }
    %>
</div>

<%@ include file="includes/footer.jsp" %>

