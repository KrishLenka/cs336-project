<%@ page import="java.sql.*, db.ApplicationDB" %>
<%
String userType = (String) session.getAttribute("userType");
if (!"rep".equals(userType)) {
    response.sendRedirect("../login.jsp");
    return;
}

String query = request.getParameter("query");
if (query == null || query.trim().isEmpty()) {
    response.sendRedirect("users.jsp");
    return;
}
request.setAttribute("pageTitle", "Search Users");
%>
<%@ include file="../includes/header.jsp" %>

<div class="container">
    <div class="page-header">
        <h1 class="page-title">Search Results: "<%= query %>"</h1>
    </div>
    
    <div class="card">
        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>Username</th>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    ApplicationDB db = new ApplicationDB();
                    Connection con = null;
                    try {
                        con = db.getConnection();
                        
                        PreparedStatement ps = con.prepareStatement(
                            "SELECT * FROM User WHERE user_id LIKE ? OR email LIKE ? OR first_name LIKE ? OR last_name LIKE ?");
                        String searchPattern = "%" + query.trim() + "%";
                        ps.setString(1, searchPattern);
                        ps.setString(2, searchPattern);
                        ps.setString(3, searchPattern);
                        ps.setString(4, searchPattern);
                        ResultSet rs = ps.executeQuery();
                        
                        boolean found = false;
                        while (rs.next()) {
                            found = true;
                    %>
                    <tr>
                        <td><%= rs.getString("user_id") %></td>
                        <td><%= rs.getString("first_name") %> <%= rs.getString("last_name") %></td>
                        <td><%= rs.getString("email") %></td>
                        <td>
                            <% if (rs.getBoolean("is_active")) { %>
                                <span class="badge badge-success">Active</span>
                            <% } else { %>
                                <span class="badge badge-error">Inactive</span>
                            <% } %>
                        </td>
                        <td>
                            <a href="editUser.jsp?id=<%= rs.getString("user_id") %>" class="btn btn-sm btn-secondary">Edit</a>
                        </td>
                    </tr>
                    <%
                        }
                        if (!found) {
                    %>
                    <tr><td colspan="5" class="text-center text-muted">No users found matching "<%= query %>"</td></tr>
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

