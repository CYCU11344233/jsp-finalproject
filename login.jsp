
<%
String sql = "SELECT * FROM member WHERE email = ? AND password = ?";
PreparedStatement pstmt = conn.prepareStatement(sql);
pstmt.setString(1, userEmail);
pstmt.setString(2, userPassword);
ResultSet rs = pstmt.executeQuery();

%>