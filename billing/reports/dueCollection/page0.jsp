<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<%@ page import="java.text.SimpleDateFormat, java.util.Date" %>
<%
String fromDate = request.getParameter("fromDate");
String toDate = request.getParameter("toDate");
%>
<jsp:useBean id="bill" class="billing.billingBean" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Purchase Report</title>
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>
        <%@ include file="/assets/navbar/navbar.jsp" %>
<%
    request.setAttribute("pageTitle",    "Due Collection");
    request.setAttribute("pageSubtitle", "Reports — Balance Collection");
    request.setAttribute("pageIcon",     "fa-solid fa-money-bill-wave");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

    <div class="container-fluid mt-3 mst-page">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <p class="mb-0 text-muted"><strong>Period:</strong> <%= fromDate %> — <%= toDate %></p>
            <div class="d-flex gap-2 no-print">
                <a href="<%=contextPath%>/reports/dueCollection/page.jsp" class="bb bb-outline"><i class="fa-solid fa-arrow-left me-1"></i>Back</a>
                <button class="bb bb-navy" onclick="printReport()"><i class="fa-solid fa-print me-1"></i>Print</button>
                <button class="bb bb-green" onclick="exportTableToExcel('printTable', 'Due_Collection_Report')"><i class="fa-solid fa-file-excel me-1"></i>Export</button>
            </div>
        </div>
        <div class="table-responsive">
        <table id="printTable" class="table mst-table">
            <thead>
                <tr>
                    <th class="text-center">S.No</th>
                    <th>Bill No</th>
                    <th>Customer name</th>
                    <th class="text-end">Balance</th>
                    <th class="text-end">Paid</th>
                    <th class="text-end">Final Balance</th>
                    <th>Mode</th>
                    <th>User</th>
                    <th>Date</th>
                    <th>Time</th>
                </tr>
            </thead>
            <tbody>
                <%
                Vector list = bill.getDueCollection(fromDate, toDate);
                if (list != null && !list.isEmpty()) {
                    for (int i = 0; i < list.size(); i++) {
                        Vector row = (Vector) list.get(i);
                        
                %>
                <tr>
                    <td><%=i+1%></td>
                    <td><%=row.elementAt(0)%></td>
                    <td><%=row.elementAt(1)%></td>
                    <td><%=row.elementAt(2)%></td>
                    <td><%=row.elementAt(3)%></td>
                    <td><%=row.elementAt(4)%></td>
                    <td><%=row.elementAt(5)%></td>
                    <td><%=row.elementAt(6)%></td>
                    <td><%=row.elementAt(7)%></td>
                    <td><%=row.elementAt(8)%></td>
                    
                </tr>
                <%
                    }
                } 
                %>
                <!-- Add more rows as needed -->
            </tbody>
        </table>
        </div>
    </div>

<script>
function printReport() {
    var printArea = document.createElement('div');
    printArea.id = 'printArea';
    fetch('<%=contextPath%>/printHeader.jsp')
        .then(r => r.text())
        .then(h => {
            printArea.innerHTML = h;
            var c = document.querySelector('.mst-page').cloneNode(true);
            c.querySelectorAll('.no-print').forEach(el => el.remove());
            printArea.appendChild(c);
            document.body.appendChild(printArea);
            window.print();
            document.body.removeChild(printArea);
        });
}

function exportTableToExcel(tableID, filename) {
    var table = document.getElementById(tableID);
    if (!table) { alert('Table not found!'); return; }
    var html = '<html xmlns:x="urn:schemas-microsoft-com:office:excel"><head><meta charset="UTF-8"><style>th,td{border:1px solid #000;padding:4px}</style></head><body>' + table.outerHTML + '</body></html>';
    var blob = new Blob(['\ufeff', html], { type: 'application/vnd.ms-excel' });
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
