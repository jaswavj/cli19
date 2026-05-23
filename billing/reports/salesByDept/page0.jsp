<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<%@ page language="java" import= "java.util.*,java.text.*" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<jsp:useBean id="prod" class="product.productBean" />
<%
    String fromDate = request.getParameter("fromDate");  
    String toDate   = request.getParameter("toDate");
    int brandId = Integer.parseInt(request.getParameter("categoryId"));

    // Just for demo - print selected dates
%>
<!DOCTYPE html>
<html lang="en">
<head>
    
    <meta charset="UTF-8">
    <title>Billing Report</title>
<%@ include file="/assets/common/head.jsp" %>
</head>
<body>
<!--%@ include file="../menu/reportMenu.jsp" %-->
    <%@ include file="/assets/navbar/navbar.jsp" %>
<%
    request.setAttribute("pageTitle",    "Sales by " + head2);
    request.setAttribute("pageSubtitle", "Reports — Department Sales");
    request.setAttribute("pageIcon",     "fa-solid fa-building");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

<div class="container-fluid mt-3 mst-page">
<div class="d-flex justify-content-between align-items-center mb-3">
    <p class="mb-0 text-muted"><strong>Report From:</strong> <%= fromDate %> — <%= toDate %></p>
    <div class="d-flex gap-2 no-print">
        <a href="<%=contextPath%>/reports/salesByDept/page.jsp" class="bb bb-outline"><i class="fa-solid fa-arrow-left me-1"></i>Back</a>
        <button class="bb bb-navy" onclick="printReport()"><i class="fa-solid fa-print me-1"></i>Print</button>
        <button class="bb bb-green" onclick="exportTableToExcel('printTable', 'Sales_By_Department_Report')"><i class="fa-solid fa-file-excel me-1"></i>Export</button>
    </div>
</div>

<div class="table-responsive">
<table id="printTable" class="table mt-3 mst-table">
    <thead>
        <tr>
            <th class="text-center">S.No</th>
            <th>Bill No</th>
            <th>Customer Name</th>
            <th class="text-center">Qty</th>
            <th class="text-end">Price</th>
            <th class="text-end">Discount</th>
            <th class="text-end">Total</th>
            <th class="text-end">Paid</th>
            <th class="text-end">Balance</th>
            <th class="text-end">Pending balance</th>
            <th><%=head1%></th>
            <th><%=head2%></th>
            <th>Date</th>
            <th>Time</th>
            <th>Biller</th>
        </tr>
    </thead>
    <tbody>
        <%
        Vector vec = bill.getSalesReportByBrand(fromDate,toDate,brandId);
        double grandTotal=0;
        double grandPrice=0;
        double grandDiscount=0;
        double finPaid=0.0;
        double finBalance=0.0;
        double finCurBalance=0.0;
        for(int i=0;i< vec.size();i++)
		{
            Vector row		= (Vector)vec.elementAt(i);
            int billId		= Integer.parseInt(row.elementAt(8).toString());
            double price    = Double.parseDouble(row.elementAt(2).toString());  
            double total    = Double.parseDouble(row.elementAt(4).toString());
            double discount = Double.parseDouble(row.elementAt(3).toString());
            double paid       = Double.parseDouble(row.elementAt(4).toString());
            double balance    = Double.parseDouble(row.elementAt(13).toString());
            double curBalance = Double.parseDouble(row.elementAt(14).toString());
            grandTotal     += total;
            grandPrice     += price;
            grandDiscount  += discount;   
            finPaid+=paid;
            finBalance+=balance;
            finCurBalance+=curBalance; 
           


        %>
        <tr>
            <td><%=i+1%></td>
            <td><a href="#" onclick="loadBillDetails(<%=billId%>); return false;" class="inv-link"><%=row.elementAt(0)%></a></td>
            <td><%=row.elementAt(15)%></td>
            <td><%=row.elementAt(1)%></td>
            <td><%=row.elementAt(2)%></td>
            <td><%=row.elementAt(3)%></td>
            <td><%=row.elementAt(4)%></td>
            <td><%=row.elementAt(4)%></td>
            <td><%=row.elementAt(13)%></td>
            <td><%=row.elementAt(14)%></td>
            <td><%=row.elementAt(10)%></td>
            <td><%=row.elementAt(11)%></td>
            <td><%=row.elementAt(5)%></td>
            <td><%=row.elementAt(6)%></td>
            <td><%=row.elementAt(7)%></td>
        </tr>
        <%
    
}
        %>
        <tr style="background:var(--bill-bg);font-weight:700">
            <td colspan="4" class="text-end"><strong>Grand Total:</strong></td>
            <td><strong><%=String.format("%.3f", grandPrice)%></strong></td>
            <td><strong><%=String.format("%.3f", grandDiscount)%></strong></td>
            <td><strong><%=String.format("%.3f", grandTotal)%></strong></td>
            <td><strong><%=String.format("%.3f", finPaid)%></strong></td>
            <td><strong><%=String.format("%.3f", finBalance)%></strong></td>
            <td><strong><%=String.format("%.3f", finCurBalance)%></strong></td>
            <td colspan="5"></td>
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
        })
        .catch(() => window.print());
}
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
        })
        .catch(() => window.print());
}

function exportTableToExcel(tableID, filename = ''){
    var table = document.getElementById(tableID);
    if (!table) { alert('Table not found!'); return; }
    var tableClone = table.cloneNode(true);
    var html = '<html xmlns:x="urn:schemas-microsoft-com:office:excel"><head><meta charset="UTF-8"><style>table {border-collapse: collapse;} td, th {border: 1px solid black; padding: 5px;}</style></head><body><table border="1">' + tableClone.innerHTML + '</table></body></html>';
    filename = filename ? filename + '.xls' : 'excel_data.xls';
    var blob = new Blob(['\ufeff', html], { type: 'application/vnd.ms-excel' });
    var downloadLink = document.createElement("a");
    downloadLink.href = URL.createObjectURL(blob);
    downloadLink.download = filename;
    document.body.appendChild(downloadLink);
    downloadLink.click();
    document.body.removeChild(downloadLink);
}

function loadBillDetails(billId) {
  var modal = new bootstrap.Modal(document.getElementById('billDetailModal'));
  modal.show();
  document.getElementById('billDetailContent').innerHTML = '<div class="text-center py-5"><div class="spinner-border text-primary" role="status"><span class="visually-hidden">Loading...</span></div></div>';
  fetch('<%=contextPath%>/billing/balanceDetailModal.jsp?billId=' + billId)
    .then(response => response.text())
    .then(data => { document.getElementById('billDetailContent').innerHTML = data; })
    .catch(error => { document.getElementById('billDetailContent').innerHTML = '<div class="alert alert-danger" role="alert"><i class="fas fa-exclamation-triangle"></i> Error loading bill details. Please try again.</div>'; console.error('Error:', error); });
}
</script>

<!-- Bill Details Modal -->
<div class="modal fade" id="billDetailModal" tabindex="-1" aria-labelledby="billDetailModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-xl modal-dialog-scrollable">
    <div class="modal-content">
      <div class="modal-header" style="background:var(--bill-navy);color:#fff;">
        <h5 class="modal-title" id="billDetailModalLabel">Bill Details</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body" id="billDetailContent">
        <div class="text-center py-5"><div class="spinner-border text-primary" role="status"><span class="visually-hidden">Loading...</span></div></div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
      </div>
    </div>
  </div>
</div>

</body>
</html>
