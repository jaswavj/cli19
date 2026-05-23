<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*,java.text.*"%>
<jsp:useBean id="bill" class="billing.billingBean" />
<jsp:useBean id="prod" class="product.productBean" />
<%
    String fromDate    = request.getParameter("fromDate");
    String toDate      = request.getParameter("toDate");
    int customerId     = Integer.parseInt(request.getParameter("customerId"));
    String customerName = prod.getCustomerNameById(customerId);

    Vector rows = bill.getCommissionReport(fromDate, toDate, customerId);

    // Group rows by bill no
    // Each row: [0]bill_display [1]bill_date [2]product_name [3]qty [4]price [5]disc [6]total [7]comm_per_unit [8]comm_amount
    String currentBill = null;
    double billCommTotal  = 0.0;
    double grandCommTotal = 0.0;
    double grandSaleTotal = 0.0;
    int serial = 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Commission Report</title>
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        .table td, .table th { vertical-align: middle; font-size: 0.85rem; }
        .bill-group-header td {
            background: var(--bill-bg);
            font-weight: 600;
            color: var(--bill-navy);
            font-size: 0.85rem;
            padding: 0.3rem 0.4rem;
        }
        .bill-subtotal td {
            background: rgba(5,150,105,0.08);
            font-weight: 600;
            color: var(--bill-green);
            font-size: 0.85rem;
            padding: 0.3rem 0.4rem;
        }
        .grand-total-row td {
            background: var(--bill-navy);
            color: #fff;
            font-weight: 700;
            font-size: 0.9rem;
            padding: 0.4rem;
        }
        @media print {
            .no-print { display: none !important; }
            body { background: #fff; }
        }
    </style>
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
        <div class="d-flex justify-content-between align-items-center mb-3">
            <p class="mb-0 text-muted"><strong>Customer:</strong> <%=customerName%> &nbsp;|&nbsp; <strong>Period:</strong> <%=fromDate%> to <%=toDate%></p>
            <div class="d-flex gap-2 no-print">
                <a href="<%=contextPath%>/reports/commissionReport/page.jsp" class="bb bb-outline"><i class="fa-solid fa-arrow-left me-1"></i>Back</a>
                <button class="bb bb-navy" onclick="window.print()"><i class="fa-solid fa-print me-1"></i>Print</button>
                <button class="bb bb-green" onclick="exportTableToExcel('commTable','Commission_Report')"><i class="fa-solid fa-file-excel me-1"></i>Export</button>
            </div>
        </div>

    <% if (rows == null || rows.size() == 0) { %>
    <div class="alert alert-info">No commission records found for the selected period and customer.</div>
    <% } else { %>

    <div class="table-responsive">
    <table id="commTable" class="table mb-0 mst-table">
        <thead>
            <tr>
                <th>#</th>
                <th>Bill No</th>
                <th>Date</th>
                <th>Product</th>
                <th class="text-end">Qty</th>
                <th class="text-end">Price</th>
                <th class="text-end">Disc</th>
                <th class="text-end">Total</th>
                <th class="text-end">Comm/Unit</th>
                <th class="text-end">Commission</th>
            </tr>
        </thead>
        <tbody>
        <%
        for (int i = 0; i < rows.size(); i++) {
            Vector row      = (Vector) rows.get(i);
            String billNo   = row.elementAt(0).toString();
            String billDate = row.elementAt(1).toString();
            String prodName = row.elementAt(2).toString();
            double qty        = (Double) row.elementAt(3);
            double price      = (Double) row.elementAt(4);
            double disc       = (Double) row.elementAt(5);
            double rowTotal   = (Double) row.elementAt(6);
            double commPerUnit= (Double) row.elementAt(7);
            double commAmt    = (Double) row.elementAt(8);

            // Detect new bill group — print subtotal for previous bill first
            if (currentBill != null && !currentBill.equals(billNo)) {
        %>
        <tr class="bill-subtotal">
            <td colspan="9" style="text-align:right; padding:0.3rem 0.4rem;">Bill Commission Subtotal (<%=currentBill%>):</td>
            <td style="text-align:right; padding:0.3rem 0.4rem;">&#8377;<%=String.format("%.2f", billCommTotal)%></td>
        </tr>
        <%
                billCommTotal = 0.0;
            }

            // Print bill group header when bill changes
            if (currentBill == null || !currentBill.equals(billNo)) {
                currentBill = billNo;
        %>
        <tr class="bill-group-header">
            <td colspan="10" style="padding:0.3rem 0.4rem;">
                <i class="fa-solid fa-file-invoice me-1"></i>Bill No: <%=billNo%> &nbsp;|&nbsp; Date: <%=billDate%>
            </td>
        </tr>
        <%      } 
            serial++;
            billCommTotal  += commAmt;
            grandCommTotal += commAmt;
            grandSaleTotal += rowTotal;
        %>
        <tr style="border-bottom:1px solid var(--bill-border-lt);">
            <td><%=serial%></td>
            <td><%=billNo%></td>
            <td><%=billDate%></td>
            <td><%=prodName%></td>
            <td class="text-end"><%=String.format("%.2f", qty)%></td>
            <td class="text-end">&#8377;<%=String.format("%.2f", price)%></td>
            <td class="text-end">&#8377;<%=String.format("%.2f", disc)%></td>
            <td class="text-end">&#8377;<%=String.format("%.2f", rowTotal)%></td>
            <td class="text-end">&#8377;<%=String.format("%.2f", commPerUnit)%></td>
            <td class="text-end" style="color:var(--bill-green);font-weight:600;">&#8377;<%=String.format("%.2f", commAmt)%></td>
        </tr>
        <% } %>

        <%-- Last bill subtotal --%>
        <% if (currentBill != null) { %>
        <tr class="bill-subtotal">
            <td colspan="9" style="text-align:right; padding:0.3rem 0.4rem;">Bill Commission Subtotal (<%=currentBill%>):</td>
            <td style="text-align:right; padding:0.3rem 0.4rem;">&#8377;<%=String.format("%.2f", billCommTotal)%></td>
        </tr>
        <% } %>

        <%-- Grand Total --%>
        <tr class="grand-total-row">
            <td colspan="7" style="text-align:right;">Grand Total Sale:</td>
            <td style="text-align:right;">&#8377;<%=String.format("%.2f", grandSaleTotal)%></td>
            <td style="text-align:right;">Total Commission:</td>
            <td style="text-align:right;">&#8377;<%=String.format("%.2f", grandCommTotal)%></td>
        </tr>

        </tbody>
    </table>
    </div>

    <% } %>
</div>

<script>
function exportTableToExcel(tableId, filename) {
    var table = document.getElementById(tableId);
    var html = '<html xmlns:x="urn:schemas-microsoft-com:office:excel"><head><meta charset="UTF-8"><style>th,td{border:1px solid #000;padding:4px}</style></head><body>' + table.outerHTML + '</body></html>';
    var blob = new Blob(['\ufeff', html], {type: 'application/vnd.ms-excel'});
    var a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = filename + '.xls';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(a.href);
}
</script>
</body>
</html>
