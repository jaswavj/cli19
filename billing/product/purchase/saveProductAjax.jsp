<%@page language="java" import="java.util.*, java.math.BigDecimal" %>
<jsp:useBean id="prod" class="product.productBean" />
<%
response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");
try {
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        out.print("{\"success\":false,\"message\":\"Session expired\"}");
        return;
    }

    String productName = request.getParameter("productName");
    if (productName == null || productName.trim().isEmpty()) {
        out.print("{\"success\":false,\"message\":\"Product name is required\"}");
        return;
    }

    String categoryId = request.getParameter("categoryId");
    String brandId    = request.getParameter("brandId");
    String productCode = request.getParameter("productCode");
    if (productCode == null || productCode.trim().isEmpty()) productCode = "0";

    int unitId = 0;
    try { unitId = Integer.parseInt(request.getParameter("unitId")); } catch (Exception e) {}

    String hsn = request.getParameter("hsn");
    if (hsn != null && hsn.trim().isEmpty()) hsn = null;

    double cost = 0.0, mrp = 0.0;
    try { cost = Double.parseDouble(request.getParameter("cost")); } catch (Exception e) {}
    try { mrp  = Double.parseDouble(request.getParameter("mrp"));  } catch (Exception e) {}

    int gst = 0;
    try { gst = Integer.parseInt(request.getParameter("gst")); } catch (Exception e) {}

    double commission = 0.0;
    String commissionParam = request.getParameter("commission");
    if (commissionParam != null && !commissionParam.trim().isEmpty()) {
        try { commission = Double.parseDouble(commissionParam); } catch (Exception e) {}
    }

    int discType = 0;
    try { discType = Integer.parseInt(request.getParameter("discType")); } catch (Exception e) {}
    double discValue = 0.0;
    String discParam = request.getParameter("discValue");
    if (discParam != null && !discParam.trim().isEmpty()) {
        try { discValue = Double.parseDouble(discParam); } catch (Exception e) {}
    }

    String stockParam = request.getParameter("stock");
    BigDecimal stock = new BigDecimal(stockParam != null && !stockParam.trim().isEmpty() ? stockParam : "0");

    // Handle unit conversion (same logic as product1.jsp)
    Vector selectedUnit = prod.getUnitById(unitId);
    if (selectedUnit != null && selectedUnit.size() > 3 && selectedUnit.elementAt(3) != null) {
        BigDecimal convertionCalculation = (BigDecimal) selectedUnit.elementAt(3);
        if (convertionCalculation.compareTo(BigDecimal.ZERO) > 0) {
            stock      = stock.multiply(convertionCalculation);
            BigDecimal calcBD = convertionCalculation;
            cost       = new BigDecimal(cost).divide(calcBD, 6, java.math.RoundingMode.HALF_UP).doubleValue();
            mrp        = new BigDecimal(mrp).divide(calcBD, 6, java.math.RoundingMode.HALF_UP).doubleValue();
            commission = new BigDecimal(commission).divide(calcBD, 6, java.math.RoundingMode.HALF_UP).doubleValue();
        }
    }

    prod.addProduct(productName.trim(), Integer.parseInt(categoryId), Integer.parseInt(brandId),
                    productCode, cost, mrp, discType, discValue, stock, userId, gst, unitId, hsn, commission);

    int newProductId = prod.getProductIdByNameAndCode(productName.trim(), productCode);

    String safeName = productName.trim().replace("\\", "\\\\").replace("\"", "\\\"");
    String safeCode = productCode.replace("\\", "\\\\").replace("\"", "\\\"");
    out.print("{\"success\":true,\"productId\":" + newProductId + ",\"productName\":\"" + safeName + "\",\"productCode\":\"" + safeCode + "\"}");

} catch (Exception e) {
    String msg = e.getMessage() != null
        ? e.getMessage().replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", " ").replace("\r", "")
        : "Unknown error";
    out.print("{\"success\":false,\"message\":\"" + msg + "\"}");
}
%>
