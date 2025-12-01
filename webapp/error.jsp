<%@ page isErrorPage="true" %>
<%-- 
    BuyMe Auction System - Error Page
--%>
<% request.setAttribute("pageTitle", "Error"); %>
<%@ include file="includes/header.jsp" %>

<div class="container container-sm text-center">
    <div class="page-header">
        <h1 class="page-title">Oops!</h1>
        <p class="page-subtitle">Something went wrong</p>
    </div>
    
    <div class="card">
        <h2>&#9888;</h2>
        <p>We encountered an error processing your request.</p>
        <p class="text-muted">Please try again or contact support if the problem persists.</p>
        
        <div class="flex-center gap-2 mt-4">
            <a href="index.jsp" class="btn btn-primary">Go Home</a>
            <a href="javascript:history.back()" class="btn btn-secondary">Go Back</a>
        </div>
    </div>
</div>

<%@ include file="includes/footer.jsp" %>

