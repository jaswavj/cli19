<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<%@ page language="java" import= "java.util.*,java.text.*" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<%
String fromDate = request.getParameter("fromDate");  
    String toDate   = request.getParameter("toDate");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Profit Analysis Report</title>
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body > 
    <jsp:include page="/assets/navbar/navbar.jsp" />
<%
    request.setAttribute("pageTitle",    "Profit Analysis");
    request.setAttribute("pageSubtitle", "Reports — Profit by Bill");
    request.setAttribute("pageIcon",     "fa-solid fa-chart-line");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

<div class="container-fluid mt-3 mst-page">
<p class="mb-1 text-muted"><strong>Period:</strong> <%= fromDate %> — <%= toDate %></p>
    <div class="d-flex gap-2 mb-3 no-print">
        <a href="<%=contextPath%>/reports/profitAnalysis/page.jsp" class="bb bb-outline"><i class="fa-solid fa-arrow-left me-1"></i>Back</a>
        <button class="bb bb-navy" onclick="printReport()"><i class="fa-solid fa-print me-1"></i>Print</button>
        <button class="bb bb-green" onclick="exportTableToExcel('printTable', 'Profit_Analysis_Report')"><i class="fa-solid fa-file-excel me-1"></i>Export</button>
    </div>

<%
        Vector vec = bill.getProfitAnalysisReport(fromDate, toDate);
        double totalCostSum = 0.0;
        double totalSaleSum = 0.0;
        double totalProfitSum = 0.0;
        
        for(int i = 0; i < vec.size(); i++) {
            Vector row = (Vector)vec.elementAt(i);
            double totalCost = Double.parseDouble(row.elementAt(4).toString());
            double saleTotal = Double.parseDouble(row.elementAt(5).toString());
            double profit = saleTotal - totalCost;
            
            totalCostSum += totalCost;
            totalSaleSum += saleTotal;
            totalProfitSum += profit;
        }
        double overallProfitPercent = (totalCostSum > 0) ? (totalProfitSum / totalCostSum) * 100 : 0;
%>

<!-- Summary Cards -->
<div class="row mb-4 g-3">
    <div class="col-md-3">
        <div class="card mst-card">
            <div class="card-body">
                <h6 class="text-muted">Total Cost</h6>
                <h4 style="color:var(--bill-navy)">&#8377; <%= String.format("%,.2f", totalCostSum) %></h4>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card mst-card">
            <div class="card-body">
                <h6 class="text-muted">Total Sales</h6>
                <h4 style="color:var(--bill-navy-mid)">&#8377; <%= String.format("%,.2f", totalSaleSum) %></h4>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card mst-card">
            <div class="card-body">
                <h6 class="text-muted">Total Profit</h6>
                <h4 style="color:<%= totalProfitSum >= 0 ? "var(--bill-green)" : "var(--bill-red)" %>">&#8377; <%= String.format("%,.2f", totalProfitSum) %></h4>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card mst-card">
            <div class="card-body">
                <h6 class="text-muted">Profit Margin</h6>
                <h4 style="color:<%= overallProfitPercent >= 0 ? "var(--bill-green)" : "var(--bill-red)" %>"><%= String.format("%.1f", overallProfitPercent) %>%</h4>
            </div>
        </div>
    </div>
</div>

<div class="table-responsive">
<table id="printTable" class="table mb-0 mst-table">
    <thead>
        <tr>
            <th>S.No</th>
            <th>Bill No</th>
            <th>Product</th>
            <th class="text-center">Qty</th>
            <th class="text-end">Cost Price</th>
            <th class="text-end">Total Cost</th>
            <th class="text-end">Sale Total</th>
            <th class="text-end">Profit</th>
            <th class="text-end">Profit %</th>
            <th>Date</th>
        </tr>
    </thead>
    <tbody>
        <%
        for(int i = 0; i < vec.size(); i++) {
            Vector row = (Vector)vec.elementAt(i);
            String billNo = row.elementAt(0).toString();
            String productName = row.elementAt(1).toString();
            double qty = Double.parseDouble(row.elementAt(2).toString());
            double costPrice = Double.parseDouble(row.elementAt(3).toString());
            double totalCost = Double.parseDouble(row.elementAt(4).toString());
            double saleTotal = Double.parseDouble(row.elementAt(5).toString());
            double profit = saleTotal - totalCost;
            double profitPercent = (totalCost > 0) ? (profit / totalCost) * 100 : 0;
            String billDate = row.elementAt(6).toString();
            
            //totalCostSum += totalCost;
            //totalSaleSum += saleTotal;
            //totalProfitSum += profit;
            
            String rowColor = (i % 2 == 0) ? "#ffffff" : "#f8f9fa";
        %><tr>
            <td><%= i + 1 %></td>
            <td><%= billNo %></td>
            <td><%= productName %></td>
            <td class="text-center"><%= qty %></td>
            <td class="text-end">&#8377; <%= String.format("%.3f", costPrice) %></td>
            <td class="text-end">&#8377; <%= String.format("%.3f", totalCost) %></td>
            <td class="text-end">&#8377; <%= String.format("%.3f", saleTotal) %></td>
            <td class="text-end" style="color:<%= profit >= 0 ? "var(--bill-green)" : "var(--bill-red)" %>;font-weight:600;">&#8377; <%= String.format("%.3f", profit) %></td>
            <td class="text-end" style="color:<%= profitPercent >= 0 ? "var(--bill-green)" : "var(--bill-red)" %>"><%= String.format("%.1f", profitPercent) %>%</td>
            <td><%= billDate %></td>
        </tr>
        <%
        }
        %>
    </tbody>
    <tfoot style="background:var(--bill-bg);font-weight:700">
        <tr>
            <td colspan="5" class="text-end">Grand Total:</td>
            <td class="text-end">&#8377; <%= String.format("%,.2f", totalCostSum) %></td>
            <td class="text-end">&#8377; <%= String.format("%,.2f", totalSaleSum) %></td>
            <td class="text-end" style="color:<%= totalProfitSum >= 0 ? "var(--bill-green)" : "var(--bill-red)" %>">&#8377; <%= String.format("%,.2f", totalProfitSum) %></td>
            <td class="text-end" style="color:<%= overallProfitPercent >= 0 ? "var(--bill-green)" : "var(--bill-red)" %>"><%= String.format("%.1f", overallProfitPercent) %>%</td>
            <td></td>
        </tr>
    </tfoot>
</table>
</div>

<!-- Summary Cards -->

</div>

<script>
function printReport() {
    fetch('<%=contextPath%>/printHeader.jsp')
        .then(r => r.text())
        .then(h => {
            const pa = document.createElement('div');
            pa.id = 'printArea';
            pa.innerHTML = h;
            const c = document.querySelector('.mst-page').cloneNode(true);
            c.querySelectorAll('.no-print').forEach(el => el.remove());
            pa.appendChild(c);
            document.body.appendChild(pa);
            window.print();
            document.body.removeChild(pa);
        });
}

function exportTableToExcel(tableID, filename) {
    var table = document.getElementById(tableID);
    var html = '<html xmlns:x="urn:schemas-microsoft-com:office:excel"><head><meta charset="UTF-8"><style>th,td{border:1px solid #000;padding:4px}</style></head><body>' + table.outerHTML + '</body></html>';
    var blob = new Blob(['\ufeff', html], {type: 'application/vnd.ms-excel'});
    var a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = (filename || 'export') + '.xls';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(a.href);
}
</script>

</body>
</html>
