<%@ page import = "java.io.*, java.sql.*" %><%@ page import = "org.json.*" %><%@ page import="java.util.ArrayList"%>
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

String movieTitle = ""; 
movieTitle = request.getParameter( "movieTitle" );

// Parse Movie Title
String searchableTitle = "";

// Or split by regular space depends on how movieTitle is printed
// if ( movieTitle.contains( "%20" ) ) (if movie title returns %20 as the space)
if( movieTitle.contains( " " ) )
{
	// String[] movieTitleSplit = movieTitle.split("(?:\\s+|%20)+"); (%20)
	String[] movieTitleSplit = movieTitle.split("\\s+");
	for( int i = 0; i < movieTitleSplit.length; ++i )
	{
		searchableTitle += (movieTitleSplit[i] + "*");
		
		if ( i != (movieTitleSplit.length -1) )
		{
			searchableTitle += " ";
		}
	}
}
else
{
	searchableTitle = movieTitle + "*";
}

PreparedStatement getMovieTitles = connection.prepareStatement("SELECT * FROM movies WHERE MATCH (title) AGAINST (? IN BOOLEAN MODE);");
getMovieTitles.setString(1, searchableTitle);
ResultSet movies = getMovieTitles.executeQuery();

ArrayList<JSONObject> movieList = new ArrayList<JSONObject>();
while( movies.next() )
{
	JSONObject movieJson = new JSONObject();
	String title = movies.getString(2);
	movieJson.put("title", title);
	movieList.add(movieJson);
}

if(session.getAttribute("search") != null){
	session.removeAttribute("search");
	session.invalidate(); 
}
connection.close();
response.getWriter().write(movieList.toString()); 
%>
