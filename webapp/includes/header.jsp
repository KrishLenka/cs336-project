<%@ page import="java.sql.*" %>
<%-- 
    BuyMe Auction System - Header Component
    Provides consistent navigation across all pages
--%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= request.getAttribute("pageTitle") != null ? request.getAttribute("pageTitle") : "BuyMe" %> - BuyMe Auctions</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <header class="header">
        <div class="container">
            <div class="header-content">
                <a href="index.jsp" class="logo">Buy<span>Me</span></a>
                
                <nav class="nav">
                    <a href="index.jsp">Home</a>
                    <a href="browse.jsp">Browse</a>
                    <a href="search.jsp">Search</a>
                    
                    <% if (session.getAttribute("user") != null) { %>
                        <a href="sell.jsp">Sell</a>
                        <a href="my-auctions.jsp">My Auctions</a>
                    <% } %>
                    
                    <% if (session.getAttribute("userType") != null && session.getAttribute("userType").equals("rep")) { %>
                        <a href="rep/dashboard.jsp">Rep Dashboard</a>
                    <% } %>
                    
                    <% if (session.getAttribute("userType") != null && session.getAttribute("userType").equals("admin")) { %>
                        <a href="admin/dashboard.jsp">Admin Dashboard</a>
                    <% } %>
                </nav>
                
                <div class="nav-user">
                    <% if (session.getAttribute("user") != null) { %>
                        <span class="user-badge">
                            &#128100; <%= session.getAttribute("userName") != null ? session.getAttribute("userName") : session.getAttribute("user") %>
                        </span>
                        <% if (session.getAttribute("userType") != null && session.getAttribute("userType").equals("user")) { %>
                            <a href="notifications.jsp" class="btn btn-sm btn-secondary">&#128276;</a>
                            <a href="alerts.jsp" class="btn btn-sm btn-secondary">&#9881;</a>
                        <% } %>
                        <a href="logout.jsp" class="btn btn-sm btn-secondary">Logout</a>
                    <% } else { %>
                        <a href="login.jsp" class="btn btn-sm btn-secondary">Login</a>
                        <a href="register.jsp" class="btn btn-sm btn-primary">Register</a>
                    <% } %>
                </div>
            </div>
        </div>
    </header>
    
    <main>

