<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*" %>
<%
String fromDate = request.getParameter("fromDate");
String toDate   = request.getParameter("toDate");
%>
<jsp:useBean id="bill" class="billing.salesReturnBean" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Payment Type Change Report</title>
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>
<%
    request.setAttribute("pageTitle",    "Payment Type Change Report");
    request.setAttribute("pageSubtitle", "Admin — Reports");
    request.setAttribute("pageIcon",     "fa-solid fa-right-left");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

<div class="container-fluid mt-3 mst-page">
    <div class="d-flex flex-wrap gap-2 mb-3 no-print">
        <a href="<%=contextPath%>/admin/report/paymentTypeChange/page.jsp" class="bb bb-outline"><i class="fa-solid fa-arrow-left me-1"></i>Back</a>
        <button class="bb bb-navy" onclick="printReport()"><i class="fa-solid fa-print me-1"></i>Print</button>
        <button class="bb bb-green" onclick="exportTableToExcel()"><i class="fa-solid fa-file-excel me-1"></i>Export Excel</button>
    </div>
    <div class="alert alert-info mb-3">
        <strong>Report Period:</strong> <%=fromDate%> &nbsp;to&nbsp; <%=toDate%>
    </div>

        <div class="table-responsive">
            <table id="paymentChangeTable" class="table mst-table table-sm">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Bill No</th>
                        <th class="text-end">Old Cash</th>
                        <th class="text-end">New Cash</th>
                        <th class="text-end">Old Bank</th>
                        <th class="text-end">New Bank</th>
                        <th>Bank Mode</th>
                        <th>Changed By</th>
                        <th>Date &amp; Time</th>
                    </tr>
                </thead>
                <tbody>
                <%
                Vector list = bill.getPaymentTypeChangeReport(fromDate, toDate);
                if (list != null && !list.isEmpty()) {
                    for (int i = 0; i < list.size(); i++) {
                        Vector row = (Vector) list.get(i);
                        int    billId      = (Integer) row.elementAt(1);
                        String billDisplay = row.elementAt(2).toString();
                        double oldCash     = (Double)  row.elementAt(3);
                        double newCash     = (Double)  row.elementAt(4);
                        double oldBank     = (Double)  row.elementAt(5);
                        double newBank     = (Double)  row.elementAt(6);
                        String bankMode    = row.elementAt(7).toString();
                        String userName    = row.elementAt(8).toString();
                        String dateTime    = row.elementAt(9).toString();

                        /* highlight rows where values actually changed */
                        String cashClass = (oldCash != newCash) ? "table-warning" : "";
                        String bankClass = (oldBank != newBank) ? "table-warning" : "";
                %>
                <tr>
                    <td><%=i + 1%></td>
                    <td>
                        <a href="#" onclick="loadBillDetails(<%=billId%>); return false;"
                           class="inv-link">
                            <%=billDisplay%>
                        </a>
                    </td>
                    <td class="<%=cashClass%> text-end"><%=String.format("%.3f", oldCash)%></td>
                    <td class="<%=cashClass%> text-end fw-semibold"><%=String.format("%.3f", newCash)%></td>
                    <td class="<%=bankClass%> text-end"><%=String.format("%.3f", oldBank)%></td>
                    <td class="<%=bankClass%> text-end fw-semibold"><%=String.format("%.3f", newBank)%></td>
                    <td><%=bankMode%></td>
                    <td><%=userName%></td>
                    <td><%=dateTime%></td>
                </tr>
                <%
                    }
                } else {
                %>
                <tr>
                    <td colspan="9" class="text-center text-muted py-3">No records found for the selected period.</td>
                </tr>
                <%
                }
                %>
                </tbody>
            </table>
        </div>

        <% if (list != null && !list.isEmpty()) { %>
        <div class="alert alert-secondary mt-2">
            <strong>Total Records:</strong> <%=list.size()%>
        </div>
        <% } %>
    </div>

<style>
@media print {
    @page { size: landscape; margin: 0.4cm; }
    body * { visibility: hidden; }
    #printArea, #printArea * { visibility: visible; }
    #printArea { position: absolute; left: 0; top: 0; width: 100%; }
    .no-print { display: none !important; }
    body { font-size: 8px; padding: 0; margin: 0; }
    .container { padding: 0 4px; max-width: 100%; }
    table { font-size: 8px; width: 100%; border-collapse: collapse; }
    th, td { padding: 2px 3px; word-wrap: break-word; }
    h3 { font-size: 11px; margin: 0 0 4px 0; }
}
</style>

<script>
function printReport() {
    fetch('<%=contextPath%>/printHeader.jsp')
        .then(r => r.text())
        .then(headerHtml => {
            var printArea = document.createElement('div');
            printArea.id = 'printArea';
            printArea.innerHTML = headerHtml;
            var container = document.querySelector('.mst-page').cloneNode(true);
            container.querySelectorAll('.no-print').forEach(function(el){ el.remove(); });
            printArea.appendChild(container);
            document.body.appendChild(printArea);
            window.print();
            document.body.removeChild(printArea);
        })
        .catch(function() { window.print(); });
}

function exportTableToExcel() {
    var table = document.getElementById('paymentChangeTable');
    var clone = table.cloneNode(true);
    clone.querySelectorAll('.no-print').forEach(function(el){ el.remove(); });
    /* replace button links with plain text */
    clone.querySelectorAll('a.btn').forEach(function(a){
        var span = document.createElement('span');
        span.textContent = a.textContent.trim();
        a.parentNode.replaceChild(span, a);
    });
    var html = '<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel">' +
               '<head><meta charset="utf-8"><style>table{border-collapse:collapse}th,td{border:1px solid #000;padding:5px}</style></head>' +
               '<body>' + clone.outerHTML + '</body></html>';
    var blob = new Blob(['\ufeff', html], { type: 'application/vnd.ms-excel' });
    var url  = URL.createObjectURL(blob);
    var a    = document.createElement('a');
    a.href     = url;
    a.download = 'Payment_Type_Change_Report.xls';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
}

function loadBillDetails(billId) {
    var modal = new bootstrap.Modal(document.getElementById('billDetailModal'));
    modal.show();
    document.getElementById('billDetailContent').innerHTML =
        '<div class="text-center py-5"><div class="spinner-border text-primary" role="status"></div></div>';
    fetch('<%=contextPath%>/billing/balanceDetailModal.jsp?billId=' + billId)
        .then(function(r){ return r.text(); })
        .then(function(data){ document.getElementById('billDetailContent').innerHTML = data; })
        .catch(function(){ document.getElementById('billDetailContent').innerHTML =
            '<div class="alert alert-danger">Error loading bill details.</div>'; });
}
</script>

<!-- Bill Detail Modal -->
<div class="modal fade" id="billDetailModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header mst-card-header">
                <h5 class="modal-title">Bill Details</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body" id="billDetailContent">
                <div class="text-center py-5"><div class="spinner-border text-primary" role="status"></div></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="bb bb-outline" data-bs-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>

</body>
</html>
