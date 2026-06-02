<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,java.util.*"%>
<%@ include file="config.jsp" %>
<html>
    <head><title>購物車檢視</title></head>
    <body>
        <h1>您的購物車</h1>
        <table border="1" width="80%">
            <tr><th>產品名稱</th><th>單價</th><th>數量</th><th>小計</th></tr>
            <%
                HashMap<String, Integer> cart = (HashMap<String, Integer>) session.getAttribute("cart");
                double total = 0;
                if (cart == null || cart.isEmpty()) {
                    out.print("<tr><td colspan='4'>購物車是空的</td></tr>");
                } else {
                    // 使用 PreparedStatement 查詢產品詳情 [1]
                    String sql = "SELECT * FROM `product` WHERE `ProductID` = ?";
                    PreparedStatement pstmt = con.prepareStatement(sql);
                    
                    for (String pid : cart.keySet()) {
                        pstmt.setString(1, pid);
                        ResultSet rs = pstmt.executeQuery();
                        if (rs.next()) {
                            String name = rs.getString("ProductName");
                            double price = rs.getDouble("Price");
                            int qty = cart.get(pid);
                            double subtotal = price * qty;
                            total += subtotal;
                        %>
                        <tr>
                            <td><%= name %></td>
                            <td><%= price %></td>
                            <td><%= qty %></td>
                            <td><%= subtotal %></td>
                        </tr>
                        <%
                        }
                        rs.close();
                    }
                    pstmt.close();
                }
            %>
        </table>
        <h3>總計金額：<%= total %> 元</h3>
        <p>
            <a href="index.jsp">繼續購物</a> |
            <a href="checkout.jsp" onclick="return confirm('確定要結帳嗎？')">前往結帳</a>
        </p>
    </body>
</html>