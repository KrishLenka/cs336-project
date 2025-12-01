<%@ page import="java.sql.*, db.ApplicationDB" %>
<%-- 
    BuyMe Auction System - Home Page
    Displays featured auctions and category navigation
--%>
<% request.setAttribute("pageTitle", "Home"); %>
<%@ include file="includes/header.jsp" %>

<div class="container">
    <!-- Hero Section -->
    <div class="page-header">
        <h1 class="page-title">Welcome to BuyMe Electronics</h1>
        <p class="page-subtitle">Your trusted marketplace for quality electronics at auction prices</p>
    </div>
    
    <!-- Quick Stats -->
    <div class="stats-grid">
        <%
        ApplicationDB db = new ApplicationDB();
        Connection con = null;
        try {
            con = db.getConnection();
            
            // Count active auctions
            Statement stmt = con.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT COUNT(*) as count FROM Auction WHERE is_active = TRUE AND close_date > NOW()");
            int activeAuctions = 0;
            if (rs.next()) activeAuctions = rs.getInt("count");
            
            // Count total items
            rs = stmt.executeQuery("SELECT COUNT(*) as count FROM Item");
            int totalItems = 0;
            if (rs.next()) totalItems = rs.getInt("count");
            
            // Count users
            rs = stmt.executeQuery("SELECT COUNT(*) as count FROM User");
            int totalUsers = 0;
            if (rs.next()) totalUsers = rs.getInt("count");
        %>
        <div class="stat-card">
            <div class="stat-value"><%= activeAuctions %></div>
            <div class="stat-label">Active Auctions</div>
        </div>
        <div class="stat-card">
            <div class="stat-value"><%= totalItems %></div>
            <div class="stat-label">Items Listed</div>
        </div>
        <div class="stat-card">
            <div class="stat-value"><%= totalUsers %></div>
            <div class="stat-label">Registered Users</div>
        </div>
        <div class="stat-card">
            <div class="stat-value">4</div>
            <div class="stat-label">Categories</div>
        </div>
        <%
        } catch (Exception e) {
            out.println("<div class='alert alert-error'>Error loading stats: " + e.getMessage() + "</div>");
        } finally {
            if (con != null) db.closeConnection(con);
        }
        %>
    </div>
    
    <!-- Browse by Category -->
    <section class="section">
        <h2>Browse by Category</h2>
        <div class="auction-grid">
            <a href="browse.jsp?category=2" class="auction-card" style="text-decoration:none;">
                <div class="auction-image">&#128187;</div>
                <div class="auction-content">
                    <div class="auction-title">Computers</div>
                    <p class="text-muted">Laptops, Desktops, Tablets</p>
                </div>
            </a>
            <a href="browse.jsp?category=3" class="auction-card" style="text-decoration:none;">
                <div class="auction-image">&#128241;</div>
                <div class="auction-content">
                    <div class="auction-title">Phones</div>
                    <p class="text-muted">Smartphones & Accessories</p>
                </div>
            </a>
            <a href="browse.jsp?category=4" class="auction-card" style="text-decoration:none;">
                <div class="auction-image">&#127911;</div>
                <div class="auction-content">
                    <div class="auction-title">Audio</div>
                    <p class="text-muted">Headphones, Speakers, Earbuds</p>
                </div>
            </a>
            <a href="browse.jsp?category=5" class="auction-card" style="text-decoration:none;">
                <div class="auction-image">&#127918;</div>
                <div class="auction-content">
                    <div class="auction-title">Gaming</div>
                    <p class="text-muted">Consoles & Controllers</p>
                </div>
            </a>
        </div>
    </section>
    
    <!-- Featured Auctions - Ending Soon -->
    <section class="section">
        <div class="flex-between mb-3">
            <h2>Ending Soon</h2>
            <a href="browse.jsp?sort=ending" class="btn btn-secondary btn-sm">View All</a>
        </div>
        
        <div class="auction-grid">
            <%
            ApplicationDB db2 = new ApplicationDB();
            Connection con2 = null;
            try {
                con2 = db2.getConnection();
                String sql = "SELECT a.*, i.item_title, i.item_condition, i.brand, c.category_name, " +
                           "u.first_name as seller_name " +
                           "FROM Auction a " +
                           "JOIN Item i ON a.item_id = i.item_id " +
                           "JOIN Category c ON i.category_id = c.category_id " +
                           "JOIN User u ON a.seller_id = u.user_id " +
                           "WHERE a.is_active = TRUE AND a.close_date > NOW() " +
                           "ORDER BY a.close_date ASC LIMIT 4";
                Statement stmt2 = con2.createStatement();
                ResultSet rs2 = stmt2.executeQuery(sql);
                
                while (rs2.next()) {
                    String title = rs2.getString("item_title");
                    String brand = rs2.getString("brand");
                    String category = rs2.getString("category_name");
                    String condition = rs2.getString("item_condition");
                    String sellerName = rs2.getString("seller_name");
                    double currentBid = rs2.getDouble("current_high_bid");
                    double initialPrice = rs2.getDouble("initial_price");
                    Timestamp closeDate = rs2.getTimestamp("close_date");
                    int auctionId = rs2.getInt("auction_id");
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
                    <div class="auction-price">
                        <span class="current-bid">$<%= String.format("%.2f", currentBid > 0 ? currentBid : initialPrice) %></span>
                        <span class="time-left" data-close-time="<%= closeDate %>">Loading...</span>
                    </div>
                </div>
            </a>
            <%
                }
            } catch (Exception e) {
                out.println("<div class='alert alert-error'>Error loading auctions: " + e.getMessage() + "</div>");
            } finally {
                if (con2 != null) db2.closeConnection(con2);
            }
            %>
        </div>
    </section>
    
    <!-- Recently Listed -->
    <section class="section">
        <div class="flex-between mb-3">
            <h2>Recently Listed</h2>
            <a href="browse.jsp?sort=newest" class="btn btn-secondary btn-sm">View All</a>
        </div>
        
        <div class="auction-grid">
            <%
            ApplicationDB db3 = new ApplicationDB();
            Connection con3 = null;
            try {
                con3 = db3.getConnection();
                String sql = "SELECT a.*, i.item_title, i.item_condition, i.brand, c.category_name, " +
                           "u.first_name as seller_name " +
                           "FROM Auction a " +
                           "JOIN Item i ON a.item_id = i.item_id " +
                           "JOIN Category c ON i.category_id = c.category_id " +
                           "JOIN User u ON a.seller_id = u.user_id " +
                           "WHERE a.is_active = TRUE AND a.close_date > NOW() " +
                           "ORDER BY a.start_date DESC LIMIT 4";
                Statement stmt3 = con3.createStatement();
                ResultSet rs3 = stmt3.executeQuery(sql);
                
                while (rs3.next()) {
                    String title = rs3.getString("item_title");
                    String brand = rs3.getString("brand");
                    String category = rs3.getString("category_name");
                    String condition = rs3.getString("item_condition");
                    double currentBid = rs3.getDouble("current_high_bid");
                    double initialPrice = rs3.getDouble("initial_price");
                    Timestamp closeDate = rs3.getTimestamp("close_date");
                    int auctionId = rs3.getInt("auction_id");
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
                    <div class="auction-price">
                        <span class="current-bid">$<%= String.format("%.2f", currentBid > 0 ? currentBid : initialPrice) %></span>
                        <span class="time-left" data-close-time="<%= closeDate %>">Loading...</span>
                    </div>
                </div>
            </a>
            <%
                }
            } catch (Exception e) {
                out.println("<div class='alert alert-error'>Error loading auctions: " + e.getMessage() + "</div>");
            } finally {
                if (con3 != null) db3.closeConnection(con3);
            }
            %>
        </div>
    </section>
    
    <!-- Call to Action -->
    <% if (session.getAttribute("user") == null) { %>
    <section class="section">
        <div class="card text-center">
            <h2>Ready to Start Bidding?</h2>
            <p>Create a free account to buy and sell electronics on BuyMe</p>
            <div class="flex-center gap-2 mt-3">
                <a href="register.jsp" class="btn btn-primary btn-lg">Create Account</a>
                <a href="login.jsp" class="btn btn-secondary btn-lg">Sign In</a>
            </div>
        </div>
    </section>
    <% } %>
</div>

<%@ include file="includes/footer.jsp" %>

