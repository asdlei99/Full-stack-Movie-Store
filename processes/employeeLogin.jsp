<%@ page import = "java.io.*, java.sql.*" %> 
<%@ page import = "org.json.*" %>
<%@page import= "javax.naming.InitialContext"%>
<%@page import= "javax.naming.Context"%>
<%@page import= "javax.sql.DataSource"%>
<%
//Create Connection

Connection connection = null;
Context initCtx = new InitialContext();
Context envCtx = (Context) initCtx.lookup("java:comp/env");
DataSource ds = (DataSource) envCtx.lookup("jdbc/moviedb");
connection = ds.getConnection();

//Handle request parameters/perform queries
String password = request.getParameter("emp_password");
String email = request.getParameter("emp_email");
Statement s = connection.createStatement();
PreparedStatement ps = connection.prepareStatement("select * from employees where email = ? and password = ?");
ps.setString(1, email);
ps.setString(2, password);

ResultSet rs = ps.executeQuery();
String loggedInUser = "";
while(rs.next()){
	loggedInUser = rs.getString(3);	
}

JSONObject json = new JSONObject();
json.put("status", "failure");
if(loggedInUser != ""){ // change to ( !( loggedInUser.equal( "" ) ) ){ 
	json.put("status", "success");
	json.put("name", loggedInUser);
	//HttpSession sessionVar = request.getSession();
	//sessionVar.setAttribute("name", loggedInUser);
}

connection.close();
//Response to ajax
response.getWriter().write(json.toString());

%>