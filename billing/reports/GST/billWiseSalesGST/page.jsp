<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.text.SimpleDateFormat, java.util.Date" %>
<%
String today = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bill Wise Sales GST Report</title>
<%@ include file="/assets/common/head.jsp" %>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>
<%
    request.setAttribute("pageTitle",    "Bill Wise Sales GST");
    request.setAttribute("pageSubtitle", "GST Reports \u2014 Bill Wise");
    request.setAttribute("pageIcon",     "fa-solid fa-file-invoice");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

<div class="container-fluid mt-3 mst-page">
    <form action="<%=contextPath%>/reports/GST/billWiseSalesGST/page1.jsp" method="get" class="row g-3">
        <div class="col-md-4">
            <label for="startDate" class="form-label">Start Date</label>
            <input type="date" class="form-control" value="<%=today%>" id="startDate" name="startDate" required>
        </div>
        <div class="col-md-4">
            <label for="endDate" class="form-label">End Date</label>
            <input type="date" class="form-control" value="<%=today%>" id="endDate" name="endDate" required>
        </div>
        <div class="col-md-4 d-flex align-items-end">
            <button type="submit" class="bb bb-primary w-100">Generate Report</button>
        </div>
    </form>
</div>
</body>
</html>
