<%@ page import = "java.io.*, java.sql.*" %>
<%@ page import = "org.json.*" %>
<%@ page import="java.util.ArrayList"%>
<%@page import= "javax.naming.InitialContext"%>
<%@page import= "javax.naming.Context"%>
<%@page import= "javax.sql.DataSource"%>
<%

// Create Connection
Connection connection = null;
Context initCtx = new InitialContext();
Context envCtx = (Context) initCtx.lookup("java:comp/env");
DataSource ds = (DataSource) envCtx.lookup("jdbc/moviedb");
connection = ds.getConnection();

String singleStarID = "";
singleStarID = request.getParameter( "starID" );

// Query
PreparedStatement psStars = connection.prepareStatement("SELECT * FROM stars WHERE id = ?;");
psStars.setString( 1, singleStarID );

ResultSet rsStars = psStars.executeQuery();
JSONObject starJson = new JSONObject();

while( rsStars.next() )
{
	int starID = rsStars.getInt( 1 );
	String name = rsStars.getString( 2 ) + " " + rsStars.getString( 3 );
	String dateOfBirth = rsStars.getString( 4 );
	String pictureLink = rsStars.getString( 5 );
	
	ArrayList<JSONObject> movieArray = new ArrayList<JSONObject>();
	Statement getMovies = connection.createStatement();
	ResultSet movieSet = getMovies.executeQuery("select m.id, m.title from stars_in_movies sim  inner join movies m on sim.movie_id = m.id where sim.star_id = " + starID );

	while ( movieSet.next() )
	{
		JSONObject tempMovie = new JSONObject();
		tempMovie.put( "movieID", movieSet.getInt( 1 ) );
		tempMovie.put( "title", movieSet.getString( 2 ) );
		movieArray.add( tempMovie );
	}
	
	starJson.put( "starID", starID );
	starJson.put( "name", name );
	starJson.put( "dob", dateOfBirth );
	starJson.put( "pictureLink", pictureLink );
	starJson.put( "movies", movieArray );
}
connection.close();
response.getWriter().write( starJson.toString() );
%>