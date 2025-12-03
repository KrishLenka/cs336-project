<%@ page import="java.sql.*" %>
<%-- 
    BuyMe Auction System - Header Component
    Provides consistent navigation across all pages
--%>
<% String ctx = request.getContextPath(); %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= request.getAttribute("pageTitle") != null ? request.getAttribute("pageTitle") : "BuyMe" %> - BuyMe Auctions</title>
    <link rel="stylesheet" href="<%= ctx %>/css/style.css">
</head>
<body>
    <header class="header">
        <div class="container">
            <div class="header-content">
                <a href="<%= ctx %>/index.jsp" class="logo">Buy<span>Me</span></a>
                
                <nav class="nav">
                    <a href="<%= ctx %>/index.jsp">Home</a>
                    <a href="<%= ctx %>/browse.jsp">Browse</a>
                    <a href="<%= ctx %>/search.jsp">Search</a>
                    
                    <% if (session.getAttribute("user") != null) { %>
                        <a href="<%= ctx %>/sell.jsp">Sell</a>
                        <a href="<%= ctx %>/my-auctions.jsp">My Auctions</a>
                    <% } %>
                    
                    <% if (session.getAttribute("userType") != null && session.getAttribute("userType").equals("rep")) { %>
                        <a href="<%= ctx %>/rep/dashboard.jsp">Rep Dashboard</a>
                    <% } %>
                    
                    <% if (session.getAttribute("userType") != null && session.getAttribute("userType").equals("admin")) { %>
                        <a href="<%= ctx %>/admin/dashboard.jsp">Admin Dashboard</a>
                    <% } %>
                </nav>
                
                <div class="nav-user">
                    <% if (session.getAttribute("user") != null) { %>
                        <span class="user-badge">
                            &#128100; <%= session.getAttribute("userName") != null ? session.getAttribute("userName") : session.getAttribute("user") %>
                        </span>
                        <% if (session.getAttribute("userType") != null && session.getAttribute("userType").equals("user")) { %>
                            <a href="<%= ctx %>/notifications.jsp" class="btn btn-sm btn-secondary" title="Notifications">&#128276;</a>
                            <a href="<%= ctx %>/alerts.jsp" class="btn btn-sm btn-secondary" title="Alerts">&#9881;</a>
                            <a href="<%= ctx %>/profile.jsp" class="btn btn-sm btn-secondary" title="Profile">&#128100;</a>
                            <a href="<%= ctx %>/askQuestion.jsp" class="btn btn-sm btn-secondary" title="Help">&#10067;</a>
                        <% } %>
                        <a href="<%= ctx %>/logout.jsp" class="btn btn-sm btn-secondary">Logout</a>
                    <% } else { %>
                        <a href="<%= ctx %>/login.jsp" class="btn btn-sm btn-secondary">Login</a>
                        <a href="<%= ctx %>/register.jsp" class="btn btn-sm btn-primary">Register</a>
                    <% } %>
                </div>
            </div>
        </div>
    </header>
    
    <main>

