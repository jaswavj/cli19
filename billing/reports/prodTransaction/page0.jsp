<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<%@ page language="java" import= "java.util.*,java.text.*" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<jsp:useBean id="prod" class="product.productBean" />
<%
    String fromDate = request.getParameter("fromDate");  
    String toDate   = request.getParameter("toDate");
    int productId = 0;
    if(request.getParameter("productId") != null && !request.getParameter("productId").isEmpty()) {
        productId = Integer.parseInt(request.getParameter("productId"));
    }

    
%>
<!DOCTYPE html>
<html lang="en">
<head>
    
    <meta charset="UTF-8">
    <title>Product Transaction Report</title>
<%@ include file="/assets/common/head.jsp" %>
    <style>
        .table td, .table th { vertical-align: middle; }
        .cell-green { background-color: rgba(5, 150, 105, 0.18) !important; color: #065f46; font-weight: 600; }
        .cell-red   { background-color: rgba(220, 38, 38,  0.18) !important; color: #991b1b; font-weight: 600; }
        @media print {
            @page { margin: 0.3cm; size: portrait; }
            body { margin: 0; padding: 0; }
            .no-print { display: none !important; }
            body * { visibility: hidden; }
            #printArea, #printArea * { visibility: visible; }
            #printArea { position: absolute; left: 0; top: 0; width: 100%; margin: 0; padding: 0; }
            #printArea .container { max-width: 100% !important; margin: 0 !important; padding: 0 5px !important; }
            #printArea .table-responsive { overflow: visible !important; }
            #printArea table { width: 100% !important; font-size: 8px !important; }
            #printArea table th, #printArea table td { padding: 1px 2px !important; font-size: 8px !important; word-wrap: break-word; max-width: 80px; }
        }
    </style>
</head>
<body >
<!--%@ include file="../menu/reportMenu.jsp" %-->
    <%@ include file="/assets/navbar/navbar.jsp" %>
<%
    request.setAttribute("pageTitle",    "Product Transaction Report");
    request.setAttribute("pageSubtitle", "Reports \u2014 Stock Movement");
    request.setAttribute("pageIcon",     "fa-solid fa-arrow-right-arrow-left");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

<div class="container-fluid mt-3 mst-page">
<div class="d-flex justify-content-between align-items-center mb-3">
    <p class="mb-0 text-muted"><strong>Period:</strong> <%= fromDate %> to <%= toDate %></p>
    <div class="no-print d-flex gap-2">
        <a href="<%=contextPath%>/reports/prodTransaction/page.jsp" class="bb bb-outline">Back</a>
        <button class="bb bb-navy" onclick="printReport()"><i class="fa-solid fa-print"></i> Print</button>
        <button class="bb bb-green" onclick="exportTableToExcel('printTable', 'Product_Transaction_Report')"><i class="fa-solid fa-file-excel"></i> Export</button>
    </div>
</div>

<div class="table-responsive">
<table id="printTable" class="table mb-0 mst-table">
    <thead>
        <tr>
            <th class="text-center">S.No</th>
            <th><%=head3%> Name</th>
            <th class="text-center">Stock in</th>
            <th class="text-center">Stock out</th>
            <th class="text-center">Stock now</th>
            <th>Notes</th>
            <th>Date/Time</th>
            <th class="text-center">Stock Adj</th>
            <th>User</th>
        </tr>
    </thead>
    <tbody>
        <%
        Vector vec = bill.getStockAdj(fromDate,toDate,productId);
        String color ="";
        String colors ="";
        String adjColors ="";
        String adjText = "-";
        for(int i=0;i< vec.size();i++)
		{
            Vector row		= (Vector)vec.elementAt(i);
            double addedStock = Double.parseDouble(row.elementAt(1).toString());  
            double removedStock = Double.parseDouble(row.elementAt(2).toString());
            int adjType = Integer.parseInt(row.elementAt(7).toString());

           
            if(addedStock>0){
                color="cell-green";
            }
            else{
                color="";
            }
            if(removedStock>0){
                colors="cell-red";
            }
            else{
                colors="";
            }

        if(adjType == 1){
            adjColors = "cell-green";
            adjText   = "Added";
        }
        else if(adjType == 2){
            adjColors = "cell-red";
            adjText   = "Removed";
        }
        else{
            adjColors = "";
            adjText   = "-";
        }

           


        %>
        <tr>
            <td class="text-center"><%=i+1%></td>
            <td><%=row.elementAt(0)%></td>
            <td class="text-center <%=color%>"><%=row.elementAt(1)%> <%=(row.size() > 9 && row.elementAt(9) != null && !row.elementAt(9).toString().isEmpty()) ? row.elementAt(9) : (row.size() > 8 && row.elementAt(8) != null ? row.elementAt(8) : "")%></td>
            <td class="text-center <%=colors%>"><%=row.elementAt(2)%> <%=(row.size() > 9 && row.elementAt(9) != null && !row.elementAt(9).toString().isEmpty()) ? row.elementAt(9) : (row.size() > 8 && row.elementAt(8) != null ? row.elementAt(8) : "")%></td>
            <td class="text-center"><%=row.elementAt(3)%> <%=(row.size() > 9 && row.elementAt(9) != null && !row.elementAt(9).toString().isEmpty()) ? row.elementAt(9) : (row.size() > 8 && row.elementAt(8) != null ? row.elementAt(8) : "")%></td>
            <td><%=row.elementAt(4)%></td>
            <td><%=row.elementAt(5)%></td>
            <td class="text-center <%=adjColors%>"><%=adjText%></td>
            <td><%=row.elementAt(6)%></td>
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
