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
    <title>Bill Date Change Report</title>
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>
<%
    request.setAttribute("pageTitle",    "Bill Date Change Report");
    request.setAttribute("pageSubtitle", "Admin — Reports");
    request.setAttribute("pageIcon",     "fa-solid fa-calendar-days");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

<div class="container-fluid mt-3 mst-page">
    <div class="d-flex flex-wrap gap-2 mb-3 no-print">
        <a href="<%=contextPath%>/admin/report/billDateChange/page.jsp" class="bb bb-outline"><i class="fa-solid fa-arrow-left me-1"></i>Back</a>
        <button class="bb bb-navy" onclick="printReport()"><i class="fa-solid fa-print me-1"></i>Print</button>
        <button class="bb bb-green" onclick="exportTableToExcel()"><i class="fa-solid fa-file-excel me-1"></i>Export Excel</button>
    </div>
    <div class="alert alert-info mb-3">
        <strong>Report Period:</strong> <%= fromDate %> to <%= toDate %>
    </div>

        <div class="table-responsive">
            <table id="billDateChangeTable" class="table mst-table">
                <thead>
                    <tr>
                        <th class="text-center">S.No</th>
                        <th>Bill No</th>
                        <th>Old Date</th>
                        <th>New Date</th>
                        <th>Change Date</th>
                        <th>Change Time</th>
                        <th>Changed By</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    Vector list = bill.getBillDateChangeReport(fromDate, toDate);
                    if (list != null && !list.isEmpty()) {
                        for (int i = 0; i < list.size(); i++) {
                            Vector row = (Vector) list.get(i);
                            int billId = Integer.parseInt(row.elementAt(0).toString());
                    %>
                    <tr>
                        <td><%=i+1%></td>
                        <td>
                            <a href="#" onclick="loadBillDetails(<%=billId%>); return false;"
                               class="inv-link">
                                <%=row.elementAt(1)%>
                            </a>
                        </td>
                        <td><%=row.elementAt(2)%></td>
                        <td><%=row.elementAt(3)%></td>
                        <td><%=row.elementAt(4)%></td>
                        <td><%=row.elementAt(5)%></td>
                        <td><%=row.elementAt(6)%></td>
                    </tr>
                    <%
                        }
                    } else {
                    %>
                    <tr>
                        <td colspan="7" class="text-center">No date changes found for the selected period.</td>
                    </tr>
                    <%
                    }
                    %>
                </tbody>
            </table>
        </div>

        <% if (list != null && !list.isEmpty()) { %>
        <div class="alert alert-secondary mt-3">
            <strong>Total Records:</strong> <%= list.size() %>
        </div>
        <% } %>
    </div>

<style>
@media print {
    @page {
        size: portrait;
        margin: 0.3cm;
    }
    body * {
        visibility: hidden;
    }
    #printArea, #printArea * {
        visibility: visible;
    }
    #printArea {
        position: absolute;
        left: 0;
        top: 0;
        width: 100%;
    }
    .no-print {
        display: none !important;
    }
    body {
        font-size: 8px;
        padding: 0;
        margin: 0;
    }
    .container {
        padding: 0 5px;
        max-width: 100%;
    }
    table {
        font-size: 8px;
        width: 100%;
        border-collapse: collapse;
    }
    th, td {
        padding: 1px 2px;
        word-wrap: break-word;
        max-width: 80px;
    }
    h2 {
        font-size: 10px;
        margin: 0;
    }
}
</style>

<script>
function printReport() {
    fetch('<%=contextPath%>/printHeader.jsp')
        .then(response => response.text())
        .then(headerHtml => {
            const printArea = document.createElement('div');
            printArea.id = 'printArea';
            printArea.innerHTML = headerHtml;
            
            const container = document.querySelector('.mst-page').cloneNode(true);
            const noPrintElements = container.querySelectorAll('.no-print');
            noPrintElements.forEach(el => el.remove());
            
            printArea.appendChild(container);
            document.body.appendChild(printArea);
            
            window.print();
            
            document.body.removeChild(printArea);
        })
        .catch(err => {
            console.error('Error loading print header:', err);
            alert('Error loading print header');
        });
}

function exportTableToExcel() {
    const table = document.getElementById('billDateChangeTable');
    const filename = 'Bill_Date_Change_Report.xls';
    
    const tableClone = table.cloneNode(true);
    const buttons = tableClone.querySelectorAll('button, .no-print');
    buttons.forEach(btn => btn.remove());
    
    const html = '<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel">' +
                 '<head><meta charset="utf-8"><style>table { border-collapse: collapse; width: 100%; } th, td { border: 1px solid #000; padding: 8px; text-align: left; }</style></head>' +
                 '<body>' + tableClone.outerHTML + '</body></html>';
    
    const blob = new Blob(['\ufeff', html], {
        type: 'application/vnd.ms-excel'
    });
    
    const url = URL.createObjectURL(blob);
    const downloadLink = document.createElement('a');
    downloadLink.href = url;
    downloadLink.download = filename;
    document.body.appendChild(downloadLink);
    downloadLink.click();
    document.body.removeChild(downloadLink);
    URL.revokeObjectURL(url);
}

function loadBillDetails(billId) {
  var modal = new bootstrap.Modal(document.getElementById('billDetailModal'));
  modal.show();
  document.getElementById('billDetailContent').innerHTML = '<div class="text-center py-5"><div class="spinner-border text-primary" role="status"><span class="visually-hidden">Loading...</span></div></div>';
  fetch('<%=contextPath%>/billing/balanceDetailModal.jsp?billId=' + billId)
    .then(response => response.text())
    .then(data => { document.getElementById('billDetailContent').innerHTML = data; })
    .catch(error => { document.getElementById('billDetailContent').innerHTML = '<div class="alert alert-danger" role="alert"><i class="fa-solid fa-triangle-exclamation"></i> Error loading bill details. Please try again.</div>'; console.error('Error:', error); });
}
</script>

<!-- Bill Details Modal -->
<div class="modal fade" id="billDetailModal" tabindex="-1" aria-labelledby="billDetailModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-xl modal-dialog-scrollable">
    <div class="modal-content">
      <div class="modal-header mst-card-header">
        <h5 class="modal-title" id="billDetailModalLabel">Bill Details</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body" id="billDetailContent">
        <div class="text-center py-5"><div class="spinner-border text-primary" role="status"><span class="visually-hidden">Loading...</span></div></div>
      </div>
      <div class="modal-footer">
        <button type="button" class="bb bb-outline" data-bs-dismiss="modal">Close</button>
      </div>
    </div>
  </div>
</div>

</body>
</html>
