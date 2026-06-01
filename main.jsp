<%@page contentType="text/html;charset=utf-8" language="java" import="java.sql.*"%>
<%@include file="config.jsp" %>

<html>
  <head>
    <title>期末專題測試</title>
  </head>
  <body>
    <%
      sql = "SELECT * FROM `counter`";
      ResultSet rs = con.createStatement().executeQuery(sql);
      rs.next();
      int count = rs.getInt(1);

      out.print(count);
      con.close();
    %>
  </body>
</html>
