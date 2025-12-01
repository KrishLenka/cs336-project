<%@ page import="java.sql.*, db.ApplicationDB" %>
<%-- 
    BuyMe Auction System - Customer Questions (Rep)
--%>
<%
String userType = (String) session.getAttribute("userType");
if (!"rep".equals(userType)) {
    response.sendRedirect("../login.jsp");
    return;
}
request.setAttribute("pageTitle", "Customer Questions");
%>
<%@ include file="../includes/header.jsp" %>

<div class="container">
    <div class="page-header">
        <h1 class="page-title">Customer Questions</h1>
    </div>
    
    <div class="tabs">
        <a href="?tab=open" class="tab <%= !"resolved".equals(request.getParameter("tab")) ? "active" : "" %>">Open</a>
        <a href="?tab=resolved" class="tab <%= "resolved".equals(request.getParameter("tab")) ? "active" : "" %>">Resolved</a>
    </div>
    
    <div class="card">
        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>User</th>
                        <th>Subject</th>
                        <th>Created</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    ApplicationDB db = new ApplicationDB();
                    Connection con = null;
                    try {
                        con = db.getConnection();
                        
                        boolean showResolved = "resolved".equals(request.getParameter("tab"));
                        PreparedStatement ps = con.prepareStatement(
                            "SELECT q.*, u.first_name, u.last_name FROM Question q " +
                            "JOIN User u ON q.user_id = u.user_id " +
                            "WHERE q.is_resolved = ? ORDER BY q.created_at " + (showResolved ? "DESC" : "ASC"));
                        ps.setBoolean(1, showResolved);
                        ResultSet rs = ps.executeQuery();
                        
                        boolean hasQuestions = false;
                        while (rs.next()) {
                            hasQuestions = true;
                    %>
                    <tr>
                        <td>#<%= rs.getInt("question_id") %></td>
                        <td><%= rs.getString("first_name") %> <%= rs.getString("last_name") %></td>
                        <td><%= rs.getString("subject") %></td>
                        <td class="text-muted"><%= rs.getTimestamp("created_at") %></td>
                        <td>
                            <a href="answerQuestion.jsp?id=<%= rs.getInt("question_id") %>" 
                               class="btn btn-sm <%= rs.getBoolean("is_resolved") ? "btn-secondary" : "btn-primary" %>">
                                <%= rs.getBoolean("is_resolved") ? "View" : "Answer" %>
                            </a>
                        </td>
                    </tr>
                    <%
                        }
                        if (!hasQuestions) {
                    %>
                    <tr><td colspan="5" class="text-center text-muted">No questions</td></tr>
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

