<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.*"%>
<%
    // 1. 取得網頁傳過來的產品 ID
    String pidStr = request.getParameter("id");
    
    if (pidStr != null && !pidStr.isEmpty()) {
        // 2. 從 Session 取得購物車物件 (使用 HashMap：key 是產品ID, value 是數量)
        HashMap<String, Integer> cart = (HashMap<String, Integer>) session.getAttribute("cart");
        
        // 3. 如果是第一次購買，初始化購物車
        if (cart == null) {
            cart = new HashMap<String, Integer>();
        }
        
        // 4. 更新購買數量 (如果已在車內就 +1)
        if (cart.containsKey(pidStr)) {
            cart.put(pidStr, cart.get(pidStr) + 1);
        } else {
            cart.put(pidStr, 1);
        }
        
        // 5. 將更新後的購物車放回 Session
        session.setAttribute("cart", cart);
    }
    
    // 6. 導向回首頁或購物車檢視頁
    out.print("<script>alert('已加入購物車！'); location.href='index.jsp';</script>");
%>