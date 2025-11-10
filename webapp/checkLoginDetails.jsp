<%@ page import ="java.sql.*, db.ApplicationDB" %>
<%
	String userid = request.getParameter("username");
	String pwd = request.getParameter("password");
	Class.forName("com.mysql.jdbc.Driver");
	Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/cs336project","root","password");
	Statement st = conn.createStatement();
	ResultSet rs;
	rs = st.executeQuery("select * from User where user_id='" + userid + "' and password='" + pwd + "'");
	if (rs.next()){
		session.setAttribute("user", userid); 
		response.sendRedirect("success.jsp");
	} else {
		out.println("Invalid username or password <a href='login.jsp'>Click here to go back to login</a>");
	}
%>