<%@ page language="java" contentType="application/json; charset=UTF-8"%>
<%@ page import="java.util.*, org.json.*" %>
<jsp:useBean id="bill" class="billing.billingBean" />

<%
String code = request.getParameter("code");
String priceCategoryStr = request.getParameter("priceCategory");
int priceCategory = (priceCategoryStr != null && !priceCategoryStr.isEmpty()) ? Integer.parseInt(priceCategoryStr) : 3;

try {
    Vector getDet = bill.getProductUsingCode(code, priceCategory);

    if (getDet == null || getDet.isEmpty()) {
        JSONObject error = new JSONObject();
        error.put("error", "Product not found");
        out.print(error.toString());
        return;
    }

    int productId = Integer.parseInt(getDet.get(0).toString());
    String name = (String) getDet.get(1);
    String mrp = String.valueOf(getDet.get(2));
    String discount = String.valueOf(getDet.get(3));
    int batchId = Integer.parseInt(getDet.get(4).toString());
    String unitId = getDet.size() > 5 && getDet.get(5) != null ? getDet.get(5).toString() : "";
    String unitName = getDet.size() > 6 && getDet.get(6) != null ? getDet.get(6).toString() : "";
    String commission = getDet.size() > 7 && getDet.get(7) != null ? getDet.get(7).toString() : "0";
    String convertionUnit = getDet.size() > 8 && getDet.get(8) != null ? getDet.get(8).toString() : "";

    JSONObject json = new JSONObject();
    json.put("id", String.valueOf(productId));
    json.put("name", name != null ? name : "");
    json.put("mrp", mrp);
    json.put("discount", discount);
    json.put("batchId", String.valueOf(batchId));
    json.put("unitId", unitId);
    json.put("unitName", unitName);
    json.put("commission", commission);
    json.put("convertionUnit", convertionUnit);
    out.print(json.toString());
} catch (Exception e) {
    JSONObject error = new JSONObject();
    error.put("error", e.getMessage() != null ? e.getMessage() : "Error fetching product");
    out.print(error.toString());
}
%>
