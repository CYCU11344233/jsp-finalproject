<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*"%>
<%@ include file="config.jsp" %>
<%
    // 設定編碼防止亂碼
    request.setCharacterEncoding("utf-8");
    
    // 接收表單參數
    String name = request.getParameter("Name");
    String email = request.getParameter("Email");
    String password = request.getParameter("Password");
    String phone = request.getParameter("Phone");
    String address = request.getParameter("Address");
    
    try {
        // 使用 PreparedStatement 防止 SQL Injection [3]
        // 根據 member 表結構：MemberID 是自動遞增的，所以不用填 [2]
        String sql = "INSERT INTO `member` (`Name`, `Email`, `Password`, `Phone`, `Address`) VALUES (?, ?, ?, ?, ?)";
        PreparedStatement pstmt = con.prepareStatement(sql);
        
        pstmt.setString(1, name);
        pstmt.setString(2, email);
        pstmt.setString(3, password);
        pstmt.setString(4, phone);
        pstmt.setString(5, address);
        
        int result = pstmt.executeUpdate();
        
        if (result > 0) {
            out.print("<script>alert('註冊成功！請重新登入'); location.href='login.html';</script>");
        } else {
            out.print("<script>alert('註冊失敗，請重試'); history.back();</script>");
        }
        
        pstmt.close();
        con.close();
    } catch (Exception e) {
        out.print("錯誤訊息：" + e.getMessage());
    }
%>