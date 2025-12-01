<%@ page import="java.sql.*, db.ApplicationDB" %>
<%-- 
    BuyMe Auction System - Sales Reports (Admin)
    Generates various sales reports as required by the project spec
--%>
<%
String userType = (String) session.getAttribute("userType");
if (!"admin".equals(userType)) {
    response.sendRedirect("../login.jsp");
    return;
}

String reportType = request.getParameter("type");
if (reportType == null) reportType = "total";
request.setAttribute("pageTitle", "Sales Reports");
%>
<%@ include file="../includes/header.jsp" %>

<div class="container">
    <div class="page-header">
        <h1 class="page-title">Sales Reports</h1>
    </div>
    
    <!-- Report Type Selection -->
    <div class="tabs mb-4">
        <a href="?type=total" class="tab <%= "total".equals(reportType) ? "active" : "" %>">Total Earnings</a>
        <a href="?type=item" class="tab <%= "item".equals(reportType) ? "active" : "" %>">By Item</a>
        <a href="?type=itemtype" class="tab <%= "itemtype".equals(reportType) ? "active" : "" %>">By Item Type</a>
        <a href="?type=user" class="tab <%= "user".equals(reportType) ? "active" : "" %>">By End-User</a>
        <a href="?type=bestselling" class="tab <%= "bestselling".equals(reportType) ? "active" : "" %>">Best-Selling</a>
        <a href="?type=bestbuyers" class="tab <%= "bestbuyers".equals(reportType) ? "active" : "" %>">Best Buyers</a>
    </div>
    
    <%
    ApplicationDB db = new ApplicationDB();
    Connection con = null;
    try {
        con = db.getConnection();
        
        if ("total".equals(reportType)) {
    %>
    <!-- Total Earnings Report -->
    <div class="card">
        <h2>Total Earnings Report</h2>
        
        <div class="stats-grid">
            <%
            Statement stmt = con.createStatement();
            
            // Total revenue
            ResultSet rs = stmt.executeQuery("SELECT COALESCE(SUM(final_price), 0) as total FROM Sale");
            double totalRevenue = rs.next() ? rs.getDouble("total") : 0;
            
            // Total sales
            rs = stmt.executeQuery("SELECT COUNT(*) as count FROM Sale");
            int totalSales = rs.next() ? rs.getInt("count") : 0;
            
            // Average sale
            rs = stmt.executeQuery("SELECT COALESCE(AVG(final_price), 0) as avg FROM Sale");
            double avgSale = rs.next() ? rs.getDouble("avg") : 0;
            
            // This month's revenue
            rs = stmt.executeQuery("SELECT COALESCE(SUM(final_price), 0) as total FROM Sale WHERE MONTH(sale_date) = MONTH(NOW()) AND YEAR(sale_date) = YEAR(NOW())");
            double monthRevenue = rs.next() ? rs.getDouble("total") : 0;
            %>
            <div class="stat-card">
                <div class="stat-value">$<%= String.format("%.2f", totalRevenue) %></div>
                <div class="stat-label">Total Revenue</div>
            </div>
            <div class="stat-card">
                <div class="stat-value"><%= totalSales %></div>
                <div class="stat-label">Total Sales</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">$<%= String.format("%.2f", avgSale) %></div>
                <div class="stat-label">Average Sale</div>
            </div>
            <div class="stat-card">
                <div class="stat-value">$<%= String.format("%.2f", monthRevenue) %></div>
                <div class="stat-label">This Month</div>
            </div>
        </div>
    </div>
    
    <% } else if ("item".equals(reportType)) { %>
    <!-- Earnings per Item Report -->
    <div class="card">
        <h2>Earnings per Item</h2>
        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>Item</th>
                        <th>Category</th>
                        <th>Times Sold</th>
                        <th>Total Earnings</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    Statement stmt = con.createStatement();
                    ResultSet rs = stmt.executeQuery(
                        "SELECT i.item_title, c.category_name, COUNT(*) as sales, SUM(s.final_price) as total " +
                        "FROM Sale s JOIN Item i ON s.item_id = i.item_id " +
                        "JOIN Category c ON i.category_id = c.category_id " +
                        "GROUP BY i.item_id ORDER BY total DESC");
                    
                    while (rs.next()) {
                    %>
                    <tr>
                        <td><%= rs.getString("item_title") %></td>
                        <td><%= rs.getString("category_name") %></td>
                        <td><%= rs.getInt("sales") %></td>
                        <td class="text-success">$<%= String.format("%.2f", rs.getDouble("total")) %></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
    
    <% } else if ("itemtype".equals(reportType)) { %>
    <!-- Earnings per Item Type (Category) Report -->
    <div class="card">
        <h2>Earnings per Item Type (Category)</h2>
        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>Category</th>
                        <th>Items Sold</th>
                        <th>Total Earnings</th>
                        <th>Avg Sale Price</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    Statement stmt = con.createStatement();
                    ResultSet rs = stmt.executeQuery(
                        "SELECT c.category_name, COUNT(*) as sales, " +
                        "SUM(s.final_price) as total, AVG(s.final_price) as avg_price " +
                        "FROM Sale s JOIN Item i ON s.item_id = i.item_id " +
                        "JOIN Category c ON i.category_id = c.category_id " +
                        "GROUP BY c.category_id ORDER BY total DESC");
                    
                    while (rs.next()) {
                    %>
                    <tr>
                        <td><%= rs.getString("category_name") %></td>
                        <td><%= rs.getInt("sales") %></td>
                        <td class="text-success">$<%= String.format("%.2f", rs.getDouble("total")) %></td>
                        <td>$<%= String.format("%.2f", rs.getDouble("avg_price")) %></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
    
    <% } else if ("user".equals(reportType)) { %>
    <!-- Earnings per End-User Report -->
    <div class="card">
        <h2>Earnings per End-User (Sellers)</h2>
        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>Seller</th>
                        <th>Items Sold</th>
                        <th>Total Earnings</th>
                        <th>Avg Sale Price</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    Statement stmt = con.createStatement();
                    ResultSet rs = stmt.executeQuery(
                        "SELECT u.user_id, u.first_name, u.last_name, " +
                        "COUNT(*) as sales, SUM(s.final_price) as total, AVG(s.final_price) as avg_price " +
                        "FROM Sale s JOIN User u ON s.seller_id = u.user_id " +
                        "GROUP BY u.user_id ORDER BY total DESC");
                    
                    while (rs.next()) {
                    %>
                    <tr>
                        <td><%= rs.getString("first_name") %> <%= rs.getString("last_name") %> (<%= rs.getString("user_id") %>)</td>
                        <td><%= rs.getInt("sales") %></td>
                        <td class="text-success">$<%= String.format("%.2f", rs.getDouble("total")) %></td>
                        <td>$<%= String.format("%.2f", rs.getDouble("avg_price")) %></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
    
    <% } else if ("bestselling".equals(reportType)) { %>
    <!-- Best-Selling Items Report -->
    <div class="card">
        <h2>Best-Selling Items</h2>
        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>Rank</th>
                        <th>Item</th>
                        <th>Brand</th>
                        <th>Category</th>
                        <th>Times Sold</th>
                        <th>Total Revenue</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    Statement stmt = con.createStatement();
                    ResultSet rs = stmt.executeQuery(
                        "SELECT i.item_title, i.brand, c.category_name, " +
                        "COUNT(*) as sales, SUM(s.final_price) as total " +
                        "FROM Sale s JOIN Item i ON s.item_id = i.item_id " +
                        "JOIN Category c ON i.category_id = c.category_id " +
                        "GROUP BY i.item_id ORDER BY sales DESC, total DESC LIMIT 20");
                    
                    int rank = 0;
                    while (rs.next()) {
                        rank++;
                    %>
                    <tr>
                        <td><%= rank %></td>
                        <td><%= rs.getString("item_title") %></td>
                        <td><%= rs.getString("brand") != null ? rs.getString("brand") : "-" %></td>
                        <td><%= rs.getString("category_name") %></td>
                        <td><strong><%= rs.getInt("sales") %></strong></td>
                        <td class="text-success">$<%= String.format("%.2f", rs.getDouble("total")) %></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
    
    <% } else if ("bestbuyers".equals(reportType)) { %>
    <!-- Best Buyers Report -->
    <div class="card">
        <h2>Best Buyers (Top Spending Users)</h2>
        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>Rank</th>
                        <th>Buyer</th>
                        <th>Items Purchased</th>
                        <th>Total Spent</th>
                        <th>Avg Purchase</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    Statement stmt = con.createStatement();
                    ResultSet rs = stmt.executeQuery(
                        "SELECT u.user_id, u.first_name, u.last_name, " +
                        "COUNT(*) as purchases, SUM(s.final_price) as total, AVG(s.final_price) as avg_price " +
                        "FROM Sale s JOIN User u ON s.buyer_id = u.user_id " +
                        "GROUP BY u.user_id ORDER BY total DESC LIMIT 20");
                    
                    int rank = 0;
                    while (rs.next()) {
                        rank++;
                    %>
                    <tr>
                        <td><%= rank %></td>
                        <td><%= rs.getString("first_name") %> <%= rs.getString("last_name") %> (<%= rs.getString("user_id") %>)</td>
                        <td><%= rs.getInt("purchases") %></td>
                        <td class="text-success"><strong>$<%= String.format("%.2f", rs.getDouble("total")) %></strong></td>
                        <td>$<%= String.format("%.2f", rs.getDouble("avg_price")) %></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
    
    <% } %>
    
    <%
    } catch (Exception e) {
        out.println("<div class='alert alert-error'>Error generating report: " + e.getMessage() + "</div>");
        e.printStackTrace();
    } finally {
        if (con != null) db.closeConnection(con);
    }
    %>
    
    <div class="mt-3">
        <a href="dashboard.jsp" class="btn btn-secondary">&larr; Back to Dashboard</a>
    </div>
</div>

<%@ include file="../includes/footer.jsp" %>

