<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*"%>
<% request.setCharacterEncoding("utf-8"); %>
<%@ include file="config.jsp" %>
<h2>訪客留言板</h2>

<%-- 在顯示留言的 HTML 中間加入此段 --%>
<hr>
<h3>我要留言</h3>
<%
    // 檢查是否登入，根據專題流程圖，留言前需確認身分 [2]
    if (session.getAttribute("mid") != null) {
    %>
    <form action="addGuestbook.jsp" method="post">
        <%-- 隱藏欄位：用來傳遞當前的產品 ID --%>
        <input type="hidden" name="pid" value="<%= request.getParameter("id") == null ? "General" : request.getParameter("id") %>">
        <textarea name="content" rows="4" cols="50" required placeholder="請輸入留言內容..."></textarea><br>
        <input type="submit" value="送出留言">
    </form>
    <%
    } else {
        out.print("<p>請先 <a href='login.html'>登入</a> 後即可留言。</p>");
    }
%>
<hr>

<%
    try {
        // 修正：在 g 後面加上空格，並移除 WHERE 子句中的 ProductID 引號（如果它是數字）
        // 備註：根據 flower.sql，guestbook 的 ProductID 是 varchar(45) [1]
        String sql = "SELECT g.*, m.Name FROM `guestbook` AS g " +
        "JOIN `member` AS m ON g.MemberID = m.MemberID " +
        "WHERE g.ProductID = ? " +
        "ORDER BY g.DateTime DESC";
        
        PreparedStatement pstmt = con.prepareStatement(sql);
        
        // 取得產品 ID 參數
        String pid = request.getParameter("id");
        if (pid == null) pid = "0"; // 預防參數為空
        
        // 雖然來源資料表 ProductID 是 varchar，但使用 setString 或 setInt 通常 MySQL 能自動轉換
        // 為了符合資料表定義 [1]，建議改用 setString
        pstmt.setString(1, pid);
        
        ResultSet rs = pstmt.executeQuery();
        
        while(rs.next()) {
        %>
        <div style="border:1px solid #ccc; margin-bottom:10px; padding:10px;">
            <strong>留言者：<%= rs.getString("Name") %></strong>
            <span style="font-size:0.8em; color:gray;">發表於：<%= rs.getTimestamp("DateTime") %></span>
            <p><%= rs.getString("Contents") %></p>
        </div>
        <%
        }
        rs.close();
        pstmt.close();
    } catch (Exception e) {
        out.print("讀取留言出錯：" + e.getMessage());
    }
%>