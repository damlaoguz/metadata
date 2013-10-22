<%@page import="java.util.Date"%>

<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.DatabaseMetaData"%>
<%@page import="javax.naming.Context"%>
<%@page import="javax.naming.InitialContext"%>
<%@page import="javax.sql.DataSource"%>
<%@page import="java.sql.Connection"%>

<%
    Date dateNow = new Date();
    String lastAccess = null;
    String error = null;

    Context initContext = null;
    Context envContext = null;
    DataSource dataSource = null;
    Connection connection = null;
    Statement statement = null;

    try {
        initContext = new InitialContext();
        envContext  = (Context)initContext.lookup("java:/comp/env");
        dataSource = (DataSource)envContext.lookup("jdbc/hsql/lastaccess");
        connection = dataSource.getConnection();

        statement = connection.createStatement();

        // dummy table creation
        try {
            String createSql = "CREATE TABLE hits2(id BIGINT, time VARCHAR(128))";
            statement = connection.createStatement();
            statement.executeUpdate(createSql);
            statement.close();
        } catch (Exception e) {
            e.printStackTrace();
        }

        // select last access time            
        String sql = "SELECT id,time FROM hits2 ORDER BY id DESC LIMIT 1";
        statement = connection.createStatement();
        ResultSet resultSet = statement.executeQuery(sql);
        while (resultSet.next()) {
            lastAccess = resultSet.getString("time");
        }
        statement.close();

        // insert last access time
        String insertSql = "INSERT INTO hits2(id, time) VALUES (" + System.currentTimeMillis() + ", \'" + dateNow + "\')";
        statement = connection.createStatement();
        statement.executeUpdate(insertSql);
        statement.close();
    } catch (Exception e) {
        e.printStackTrace();
        error = e.getMessage();
    }
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Hello Codenvy</title>
        <style>
          
            table {
                border-collapse:collapse;
            }

            table,th, td {
                border: 1px solid #CCCCCC;
                line-height:18px;
                font-size:11px;
            }

            th {
                height:24px;
                background-color:#EBE;
            }

    </style>
    </head>

    <body>
        <% if (error == null) { %>
            <div align="center">
                <center>
                <h1>Hello Codenvy</h1>
                <br>
                <hr>
                <br>
                Today's date is <%= dateNow %>
                <br>
                <br>
                <% if (lastAccess == null) { %>
                    This script was accessed the first time
                <% } else { %>
                    This script was last accessed at <%= lastAccess %>
                <% } %>
                <br>
                <br>
                Below the list of the latest 20 hits
                <br>
                <br>
                
                <table border="1px" style="width:400px;">
                    <tr><th>ID</th><th>TIME</th></tr>
                    <%
                        // select last 20 hits
                        String sql = "SELECT id,time FROM hits2 ORDER BY id DESC LIMIT 20";
                        statement = connection.createStatement();
                        ResultSet resultSet = statement.executeQuery(sql);
                        while (resultSet.next()) {
                            String _id = resultSet.getString("id");
                            String _time = resultSet.getString("time");
                    %>
                    <tr><td><%= _id %></td><td><%= _time %></td></tr>
                    <%
                        }
                        statement.close();
                    %>
                </table>
                </center>
            </div>    
        <% } else { %>    
            <div align="center">
                <font style="color:darr-red;">ERROR: <%= error %></font>
            </div>
        <% } %>   
    </body>
</html>

<%
    try {
        connection.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
