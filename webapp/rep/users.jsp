<%@ page import="java.sql.*, db.ApplicationDB" %>
<%-- 
    BuyMe Auction System - User Management (Rep)
--%>
<%
String userType = (String) session.getAttribute("userType");
if (!"rep".equals(userType)) {
    response.sendRedirect("../login.jsp");
    return;
}
request.setAttribute("pageTitle", "Manage Users");
String message = request.getParameter("msg");
%>
<%@ include file="../includes/header.jsp" %>

<div class="container">
    <div class="page-header">
        <h1 class="page-title">User Management</h1>
    </div>
    
    <% if (message != null) { %>
        <div class="alert alert-success">
            <% if ("updated".equals(message)) { %>User updated successfully.<% } %>
            <% if ("deleted".equals(message)) { %>User account deactivated.<% } %>
        </div>
    <% } %>
    
    <div class="card">
        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>Username</th>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Type</th>
                        <th>Status</th>
                        <th>Joined</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    ApplicationDB db = new ApplicationDB();
                    Connection con = null;
                    try {
                        con = db.getConnection();
                        
                        Statement stmt = con.createStatement();
                        ResultSet rs = stmt.executeQuery(
                            "SELECT u.*, " +
                            "(SELECT COUNT(*) FROM Buyer WHERE buyer_id = u.user_id) as is_buyer, " +
                            "(SELECT COUNT(*) FROM Seller WHERE seller_id = u.user_id) as is_seller " +
                            "FROM User u ORDER BY u.date_created DESC LIMIT 50");
                        
                        while (rs.next()) {
                            boolean isBuyer = rs.getInt("is_buyer") > 0;
                            boolean isSeller = rs.getInt("is_seller") > 0;
                    %>
                    <tr>
                        <td><%= rs.getString("user_id") %></td>
                        <td><%= rs.getString("first_name") %> <%= rs.getString("last_name") %></td>
                        <td><%= rs.getString("email") %></td>
                        <td>
                            <% if (isBuyer && isSeller) { %>
                                <span class="badge badge-primary">Both</span>
                            <% } else if (isBuyer) { %>
                                <span class="badge badge-info">Buyer</span>
                            <% } else if (isSeller) { %>
                                <span class="badge badge-success">Seller</span>
                            <% } %>
                        </td>
                        <td>
                            <% if (rs.getBoolean("is_active")) { %>
                                <span class="badge badge-success">Active</span>
                            <% } else { %>
                                <span class="badge badge-error">Inactive</span>
                            <% } %>
                        </td>
                        <td class="text-muted"><%= rs.getDate("date_created") %></td>
                        <td>
                            <a href="editUser.jsp?id=<%= rs.getString("user_id") %>" class="btn btn-sm btn-secondary">Edit</a>
                        </td>
                    </tr>
                    <% }
                    } finally {
                        if (con != null) db.closeConnection(con);
                    }
                    %>
                </tbody>
            </table>
        </div>
    </div>
    
    <div class="mt-3">
        <a href="dashboard.jsp" class="btn btn-secondary">&larr; Back to Dashboard</a>
    </div>
</div>

<%@ include file="../includes/footer.jsp" %>

