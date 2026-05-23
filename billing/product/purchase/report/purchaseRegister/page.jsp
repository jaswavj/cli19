<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<%@ page import="java.text.SimpleDateFormat, java.util.Date" %>
<jsp:useBean id="prod" class="product.productBean" />
<%
String today = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Purchase Register — Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
<%@ include file="/assets/common/head.jsp" %>
</head>
<body>

    <%@ include file="/assets/navbar/navbar.jsp" %>
<%
    request.setAttribute("pageTitle",    "Purchase Register");
    request.setAttribute("pageSubtitle", "Purchase Reports — Purchase Register");
    request.setAttribute("pageIcon",     "fa-solid fa-file-invoice-dollar");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

    <div class="container-fluid mt-3 mst-page" style="max-width: 1200px;">

        <div class="mst-filter-card">
            <form action="<%=contextPath%>/product/purchase/report/purchaseRegister/page0.jsp" method="get" class="row g-3 align-items-end">
                <div class="col-md-3">
                    <label class="form-label">From Date</label>
                    <input type="date" name="fromDate" value="<%=today%>" class="form-control" required>
                </div>

                <div class="col-md-3">
                    <label class="form-label">To Date</label>
                    <input type="date" name="toDate" value="<%=today%>" class="form-control" required>
                </div>

                <div class="col-md-3">
                    <label class="form-label">Supplier</label>
                    <select name="supId" class="form-select">
                        <option value="0">Select Supplier</option>
                        <%
                            Vector vec = prod.GetSupplier();
                            for(int n = 0; n < vec.size(); n++) {
                                Vector sub  = (Vector) vec.elementAt(n);
                                int ID      = Integer.parseInt(sub.elementAt(0).toString());
                                String name = sub.elementAt(1).toString();
                        %>
                            <option value="<%=ID%>"><%=name%></option>
                        <% } %>
                    </select>
                </div>

                <div class="col-md-3">
                    <button type="submit" class="bb bb-primary w-100">
                        <i class="fa-solid fa-magnifying-glass me-1"></i> Generate Report
                    </button>
                </div>
            </form>
        </div>

    </div>

</body>
</html>
