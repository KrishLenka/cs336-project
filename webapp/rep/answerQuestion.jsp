<%@ page import="java.sql.*, db.ApplicationDB" %>
<%-- 
    BuyMe Auction System - Answer Question (Rep)
--%>
<%
String userType = (String) session.getAttribute("userType");
if (!"rep".equals(userType)) {
    response.sendRedirect("../login.jsp");
    return;
}

String questionIdParam = request.getParameter("id");
if (questionIdParam == null) {
    response.sendRedirect("questions.jsp");
    return;
}
int questionId = Integer.parseInt(questionIdParam);
request.setAttribute("pageTitle", "Answer Question");
%>
<%@ include file="../includes/header.jsp" %>

<div class="container container-md">
    <%
    ApplicationDB db = new ApplicationDB();
    Connection con = null;
    try {
        con = db.getConnection();
        
        PreparedStatement ps = con.prepareStatement(
            "SELECT q.*, u.first_name, u.last_name, u.email FROM Question q " +
            "JOIN User u ON q.user_id = u.user_id WHERE q.question_id = ?");
        ps.setInt(1, questionId);
        ResultSet rs = ps.executeQuery();
        
        if (rs.next()) {
    %>
    
    <div class="page-header">
        <h1 class="page-title">Question #<%= questionId %></h1>
    </div>
    
    <div class="card">
        <h3><%= rs.getString("subject") %></h3>
        <p class="text-muted">
            From: <%= rs.getString("first_name") %> <%= rs.getString("last_name") %> 
            (<%= rs.getString("email") %>) 
            &middot; <%= rs.getTimestamp("created_at") %>
        </p>
        <div class="mt-3" style="background: var(--bg-tertiary); padding: var(--spacing-lg); border-radius: var(--radius-md);">
            <%= rs.getString("message").replace("\n", "<br>") %>
        </div>
    </div>
    
    <% if (rs.getString("response") != null) { %>
    <div class="card mt-3">
        <h3>Response</h3>
        <p class="text-muted">Answered: <%= rs.getTimestamp("resolved_at") %></p>
        <div style="background: var(--bg-tertiary); padding: var(--spacing-lg); border-radius: var(--radius-md);">
            <%= rs.getString("response").replace("\n", "<br>") %>
        </div>
    </div>
    <% } else { %>
    <div class="card mt-3">
        <h3>Your Response</h3>
        <form action="submitAnswer.jsp" method="POST">
            <input type="hidden" name="questionId" value="<%= questionId %>">
            <div class="form-group">
                <textarea name="response" class="form-textarea" rows="5" 
                          placeholder="Type your response..." required></textarea>
            </div>
            <button type="submit" class="btn btn-primary">Submit Response</button>
        </form>
    </div>
    <% } %>
    
    <%
        } else {
            out.println("<div class='alert alert-error'>Question not found.</div>");
        }
    } finally {
        if (con != null) db.closeConnection(con);
    }
    %>
    
    <div class="mt-3">
        <a href="questions.jsp" class="btn btn-secondary">&larr; Back to Questions</a>
    </div>
</div>

<%@ include file="../includes/footer.jsp" %>

