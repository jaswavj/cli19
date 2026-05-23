<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, javax.servlet.http.*" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<%
int supId = Integer.parseInt(request.getParameter("supId"));

Vector billList = bill.getDueSupplierBills(supId);

    
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Billing - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>
<%
    request.setAttribute("pageTitle",    "Pending Supplier Payments");
    request.setAttribute("pageSubtitle", "Product — Supplier Bills");
    request.setAttribute("pageIcon",     "fa-solid fa-truck-ramp-box");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

<div class="container-fluid mt-3 mst-page">

  <div class="table-responsive">
    <table class="table mst-table">
      <thead>
        <tr>
          <th>S.No</th>
          <th>Inv/GR No</th>
          <th>Invoice date</th>
          <th class="text-end">Total</th>
          <th class="text-end">Paid</th>
          <th class="text-end">Balance</th>
          <th>Date/Time</th>
          <th>User</th>
          <th>Supplier</th>
          <th>Action</th>
        </tr>
      </thead>
      <tbody>
        <%
            for (int i = 0; i < billList.size(); i++) {
                Vector row = (Vector) billList.get(i);
                
                String currentBalance   = row.get(5).toString();
                int billId		= Integer.parseInt(row.elementAt(0).toString());

            %>
        <tr>
          <td><%=i+1%></td>
          <td><a href="<%=contextPath%>/product/purchase/report/purchaseRegister/purchaseDetails.jsp?id=<%=billId%>" class="inv-link"><%=row.elementAt(1)%>/<%=row.elementAt(9)%></a></td>
          <td><%=row.elementAt(2)%></td>
          <td><%=row.elementAt(3)%></td>
          <td class="text-end"><%=row.elementAt(4)%></td>
          <td class="text-end <%= (Double.parseDouble(currentBalance) > 0) ? "text-danger fw-bold" : "" %>"><%=currentBalance%></td>
          <td><%=row.elementAt(6)%></td>
          <td><%=row.elementAt(7)%></td>
          <td><%=row.elementAt(8)%></td>
          <td class="text-center">
            <a href="<%=contextPath%>/product/supplierPayment/payBalance.jsp?billId=<%=billId%>&supId=<%=supId%>" class="bb bb-outline">Pay Balance</a>
          </td>
        </tr>
        <%
    }
        %>
        
      </tbody>
    </table>
  </div>
</div>

        
<script src="billing.js"></script>
</body>
</html>
    

