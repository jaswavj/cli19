<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<%
    String fromDate = request.getParameter("startDate");
    String toDate   = request.getParameter("endDate");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HSN Sales GST Report</title>
<%@ include file="/assets/common/head.jsp" %>
<script src="<%=contextPath%>/dist/js/xlsx.full.min.js"></script>
    <style>
        .grand-total-row td { background: #fff; color: #000; font-weight: 700; border-top: 2px solid var(--bill-navy); }
        @media print { .no-print { display: none !important; } }
    </style>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>
<%
    request.setAttribute("pageTitle",    "HSN Sales GST");
    request.setAttribute("pageSubtitle", "GST Reports \u2014 HSN Wise | " + fromDate + " to " + toDate);
    request.setAttribute("pageIcon",     "fa-solid fa-tags");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

<div class="container-fluid mt-3 mst-page">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <p class="mb-0 text-muted"><strong>Period:</strong> <%=fromDate%> to <%=toDate%></p>
        <div class="d-flex gap-2 no-print">
            <a href="<%=contextPath%>/reports/GST/hsnSalesGST/page.jsp" class="bb bb-outline"><i class="fa-solid fa-arrow-left me-1"></i>Back</a>
            <button class="bb bb-navy" onclick="window.print()"><i class="fa-solid fa-print me-1"></i>Print</button>
            <button class="bb bb-green" onclick="exportGSTXLSX()"><i class="fa-solid fa-file-excel me-1"></i>Export XLSX</button>
        </div>
    </div>

    <div class="table-responsive">
    <table id="gstTable" class="table mb-0 mst-table">
        <thead>
            <tr>
                <th>#</th>
                <th>HSN Code</th>
                <th>Description</th>
                <th class="text-center">GST%</th>
                <th class="text-end">Total Qty</th>
                <th class="text-end">Taxable (&#8377;)</th>
                <th class="text-end">CGST (&#8377;)</th>
                <th class="text-end">SGST (&#8377;)</th>
                <th class="text-end">Total GST (&#8377;)</th>
                <th class="text-end">Total Value (&#8377;)</th>
            </tr>
        </thead>
        <tbody>
        <%
            Vector data = bill.getHSNSalesGST(fromDate, toDate);
            double gtTaxable = 0, gtCGST = 0, gtSGST = 0, gtGST = 0, gtValue = 0;
            if (data != null && data.size() > 0) {
                for (int i = 0; i < data.size(); i++) {
                    Vector row = (Vector) data.elementAt(i);
                    double taxable  = Double.parseDouble((String)row.elementAt(4));
                    double cgst     = Double.parseDouble((String)row.elementAt(5));
                    double sgst     = Double.parseDouble((String)row.elementAt(6));
                    double totalGst = Double.parseDouble((String)row.elementAt(7));
                    double totVal   = Double.parseDouble((String)row.elementAt(8));
                    gtTaxable += taxable; gtCGST += cgst; gtSGST += sgst; gtGST += totalGst; gtValue += totVal;
        %>
            <tr>
                <td><%=i+1%></td>
                <td><%=row.elementAt(0)%></td>
                <td class="text-muted"><%=row.elementAt(1)%></td>
                <td class="text-center"><%=row.elementAt(2)%>%</td>
                <td class="text-end"><%=row.elementAt(3)%></td>
                <td class="text-end"><%=row.elementAt(4)%></td>
                <td class="text-end"><%=row.elementAt(5)%></td>
                <td class="text-end"><%=row.elementAt(6)%></td>
                <td class="text-end"><%=row.elementAt(7)%></td>
                <td class="text-end"><%=row.elementAt(8)%></td>
            </tr>
        <%
                }
        %>
            <tr class="grand-total-row">
                <td colspan="5" class="text-end">GRAND TOTAL</td>
                <td class="text-end"><%=String.format("%.2f", gtTaxable)%></td>
                <td class="text-end"><%=String.format("%.2f", gtCGST)%></td>
                <td class="text-end"><%=String.format("%.2f", gtSGST)%></td>
                <td class="text-end"><%=String.format("%.2f", gtGST)%></td>
                <td class="text-end"><%=String.format("%.2f", gtValue)%></td>
            </tr>
        <%
            } else {
        %>
            <tr>
                <td colspan="10" class="text-center py-4 text-muted">
                    <i class="fas fa-inbox fs-3 d-block mb-2"></i>
                    No records found for the selected date range.
                </td>
            </tr>
        <%
            }
        %>
        </tbody>
    </table>
    </div>
</div>
<script>
var fromDate = '<%=fromDate%>';
var toDate   = '<%=toDate%>';
function exportGSTXLSX() {
    var table = document.getElementById('gstTable');
    var wb    = XLSX.utils.table_to_book(table, { sheet: 'HSN Sales GST' });
    XLSX.writeFile(wb, 'HSN_Sales_GST_' + fromDate + '_to_' + toDate + '.xlsx');
}
</script>
</body>
</html>
