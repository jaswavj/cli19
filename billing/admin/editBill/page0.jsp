<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<%@ page language="java" import= "java.util.*,java.text.*" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<jsp:useBean id="prod" class="product.productBean" />
<%
    String fromDate = request.getParameter("fromDate");  
    String toDate   = request.getParameter("toDate");
    String userIdParam = request.getParameter("userId");
    int userId = (userIdParam != null && !userIdParam.isEmpty()) ? Integer.parseInt(userIdParam) : 0;
    int typeId = 0; 
    int modeId = 0; 
    
    //int modeId = Integer.parseInt(request.getParameter("mode"));
    /*String typeParam = request.getParameter("type");
    int typeId = 0; // default
    if (typeParam != null && !typeParam.isEmpty()) {
        typeId = Integer.parseInt(typeParam);
    }*/
    

%>
<!DOCTYPE html>
<html lang="en">
<head>
    
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    <title>Sales Report</title>
<%@ include file="/assets/common/head.jsp" %>
</head>
<body>
<%@ include file="/assets/navbar/navbar.jsp" %>
<%
    request.setAttribute("pageTitle",    "Edit Bill Report");
    request.setAttribute("pageSubtitle", "Admin — Bill Management");
    request.setAttribute("pageIcon",     "fa-solid fa-file-pen");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

<div class="container-fluid mt-3 mst-page">
<p class="fw-semibold"><i class="fa-solid fa-file-invoice me-1"></i>Sales Report From: <%= fromDate %> &ndash; <%= toDate %></p>

<div class="table-responsive">
<table class="table mst-table table-sm mt-3" style="min-width: 900px;">
    <thead>
        <tr>
            <th class="text-center">S.No</th>
            <th>Bill No</th>
            <th class="text-end">Total</th>
            <th class="text-end">Discount</th>
            <th class="text-end">Payable</th>
            <th class="text-end">Paid</th>
            <th class="text-end">Balance</th>
            <th>Date</th>
            <th>Time</th>
            <th>Biller</th>
            <th class="text-center">Action</th>
        </tr>
    </thead>
    <tbody>
        <%
        Vector vec = new Vector();
        try {
            vec = bill.getsalesCashBankReport(fromDate,toDate,modeId,typeId,userId);
        } catch (Exception e) {
            e.printStackTrace();
        }
        double finTotal=0.0;
        double finDiscount=0.0;
        double finPayable=0.0; 
        double finPaid=0.0;
        double finCash=0.0;
        double finBank=0.0;
        double finBalance=0.0;
        double finCurBalance=0.0;
        for(int i=0;i< vec.size();i++)
		{
            Vector row		= (Vector)vec.elementAt(i);
            int billId		= Integer.parseInt(row.elementAt(8).toString());  
            double totalAmt   = Double.parseDouble(row.elementAt(1).toString());
            double discount    = Double.parseDouble(row.elementAt(2).toString());
            double payable     = Double.parseDouble(row.elementAt(3).toString());
            double paid        = Double.parseDouble(row.elementAt(4).toString());
            double cash       = Double.parseDouble(row.elementAt(10).toString());
            double bank       = Double.parseDouble(row.elementAt(11).toString());
            double Balance       = Double.parseDouble(row.elementAt(12).toString());
            double curBalance       = Double.parseDouble(row.elementAt(13).toString());
            finTotal+=totalAmt;
            finDiscount+=discount;  
            finPayable+=payable;
            finPaid+=paid;
            finCash+=cash;
            finBank+=bank;
            finBalance+=Balance;
            finCurBalance+=curBalance;
            


        %>
        <tr>
            <td><%=i+1%></td>
            <td><%=row.elementAt(0)%></td>
            <td><%=row.elementAt(1)%></td>
            <td><%=row.elementAt(2)%></td>
            <td><%=row.elementAt(3)%></td>
            <td><%=row.elementAt(4)%></td>
            <td><%=row.elementAt(12)%></td>
            <!--<% if(modeId !=2) { %><td><%=row.elementAt(10)%></td><%}%>
            <% if(modeId !=1) { %><td><%=row.elementAt(11)%></td><%}%>
        
            <td><%=row.elementAt(13)%></td>
            <% if(modeId !=1) { %><td><%=row.elementAt(9)%></td><%}%>
            --><td><%=row.elementAt(5)%></td>
            <td><%=row.elementAt(6)%></td>
            <td><%=row.elementAt(7)%></td>
            <td>
                <a href="<%=contextPath%>/admin/editBill/edit.jsp?billId=<%=billId%>" class="bb bb-outline btn-sm"><i class="fa-solid fa-pen"></i> Edit</a>
                <a href="<%=contextPath%>/admin/editBill/cancel.jsp?billId=<%=billId%>" class="btn btn-sm btn-outline-danger"><i class="fa-solid fa-ban"></i> Cancel</a>
            </td>
        </tr>
        <%
    
}
        %>
        <tr class="table-secondary">
            <td colspan="2"><strong>Grand Total</strong></td>
            <td><strong><%=String.format("%.3f", finTotal)%></strong></td>
            <td><strong><%=String.format("%.3f", finDiscount)%></strong></td>
            <td><strong><%=String.format("%.3f", finPayable)%></strong></td>
            <td><strong><%=String.format("%.3f", finPaid)%></strong></td>
            <td><strong><%=finBalance%></strong></td>
            <!--<% if(modeId !=2) { %><td><strong><%=String.format("%.3f", finCash)%></strong></td><%}%>
            <% if(modeId !=1) { %><td><strong><%=String.format("%.3f", finBank)%></strong></td><%}%>
        -->
            <td><strong><%=finCurBalance%></strong></td>
            <% if(modeId !=1) { %><td></td><%}%>
            <td></td>
            <td></td>
            
            
        </tr>
    </tbody>
</table>
</div>
<p class="fw-semibold mt-4"><i class="fa-solid fa-money-bill-wave me-1"></i>Due Collection Report From: <%= fromDate %> – <%= toDate %></p>

<div class="table-responsive">
<table class="table mst-table mt-3">
   <thead>
    <tr>
        <th>S.No</th>
        <th>Bill No</th>
        <th>Customer Name</th>
        <th>Balance</th>
        <th>Cash Paid</th>
        <th>Bank Paid</th>
        <th>Mode</th>
        <th>Bank Option</th>
        <th>Date</th>
        <th>Time</th>
        <th>Biller</th>
    </tr>
</thead>
<tbody>
<%
    Vector dueDetails = new Vector();
    try {
        dueDetails = bill.getDuePaidList(fromDate, toDate, userId);
    } catch (Exception e) {
        e.printStackTrace();
    }
    double totalCashPaid = 0.0;
    double totalBankPaid = 0.0;
    for (int j = 0; j < dueDetails.size(); j++) {
        Vector row = (Vector) dueDetails.elementAt(j);

        String cusName     = row.elementAt(0).toString();   // Customer
        String mode        = row.elementAt(4).toString();   // Cash / Bank
        String bank        = row.elementAt(5).toString();   // UPI / NEFT / etc.
        String date        = row.elementAt(6).toString();   // Date
        String time        = row.elementAt(7).toString();   // Time
        String userName    = row.elementAt(8).toString();   // Biller
        String billDisplay = row.elementAt(9).toString();   // Bill No

        double balance  = Double.parseDouble(row.elementAt(1).toString());
        double cashPaid = Double.parseDouble(row.elementAt(2).toString());
        double bankPaid = Double.parseDouble(row.elementAt(3).toString());
        int billId      = Integer.parseInt(row.elementAt(10).toString());

        totalCashPaid += cashPaid;
        totalBankPaid += bankPaid;
        double totalPaid = cashPaid + bankPaid;
%>
    <tr>
        <td><%= j + 1 %></td>
        <td><%= billDisplay %></td>
        <td><%= cusName %></td>
        <td><%= balance %></td>
        <td><%= cashPaid %></td>
        <td><%= bankPaid %></td>
        <td><%= mode %></td>
        <td><%= bank %></td>
        <td><%= date %></td>
        <td><%= time %></td>
        <td><%= userName %></td>
    </tr>
<%
    } // end for
%>
    <tr class="table-secondary">
        <td colspan="4"><strong>Grand Total</strong></td>
        <td><strong><%= String.format("%.3f", totalCashPaid) %></strong></td>
        <td><strong><%= String.format("%.3f", totalBankPaid) %></strong></td>
        <td colspan="5"></td>
    </tr>
</tbody>
</table>
</div>
</div>
</body>
</html>
