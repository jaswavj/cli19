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
    request.setAttribute("pageTitle",    "Supplier Payment");
    request.setAttribute("pageSubtitle", "Product — Supplier Payments");
    request.setAttribute("pageIcon",     "fa-solid fa-hand-holding-dollar");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

    <div class="container-fluid mt-3 mst-page">

    <form action="<%=contextPath%>/product/supplierPayment/page1.jsp" method="get" class="row g-3">
        
        <div class="col-md-3">
            <label for="fromDate" class="form-label">Supplier:</label>
            <select name="supId" class="form-select fg-inp">
                <option value="0">Select Supplier</option>
                <%
                    Vector vec		= prod.GetSupplier();
                    ///////////////Supplier////////
                    for(int n=0;n< vec.size();n++)
                        {
                        Vector sub	 	= (Vector)vec.elementAt(n);
                        int ID			= Integer.parseInt(sub.elementAt(0).toString());
                        String name 	= sub.elementAt(1).toString();
                %>
                    <option value="<%=ID%>"><%=name%></option>
                <% } %>
            </select>
        </div>
        

        
        

        <div class="col-md-4 d-flex align-items-end">
            <button type="submit" class="bb bb-primary w-100">Get Pending Supplier Payment</button>
        </div>
    </form>
</div>
    <!-- Bootstrap JS -->

</body>
</html>
