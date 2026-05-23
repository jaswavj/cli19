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
    <title>Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- Bootstrap CSS -->
<%@ include file="/assets/common/head.jsp" %>
    

</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>
<%
    request.setAttribute("pageTitle",    "Cancel Bill Report");
    request.setAttribute("pageSubtitle", "Admin — Reports");
    request.setAttribute("pageIcon",     "fa-solid fa-ban");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

<div class="container-fluid mt-3 mst-page">

    <form action="<%=contextPath%>/admin/report/cancelBill/page0.jsp" method="get" class="row g-3">
        <div class="col-md-3">
            <label for="fromDate" class="form-label">From Date:</label>
            <input type="date" id="fromDate" name="fromDate" value="<%=today%>" class="form-control fg-inp" required>
        </div>

        <div class="col-md-3">
            <label for="toDate" class="form-label">To Date:</label>
            <input type="date" id="toDate" name="toDate" value="<%=today%>" class="form-control fg-inp" required>
        </div>
        
        

        <div class="col-md-4 d-flex align-items-end">
            <button type="submit" class="bb bb-primary w-100"><i class="fa-solid fa-magnifying-glass me-1"></i>Generate Report</button>
        </div>
    </form>
</div>
    <!-- Bootstrap JS -->

</body>
</html>
