<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<%@ page language="java" import= "java.util.*,java.text.*" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<jsp:useBean id="prod" class="product.productBean" />
<%
    String fromDate = request.getParameter("fromDate");  
    String toDate   = request.getParameter("toDate");
    int categoryId = Integer.parseInt(request.getParameter("categoryId"));
    

    // Just for demo - print selected dates
%>
<!DOCTYPE html>
<html lang="en">
<head>
    
    <meta charset="UTF-8">
    <title>Sales Report</title>
<%@ include file="/assets/common/head.jsp" %>
</head>
<body>
<!--%@ include file="../menu/reportMenu.jsp" %-->
    <%@ include file="/assets/navbar/navbar.jsp" %>
<%
    request.setAttribute("pageTitle",    "Day Account Details");
    request.setAttribute("pageSubtitle", "Reports — Daily Sales Detail");
    request.setAttribute("pageIcon",     "fa-solid fa-list");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

<div class="container-fluid mt-3 mst-page">
<p class="mb-2 text-muted"><strong>Sales Report From:</strong> <%= fromDate %> — <%= toDate %></p>

<table class="table mst-table mt-3">
    <thead>
        <tr>
            <th>S.No</th>
            <th>Bill No</th>
            <th>Item Name</th>
            <th>Qty</th>
            <th>Price</th>
            <th>Discount</th>
            <th>Total</th>
            <th>Category</th>
            <th>Brand</th>
            <th>Date</th>
            <th>Time</th>
            <th>Biller</th>
        </tr>
    </thead>
    <tbody>
        <%
        Vector vec = bill.getSalesReport(fromDate,toDate,categoryId);
        double grandTotal=0;
        double grandPrice=0;
        double grandDiscount=0;
        for(int i=0;i< vec.size();i++)
		{
            Vector row		= (Vector)vec.elementAt(i);
            int billId		= Integer.parseInt(row.elementAt(8).toString());
            double price    = Double.parseDouble(row.elementAt(2).toString());  
            double total    = Double.parseDouble(row.elementAt(4).toString());
            double discount = Double.parseDouble(row.elementAt(3).toString());
            grandTotal     += total;
            grandPrice     += price;
            grandDiscount  += discount;    
           


        %>
        <tr>
            <td><%=i+1%></td>
            <td><%=row.elementAt(0)%></td>
            <td><%=row.elementAt(9)%></td>
            <td><%=row.elementAt(1)%></td>
            <td><%=row.elementAt(2)%></td>
            <td><%=row.elementAt(3)%></td>
            <td><%=row.elementAt(4)%></td>
            <td><%=row.elementAt(10)%></td>
            <td><%=row.elementAt(11)%></td>
            <td><%=row.elementAt(5)%></td>
            <td><%=row.elementAt(6)%></td>
            <td><%=row.elementAt(7)%></td>
        </tr>
        <%
    
}
        %>
        <tr style="background:var(--bill-bg);font-weight:700">
            <td colspan="4" class="text-end"><strong>Grand Total:</strong></td>
            <td><strong><%=String.format("%.3f", grandPrice)%></strong></td>
            <td><strong><%=String.format("%.3f", grandDiscount)%></strong></td>
            <td><strong><%=String.format("%.3f", grandTotal)%></strong></td>
            <td colspan="5"></td>
    </tbody>
</table>
</div>
</body>
</html>
