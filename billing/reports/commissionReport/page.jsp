<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<%@ page import="java.text.SimpleDateFormat, java.util.Date" %>
<jsp:useBean id="prod" class="product.productBean" />
<%
String today = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Commission Report</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>
<%
    request.setAttribute("pageTitle",    "Commission Report");
    request.setAttribute("pageSubtitle", "Reports — Customer Commission");
    request.setAttribute("pageIcon",     "fa-solid fa-percent");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

    <div class="container-fluid mt-3 mst-page">

        <form action="<%=contextPath%>/reports/commissionReport/page0.jsp" method="get" class="row g-3">
            <div class="col-md-3">
                <label for="fromDate" class="form-label">From Date:</label>
                <input type="date" id="fromDate" name="fromDate" value="<%=today%>" class="form-control" required>
            </div>
            <div class="col-md-3">
                <label for="toDate" class="form-label">To Date:</label>
                <input type="date" id="toDate" name="toDate" value="<%=today%>" class="form-control" required>
            </div>
            <div class="col-md-3">
                <label for="customerId" class="form-label">Customer:</label>
                <select name="customerId" id="customerId" class="form-select" required>
                    <option value="">Select Customer</option>
                    <%
                        Vector customers = prod.getCommissionCustomers();
                        for (int i = 0; i < customers.size(); i++) {
                            Vector cust = (Vector) customers.get(i);
                            int custId   = (Integer) cust.elementAt(0);
                            String custName = cust.elementAt(1).toString();
                    %>
                    <option value="<%=custId%>"><%=custName%></option>
                    <% } %>
                </select>
            </div>
            <div class="col-md-3 d-flex align-items-end">
                <button type="submit" class="bb bb-primary w-100">Generate Report</button>
            </div>
        </form>
    </div>
</body>
</html>
