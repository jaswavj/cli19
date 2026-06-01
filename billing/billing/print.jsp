<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<%@ page language="java" import="java.text.DecimalFormat"%>

<jsp:useBean id="bill" class="billing.billingBean" />
<jsp:useBean id="userBean" class="user.userBean" scope="page"/>
<%
String billNo = request.getParameter("billNo");
if(billNo == null || billNo.trim().isEmpty()){
    out.print("Error: Missing bill number");
    return;
}

double extradisc = bill.getExtraDisc(billNo);
String cusName=bill.getCusName(billNo);
String cusNumber=bill.getCusNumber(billNo);

// Get customer details from customers table
Vector customerDetails = bill.getCustomerDetailsByBillNo(billNo);
String customerName = "-";
String customerPhone = "-";
String customerAddress = "-";
String customerGSTIN = "-";

if (customerDetails != null && customerDetails.size() >= 4) {
    customerName = customerDetails.get(0) != null ? customerDetails.get(0).toString() : cusName;
    customerPhone = customerDetails.get(1) != null ? customerDetails.get(1).toString() : cusNumber;
    customerAddress = customerDetails.get(2) != null ? customerDetails.get(2).toString() : "-";
    customerGSTIN = customerDetails.get(3) != null ? customerDetails.get(3).toString() : "-";
} else {
    // Fallback to old fields if customer not found
    customerName = cusName;
    customerPhone = cusNumber;
}


double paid = bill.getPaidTotal(billNo);
String numPaid=bill.getNumPaid(paid);
double balance = bill.getbalanceTotal(billNo);
String billDate = bill.getBillDate(billNo);
Vector<Vector<Object>> billDetails = bill.getBillDetailsUsingNo(billNo);

// Get LR details
Vector lrDetails = bill.getLRDetails(billNo);
String lrNo = "";
String lrDate = "";
String lrName = "";

if (lrDetails != null && lrDetails.size() >= 3) {
    lrNo = lrDetails.get(0) != null ? lrDetails.get(0).toString() : "";
    lrDate = lrDetails.get(1) != null ? lrDetails.get(1).toString() : "";
    lrName = lrDetails.get(2) != null ? lrDetails.get(2).toString() : "";
}

// Fetch company details
Vector companyDetails = userBean.getCompanyDetails();
String companyName = "";
String companyAddress = "";
String companyGSTIN = "";
String companyBankDetails = "";

if (companyDetails != null && companyDetails.size() >= 4) {
    companyName = companyDetails.get(1) != null ? companyDetails.get(1).toString() : "";
    companyAddress = companyDetails.get(2) != null ? companyDetails.get(2).toString() : "";
    companyGSTIN = companyDetails.get(3) != null ? companyDetails.get(3).toString() : "";
    if (companyDetails.size() > 6) {
        companyBankDetails = companyDetails.get(6) != null ? companyDetails.get(6).toString() : "";
    }
}

DecimalFormat df = new DecimalFormat("0.00");

// GST Calculation variables
double totalAmount = 0;
double totalDiscount = 0;
double finalPaid = 0;
double totalItemAmount = 0;
double totalTaxableAmount = 0;
double totalCGST = 0;
double totalSGST = 0;
double totalIGST = 0;
double totalGSTAmount = 0;
double totalQty = 0;
double subTotalBeforeDiscount = 0;

// Map to store GST-wise totals
Map<Integer, Double> gstWiseTaxable = new HashMap<Integer, Double>();
Map<Integer, Double> gstWiseCGST = new HashMap<Integer, Double>();
Map<Integer, Double> gstWiseSGST = new HashMap<Integer, Double>();

for(Vector<Object> prod : billDetails){
    double itemTotal = Double.parseDouble(prod.get(4).toString());
    double itemDisc = Double.parseDouble(prod.get(3).toString());
    double itemPrice = Double.parseDouble(prod.get(2).toString());
    int gstPer = Integer.parseInt(prod.get(5).toString());
    double qty = Double.parseDouble(prod.get(1).toString());
    
    // Calculate taxable amount (amount before GST)
    double taxableAmount = itemTotal / (1 + (gstPer / 100.0));
    double gstAmount = itemTotal - taxableAmount;
    double cgst = gstAmount / 2;
    double sgst = gstAmount / 2;
    
    totalAmount += itemTotal;
    totalDiscount += itemDisc;
    totalItemAmount += itemPrice;
    totalTaxableAmount += taxableAmount;
    totalCGST += cgst;
    totalSGST += sgst;
    totalGSTAmount += gstAmount;
    totalQty += qty;
    
    // Group by GST rate
    gstWiseTaxable.put(gstPer, gstWiseTaxable.getOrDefault(gstPer, 0.0) + taxableAmount);
    gstWiseCGST.put(gstPer, gstWiseCGST.getOrDefault(gstPer, 0.0) + cgst);
    gstWiseSGST.put(gstPer, gstWiseSGST.getOrDefault(gstPer, 0.0) + sgst);
}

// Calculate subtotal before discount (totalAmount is after item discounts, so add them back)
subTotalBeforeDiscount = totalAmount + totalDiscount;
    
finalPaid = totalAmount - extradisc;
int isTaxBill = bill.getIsTaxBill(billNo);
%>
<% if (isTaxBill == 1) { %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Tax Invoice</title>
    <style>
        @page { size: A5 portrait; margin: 4mm; }
        html {
            color: #000;
            -webkit-print-color-adjust: exact;
            print-color-adjust: exact;
        }
        body {
            font-family: Arial, sans-serif;
            font-size: 10.5px;
            font-weight: 600;
            margin: 0;
            padding: 2px;
            color: #000;
        }
        .container {
            width: calc(100% - 8px);
            border: 2px solid #000;
            margin: 0 auto;
            background: white;
        }
        .page-section + .page-section .container {
            border-top: none;
        }
        .page-section + .page-section {
            margin-top: 10px;
        }
        .header-title {
            text-align: center;
            font-weight: bold;
            font-size: 16px;
            margin-bottom: 5px;
            color: #000;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        
        /* Grid Layout Helpers */
        .row { display: flex; width: 100%; }
        .col-50 { width: 50%; }
        .col-40 { width: 40%; }
        .col-60 { width: 60%; }
        
        .border-bottom { border-bottom: 1px solid #000; }
        .border-right { border-right: 1px solid #000; }
        .border-top { border-top: 1px solid #000; }
        
        .p-5 { padding: 5px; }
        .text-right { text-align: right; }
        .text-center { text-align: center; }
        .font-bold { font-weight: bold; }
        
        /* Header Section */
        .company-header {
            display: flex;
            border-bottom: 2px solid #000;
            background: #fff;
            padding: 5px;
            align-items: center;
        }
        /*.logo-area {
            width: 150px;
            height: 80px;
            border-radius: 8px;
            display: flex;
            
            
        }*/

        .logo-area img {
            max-width: 120px;
            max-height: 60px;
            object-fit: contain;
            margin-right: 10px;
        }
        .logo-area1 img {
            max-width: 100px;
            max-height: 55px;
            object-fit: contain;
            margin-right: 10px;
        }
        .company-details {
            flex: 1;
            color: #000;
            font-size: 10.5px;
            line-height: 1.45;
            text-align: center;
        }
        .company-name {
            font-size: 18px;
            font-weight: bold;
            text-transform: uppercase;
            margin-bottom: 3px;
            letter-spacing: 0.5px;
            color: #000;
        }
        .company-details div {
            margin: 1px 0;
        }
        
        /* Section Headers */
        .purple-header {
            background: #dedede;
            color: #000;
            padding: 4px 6px;
            font-weight: bold;
            border-bottom: 1px solid #000;
            border-right: 1px solid #000;
            font-size: 10.5px;
            letter-spacing: 0.3px;
        }
        
        /* Bill To & Invoice Details */
        .bill-info-row {
            display: flex;
            border-bottom: 2px solid #000;
        }
        .bill-to-box {
            width: 50%;
            border-right: 2px solid #000;
        }
        .invoice-details-box {
            width: 50%;
        }
        .info-content {
            padding: 6px;
            min-height: 34px;
            font-size: 10.5px;
            line-height: 1.45;
        }
        
        /* Main Table */
        .items-table {
            width: 100%;
            border-collapse: collapse;
        }
        .items-table th {
            background-color: #dedede;
            color: #000;
            border-left: 1px solid #000;
            border-right: 1px solid #000;
            border-top: 1px solid #000;
            border-bottom: 1px solid #000;
            padding: 3px 2px;
            font-size: 9.5px;
            text-align: center;
            font-weight: bold;
        }
        .items-table th:first-child {
            border-left: 1px solid #000;
        }
        .items-table th:last-child {
            border-right: 1px solid #000;
        }
        .items-table td {
            border-left: 1px solid #000;
            border-right: 1px solid #000;
            border-top: none;
            border-bottom: none;
            padding: 3px 3px;
            font-size: 10px;
            vertical-align: middle;
        }
        .items-table tbody {
            display: table-row-group;
            min-height: 120px;
            height: 120px;
        }
        .items-table tbody tr:first-child td {
            border-top: 1px solid #000;
        }
        .empty-filler-row td {
            border-bottom: none !important;
            height: 25px;
        }
        
        /* Total Row */
        .total-row {
            font-weight: bold;
            background-color: transparent;
        }
        .total-row td {
            border-top: 1px solid #000 !important;
            border-bottom: 1px solid #000 !important;
        }
        
        /* Tax & Amounts Section */
        .tax-amounts-row {
            display: flex;
            border-bottom: 1px solid #000;
        }
        .tax-box {
            width: 50%;
            border-right: 1px solid #000;
        }
        .amounts-box {
            width: 50%;
        }
        
        .tax-row {
            display: flex;
            justify-content: space-between;
            padding: 3px 6px;
            border-bottom: 1px solid #000;
            font-size: 10.5px;
            font-weight: 600;
        }
        .tax-row:last-child { border-bottom: none; }
        
        .amount-row {
            display: flex;
            justify-content: space-between;
            padding: 4px 6px;
            border-bottom: 1px solid #000;
            font-size: 10.5px;
            font-weight: 600;
        }
        .amount-row.total {
            font-weight: bold;
            border-bottom: none;
            font-size: 12px;
            background: #dedede;
            padding: 5px 6px;
        }
        
        /* Footer Info */
        .footer-row {
            display: flex;
            border-bottom: 1px solid #000;
        }
        .words-box {
            width: 50%;
            border-right: 1px solid #000;
        }
        .rightBorder {
            border-right: 1px solid #000;
        }
        .words-boxWord {
            width: 100%;
            
        }
        .desc-box {
            width: 50%;
        }
        .footer-content {
            padding: 5px;
            text-align: center;
            min-height: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            font-weight: 700;
        }
        
        
        /* Terms & Signature */
        .terms-sign-row {
            display: flex;
        }
        .terms-box {
            width: 50%;
            border-right: 1px solid #000;
            font-size: 10.5px;
        }
        .sign-box {
            width: 50%;
            padding: 8px;
            text-align: right;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            min-height: 60px;
        }
        .sign-box .text-center {
            font-weight: 600;
            color: #000;
            padding-top: 10px;
            display: inline-block;
            width: 200px;
            margin-left: auto;
        }
        
        ul.terms-list {
            padding-left: 15px;
            margin: 5px 0;
        }
        ul.terms-list li {
            margin-bottom: 2px;
        }
        
        /* Bank Details with QR Code */
        .bank-qr-container {
            display: flex;
            align-items: flex-start;
            padding: 5px;
        }
        .bank-details-text {
            flex: 1;
            line-height: 1.6;
        }
        .qr-code-box {
            margin-left: auto;
            padding-left: 15px;
        }
        .qr-code-box img {
            width: 100px;
            height: 100px;
            border: 2px solid #5b21b6;
            border-radius: 8px;
            padding: 3px;
        }
        
        /* Print/Cancel Buttons */
        .print-controls {
            position: fixed;
            top: 10px;
            right: 10px;
            z-index: 1000;
            display: flex;
            gap: 10px;
        }
        .btn {
            padding: 10px 20px;
            font-size: 14px;
            font-weight: bold;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }
        .btn-print {
            background-color: #4CAF50;
            color: white;
        }
        .btn-print:hover {
            background-color: #45a049;
        }
        .btn-cancel {
            background-color: #f44336;
            color: white;
        }
        .btn-cancel:hover {
            background-color: #da190b;
        }
        
        @media print {
            .print-controls {
                display: none !important;
            }
            .page-section {
                page-break-after: always;
            }
            .page-section:last-child {
                page-break-after: avoid;
            }
        }
    </style>
    <script>
        window.onload = function() {
            // Direct print on page load
            window.print();
        };
        
        // Close window after print dialog is closed (either printed or cancelled)
        window.onafterprint = function() {
            window.close();
        };
        
        function printInvoice() {
            window.print();
        }
        
        function cancelPrint() {
            window.close();
        }
    </script>
</head>
<body>

<!-- Print/Cancel Controls -->
<div class="print-controls">
    <button class="btn btn-print" onclick="printInvoice()">🖨️ Print</button>
    <button class="btn btn-cancel" onclick="cancelPrint()">❌ Cancel</button>
</div>

<div class="header-title">Tax Invoice</div>

<%
int ITEMS_PER_PAGE = 12;
int totalItems = billDetails.size();
int totalPages = (totalItems == 0) ? 1 : (int) Math.ceil((double) totalItems / ITEMS_PER_PAGE);
int globalCount = 1;
%>

<% for (int pageNum = 0; pageNum < totalPages; pageNum++) {
    int fromIdx = pageNum * ITEMS_PER_PAGE;
    int toIdx = Math.min(fromIdx + ITEMS_PER_PAGE, totalItems);
    boolean isLastPage = (pageNum == totalPages - 1);
%>
<div class="page-section">
<div class="container">
    <!-- Header -->
    <div class="company-header">
        <div class="logo-area">
            <!--img src="logo.png" alt="Company Logo" -->
        </div>
        <div class="company-details">
            <% if (!companyName.isEmpty()) { %>
                <div class="company-name"><%= companyName %></div>
            <% } %>
            <% if (!companyAddress.isEmpty()) { %>
                <% String[] addressLines = companyAddress.split("\\r?\\n");
                   for (String line : addressLines) {
                       if (line != null && !line.trim().isEmpty()) { %>
                           <div><%= line.trim() %></div>
                <% }} %>
            <% } %>
            <% if (!companyGSTIN.isEmpty()) { %>
                <div>GSTIN: <%= companyGSTIN %></div>
            <% } %>
        </div>
    </div>

    <!-- Bill To & Invoice Details -->
    <div class="bill-info-row">
        <div class="bill-to-box">
            <div class="purple-header">Bill To</div>
            <div class="info-content">
                <div class="font-bold"><%= customerName %></div>
                <% if(customerPhone != null && !customerPhone.equals("-") && !customerPhone.trim().isEmpty()) { %>
                <div>Ph: <%= customerPhone %></div>
                <% } %>
                <% if(customerAddress != null && !customerAddress.equals("-") && !customerAddress.trim().isEmpty()) { %>
                <div><%= customerAddress %></div>
                <% } %>
                <% if(customerGSTIN != null && !customerGSTIN.equals("-") && !customerGSTIN.trim().isEmpty()) { %>
                <div>GSTIN: <%= customerGSTIN %></div>
                <% } %>
            </div>
        </div>
        <div class="invoice-details-box">
            <div class="purple-header text-right">Invoice Details</div>
            <div class="info-content text-right">
                <div>Invoice No.: <%= billNo %></div>
                <div>Date: <%= billDate %></div>
                <div>Place of Supply: Tamil Nadu</div>
                <% if (lrNo != null && !lrNo.trim().isEmpty()) { %><div>LR No.: <%= lrNo %></div><% } %>
                <% if (lrDate != null && !lrDate.trim().isEmpty()) { %><div>LR Date: <%= lrDate %></div><% } %>
                <% if (lrName != null && !lrName.trim().isEmpty()) { %><div>LR Name: <%= lrName %></div><% } %>
                <% if (totalPages > 1) { %><div>Page <%= (pageNum+1) %> of <%= totalPages %></div><% } %>
            </div>
        </div>
    </div>

    <!-- Items Table -->
    <table class="items-table">
        <thead>
            <tr>
                <th style="width: 5%;">S.No</th>
                <th style="width: 30%;">Item name</th>
                <th style="width: 8%;">HSN/SAC</th>
                <th style="width: 10%;">price/Unit</th>
                <th style="width: 5%;">Qty</th>
                <th style="width: 8%;">Taxable</th>
                <th style="width: 10%;">CGST</th>
                <th style="width: 10%;">SGST</th>
                <th style="width: 14%;">Amount</th>
            </tr>
        </thead>
        <tbody>
            <% for (int i = fromIdx; i < toIdx; i++) {
                Vector<Object> prod = billDetails.get(i);
                double itemTotal = Double.parseDouble(prod.get(4).toString());
                double itemPrice = Double.parseDouble(prod.get(2).toString());
                int gstPer = Integer.parseInt(prod.get(5).toString());
                double qty = Double.parseDouble(prod.get(1).toString());
                String category = (prod.size() > 6 && prod.get(6) != null) ? prod.get(6).toString() : "";
                String productName = prod.get(0).toString();
                String displayName = category.isEmpty() ? productName : category + " - " + productName;
                String hsnCode = (prod.size() > 7 && prod.get(7) != null) ? prod.get(7).toString() : "";
                String unitName = (prod.size() > 8 && prod.get(8) != null) ? prod.get(8).toString() : "";
                double taxableAmount = itemTotal / (1 + (gstPer / 100.0));
                double gstAmount = itemTotal - taxableAmount;
                double cgst = gstAmount / 2;
                double sgst = gstAmount / 2;
            %>
            <tr class="item-row">
                <td class="text-center"><%= globalCount++ %></td>
                <td><div class="font-bold"><%= displayName %></div></td>
                <td class="text-center"><%= hsnCode %></td>
                <td class="text-right"><%= df.format(itemPrice) %></td>
                <td class="text-center"><%= qty %><% if(!unitName.trim().isEmpty()){%> <%= unitName %><% } %></td>
                <td class="text-right"><%= df.format(taxableAmount) %></td>
                <td class="text-right"><%= df.format(cgst) %></td>
                <td class="text-right"><%= df.format(sgst) %></td>
                <td class="text-right"><%= df.format(itemTotal) %></td>
            </tr>
            <% } %>
            <!-- Filler rows (only on non-last pages to fill the page) -->
            <% int pageRows = toIdx - fromIdx;
               int fillerNeeded = (!isLastPage) ? Math.max(0, ITEMS_PER_PAGE - pageRows) : 0;
               for (int f = 0; f < fillerNeeded; f++) { %>
            <tr class="empty-filler-row">
                <td style="height:22px;">&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>
                <td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>
                <td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>
            </tr>
            <% } %>
        </tbody>
        <tfoot>
            <tr class="total-row">
                <td colspan="4" class="text-right"><% if(isLastPage){ %>Total<% } else { %>Continued...<% } %></td>
                <td class="text-center"><%= isLastPage ? df.format(totalQty) : "" %></td>
                <td class="text-right"><%= isLastPage ? df.format(totalTaxableAmount) : "" %></td>
                <td class="text-right"><%= isLastPage ? df.format(totalCGST) : "" %></td>
                <td class="text-right"><%= isLastPage ? df.format(totalSGST) : "" %></td>
                <td class="text-right"><%= isLastPage ? df.format(totalAmount) : "" %></td>
            </tr>
        </tfoot>
    </table>

    <!-- Tax & Amounts -->
    <div class="tax-amounts-row">
        <div class="tax-box">
            <div class="tax-row border-bottom">
                <div>Tax details</div>
                <div><% for(Integer rate : gstWiseTaxable.keySet()){ out.print(rate+".0%"); } %></div>
            </div>
            <div class="tax-row"><div>CGST</div><div>&#8377; <%= df.format(totalCGST) %></div></div>
            <div class="tax-row"><div>SGST</div><div>&#8377; <%= df.format(totalSGST) %></div></div>
            <div class="tax-row"><div>IGST</div><div>&#8377; <%= df.format(totalIGST) %></div></div>
        </div>
        <div class="amounts-box">
            <div class="purple-header">Amounts</div>
            <div class="amount-row"><div>Sub Total</div><div>&#8377; <%= df.format(subTotalBeforeDiscount) %></div></div>
            <% if (totalDiscount > 0) { %>
            <div class="amount-row"><div>Item Discount</div><div>- &#8377; <%= df.format(totalDiscount) %></div></div>
            <% } %>
            <% if (extradisc > 0) { %>
            <div class="amount-row"><div>Extra Discount</div><div>- &#8377; <%= df.format(extradisc) %></div></div>
            <% } %>
            <div class="amount-row total"><div>Total</div><div>&#8377; <%= df.format(finalPaid) %></div></div>
            <div class="amount-row"><div>Paid</div><div>&#8377; <%= df.format(paid) %></div></div>
            <div class="amount-row"><div>Balance</div><div>&#8377; <%= df.format(balance) %></div></div>
        </div>
    </div>
    <!-- Amount in Words -->
    <div class="footer-row">
        <div class="words-boxWord">
            <div class="footer-content">Amount In Words : <%= numPaid %></div>
        </div>
    </div>

</div>
</div>
<% } %>
</body>
</html>
<% } else { %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Estimate</title>
    <style>
        @page { size: A5; margin: 8mm; }
        body { font-family: 'Courier New', Courier, monospace; font-size: 13px; margin: 0; padding: 4px; color: #000; }
        .print-controls { position: fixed; top: 10px; right: 10px; z-index: 1000; display: flex; gap: 10px; }
        .btn { padding: 10px 20px; font-size: 14px; font-weight: bold; border: none; border-radius: 5px; cursor: pointer; }
        .btn-print { background-color: #4CAF50; color: white; }
        .btn-cancel { background-color: #f44336; color: white; }
        @media print { .print-controls { display: none !important; } }
        .receipt-wrapper { width: 100%; max-width: 100%; }
        .title-row { display: flex; justify-content: space-between; align-items: flex-start; font-size: 13px; margin: 4px 0; }
        .bill-title { font-size: 18px; font-weight: bold; text-align: center; text-transform: uppercase; flex: 1; }
        .dash-sep { border: none; border-top: 1px dashed #000; margin: 4px 0; }
        .est-table { width: 100%; border-collapse: collapse; font-size: 13px; }
        .est-table th { text-align: left; padding: 2px 4px; border-bottom: 1px dashed #000; border-top: 1px dashed #000; font-weight: bold; white-space: nowrap; }
        .est-table td { padding: 2px 4px; vertical-align: top; }
        .est-table .num { text-align: right; }
        .est-table .ctr { text-align: center; }
        .summary-table { width: 65%; margin-left: auto; font-size: 13px; border-collapse: collapse; }
        .summary-table td { padding: 2px 5px; font-weight: bold; }
        .summary-table .val { text-align: right; }
        .net-row td { font-weight: bold; font-size: 15px; border-top: 1px dashed #000; }
        .thank-you { text-align: center; font-size: 13px; font-weight: bold; margin-top: 8px; }
    </style>
    <script>
        window.onload = function() { window.print(); };
        window.onafterprint = function() { window.close(); };
        function printInvoice() { window.print(); }
        function cancelPrint() { window.close(); }
    </script>
</head>
<body>
<div class="print-controls">
    <button class="btn btn-print" onclick="printInvoice()">&#128424; Print</button>
    <button class="btn btn-cancel" onclick="cancelPrint()">&#10060; Cancel</button>
</div>
<div class="receipt-wrapper">
    <!-- Title Row -->
    <%
        String simpleDate = "";
        String simpleTime = "";
        if (billDate != null && billDate.contains(" ")) {
            int spIdx = billDate.indexOf(' ');
            simpleDate = billDate.substring(0, spIdx);
            simpleTime = billDate.substring(spIdx + 1);
        } else if (billDate != null) {
            simpleDate = billDate;
        }
    %>
    <div class="title-row">
        <div style="line-height:1.7;">
            <div>BillNo:<%= billNo %></div>
            <div>Customer:<%= customerName %></div>
            <% if (customerAddress != null && !customerAddress.equals("-") && !customerAddress.trim().isEmpty()) { %>
            <div>Area:<%= customerAddress %></div>
            <% } %>
        </div>
        <div class="bill-title">ESTIMATE</div>
        <div style="text-align:right; line-height:1.7;">
            <div>Date:<%= simpleDate %></div>
            <div>Time:<%= simpleTime %></div>
        </div>
    </div>
    <hr class="dash-sep">
    <!-- Items Table -->
    <table class="est-table">
        <thead>
            <tr>
                <th>Sno</th>
                <th>Description</th>
                <th class="num">Rate</th>
                <th class="num">Qty</th>
                <th class="ctr">Uom</th>
                <th class="num">Dis%</th>
                <th class="num">Amount</th>
            </tr>
        </thead>
        <tbody>
            <%
            int simpleSno = 1;
            double simpleTotalQty = 0;
            for (Vector<Object> sprod : billDetails) {
                double spItemTotal  = Double.parseDouble(sprod.get(4).toString());
                double spItemDisc   = Double.parseDouble(sprod.get(3).toString());
                double spItemPrice  = Double.parseDouble(sprod.get(2).toString());
                double spQty        = Double.parseDouble(sprod.get(1).toString());
                String spUnit       = (sprod.size() > 8 && sprod.get(8) != null) ? sprod.get(8).toString() : "";
                String spName       = sprod.get(0).toString();
                int spDiscPct       = (spItemPrice > 0 && spQty > 0) ? (int)Math.round((spItemDisc / (spItemPrice * spQty)) * 100) : 0;
                simpleTotalQty += spQty;
            %>
            <tr>
                <td><%= simpleSno++ %></td>
                <td><%= spName %></td>
                <td class="num"><%= df.format(spItemPrice) %></td>
                <td class="num"><%= spQty %></td>
                <td class="ctr"><%= spUnit %></td>
                <td class="num"><%= spDiscPct %></td>
                <td class="num"><%= df.format(spItemTotal) %></td>
            </tr>
            <% } %>
        </tbody>
    </table>
    <hr class="dash-sep">
    <div style="font-size:9px;">t.Qty &nbsp;: <%= df.format(simpleTotalQty) %></div>
    <hr class="dash-sep">
    <!-- Summary -->
    <table class="summary-table">
        <tr><td>Total</td><td>:</td><td class="val"><%= df.format(totalAmount) %></td></tr>
        <tr><td>DisAmt</td><td>:</td><td class="val"><%= df.format(totalDiscount) %></td></tr>
        <tr><td>LESS</td><td>:</td><td class="val"><%= df.format(extradisc) %></td></tr>
        <tr class="net-row"><td>NETTOTAL</td><td>:</td><td class="val"><%= df.format(finalPaid) %></td></tr>
    </table>
    <hr class="dash-sep">
    <div class="thank-you">Thank You !.. Visit Again</div>
</div>
</body>
</html>
<% } %>
