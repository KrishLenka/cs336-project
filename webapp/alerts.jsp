<%@ page import="java.sql.*, db.ApplicationDB" %>
<%-- 
    BuyMe Auction System - Alerts Management Page
    Allows buyers to set up and manage item alerts
--%>
<%
String currentUser = (String) session.getAttribute("user");
if (currentUser == null) {
    response.sendRedirect("login.jsp");
    return;
}
request.setAttribute("pageTitle", "My Alerts");

// Get pre-filled parameters (from auction page)
String prefillCategory = request.getParameter("category");
String prefillBrand = request.getParameter("brand");

String message = request.getParameter("msg");
%>
<%@ include file="includes/header.jsp" %>

<div class="container container-md">
    <div class="page-header">
        <h1 class="page-title">Item Alerts</h1>
        <p class="page-subtitle">Get notified when items matching your criteria are listed</p>
    </div>
    
    <% if (message != null) { %>
        <div class="alert alert-success">
            <% if ("created".equals(message)) { %>Alert created successfully!<% } %>
            <% if ("deleted".equals(message)) { %>Alert deleted.<% } %>
        </div>
    <% } %>
    
    <!-- Create New Alert -->
    <div class="card">
        <div class="card-header">
            <h3 class="card-title">Create New Alert</h3>
        </div>
        
        <form action="createAlert.jsp" method="POST">
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label" for="category">Category</label>
                    <select id="category" name="categoryId" class="form-select">
                        <option value="">Any Category</option>
                        <%
                        ApplicationDB dbCat = new ApplicationDB();
                        Connection conCat = null;
                        try {
                            conCat = dbCat.getConnection();
                            Statement stmtCat = conCat.createStatement();
                            ResultSet rsCat = stmtCat.executeQuery(
                                "SELECT category_id, category_name FROM Category ORDER BY category_id");
                            while (rsCat.next()) {
                                int catId = rsCat.getInt("category_id");
                                String selected = (prefillCategory != null && prefillCategory.equals(String.valueOf(catId))) ? "selected" : "";
                        %>
                        <option value="<%= catId %>" <%= selected %>><%= rsCat.getString("category_name") %></option>
                        <%
                            }
                        } finally {
                            if (conCat != null) dbCat.closeConnection(conCat);
                        }
                        %>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label" for="brand">Brand</label>
                    <input type="text" id="brand" name="brand" class="form-input" 
                           placeholder="e.g., Apple, Samsung"
                           value="<%= prefillBrand != null ? prefillBrand : "" %>">
                </div>
            </div>
            
            <div class="form-group">
                <label class="form-label" for="keyword">Keywords</label>
                <input type="text" id="keyword" name="keyword" class="form-input" 
                       placeholder="e.g., MacBook Pro, iPhone 15">
            </div>
            
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label" for="minPrice">Min Price ($)</label>
                    <input type="number" id="minPrice" name="minPrice" class="form-input" 
                           min="0" step="0.01">
                </div>
                <div class="form-group">
                    <label class="form-label" for="maxPrice">Max Price ($)</label>
                    <input type="number" id="maxPrice" name="maxPrice" class="form-input" 
                           min="0" step="0.01">
                </div>
            </div>
            
            <button type="submit" class="btn btn-primary">Create Alert</button>
        </form>
    </div>
    
    <!-- Existing Alerts -->
    <h2 class="mt-4 mb-3">My Active Alerts</h2>
    
    <%
    ApplicationDB db = new ApplicationDB();
    Connection con = null;
    try {
        con = db.getConnection();
        
        PreparedStatement ps = con.prepareStatement(
            "SELECT a.*, c.category_name FROM Alert a " +
            "LEFT JOIN Category c ON a.category_id = c.category_id " +
            "WHERE a.buyer_id = ? AND a.is_active = TRUE " +
            "ORDER BY a.created_at DESC");
        ps.setString(1, currentUser);
        ResultSet rs = ps.executeQuery();
        
        boolean hasAlerts = false;
    %>
    
    <div class="table-wrapper">
        <table>
            <thead>
                <tr>
                    <th>Category</th>
                    <th>Keywords</th>
                    <th>Brand</th>
                    <th>Price Range</th>
                    <th>Created</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <% while (rs.next()) { 
                    hasAlerts = true;
                    String category = rs.getString("category_name");
                    String keyword = rs.getString("keyword");
                    String brand = rs.getString("brand");
                    double minP = rs.getDouble("min_price");
                    double maxP = rs.getDouble("max_price");
                %>
                <tr>
                    <td><%= category != null ? category : "Any" %></td>
                    <td><%= keyword != null ? keyword : "-" %></td>
                    <td><%= brand != null ? brand : "-" %></td>
                    <td>
                        <% if (minP > 0 || maxP > 0) { %>
                            $<%= String.format("%.0f", minP) %> - $<%= maxP > 0 ? String.format("%.0f", maxP) : "∞" %>
                        <% } else { %>
                            Any
                        <% } %>
                    </td>
                    <td class="text-muted"><%= rs.getTimestamp("created_at") %></td>
                    <td>
                        <form action="deleteAlert.jsp" method="POST" style="display:inline;">
                            <input type="hidden" name="alertId" value="<%= rs.getInt("alert_id") %>">
                            <button type="submit" class="btn btn-sm btn-danger" 
                                    onclick="return confirm('Delete this alert?')">Delete</button>
                        </form>
                    </td>
                </tr>
                <% } 
                if (!hasAlerts) { %>
                <tr><td colspan="6" class="text-center text-muted">No alerts set up yet</td></tr>
                <% } %>
            </tbody>
        </table>
    </div>
    
    <%
    } catch (Exception e) {
        out.println("<div class='alert alert-error'>Error: " + e.getMessage() + "</div>");
    } finally {
        if (con != null) db.closeConnection(con);
    }
    %>
</div>

<%@ include file="includes/footer.jsp" %>

