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
DataSource ds = (DataSource) envCtx.lookup("jdbc/moviedb");
connection = ds.getConnection();

Statement s = connection.createStatement();
PreparedStatement ps = connection.prepareStatement("SELECT * FROM information_schema.columns WHERE table_name IN (SELECT TABLE_NAME "
		+ "FROM information_schema.TABLES WHERE table_type = 'base table' AND table_schema = 'moviedb')");

ResultSet metadata = ps.executeQuery();
ArrayList<JSONObject> metadataJson = new ArrayList<JSONObject>();

while( metadata.next() )
{
	JSONObject entry = new JSONObject();
	String table = metadata.getString(3);
	String attribute = metadata.getString(4);
	String type = metadata.getString(8);
	
	entry.put("table", table);
	entry.put("attribute", attribute);
	entry.put("type", type);
	
	metadataJson.add(entry);
}
connection.close();
response.getWriter().write(metadataJson.toString());
%>