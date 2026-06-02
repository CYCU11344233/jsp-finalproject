<%@page contentType="text/html;charset=utf-8" language="java" import="java.sql.*"%>
<%@include file="config.jsp" %>
<html>
  <head><title>花卉購物商城</title></head>
  <body>
    <!-- 登入狀態控制 -->
    <%
      String loginEmail = (String) session.getAttribute("email");
      String loginName = (String) session.getAttribute("name");
      if(loginEmail != null) {
        out.print("<p>歡迎光臨，" + loginName + "！ <a href='logout.jsp'>登出</a></p>");
      } else {
        out.print("<p><a href='login.html'>會員登入</a> | <a href='register.html'>加入會員</a></p>");
      }
    %>

    <%-- 建立搜尋表單 --%>
    <form action="index.jsp" method="get">
      搜尋產品名稱：
      <input type="text" name="searchKeyword" placeholder="輸入花卉名稱...">
      <input type="submit" value="搜尋">
      <a href="index.jsp">清除搜尋</a>
    </form>
    <hr>

    <a href="checkout.jsp">查看購物車</a>

    <%
      // 獲取搜尋關鍵字
      String keyword = request.getParameter("searchKeyword");
      ResultSet rs = null;
      PreparedStatement psmt = null;
      
      try {
        String sqlSearch;
        // 如果有輸入關鍵字，則進行篩選；否則顯示全部產品
        if (keyword != null && !keyword.trim().isEmpty()) {
          sqlSearch = "SELECT * FROM `product` WHERE `ProductName` LIKE ?";
          psmt = con.prepareStatement(sqlSearch);
          // 使用 % 進行模糊比對
          psmt.setString(1, "%" + keyword + "%");
          rs = psmt.executeQuery();
        %>

        <!-- 產品顯示表格 -->
        <table border="1">
          <tr>
            <th>產品名稱</th>
            <th>分類</th>
            <th>價格</th>
            <th>庫存數量</th>
          </tr>
          <%
            while(rs.next()) {
            %>
            <tr>
              <td><%= rs.getString("ProductName") %></td>
              <td><%= rs.getString("Category") %></td>
              <td><%= rs.getDouble("Price") %></td>
              <td><%= rs.getInt("Quantity") %></td>
            </tr>
            <%
            }
          %>
        </table>

        <%
        }
      } catch (Exception e) {
        out.print("搜尋出錯：" + e.getMessage());
      } finally {
      if (rs != null) rs.close();
      if (psmt != null) psmt.close();
    }
  %>

  <%-- 產品陳列功能並顯示庫存 --%>
  <h2>本月精選花卉</h2>
  <table border="1" style="width: 80%; border-collapse: collapse;">
    <tr style="background-color: #f2f2f2;">
      <th>產品名稱</th>
      <th>分類</th>
      <th>價格</th>
      <th>剩餘庫存</th>
      <th>操作</th>
    </tr>

    <%
      try {
        // 1. 撰寫查詢語句 (依照 product 資料表結構)
        String sqlProduct = "SELECT * FROM `product`";
        psmt = con.prepareStatement(sqlProduct);
        
        // 2. 執行查詢
        rs = psmt.executeQuery();
        
        // 3. 迴圈讀取每一筆產品資料並顯示
        while(rs.next()) {
          int pid = rs.getInt("ProductID");
          String pName = rs.getString("ProductName");
          String category = rs.getString("Category");
          double price = rs.getDouble("Price");
          int quantity = rs.getInt("Quantity"); // 顯示庫存的關鍵
        %>
        <tr>
          <td><%= pName %></td>
          <td><%= category %></td>
          <td>NT$ <%= price %></td>
          <td style="<%= (quantity < 5) ? "color:red; font-weight:bold;" : "" %>">
            <%= quantity %> <!-- 顯示庫存數量 -->
          </td>
          <td>
            <% if(quantity > 0) { %>
            <a href="addToCart.jsp?id=<%= pid %>">加入購物車</a>
            <% } else { %>
            <span style="color:gray;">補貨中</span>
            <% } %>
            <br/>
            <a href="guestbook.jsp?id=<%= pid %>">訪客留言板</a>
          </td>
        </tr>
        <%
        } // End while
        
        // 關閉資源
        rs.close();
        psmt.close();
        // 注意：若下方還有其他資料庫操作，con 先不要關閉
      } catch (Exception e) {
        out.print("產品載入出錯：" + e.getMessage());
      }
    %>
  </table>

  <!-- 2. 網頁計數器顯示 -->
  <%
    // 1. 取得目前的計數 (加上變數型別宣告)
    String sql = "SELECT visitCount FROM `counter`";
    rs = con.createStatement().executeQuery(sql);
    int count = 0;
    if(rs.next()) {
      count = rs.getInt(1);
    }
    
    // 2. 如果是新連線，更新資料庫
    if (session.isNew()){
      count++;
      String updateSql = "UPDATE `counter` SET `visitCount` = ?";
      PreparedStatement pstmt = con.prepareStatement(updateSql);
      pstmt.setInt(1, count);
      pstmt.executeUpdate();
      pstmt.close();
    }
    
    out.print("<hr><p>訪客瀏覽人次：" + count + "</p>");
    
    // 注意：關閉連接前請確認 rs 已不再使用
    rs.close();
    con.close();
  %>
</body>
</html>