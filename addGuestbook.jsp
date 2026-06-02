<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*"%>
<%@ include file="config.jsp" %>
<%
    request.setCharacterEncoding("utf-8"); // 確保支援中文留言 [1]
    
    Integer mid = (Integer) session.getAttribute("mid");
    String pid = request.getParameter("pid"); // 接收從表單傳來的產品 ID
    String content = request.getParameter("content");

    if (mid != null && content != null && !content.trim().isEmpty()) {
        try {
            String insertSql = "INSERT INTO `guestbook` (`MemberID`, `ProductID`, `Contents`, `DateTime`) VALUES (?, ?, ?, NOW())";
            PreparedStatement pstmtAdd = con.prepareStatement(insertSql);
            
            pstmtAdd.setInt(1, mid);
            pstmtAdd.setString(2, pid);
            pstmtAdd.setString(3, content);
            
            pstmtAdd.executeUpdate();
            pstmtAdd.close();
            con.close();
            
            // 導回原本的頁面並帶上產品 ID
            response.sendRedirect("guestbook.jsp?id=" + pid); 
        } catch (Exception e) {
            out.print("儲存留言失敗：" + e.getMessage());
        }
    } else {
        out.print("<script>alert('請先登入並輸入內容'); history.back();</script>");
    }
%>