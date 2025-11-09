package db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ApplicationDB {
	public ApplicationDB(){
	}

	public Connection getConnection() {
		String connectionURL="jdbc:mysql://localhost:3306/cs336project";
		Connection connection = null;
		try{
			Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
		} catch (InstantiationException var5) {
			var5.printStackTrace();
		 } catch (IllegalAccessException var6) {
			var6.printStackTrace();
		 } catch (ClassNotFoundException var7) {
			var7.printStackTrace();
		 }

		 try{
			connection = DriverManager.getConnection(connectionURL,"root","password");
		 } catch(SQLException var4){
			var4.printStackTrace();
		 }
		 return connection;
	}
	public void closeConnection(Connection connection){
		try{
			connection.close();
		} catch(SQLException var3){
			var3.printStackTrace();
		}
	}
	/**
	 * Like the only method I understand.
	 * Create a temporary connection each time someone accesses the website.
	 * THis is because HTTP is stateless so we create a new connection between client and db.
	 * Then close the connection when the session is done.
	 */
	public static void main(String[] args){
		ApplicationDB appDB = new ApplicationDB();
		Connection connection = appDB.getConnection();
		System.out.println(connection);
		appDB.closeConnection(connection);
	}
	
}
