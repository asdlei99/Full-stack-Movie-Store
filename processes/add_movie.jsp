<%@ page import = "java.io.*, java.sql.*" %> 
<%@ page import = "org.json.*" %>
<%@ page import = "java.util.ArrayList"%>
<%@ page import="java.util.ArrayList"%>
<%@page import= "javax.naming.InitialContext"%>
<%@page import= "javax.naming.Context"%>
<%@page import= "javax.sql.DataSource"%><%

// Create Connection
Connection connection = null;
Context initCtx = new InitialContext();
Context envCtx = (Context) initCtx.lookup("java:comp/env");
DataSource ds = (DataSource) envCtx.lookup("jdbc/master");
connection = ds.getConnection();

String movieTitle = "";
movieTitle = request.getParameter( "movieTitle" );
String movieYear = "";
movieYear = request.getParameter( "movieYear" );
String movieDirector = "";
movieDirector = request.getParameter( "movieDirector" );
String starName = "";
starName = request.getParameter( "starName" );

String[] starNameSplit;
String starFirstName = "";
String starLastName = "";
if ( starName.contains(" ") )
{
	starNameSplit = starName.split("\\s+");
	starFirstName = starNameSplit[0];
	starLastName = starNameSplit[1];
}
else
{
	starLastName = starName;	
}

String genreName = "";
genreName = request.getParameter( "genreName" );

// Check if the movie exists
PreparedStatement addMovie = connection.prepareStatement( "CALL add_movie(?,?,?,?,?,?)" );
addMovie.setString(1, movieTitle);
addMovie.setString(2, movieYear);
addMovie.setString(3, movieDirector);
addMovie.setString(4, starFirstName);
addMovie.setString(5, starLastName);
addMovie.setString(6, genreName);


JSONObject json = new JSONObject();
json.put("movieName", movieTitle);
try{
	addMovie.executeUpdate();
}
catch(java.sql.SQLException e){
	json.put("status", "failure");
}
connection.close();
response.getWriter().write(json.toString());

%>