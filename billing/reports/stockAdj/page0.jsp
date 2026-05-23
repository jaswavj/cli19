<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*,java.sql.*,java.text.*"%>
<jsp:useBean id="prod" class="product.productBean" />

<%
    String fromDate = request.getParameter("fromDate");  
    String toDate   = request.getParameter("toDate");
    int productId = 0;
    if(request.getParameter("productId") != null && !request.getParameter("productId").isEmpty()) {
        productId = Integer.parseInt(request.getParameter("productId"));
    }
    
    int stockType = 0;
    if(request.getParameter("stockType") != null && !request.getParameter("stockType").isEmpty()) {
        stockType = Integer.parseInt(request.getParameter("stockType"));
    }

    if(fromDate == null) fromDate = "";
    if(toDate == null) toDate = "";

    
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    <title>Stock Adjustment Report</title>
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        .table td, .table th { vertical-align: middle; }
        .badge-add    { background-color: var(--bill-green)    !important; color: #fff !important; }
        .badge-remove { background-color: var(--bill-red)      !important; color: #fff !important; }
        .badge-warn   { background-color: var(--bill-gold)     !important; color: #fff !important; }
        .badge-info   { background-color: var(--bill-navy-mid) !important; color: #fff !important; }
        @media (max-width: 768px) {
            .d-flex.justify-content-between { flex-direction: column; gap: 1rem; }
            .no-print { display: flex; flex-direction: column; gap: 0.5rem; }
            .no-print a, .no-print button { width: 100%; }
        }
        @media print {
            @page { margin: 0.3cm; size: portrait; }
            body { margin: 0; padding: 0; }
            .no-print { display: none !important; }
            body * { visibility: hidden; }
            #printArea, #printArea * { visibility: visible; }
            #printArea { position: absolute; left: 0; top: 0; width: 100%; margin: 0; padding: 0; }
            #printArea .container { max-width: 100% !important; margin: 0 !important; padding: 0 5px !important; }
            #printArea table { width: 100% !important; font-size: 8px !important; }
            #printArea table th, #printArea table td { padding: 1px 2px !important; font-size: 8px !important; word-wrap: break-word; max-width: 80px; }
        }
    </style>
</head>
<body>
<!--%@ include file="../menu/reportMenu.jsp" %-->
    <%@ include file="/assets/navbar/navbar.jsp" %>
<%
    request.setAttribute("pageTitle",    "Stock Adjustment Report");
    request.setAttribute("pageSubtitle", "Reports \u2014 Stock Adjustments");
    request.setAttribute("pageIcon",     "fa-solid fa-sliders");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

<div class="container-fluid mt-3 mst-page">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <p class="mb-0 text-muted"><strong>Period:</strong> <%= fromDate %> to <%= toDate %></p>
        <div class="no-print d-flex gap-2">
            <a href="<%=contextPath%>/reports/stockAdj/page.jsp" class="bb bb-outline">Back</a>
            <button class="bb bb-navy" onclick="printReport()"><i class="fa-solid fa-print"></i> Print</button>
            <button class="bb bb-green" onclick="exportTableToExcel('printTable', 'Stock_Adjustment_Report')"><i class="fa-solid fa-file-excel"></i> Export</button>
        </div>
    </div>

    <div class="table-responsive">
    <table id="printTable" class="table mb-0 mst-table">
        <thead>
            <tr>
                <th class="text-center">SI.NO</th>
                <th><%=head3%></th>
                <th class="text-center">Action</th>
                <th class="text-center">Stock</th>
                <th>Date</th>
                <th>Time</th>
                <th>User</th>
                <th>Notes</th>
            </tr>
        </thead>
        <tbody>
        <%
    Vector vec = prod.getStockAdjReport(fromDate, toDate, productId, stockType);

    for (int i = 0; i < vec.size(); i++) {
        Vector row = (Vector) vec.elementAt(i);
%>
<tr>
    <td class="text-center"><%=i+1 %></td>
    <td><%= row.get(2) %></td>
    <td class="text-center">
        <%
            String stockTypeStr = row.get(4).toString();
            String badgeClass = "badge badge-remove";
            String label = "Removed";
            if("1".equals(stockTypeStr)) {
                badgeClass = "badge badge-add";
                label = "Added";
            } else if("3".equals(stockTypeStr)) {
                badgeClass = "badge badge-warn";
                label = "Damage";
            } else if("4".equals(stockTypeStr)) {
                badgeClass = "badge badge-info";
                label = "Internal Use";
            }
        %>
        <span class="<%= badgeClass %>"><%= label %></span>
    </td>
    <td class="text-center"><%= row.get(5) %><%=(row.size() > 11 && row.get(11) != null && !row.get(11).toString().isEmpty()) ? " " + row.get(11) : ""%></td>
    <td><%= row.get(6) %></td>
    <td><%= row.get(7) %></td>
    <td><%= row.get(10) %></td>
    <td><%= row.get(8) %></td>
</tr>
<%
    }
%>

        </tbody>
</table>
</div>
</div>

<script>
function printReport() {
    var printArea = document.createElement('div');
    printArea.id = 'printArea';
    
    fetch('<%=contextPath%>/printHeader.jsp')
        .then(response => response.text())
        .then(headerHtml => {
            printArea.innerHTML = headerHtml;
            
            var tableContainer = document.querySelector('.container');
            var tableClone = tableContainer.cloneNode(true);
            
            var buttons = tableClone.querySelector('.no-print');
            if(buttons) buttons.remove();
            
            printArea.appendChild(tableClone);
            
            document.body.appendChild(printArea);
            window.print();
            
            document.body.removeChild(printArea);
        })
        .catch(error => {
            console.error('Error loading print header:', error);
            window.print();
        });
}

function exportTableToExcel(tableID, filename = ''){
    var table = document.getElementById(tableID);
    if (!table) {
        alert('Table not found!');
        return;
    }
    
    var tableClone = table.cloneNode(true);
    
    var html = '<html xmlns:x="urn:schemas-microsoft-com:office:excel">';
    html += '<head><meta charset="UTF-8">';
    html += '<style>table {border-collapse: collapse;} td, th {border: 1px solid black; padding: 5px;}</style>';
    html += '</head><body>';
    html += '<table border="1">' + tableClone.innerHTML + '</table>';
    html += '</body></html>';
    
    filename = filename ? filename + '.xls' : 'excel_data.xls';
    
    var blob = new Blob(['\ufeff', html], {
        type: 'application/vnd.ms-excel'
    });
    
    var downloadLink = document.createElement("a");
    downloadLink.href = URL.createObjectURL(blob);
    downloadLink.download = filename;
    document.body.appendChild(downloadLink);
    downloadLink.click();
    document.body.removeChild(downloadLink);
}
</script>

</body>
</html>
