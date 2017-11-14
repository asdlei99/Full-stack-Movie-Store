<%@ page import = "java.io.*, java.sql.*" %> 
<%@ page import = "org.json.*" %>
<%@ page import = "java.util.ArrayList"%>
<%@page import= "com.VerifyUtils.VerifyUtils"%>
<%@page import= "java.sql.Connection"%>
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
String password = request.getParameter("password");
String email = request.getParameter("email");
String gRecaptchaResponse = request.getParameter("g-recaptcha-response");
System.out.println("gRecaptchaResponse=" + gRecaptchaResponse);
// Verify CAPTCHA.
boolean valid = VerifyUtils.verify(gRecaptchaResponse);
Statement s = connection.createStatement();
PreparedStatement ps = connection.prepareStatement("select * from customers where email = ? and password = ?");
ps.setString(1, email);
ps.setString(2, password);

ResultSet rs = ps.executeQuery();
String loggedInUser = "";
while(rs.next()){
	loggedInUser = rs.getString(2);	
}

JSONObject json = new JSONObject();
json.put("status", "failure");
json.put("captcha", "failure");
if(loggedInUser != ""){ // change to ( !( loggedInUser.equal( "" ) ) ){ 
	json.put("status", "success");
	json.put("name", loggedInUser);
	if(valid){
		json.put("captcha", "success");
	}
	ArrayList<JSONObject> moviesInCart = new ArrayList<JSONObject>();
	HttpSession sessionVar = request.getSession();
	sessionVar.setAttribute("name", loggedInUser);
	sessionVar.setAttribute("moviesInCart", moviesInCart);
}


//Response to ajax
connection.close();
response.getWriter().write(json.toString());

%>