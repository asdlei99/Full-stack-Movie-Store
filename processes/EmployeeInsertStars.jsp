<%@ page import = "java.io.*, java.sql.*" %> 
<%@ page import = "org.json.*" %>
<%@ page import = "java.util.ArrayList"%>
<%@page import= "javax.naming.InitialContext"%>
<%@page import= "javax.naming.Context"%>
<%@page import= "javax.sql.DataSource"%>
<%
//Create Connection

Connection connection = null;
Context initCtx = new InitialContext();
Context envCtx = (Context) initCtx.lookup("java:comp/env");
DataSource ds = (DataSource) envCtx.lookup("jdbc/master");
connection = ds.getConnection();

//Handle request parameters/perform queries
String starId = "0";
String firstName = "";
firstName = request.getParameter("starFirstName");
String lastName = "";
lastName = request.getParameter("starLastName");
String starDob = "";
starDob = request.getParameter("starDob");
String photoUrl = "";
photoUrl = request.getParameter("photoUrl");


//If only first name is provided, add it as his last_name and assign empty string to first_name
if ( !firstName.equals( "" ) && lastName.equals( "" ) )
{
	lastName = firstName;
	firstName = "";
}

Statement s = connection.createStatement();
PreparedStatement ps = connection.prepareStatement("INSERT INTO stars VALUES(?, ?, ?, ?, ?)");
ps.setString(1, starId);
ps.setString(2, firstName);
ps.setString(3, lastName);
if (starDob.equals(""))
{
	ps.setString(4, null);
}
else
{
	ps.setString(4, starDob);
}

ps.setString(5, photoUrl);
JSONObject json = new JSONObject();
json.put("name", firstName + " " + lastName);
try{
	ps.executeUpdate();
}
catch(com.mysql.jdbc.MysqlDataTruncation e){
	json.put("status", "failure");
}


connection.close();
response.getWriter().write(json.toString());

%>