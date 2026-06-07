<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<jsp:useBean id="prod" class="product.productBean" />
<%
    response.setContentType("application/json");

    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        out.print("{\"success\":false,\"message\":\"Unauthorized\"}");
        return;
    }

    String idStr  = request.getParameter("id");
    String action = request.getParameter("action");

    try {
        if (idStr != null && !idStr.isEmpty() && action != null) {
            int id        = Integer.parseInt(idStr);
            int newStatus = action.equals("block") ? 0 : 1;
            prod.updateProductStatus(id, newStatus);

            String msg = action.equals("block") ? "Product blocked successfully" : "Product unblocked successfully";
            out.print("{\"success\":true,\"message\":\"" + msg + "\"}");
        } else {
            out.print("{\"success\":false,\"message\":\"Invalid request\"}");
        }
    } catch (Exception e) {
        out.print("{\"success\":false,\"message\":\"Error: " + e.getMessage().replace("\"", "'") + "\"}");
    }
%>
