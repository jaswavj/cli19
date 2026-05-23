<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<%@ page import="java.text.SimpleDateFormat, java.util.Date" %>
<%
String fromDate = request.getParameter("fromDate");
String toDate = request.getParameter("toDate");
    int supId = Integer.parseInt(request.getParameter("supId"));
    //out.print(supId);

%>
<jsp:useBean id="prod" class="product.productBean" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    <title>Purchase Register — Billing App</title>
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        .inv-link { color: var(--bill-navy); font-weight: 600; text-decoration: none; }
        .inv-link:hover { color: var(--bill-gold); text-decoration: underline; }
        @media (max-width: 768px) {
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
    <%@ include file="/assets/navbar/navbar.jsp" %>
<%
    request.setAttribute("pageTitle",    "Purchase Register");
    request.setAttribute("pageSubtitle", "Purchase Reports — Purchase Register");
    request.setAttribute("pageIcon",     "fa-solid fa-file-invoice-dollar");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

    <div class="container-fluid mt-3 mst-page" style="max-width: 1400px;">
        <div class="d-flex justify-content-end align-items-center mb-3 no-print">
            <a href="page.jsp" class="bb bb-outline me-2"><i class="fa-solid fa-arrow-left me-1"></i> Back</a>
            <button class="bb bb-navy me-2" onclick="printReport()"><i class="fa-solid fa-print me-1"></i> Print</button>
            <button class="bb bb-green" onclick="exportTableToExcel('purchaseTable', 'Purchase_Report')"><i class="fa-solid fa-file-excel me-1"></i> Export</button>
        </div>
        <div class="table-responsive">
        <table id="purchaseTable" class="table table-hover mb-0" style="border-collapse: separate; border-spacing: 0; min-width: 900px;">
            <thead style="background: linear-gradient(135deg, #f7fafc 0%, #edf2f7 100%);">
                <tr>
                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">S.No</th>
                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Inv No/GR no</th>
                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Invoice Date/Time</th>
                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Supplier</th>
                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Total (₹)</th>
                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Paid (₹)</th>
                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Balance (₹)</th>
                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Date</th>
                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Time</th>
                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">User</th>
                </tr>
            </thead>
            <tbody>
                <%
                Vector list = prod.getPurchaseReport(fromDate, toDate,supId);
                if (list != null && !list.isEmpty()) {
                    for (int i = 0; i < list.size(); i++) {
                        Vector row = (Vector) list.get(i);
                        String purchaseId = (String) row.elementAt(0);
                        
                %>
                <tr>
                    <td><%=i+1%></td>
                    <td><a href="purchaseDetails.jsp?id=<%=purchaseId%>&fromDate=<%=fromDate%>&toDate=<%=toDate%>&supId=<%=supId%>" class="inv-link"><%=row.elementAt(1)%>/<%=row.elementAt(11)%></a></td>
                    <td><%=row.elementAt(3)%></td>
                    <td><%=row.elementAt(10)%></td>
                    <td><%=row.elementAt(4)%></td>
                    <td><%=row.elementAt(5)%></td>
                    <td><%=row.elementAt(6)%></td>
                    <td><%=row.elementAt(7)%></td>
                    <td><%=row.elementAt(8)%></td>
                    <td><strong><%=row.elementAt(9)%></strong></td>
                </tr>
                <%
                    }
                } else {
                %>
                <tr>
                    <td colspan="10" class="text-center py-4 text-muted">
                        <i class="fas fa-inbox fa-2x mb-2 d-block" style="opacity:0.35;"></i>
                        No purchase records found for the selected period.
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
