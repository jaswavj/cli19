<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<%@ page language="java" import="java.text.DecimalFormat"%>

<jsp:useBean id="bill" class="billing.billingBean" />
<jsp:useBean id="userBean" class="user.userBean" scope="page"/>
<%
String quotIdStr = request.getParameter("quotId");
if(quotIdStr == null || quotIdStr.trim().isEmpty()){
    out.print("Error: Missing quotation ID");
    return;
}

int quotId = Integer.parseInt(quotIdStr);

// Get quotation header
Vector quotHeader = bill.getQuotationHeader(quotId);
if (quotHeader == null || quotHeader.isEmpty()) {
    out.print("Error: Quotation not found");
    return;
}

String quotNo = quotHeader.get(0).toString();
double total = Double.parseDouble(quotHeader.get(1).toString());
double prodDisc = Double.parseDouble(quotHeader.get(2).toString());
double extraDisc = Double.parseDouble(quotHeader.get(3).toString());
double payable = Double.parseDouble(quotHeader.get(4).toString());
String cusName = quotHeader.get(5) != null ? quotHeader.get(5).toString() : "-";
String cusPhone = quotHeader.get(6) != null ? quotHeader.get(6).toString() : "-";
String quotDate = quotHeader.get(8).toString();
String quotTime = quotHeader.get(9).toString();

// Get quotation details
Vector<Vector> quotDetails = bill.getQuotationDetails(quotId);

// Fetch company details
Vector companyDetails = userBean.getCompanyDetails();
String companyName = "";
String companyAddress = "";
String companyGSTIN = "";
String companyPhone = "";
String bankDetails = "";

if (companyDetails != null && companyDetails.size() >= 4) {
    companyName = companyDetails.get(1) != null ? companyDetails.get(1).toString() : "";
    companyAddress = companyDetails.get(2) != null ? companyDetails.get(2).toString() : "";
    companyGSTIN = companyDetails.get(3) != null ? companyDetails.get(3).toString() : "";
    if (companyDetails.size() > 4) {
        companyPhone = companyDetails.get(4) != null ? companyDetails.get(4).toString() : "";
    }
    if (companyDetails.size() > 6) {
        bankDetails = companyDetails.get(6) != null ? companyDetails.get(6).toString() : "";
    }
}

DecimalFormat df = new DecimalFormat("0.00");

// Calculation variables
double totalQty = 0;
double totalAmount = 0;
double totalDiscount = 0;

for(Vector prod : quotDetails){
    double qty = Double.parseDouble(prod.get(4).toString());
    double itemTotal = Double.parseDouble(prod.get(7).toString());
    double itemDisc = Double.parseDouble(prod.get(6).toString());
    
    totalQty += qty;
    totalAmount += itemTotal;
    totalDiscount += itemDisc;
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Quotation - <%= quotNo %></title>
    <style>
        @page { size: A5; margin: 8mm; }
        body { font-family: Arial, sans-serif; font-size: 13px; margin: 0; padding: 4px; color: #000; }
        .container { width: 100%; }
        .company-block { text-align: center; margin-bottom: 4px; }
        .company-name { font-size: 18px; font-weight: bold; text-transform: uppercase; }
        .company-addr { font-size: 12px; line-height: 1.5; }
        .dash-sep { border: none; border-top: 1px dashed #000; margin: 4px 0; }
        .title-row { display: flex; justify-content: space-between; align-items: flex-start; font-size: 13px; margin: 4px 0; }
        .quot-title { font-size: 18px; font-weight: bold; text-align: center; text-transform: uppercase; flex: 1; }
        .quot-table { width: 100%; border-collapse: collapse; table-layout: fixed; font-size: 13px; }
        .quot-table th { text-align: left; padding: 3px 4px; border-bottom: 1px dashed #000; border-top: 1px dashed #000; font-weight: bold; white-space: nowrap; }
        .quot-table td { padding: 3px 4px; vertical-align: top; }
        .quot-table .num { text-align: right; }
        .quot-table .ctr { text-align: center; }
        .quot-table tfoot td { border-top: 1px dashed #000; font-weight: bold; }
        .summary-table { width: 65%; margin-left: auto; font-size: 13px; border-collapse: collapse; margin-top: 3px; }
        .summary-table td { padding: 3px 5px; font-weight: bold; }
        .summary-table .val { text-align: right; }
        .net-row td { font-weight: bold; font-size: 15px; border-top: 1px dashed #000; }
        .thank-you { text-align: center; font-size: 13px; font-weight: bold; margin-top: 8px; }
        @media print { body { padding: 0; } }
    </style>
    <script>
        window.onload = function() { window.print(); };
        window.onafterprint = function() { window.close(); };
    </script>
</head>
<body>
<div class="container">
    <!-- Company Header -->
    
    <!-- Title & Info Row -->
    <div class="title-row">
        <div style="line-height:1.7;">
            <div>QuotNo: <%= quotNo %></div>
            <div>Customer: <%= cusName %></div>
            <% if (!cusPhone.equals("-") && !cusPhone.trim().isEmpty()) { %>
            <div>Phone: <%= cusPhone %></div>
            <% } %>
        </div>
        <div class="quot-title">ESTIMATE</div>
        <div style="text-align:right; line-height:1.7;">
            <div>Date: <%= quotDate %></div>
            <div>Time: <%= quotTime %></div>
        </div>
    </div>
    
    <!-- Items Table -->
    <table class="quot-table">
        <colgroup>
            <col style="width:7%">
            <col style="width:auto">
            <col style="width:13%">
            <col style="width:13%">
            <col style="width:13%">
            <col style="width:15%">
        </colgroup>
        <thead>
            <tr>
                <th class="ctr">Sno</th>
                <th>Description</th>
                <th class="num">Rate</th>
                <th class="num">Qty</th>
                <th class="num">Disc</th>
                <th class="num">Amount</th>
            </tr>
        </thead>
        <tbody>
            <%
            int rowNum = 1;
            for(Vector prod : quotDetails){
                String prodName = prod.get(2).toString();
                double qty = Double.parseDouble(prod.get(4).toString());
                double price = Double.parseDouble(prod.get(5).toString());
                double disc = Double.parseDouble(prod.get(6).toString());
                double itemTotal = Double.parseDouble(prod.get(7).toString());
            %>
            <tr>
                <td class="ctr"><%= rowNum++ %></td>
                <td><%= prodName %></td>
                <td class="num"><%= df.format(price) %></td>
                <td class="num"><%= df.format(qty) %></td>
                <td class="num"><%= df.format(disc) %></td>
                <td class="num"><%= df.format(itemTotal) %></td>
            </tr>
            <% } %>
        </tbody>
        <tfoot>
            <tr>
                <td colspan="3">total.Qty :</td>
                <td class="num"><%= df.format(totalQty) %></td>
                <td colspan="2"></td>
            </tr>
        </tfoot>
    </table>
    <hr class="dash-sep">
    <!-- Summary -->
    <table class="summary-table">
        <tr><td>Total</td><td>:</td><td class="val"><%= df.format(total) %></td></tr>
        <% if (prodDisc > 0) { %><tr><td>Item Disc</td><td>:</td><td class="val"><%= df.format(prodDisc) %></td></tr><% } %>
        <% if (extraDisc > 0) { %><tr><td>Extra Disc</td><td>:</td><td class="val"><%= df.format(extraDisc) %></td></tr><% } %>
        <tr class="net-row"><td>PAYABLE</td><td>:</td><td class="val"><%= df.format(payable) %></td></tr>
    </table>
    <hr class="dash-sep">
    <div class="thank-you">Thank You !.. Visit Again</div>
</div>
</body>
</html>
