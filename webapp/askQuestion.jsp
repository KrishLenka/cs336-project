<%@ page import="java.sql.*, db.ApplicationDB" %>
<%-- 
    BuyMe Auction System - Ask Question Page
    Allows users to submit questions to customer representatives
--%>
<%
String currentUser = (String) session.getAttribute("user");
if (currentUser == null) {
    response.sendRedirect("login.jsp");
    return;
}
request.setAttribute("pageTitle", "Ask a Question");
String message = request.getParameter("msg");
%>
<%@ include file="includes/header.jsp" %>

<div class="container container-md">
    <div class="page-header">
        <h1 class="page-title">Customer Support</h1>
        <p class="page-subtitle">Ask our team a question</p>
    </div>
    
    <% if ("sent".equals(message)) { %>
        <div class="alert alert-success">Your question has been submitted. We'll respond soon!</div>
    <% } %>
    
    <div class="card">
        <form action="submitQuestion.jsp" method="POST">
            <div class="form-group">
                <label class="form-label" for="subject">Subject *</label>
                <input type="text" id="subject" name="subject" class="form-input" 
                       placeholder="Brief description of your question" required>
            </div>
            
            <div class="form-group">
                <label class="form-label" for="message">Message *</label>
                <textarea id="message" name="message" class="form-textarea" rows="6"
                          placeholder="Describe your question in detail..." required></textarea>
            </div>
            
            <button type="submit" class="btn btn-primary">Submit Question</button>
        </form>
    </div>
    
    <!-- Previous Questions -->
    <h2 class="mt-4 mb-3">My Questions</h2>
    <%
    ApplicationDB db = new ApplicationDB();
    Connection con = null;
    try {
        con = db.getConnection();
        
        PreparedStatement ps = con.prepareStatement(
            "SELECT * FROM Question WHERE user_id = ? ORDER BY created_at DESC");
        ps.setString(1, currentUser);
        ResultSet rs = ps.executeQuery();
        
        boolean hasQuestions = false;
    %>
    
    <% while (rs.next()) { 
        hasQuestions = true;
        boolean isResolved = rs.getBoolean("is_resolved");
    %>
    <div class="card">
        <div class="flex-between">
            <h4><%= rs.getString("subject") %></h4>
            <% if (isResolved) { %>
                <span class="badge badge-success">Answered</span>
            <% } else { %>
                <span class="badge badge-warning">Pending</span>
            <% } %>
        </div>
        <p class="text-muted">Asked: <%= rs.getTimestamp("created_at") %></p>
        <p><%= rs.getString("message") %></p>
        
        <% if (rs.getString("response") != null) { %>
        <div style="background: var(--bg-tertiary); padding: var(--spacing-md); border-radius: var(--radius-md); margin-top: var(--spacing-md);">
            <strong>Response:</strong>
            <p class="mb-0"><%= rs.getString("response") %></p>
        </div>
        <% } %>
    </div>
    <% } 
    
    if (!hasQuestions) { %>
    <div class="card text-center text-muted">
        <p>You haven't asked any questions yet.</p>
    </div>
    <% }
    } catch (Exception e) {
        out.println("<div class='alert alert-error'>Error: " + e.getMessage() + "</div>");
    } finally {
        if (con != null) db.closeConnection(con);
    }
    %>
</div>

<%@ include file="includes/footer.jsp" %>

