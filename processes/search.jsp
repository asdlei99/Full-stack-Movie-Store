<%@ page import = "java.io.*, java.sql.*" %><%@ page import = "org.json.*" %><%@ page import="java.util.ArrayList"%>
<%@page import= "javax.naming.InitialContext"%>
<%@page import= "javax.naming.Context"%>
<%@page import= "javax.sql.DataSource"%>
<%
//Create Connection
if(session.getAttribute("name") == null || request.getParameter("search") == null){
	response.sendRedirect(request.getContextPath()); 
}
Connection connection = null;
Context initCtx = new InitialContext();
Context envCtx = (Context) initCtx.lookup("java:comp/env");
DataSource ds = (DataSource) envCtx.lookup("jdbc/moviedb");
connection = ds.getConnection();
// Create Connection


// Retrieve search data and set up queries
ArrayList<String> parameters = new ArrayList<String>();
String movieTitle = ""; 
movieTitle = request.getParameter( "movieTitle" );
String yearProduced = "";
yearProduced = request.getParameter( "yearProduced" );
String director = "";
director = request.getParameter( "director" );
String firstName = "";
firstName = request.getParameter( "firstName" );
String lastName = "";
lastName = request.getParameter( "lastName" );

// Query
PreparedStatement getMovieIDs = connection.prepareStatement("select distinct m.* from movies m "+
"inner join stars_in_movies sm on m.id = sm.movie_id "+
"inner join stars s on s.id = sm.star_id "+ 
"where m.title like ? and m.year like ? and m.director like ? and s.first_name like ? and s.last_name like ?");

getMovieIDs.setString(1, "%"+movieTitle+"%");
getMovieIDs.setString(2, "%"+yearProduced+"%");
getMovieIDs.setString(3, "%"+director+"%");
getMovieIDs.setString(4, "%"+firstName+"%");
getMovieIDs.setString(5, "%"+lastName+"%");

ResultSet movies = getMovieIDs.executeQuery();

ArrayList<JSONObject> movieList = new ArrayList<JSONObject>();
while(movies.next()){
	JSONObject movieJson = new JSONObject();
	
	int movieID = movies.getInt(1);
	
	JSONObject titleObj = new JSONObject();
	titleObj.put("id", movieID);
	titleObj.put("name", movies.getString(2));

	int year = movies.getInt(3);
	String dir = movies.getString(4);
	
	//GET stars for this movie 
	Statement getStars = connection.createStatement();
	ResultSet starSet = getStars.executeQuery(
	"select distinct s.id, s.first_name, s.last_name from movies m inner join stars_in_movies sm on m.id = sm.movie_id inner join stars s on s.id = sm.star_id where m.id = " + movieID
	);
	ArrayList<JSONObject> stars = new ArrayList<JSONObject>();
	while(starSet.next()){
		String starName = "";
		String starID = "";
		starName = starSet.getString(3) + ", " + starSet.getString(2);
		starID = starSet.getString(1);
		JSONObject star = new JSONObject();
		star.put("starID", starID);
		star.put("name", starName);
		stars.add(star);
	}
	
	//GET genres for this movie
	Statement getGenres = connection.createStatement();
	ResultSet genreSet = getGenres.executeQuery(
	"select distinct g.name from movies m inner join genres_in_movies gm on m.id = gm.movie_id_1 inner join genres g on g.id = gm.genre_id where m.id = " + movieID		
	);
	ArrayList<String> genres  = new ArrayList<String>();
	while(genreSet.next()){
		genres.add(genreSet.getString(1));
	}
	
	//Construct Movie Json Object
	movieJson.put("movieID", movieID);
	movieJson.put("title", titleObj);
	movieJson.put("year", year);
	movieJson.put("director", dir);
	movieJson.put("stars", stars);
	movieJson.put("genres", genres);
	
	//Add to the Movie-list
	movieList.add(movieJson);
}if(session.getAttribute("search") != null){
	session.removeAttribute("search");
	session.invalidate(); 
}
connection.close();
response.getWriter().write(movieList.toString()); 
%>
