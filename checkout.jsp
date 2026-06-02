<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,java.util.*"%>
<%@ include file="config.jsp" %>
<%
    request.setCharacterEncoding("utf-8");
    Integer mid = (Integer) session.getAttribute("mid");
    HashMap<String, Integer> cart = (HashMap<String, Integer>) session.getAttribute("cart");
    
    // 基礎檢查：沒登入或沒東西就踢回首頁
    if (mid == null || cart == null || cart.isEmpty()) {
        out.print("<script>alert('請先登入並選購商品'); location.href='index.jsp';</script>");
        return;
    }
    
    // 【判斷點】：檢查是否是按下了「確認結帳」按鈕提交過來的
    String action = request.getParameter("action");
    
    if (action != null && action.equals("confirm")) {
        // --- 第一階段：執行結帳邏輯 (原本的 SQL 扣庫存程式碼放這裡) ---
        try {
            // (1) 新增訂單 (orders)
            String orderSql = "INSERT INTO `orders` (`MemberID`, `OrderDate`, `Status`, `TotalAmount`) VALUES (?, NOW(), '未付款', 0)";
            PreparedStatement pstmtOrder = con.prepareStatement(orderSql, Statement.RETURN_GENERATED_KEYS);
            pstmtOrder.setInt(1, mid);
            pstmtOrder.executeUpdate();
            
            ResultSet rsKeys = pstmtOrder.getGeneratedKeys();
            int orderId = 0; if (rsKeys.next()) orderId = rsKeys.getInt(1);
            
            double finalTotal = 0;
            // (2) 處理明細與【扣除庫存】(基本功能 2) [2]
            for (String pid : cart.keySet()) {
                int buyQty = cart.get(pid);
                
                // A. 查詢產品單價來計算小計
                String pSql = "SELECT `Price` FROM `product` WHERE `ProductID` = ?";
                PreparedStatement pstmtP = con.prepareStatement(pSql);
                pstmtP.setString(1, pid);
                ResultSet rsP = pstmtP.executeQuery();
                double price = 0;
                if(rsP.next()) price = rsP.getDouble("Price");
                double subtotal = price * buyQty;
                finalTotal += subtotal;
                
                // B. 新增訂單明細 (order_detail) [2]
                String detailSql = "INSERT INTO `order_detail` (`OrderID`, `ProductID`, `Quantity`, `Subtotal`) VALUES (?, ?, ?, ?)";
                PreparedStatement pstmtD = con.prepareStatement(detailSql);
                pstmtD.setInt(1, orderId);
                pstmtD.setString(2, pid);
                pstmtD.setInt(3, buyQty);
                pstmtD.setDouble(4, subtotal);
                pstmtD.executeUpdate();
                
                // C. 關鍵功能：減少庫存數量 (基本功能第 2 項) [1, 4]
                String stockSql = "UPDATE `product` SET `Quantity` = `Quantity` - ? WHERE `ProductID` = ?";
                PreparedStatement pstmtS = con.prepareStatement(stockSql);
                pstmtS.setInt(1, buyQty);
                pstmtS.setString(2, pid);
                pstmtS.executeUpdate();
            }
            
            session.removeAttribute("cart"); // 完成結帳刪除購物車 [2]
            out.print("<script>alert('結帳成功！'); location.href='index.jsp';</script>");
        } catch (Exception e) { out.print("結帳失敗：" + e.getMessage()); }
        
    } else {
        // --- 第二階段：顯示確認畫面 (讓使用者看一眼，還沒動到資料庫) ---
    %>
    <h2>結帳確認</h2>
    <p>請確認您的購買清單及收件資訊：</p>
    <!-- 這裡可以列出購物車內容摘要 -->

    <form action="checkout.jsp" method="post">
        <input type="hidden" name="action" value="confirm">
        <table border="0">
            <tr><td>收件人地址：</td><td><input type="text" name="address" required></td></tr>
            <tr><td>連絡電話：</td><td><input type="text" name="phone" required></td></tr>
        </table>
        <br>
        <input type="submit" value="確認購買並結帳">
        <a href="cart.jsp">返回購物車修改</a>
    </form>
    <%
    }
%>