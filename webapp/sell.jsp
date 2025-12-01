<%@ page import="java.sql.*, db.ApplicationDB" %>
<%-- 
    BuyMe Auction System - Create Auction Page
    Allows sellers to list new items for auction
--%>
<%
String currentUser = (String) session.getAttribute("user");
if (currentUser == null) {
    response.sendRedirect("login.jsp");
    return;
}

// Check if user is a seller
ApplicationDB dbCheck = new ApplicationDB();
Connection conCheck = null;
boolean isSeller = false;
try {
    conCheck = dbCheck.getConnection();
    PreparedStatement ps = conCheck.prepareStatement("SELECT * FROM Seller WHERE seller_id = ?");
    ps.setString(1, currentUser);
    isSeller = ps.executeQuery().next();
} finally {
    if (conCheck != null) dbCheck.closeConnection(conCheck);
}

if (!isSeller) {
    // Redirect to registration or show error
%>
<%@ include file="includes/header.jsp" %>
<div class="container container-sm">
    <div class="card text-center">
        <h2>Seller Account Required</h2>
        <p>You need a seller account to list items for auction.</p>
        <p>Please update your account settings to become a seller.</p>
        <a href="profile.jsp" class="btn btn-primary">Go to Profile</a>
    </div>
</div>
<%@ include file="includes/footer.jsp" %>
<%
    return;
}

String error = request.getParameter("error");
request.setAttribute("pageTitle", "Sell Item");
%>
<%@ include file="includes/header.jsp" %>

<div class="container container-md">
    <div class="page-header">
        <h1 class="page-title">List an Item for Auction</h1>
        <p class="page-subtitle">Create your auction listing</p>
    </div>
    
    <% if (error != null) { %>
        <div class="alert alert-error">
            <% if ("invalid".equals(error)) { %>
                Please fill in all required fields correctly.
            <% } else { %>
                An error occurred. Please try again.
            <% } %>
        </div>
    <% } %>
    
    <div class="card">
        <form action="createAuction.jsp" method="POST">
            <!-- Item Information -->
            <h3 class="mb-3">Item Details</h3>
            
            <div class="form-group">
                <label class="form-label" for="title">Item Title *</label>
                <input type="text" id="title" name="title" class="form-input" 
                       placeholder="e.g., MacBook Pro 14-inch M3 2023" required>
            </div>
            
            <div class="form-group">
                <label class="form-label" for="description">Description *</label>
                <textarea id="description" name="description" class="form-textarea" 
                          placeholder="Describe your item in detail..." required></textarea>
            </div>
            
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label" for="categoryId">Category *</label>
                    <select id="categoryId" name="categoryId" class="form-select" required>
                        <option value="">Select a category</option>
                        <%
                        ApplicationDB dbCat = new ApplicationDB();
                        Connection conCat = null;
                        try {
                            conCat = dbCat.getConnection();
                            Statement stmtCat = conCat.createStatement();
                            // Only show leaf categories (most specific)
                            ResultSet rsCat = stmtCat.executeQuery(
                                "SELECT c.category_id, c.category_name, c.parent_id, p.category_name as parent_name " +
                                "FROM Category c LEFT JOIN Category p ON c.parent_id = p.category_id " +
                                "ORDER BY c.category_id");
                            while (rsCat.next()) {
                                int catId = rsCat.getInt("category_id");
                                String catName = rsCat.getString("category_name");
                                String parentName = rsCat.getString("parent_name");
                                String displayName = parentName != null ? parentName + " > " + catName : catName;
                        %>
                        <option value="<%= catId %>"><%= displayName %></option>
                        <%
                            }
                        } finally {
                            if (conCat != null) dbCat.closeConnection(conCat);
                        }
                        %>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label" for="condition">Condition *</label>
                    <select id="condition" name="condition" class="form-select" required>
                        <option value="New">New</option>
                        <option value="Like New">Like New</option>
                        <option value="Very Good">Very Good</option>
                        <option value="Good">Good</option>
                        <option value="Acceptable">Acceptable</option>
                    </select>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label" for="brand">Brand</label>
                    <input type="text" id="brand" name="brand" class="form-input" 
                           placeholder="e.g., Apple, Samsung, Sony">
                </div>
                <div class="form-group">
                    <label class="form-label" for="model">Model</label>
                    <input type="text" id="model" name="model" class="form-input" 
                           placeholder="e.g., MacBook Pro 14">
                </div>
                <div class="form-group">
                    <label class="form-label" for="yearMade">Year Manufactured</label>
                    <input type="number" id="yearMade" name="yearMade" class="form-input" 
                           min="1990" max="2025" placeholder="e.g., 2023">
                </div>
            </div>
            
            <!-- Category-specific fields -->
            <div id="computerFields" class="category-fields" style="display:none;">
                <h4 class="mt-3 mb-2">Computer Specifications</h4>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="processor">Processor</label>
                        <input type="text" id="processor" name="processor" class="form-input" 
                               placeholder="e.g., Apple M3, Intel Core i7">
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="ram">RAM (GB)</label>
                        <input type="number" id="ram" name="ram" class="form-input" 
                               min="1" placeholder="e.g., 16">
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="storage">Storage (GB)</label>
                        <input type="number" id="storage" name="storage" class="form-input" 
                               min="1" placeholder="e.g., 512">
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="screenSize">Screen Size (inches)</label>
                        <input type="number" id="screenSize" name="screenSize" class="form-input" 
                               min="1" step="0.1" placeholder="e.g., 14.2">
                    </div>
                </div>
            </div>
            
            <div id="phoneFields" class="category-fields" style="display:none;">
                <h4 class="mt-3 mb-2">Phone Specifications</h4>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="carrier">Carrier</label>
                        <input type="text" id="carrier" name="carrier" class="form-input" 
                               placeholder="e.g., Unlocked, Verizon, AT&T">
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="storageCapacity">Storage Capacity</label>
                        <input type="text" id="storageCapacity" name="storageCapacity" class="form-input" 
                               placeholder="e.g., 256GB">
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="color">Color</label>
                        <input type="text" id="color" name="color" class="form-input" 
                               placeholder="e.g., Titanium Black">
                    </div>
                </div>
            </div>
            
            <div id="audioFields" class="category-fields" style="display:none;">
                <h4 class="mt-3 mb-2">Audio Specifications</h4>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="connectivity">Connectivity</label>
                        <select id="connectivity" name="connectivity" class="form-select">
                            <option value="">Select...</option>
                            <option value="Wired">Wired</option>
                            <option value="Wireless">Wireless</option>
                            <option value="Both">Both</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="batteryLife">Battery Life (hours)</label>
                        <input type="number" id="batteryLife" name="batteryLife" class="form-input" 
                               min="1" placeholder="e.g., 30">
                    </div>
                </div>
            </div>
            
            <div id="gamingFields" class="category-fields" style="display:none;">
                <h4 class="mt-3 mb-2">Gaming Specifications</h4>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="platform">Platform</label>
                        <input type="text" id="platform" name="platform" class="form-input" 
                               placeholder="e.g., PlayStation, Xbox, Nintendo">
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="region">Region</label>
                        <input type="text" id="region" name="region" class="form-input" 
                               placeholder="e.g., USA, Japan, PAL">
                    </div>
                </div>
            </div>
            
            <!-- Auction Settings -->
            <h3 class="mt-4 mb-3">Auction Settings</h3>
            
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label" for="initialPrice">Starting Price ($) *</label>
                    <input type="number" id="initialPrice" name="initialPrice" class="form-input" 
                           min="0.01" step="0.01" required>
                </div>
                <div class="form-group">
                    <label class="form-label" for="increment">Bid Increment ($) *</label>
                    <input type="number" id="increment" name="increment" class="form-input" 
                           min="0.01" step="0.01" value="5.00" required>
                    <span class="form-hint">Minimum amount bids must increase by</span>
                </div>
            </div>
            
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label" for="minPrice">Reserve Price ($) *</label>
                    <input type="number" id="minPrice" name="minPrice" class="form-input" 
                           min="0.01" step="0.01" required>
                    <span class="form-hint">Secret minimum - item won't sell below this</span>
                </div>
                <div class="form-group">
                    <label class="form-label" for="duration">Auction Duration *</label>
                    <select id="duration" name="duration" class="form-select" required>
                        <option value="1">1 Day</option>
                        <option value="3">3 Days</option>
                        <option value="5">5 Days</option>
                        <option value="7" selected>7 Days</option>
                        <option value="10">10 Days</option>
                        <option value="14">14 Days</option>
                    </select>
                </div>
            </div>
            
            <div class="mt-4">
                <button type="submit" class="btn btn-primary btn-lg">Create Auction</button>
                <a href="my-auctions.jsp" class="btn btn-secondary btn-lg">Cancel</a>
            </div>
        </form>
    </div>
</div>

<%@ include file="includes/footer.jsp" %>

