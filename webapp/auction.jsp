<%@ page import="java.sql.*, db.ApplicationDB" %>
<%-- 
    BuyMe Auction System - Auction Detail Page
    Displays full auction details and bidding interface
--%>
<%
String auctionIdParam = request.getParameter("id");
if (auctionIdParam == null || auctionIdParam.isEmpty()) {
    response.sendRedirect("browse.jsp");
    return;
}

int auctionId = 0;
try {
    auctionId = Integer.parseInt(auctionIdParam);
} catch (NumberFormatException e) {
    response.sendRedirect("browse.jsp");
    return;
}

String message = request.getParameter("msg");
String error = request.getParameter("error");
String currentUser = (String) session.getAttribute("user");
%>

<%@ include file="includes/header.jsp" %>

<div class="container">
    <%
    ApplicationDB db = new ApplicationDB();
    Connection con = null;
    try {
        con = db.getConnection();
        
        // Get auction details
        PreparedStatement ps = con.prepareStatement(
            "SELECT a.*, i.*, c.category_name, c.parent_id as cat_parent, " +
            "u.first_name as seller_first, u.last_name as seller_last, u.user_id as seller_id, " +
            "s.rating as seller_rating, s.total_ratings, " +
            "(SELECT COUNT(*) FROM Bid b WHERE b.auction_id = a.auction_id) as bid_count " +
            "FROM Auction a " +
            "JOIN Item i ON a.item_id = i.item_id " +
            "JOIN Category c ON i.category_id = c.category_id " +
            "JOIN User u ON a.seller_id = u.user_id " +
            "JOIN Seller s ON a.seller_id = s.seller_id " +
            "WHERE a.auction_id = ?");
        ps.setInt(1, auctionId);
        ResultSet rs = ps.executeQuery();
        
        if (!rs.next()) {
            out.println("<div class='alert alert-error'>Auction not found.</div>");
            out.println("<a href='browse.jsp' class='btn btn-secondary'>Back to Browse</a>");
        } else {
            // Extract auction data
            String title = rs.getString("item_title");
            String description = rs.getString("item_description");
            String condition = rs.getString("item_condition");
            String category = rs.getString("category_name");
            String brand = rs.getString("brand");
            String model = rs.getString("model");
            int yearMade = rs.getInt("year_manufactured");
            String sellerFirst = rs.getString("seller_first");
            String sellerLast = rs.getString("seller_last");
            String sellerId = rs.getString("seller_id");
            double sellerRating = rs.getDouble("seller_rating");
            int totalRatings = rs.getInt("total_ratings");
            
            double initialPrice = rs.getDouble("initial_price");
            double increment = rs.getDouble("increment_price");
            double currentBid = rs.getDouble("current_high_bid");
            double minPrice = rs.getDouble("min_price"); // Secret - don't show to users
            String highBidderId = rs.getString("high_bidder_id");
            Timestamp closeDate = rs.getTimestamp("close_date");
            Timestamp startDate = rs.getTimestamp("start_date");
            boolean isActive = rs.getBoolean("is_active");
            boolean isClosed = rs.getBoolean("is_closed");
            int bidCount = rs.getInt("bid_count");
            
            // Category-specific fields
            String processor = rs.getString("processor");
            int ram = rs.getInt("ram_gb");
            int storage = rs.getInt("storage_gb");
            double screenSize = rs.getDouble("screen_size_inches");
            String carrier = rs.getString("carrier");
            String storageCapacity = rs.getString("storage_capacity");
            String color = rs.getString("color");
            String connectivity = rs.getString("connectivity");
            int batteryLife = rs.getInt("battery_life_hours");
            String platform = rs.getString("platform");
            String region = rs.getString("region");
            
            // Calculate minimum bid
            double minBid = currentBid > 0 ? currentBid + increment : initialPrice;
            
            // Check if current user is the seller
            boolean isSeller = sellerId.equals(currentUser);
            
            // Check if current user is the high bidder
            boolean isHighBidder = currentUser != null && currentUser.equals(highBidderId);
            
            // Check if auction has ended
            boolean hasEnded = closeDate.before(new Timestamp(System.currentTimeMillis())) || isClosed || !isActive;
            
            // Auto-process this auction if it has ended but hasn't been processed yet
            if (hasEnded && !isClosed && isActive) {
                // Process this specific auction
                if (highBidderId != null && currentBid >= minPrice) {
                    // Winner! Create sale and update auction
                    PreparedStatement salePs = con.prepareStatement(
                        "INSERT INTO Sale (auction_id, item_id, buyer_id, seller_id, final_price, shipping_address, payment_card) " +
                        "SELECT ?, a.item_id, ?, a.seller_id, ?, COALESCE(b.shipping_address, ''), COALESCE(b.default_card, '') " +
                        "FROM Auction a LEFT JOIN Buyer b ON b.buyer_id = ? WHERE a.auction_id = ?");
                    salePs.setInt(1, auctionId);
                    salePs.setString(2, highBidderId);
                    salePs.setDouble(3, currentBid);
                    salePs.setString(4, highBidderId);
                    salePs.setInt(5, auctionId);
                    salePs.executeUpdate();
                    
                    PreparedStatement updatePs = con.prepareStatement(
                        "UPDATE Auction SET is_closed = TRUE, winner_id = ?, final_price = ? WHERE auction_id = ?");
                    updatePs.setString(1, highBidderId);
                    updatePs.setDouble(2, currentBid);
                    updatePs.setInt(3, auctionId);
                    updatePs.executeUpdate();
                    
                    // Update seller earnings
                    PreparedStatement earningsPs = con.prepareStatement(
                        "UPDATE Seller SET earnings = earnings + ? WHERE seller_id = ?");
                    earningsPs.setDouble(1, currentBid);
                    earningsPs.setString(2, sellerId);
                    earningsPs.executeUpdate();
                    
                    // Notify winner
                    PreparedStatement notifyWinnerPs = con.prepareStatement(
                        "INSERT INTO Notification (user_id, message, auction_id) VALUES (?, ?, ?)");
                    notifyWinnerPs.setString(1, highBidderId);
                    notifyWinnerPs.setString(2, "Congratulations! You won auction #" + auctionId + " for $" + String.format("%.2f", currentBid));
                    notifyWinnerPs.setInt(3, auctionId);
                    notifyWinnerPs.executeUpdate();
                    
                    // Notify seller
                    PreparedStatement notifySellerPs = con.prepareStatement(
                        "INSERT INTO Notification (user_id, message, auction_id) VALUES (?, ?, ?)");
                    notifySellerPs.setString(1, sellerId);
                    notifySellerPs.setString(2, "Your auction #" + auctionId + " sold for $" + String.format("%.2f", currentBid));
                    notifySellerPs.setInt(3, auctionId);
                    notifySellerPs.executeUpdate();
                    
                    // Notify losing bidders
                    PreparedStatement losingBiddersPs = con.prepareStatement(
                        "SELECT DISTINCT buyer_id FROM Bid WHERE auction_id = ? AND buyer_id != ?");
                    losingBiddersPs.setInt(1, auctionId);
                    losingBiddersPs.setString(2, highBidderId);
                    ResultSet loserRs = losingBiddersPs.executeQuery();
                    while (loserRs.next()) {
                        PreparedStatement notifyLoserPs = con.prepareStatement(
                            "INSERT INTO Notification (user_id, message, auction_id) VALUES (?, ?, ?)");
                        notifyLoserPs.setString(1, loserRs.getString("buyer_id"));
                        notifyLoserPs.setString(2, "Auction #" + auctionId + " has ended. Unfortunately, you were outbid. Final price: $" + String.format("%.2f", currentBid));
                        notifyLoserPs.setInt(3, auctionId);
                        notifyLoserPs.executeUpdate();
                    }
                    
                    // Refresh the data
                    isClosed = true;
                    rs.close();
                    ps.setInt(1, auctionId);
                    rs = ps.executeQuery();
                    rs.next();
                } else {
                    // No winner - just close the auction
                    PreparedStatement closePs = con.prepareStatement(
                        "UPDATE Auction SET is_closed = TRUE WHERE auction_id = ?");
                    closePs.setInt(1, auctionId);
                    closePs.executeUpdate();
                    
                    // Notify seller
                    PreparedStatement notifySellerPs = con.prepareStatement(
                        "INSERT INTO Notification (user_id, message, auction_id) VALUES (?, ?, ?)");
                    notifySellerPs.setString(1, sellerId);
                    if (highBidderId == null) {
                        notifySellerPs.setString(2, "Your auction #" + auctionId + " ended with no bids.");
                    } else {
                        notifySellerPs.setString(2, "Your auction #" + auctionId + " ended but the reserve price was not met.");
                    }
                    notifySellerPs.setInt(3, auctionId);
                    notifySellerPs.executeUpdate();
                    
                    // Notify all bidders that reserve wasn't met
                    if (highBidderId != null) {
                        PreparedStatement allBiddersPs = con.prepareStatement(
                            "SELECT DISTINCT buyer_id FROM Bid WHERE auction_id = ?");
                        allBiddersPs.setInt(1, auctionId);
                        ResultSet bidderRs = allBiddersPs.executeQuery();
                        while (bidderRs.next()) {
                            PreparedStatement notifyBidderPs = con.prepareStatement(
                                "INSERT INTO Notification (user_id, message, auction_id) VALUES (?, ?, ?)");
                            notifyBidderPs.setString(1, bidderRs.getString("buyer_id"));
                            notifyBidderPs.setString(2, "Auction #" + auctionId + " ended but the reserve price was not met.");
                            notifyBidderPs.setInt(3, auctionId);
                            notifyBidderPs.executeUpdate();
                        }
                    }
                    
                    isClosed = true;
                }
            }
            
            request.setAttribute("pageTitle", title);
    %>
    
    <% if (message != null) { %>
        <div class="alert alert-success">
            <% if ("bid".equals(message)) { %>
                Your bid was placed successfully!
            <% } else if ("autobid".equals(message)) { %>
                Your automatic bidding has been set up.
            <% } %>
        </div>
    <% } %>
    
    <% if (error != null) { %>
        <div class="alert alert-error">
            <% if ("low".equals(error)) { %>
                Your bid must be at least $<%= String.format("%.2f", minBid) %>
            <% } else if ("login".equals(error)) { %>
                Please <a href="login.jsp">log in</a> to place a bid.
            <% } else if ("buyer".equals(error)) { %>
                You need a buyer account to place bids. <a href="register.jsp">Register as a buyer</a>.
            <% } else if ("closed".equals(error)) { %>
                This auction has ended.
            <% } else { %>
                An error occurred. Please try again.
            <% } %>
        </div>
    <% } %>
    
    <div class="dashboard-grid">
        <!-- Main Content -->
        <div class="col-8">
            <div class="card">
                <!-- Item Header -->
                <div class="flex-between mb-3">
                    <span class="badge badge-primary"><%= category %></span>
                    <span class="badge <%= condition.equals("New") ? "badge-success" : "badge-info" %>">
                        <%= condition %>
                    </span>
                </div>
                
                <h1><%= title %></h1>
                
                <% if (brand != null || model != null) { %>
                <p class="text-muted">
                    <% if (brand != null) { %><strong><%= brand %></strong><% } %>
                    <% if (model != null) { %> <%= model %><% } %>
                    <% if (yearMade > 0) { %> (<%= yearMade %>)<% } %>
                </p>
                <% } %>
                
                <!-- Item Image Placeholder -->
                <div class="auction-image" style="height: 300px; margin: var(--spacing-lg) 0; border-radius: var(--radius-md);">
                    &#128230;
                </div>
                
                <!-- Description -->
                <h3>Description</h3>
                <p><%= description %></p>
                
                <!-- Specifications -->
                <% if (processor != null || ram > 0 || storage > 0 || carrier != null || connectivity != null || platform != null) { %>
                <h3 class="mt-4">Specifications</h3>
                <div class="table-wrapper">
                    <table>
                        <% if (processor != null) { %><tr><th>Processor</th><td><%= processor %></td></tr><% } %>
                        <% if (ram > 0) { %><tr><th>RAM</th><td><%= ram %> GB</td></tr><% } %>
                        <% if (storage > 0) { %><tr><th>Storage</th><td><%= storage %> GB</td></tr><% } %>
                        <% if (screenSize > 0) { %><tr><th>Screen Size</th><td><%= screenSize %>"</td></tr><% } %>
                        <% if (carrier != null) { %><tr><th>Carrier</th><td><%= carrier %></td></tr><% } %>
                        <% if (storageCapacity != null) { %><tr><th>Storage</th><td><%= storageCapacity %></td></tr><% } %>
                        <% if (color != null) { %><tr><th>Color</th><td><%= color %></td></tr><% } %>
                        <% if (connectivity != null) { %><tr><th>Connectivity</th><td><%= connectivity %></td></tr><% } %>
                        <% if (batteryLife > 0) { %><tr><th>Battery Life</th><td><%= batteryLife %> hours</td></tr><% } %>
                        <% if (platform != null) { %><tr><th>Platform</th><td><%= platform %></td></tr><% } %>
                        <% if (region != null) { %><tr><th>Region</th><td><%= region %></td></tr><% } %>
                    </table>
                </div>
                <% } %>
                
                <!-- Bid History -->
                <h3 class="mt-4">Bid History</h3>
                <%
                PreparedStatement bidPs = con.prepareStatement(
                    "SELECT b.*, u.first_name, u.last_name, u.user_id " +
                    "FROM Bid b JOIN User u ON b.buyer_id = u.user_id " +
                    "WHERE b.auction_id = ? ORDER BY b.bid_time DESC LIMIT 10");
                bidPs.setInt(1, auctionId);
                ResultSet bidRs = bidPs.executeQuery();
                
                if (!bidRs.isBeforeFirst()) {
                %>
                <p class="text-muted">No bids yet. Be the first to bid!</p>
                <% } else { %>
                <div class="table-wrapper">
                    <table>
                        <thead>
                            <tr>
                                <th>Bidder</th>
                                <th>Amount</th>
                                <th>Time</th>
                                <th>Type</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% while (bidRs.next()) { 
                                String bidderId = bidRs.getString("user_id");
                                // Anonymize bidder name (show first letter + ***)
                                String bidderName = bidRs.getString("first_name").charAt(0) + "***";
                            %>
                            <tr>
                                <td><%= bidderName %></td>
                                <td class="text-primary">$<%= String.format("%.2f", bidRs.getDouble("bid_amount")) %></td>
                                <td class="text-muted"><%= bidRs.getTimestamp("bid_time") %></td>
                                <td><%= bidRs.getBoolean("is_auto_bid") ? "<span class='badge badge-info'>Auto</span>" : "<span class='badge badge-secondary'>Manual</span>" %></td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
                <% } %>
                
                <div class="mt-3">
                    <a href="bidHistory.jsp?auction=<%= auctionId %>" class="btn btn-secondary btn-sm">View Full Bid History</a>
                </div>
            </div>
            
            <!-- Similar Items -->
            <div class="card mt-4">
                <h3>Similar Items</h3>
                <div class="auction-grid" style="grid-template-columns: repeat(3, 1fr);">
                    <%
                    // Get similar items from same category
                    PreparedStatement simPs = con.prepareStatement(
                        "SELECT a.auction_id, i.item_title, i.brand, a.current_high_bid, a.initial_price, a.close_date " +
                        "FROM Auction a " +
                        "JOIN Item i ON a.item_id = i.item_id " +
                        "WHERE i.category_id = ? AND a.auction_id != ? " +
                        "AND a.is_active = TRUE AND a.close_date > NOW() " +
                        "ORDER BY a.start_date DESC LIMIT 3");
                    simPs.setInt(1, rs.getInt("category_id"));
                    simPs.setInt(2, auctionId);
                    ResultSet simRs = simPs.executeQuery();
                    
                    boolean hasSimilar = false;
                    while (simRs.next()) {
                        hasSimilar = true;
                        double simBid = simRs.getDouble("current_high_bid");
                        double simInitial = simRs.getDouble("initial_price");
                    %>
                    <a href="auction.jsp?id=<%= simRs.getInt("auction_id") %>" class="auction-card" style="text-decoration:none;">
                        <div class="auction-image" style="height: 100px;">&#128230;</div>
                        <div class="auction-content">
                            <div class="auction-title" style="font-size: 0.9rem;"><%= simRs.getString("item_title") %></div>
                            <div class="current-bid">$<%= String.format("%.2f", simBid > 0 ? simBid : simInitial) %></div>
                        </div>
                    </a>
                    <% } 
                    if (!hasSimilar) { %>
                    <p class="text-muted">No similar items currently available.</p>
                    <% } %>
                </div>
            </div>
        </div>
        
        <!-- Sidebar - Bidding Interface -->
        <div class="col-4">
            <!-- Price Card -->
            <div class="card">
                <% if (hasEnded) { %>
                    <span class="badge badge-error mb-3">Auction Ended</span>
                    <% if (rs.getString("winner_id") != null) { %>
                        <p>Winner: <%= rs.getString("winner_id").charAt(0) %>***</p>
                        <p>Final Price: <strong class="text-primary">$<%= String.format("%.2f", rs.getDouble("final_price")) %></strong></p>
                    <% } else { %>
                        <p class="text-muted">No winner (reserve not met or no bids)</p>
                    <% } %>
                <% } else { %>
                    <div class="text-center mb-3">
                        <div class="text-muted">Current Bid</div>
                        <div class="stat-value">$<%= String.format("%.2f", currentBid > 0 ? currentBid : initialPrice) %></div>
                        <% if (currentBid == 0) { %>
                            <div class="text-muted">Starting price</div>
                        <% } %>
                    </div>
                    
                    <div class="flex-between mb-3">
                        <span class="text-muted"><%= bidCount %> bid<%= bidCount != 1 ? "s" : "" %></span>
                        <span class="time-left <%= (closeDate.getTime() - System.currentTimeMillis()) < 86400000 ? "text-error pulse" : "text-warning" %>" 
                              data-close-time="<%= closeDate %>">Loading...</span>
                    </div>
                    
                    <% if (isHighBidder) { %>
                        <div class="alert alert-success mb-3">
                            You are the highest bidder!
                        </div>
                    <% } %>
                    
                    <% if (!isSeller && currentUser != null) { 
                        // Check if user is a buyer
                        PreparedStatement buyerCheck = con.prepareStatement("SELECT * FROM Buyer WHERE buyer_id = ?");
                        buyerCheck.setString(1, currentUser);
                        boolean userIsBuyer = buyerCheck.executeQuery().next();
                        
                        if (userIsBuyer) {
                    %>
                    <form action="placeBid.jsp" method="POST">
                        <input type="hidden" name="auctionId" value="<%= auctionId %>">
                        
                        <div class="form-group">
                            <label class="form-label">Your Bid ($)</label>
                            <input type="number" name="bidAmount" class="form-input" 
                                   min="<%= String.format("%.2f", minBid) %>" 
                                   step="0.01" 
                                   value="<%= String.format("%.2f", minBid) %>" required>
                            <span class="form-hint">Minimum: $<%= String.format("%.2f", minBid) %> (increment: $<%= String.format("%.2f", increment) %>)</span>
                        </div>
                        
                        <button type="submit" class="btn btn-primary btn-block btn-lg">Place Bid</button>
                    </form>
                    
                    <!-- Automatic Bidding -->
                    <div class="mt-4">
                        <h4>Automatic Bidding</h4>
                        <p class="text-muted text-sm">Set a maximum amount and let the system bid for you automatically.</p>
                        
                        <%
                        // Check if user has auto-bid set
                        PreparedStatement autoBidCheck = con.prepareStatement(
                            "SELECT * FROM AutoBidSetting WHERE auction_id = ? AND buyer_id = ? AND is_active = TRUE");
                        autoBidCheck.setInt(1, auctionId);
                        autoBidCheck.setString(2, currentUser);
                        ResultSet autoBidRs = autoBidCheck.executeQuery();
                        
                        if (autoBidRs.next()) {
                        %>
                        <div class="alert alert-info">
                            Auto-bid active: up to $<%= String.format("%.2f", autoBidRs.getDouble("max_bid_amount")) %>
                        </div>
                        <form action="cancelAutoBid.jsp" method="POST">
                            <input type="hidden" name="auctionId" value="<%= auctionId %>">
                            <button type="submit" class="btn btn-secondary btn-block">Cancel Auto-Bid</button>
                        </form>
                        <% } else { %>
                        <form action="setAutoBid.jsp" method="POST">
                            <input type="hidden" name="auctionId" value="<%= auctionId %>">
                            <div class="form-group">
                                <label class="form-label">Maximum Bid ($)</label>
                                <input type="number" name="maxBid" class="form-input" 
                                       min="<%= String.format("%.2f", minBid) %>" 
                                       step="0.01" required>
                            </div>
                            <button type="submit" class="btn btn-secondary btn-block">Set Auto-Bid</button>
                        </form>
                        <% } %>
                    </div>
                    <% } else { %>
                    <div class="alert alert-warning">
                        You need a <a href="register.jsp">buyer account</a> to place bids.
                    </div>
                    <% } %>
                    <% } else if (isSeller) { %>
                    <div class="alert alert-info">
                        This is your auction listing.
                    </div>
                    <% } else { %>
                    <a href="login.jsp" class="btn btn-primary btn-block btn-lg">Login to Bid</a>
                    <% } %>
                <% } %>
            </div>
            
            <!-- Seller Info -->
            <div class="card mt-3">
                <h4>Seller Information</h4>
                <p>
                    <strong><%= sellerFirst %> <%= sellerLast.charAt(0) %>.</strong><br>
                    <% if (totalRatings > 0) { %>
                        Rating: <%= String.format("%.1f", sellerRating) %>/5.0 
                        (<%= totalRatings %> review<%= totalRatings != 1 ? "s" : "" %>)
                    <% } else { %>
                        <span class="text-muted">New seller</span>
                    <% } %>
                </p>
                <a href="sellerAuctions.jsp?seller=<%= sellerId %>" class="btn btn-secondary btn-sm">View Seller's Auctions</a>
            </div>
            
            <!-- Auction Details -->
            <div class="card mt-3">
                <h4>Auction Details</h4>
                <table style="width: 100%;">
                    <tr><td class="text-muted">Started</td><td><%= startDate %></td></tr>
                    <tr><td class="text-muted">Ends</td><td><%= closeDate %></td></tr>
                    <tr><td class="text-muted">Starting Price</td><td>$<%= String.format("%.2f", initialPrice) %></td></tr>
                    <tr><td class="text-muted">Bid Increment</td><td>$<%= String.format("%.2f", increment) %></td></tr>
                    <tr><td class="text-muted">Auction ID</td><td>#<%= auctionId %></td></tr>
                </table>
            </div>
            
            <% if (currentUser != null) { %>
            <!-- Set Alert -->
            <div class="card mt-3">
                <h4>Get Alerts</h4>
                <p class="text-muted">Get notified about similar items.</p>
                <a href="alerts.jsp?category=<%= rs.getInt("category_id") %>&brand=<%= brand != null ? brand : "" %>" 
                   class="btn btn-secondary btn-block btn-sm">Set Alert for Similar Items</a>
            </div>
            <% } %>
        </div>
    </div>
    <%
        }
    } catch (Exception e) {
        out.println("<div class='alert alert-error'>Error loading auction: " + e.getMessage() + "</div>");
        e.printStackTrace();
    } finally {
        if (con != null) db.closeConnection(con);
    }
    %>
</div>

<%@ include file="includes/footer.jsp" %>

