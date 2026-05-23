<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<%@ page language="java" import= "java.util.*,java.text.*" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<jsp:useBean id="prod" class="product.productBean" />
<%
String fromDate = request.getParameter("fromDate");  
    String toDate   = request.getParameter("toDate");
    
    String modeParam = request.getParameter("mode");
    int modeId = 0;
    if (modeParam != null && !modeParam.isEmpty()) {
        modeId = Integer.parseInt(modeParam);
    }
    
    String userParam = request.getParameter("userId");
    int userId = 0;
    if (userParam != null && !userParam.isEmpty()) {
        userId = Integer.parseInt(userParam);
    }
    
    String typeParam = request.getParameter("type");
    int typeId = 0;
    if (typeParam != null && !typeParam.isEmpty()) {
        typeId = Integer.parseInt(typeParam);
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    
    <meta charset="UTF-8">
    <title>Collection Report</title>
<%@ include file="/assets/common/head.jsp" %>




</head>
<body > 

    <jsp:include page="/assets/navbar/navbar.jsp" />
<%
    request.setAttribute("pageTitle",    "Sales Report");
    request.setAttribute("pageSubtitle", "Reports — Cash/Bank Collection");
    request.setAttribute("pageIcon",     "fa-solid fa-cash-register");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

<div class="container-fluid mt-3 mst-page">
<p class="mb-1 text-muted"><strong>Collection Report From:</strong> <%= fromDate %> — <%= toDate %></p>
    <div class="d-flex gap-2 mb-3 no-print">
        <a href="<%=contextPath%>/reports/sales/page.jsp" class="bb bb-outline"><i class="fa-solid fa-arrow-left me-1"></i>Back</a>
        <button class="bb bb-navy" onclick="printReport()"><i class="fa-solid fa-print me-1"></i>Print</button>
        <button class="bb bb-green" onclick="exportTableToExcel('printTable', 'Sales_Report')"><i class="fa-solid fa-file-excel me-1"></i>Export</button>
    </div>
<div class="table-responsive">
<table id="printTable" class="table mb-0 mst-table">
    <thead>
        <tr>
            <th>S.No</th>
            <th>Bill No</th>
            <th>Patient Name</th>
            <th>Total</th>
            <!--th>Discount</th-->
            <th>Payable</th>
            <th>Paid</th>
            <% if(modeId !=2) { %><th>Cash</th><%}%>
            <% if(modeId !=1) { %><th>Bank</th><% } %>
            <th>Balance</th>
            <th>Pending Balance</th>
            <th>Date</th>
            <th>Time</th>
            <th>Biller</th>
        </tr>
    </thead>
    <tbody>
        <%
        Vector vec = bill.getsalesCashBankReport(fromDate,toDate,modeId,typeId,userId);
        double finTotal=0.0;
        double finDiscount=0.0;
        double finPayable=0.0; 
        double finPaid=0.0;
        double finCash=0.0;
        double finBank=0.0;
        double finBalance=0.0;
        double finCurBalance=0.0;
        for(int i=0;i< vec.size();i++)
		{
            Vector row		= (Vector)vec.elementAt(i);
            int billId		= Integer.parseInt(row.elementAt(8).toString());  
            double totalAmt   = Double.parseDouble(row.elementAt(1).toString());
            double discount    = Double.parseDouble(row.elementAt(2).toString());
            double payable     = Double.parseDouble(row.elementAt(3).toString());
            double paid        = Double.parseDouble(row.elementAt(4).toString());
            double cash       = Double.parseDouble(row.elementAt(10).toString());
            double bank       = Double.parseDouble(row.elementAt(11).toString());
            double Balance       = Double.parseDouble(row.elementAt(12).toString());
            double curBalance       = Double.parseDouble(row.elementAt(13).toString());
            String billNo    = row.elementAt(0).toString();
            finTotal+=totalAmt;
            finDiscount+=discount;  
            finPayable+=payable;
            finPaid+=paid;
            finCash+=cash;
            finBank+=bank;
            finBalance+=Balance;
            finCurBalance+=curBalance;
            String cusPhone = row.elementAt(15).toString();
            


        %>
        <tr>
            <td><%=i+1%></td>
            <td>
                <a href="<%=contextPath%>/billing/print.jsp?billNo=<%=billNo%>" target="_blank" name="billNo" class="inv-link"><%=row.elementAt(0)%></a>
                <button onclick="directPrint('<%=billNo%>')" class="bb bb-green ms-1" title="Thermal Print" style="padding:0.15rem 0.4rem;font-size:0.8rem">
                    <i class="fas fa-receipt"></i>
                </button>
            <td><a href="https://wa.me/<%=cusPhone%>" target="_blank" style="color:#25D366;text-decoration:none;font-weight:500"><%=row.elementAt(14)%></a></td>
            <td><%=row.elementAt(1)%></td>
            <!--td><%=row.elementAt(2)%></td-->
            <td><%=row.elementAt(3)%></td>
            <td><%=row.elementAt(4)%></td>
            <% if(modeId !=2) { %><td><%=row.elementAt(10)%></td><%}%>
            <% if(modeId !=1) { %><td><%=row.elementAt(11)%></td><%}%>
            <td><%=row.elementAt(12)%></td>
            <td><%=row.elementAt(13)%></td>
            <!--<% if(modeId !=1) { %><td><%=row.elementAt(9)%></td><%}%>-->
            <td><%=row.elementAt(5)%></td>
            <td><%=row.elementAt(6)%></td>
            <td><%=row.elementAt(7)%></td>
        </tr>
        <%
    
}
        %>
        <tr style="background:var(--bill-bg);font-weight:700">
            <td colspan="3"><strong>Grand Total</strong></td>
            <td><strong><%=String.format("%.3f", finTotal)%></strong></td>
            <!--td><strong><%=String.format("%.3f", finDiscount)%></strong></td-->
            <td><strong><%=String.format("%.3f", finPayable)%></strong></td>
            <td><strong><%=String.format("%.3f", finPaid)%></strong></td>
            <% if(modeId !=2) { %><td><strong><%=String.format("%.3f", finCash)%></strong></td><%}%>
            <% if(modeId !=1) { %><td><strong><%=String.format("%.3f", finBank)%></strong></td><%}%>
            <td><strong><%=finBalance%></strong></td>
            <td><strong><%=finCurBalance%></strong></td>
            <% if(modeId !=1) { %><td></td><%}%>
            <td></td><td></td>
        </tr>
    </tbody>
</table>
</div>
<p class="mt-3 text-muted"><strong>Due Collection Report From:</strong> <%= fromDate %> — <%= toDate %></p>

<div class="table-responsive">
<table class="table mb-0 mst-table">
   <thead>
    <tr>
        <th>S.No</th>
        <th>Bill No</th>
        <th>Customer Name</th>
        <th>Balance</th>
        <th>Cash Paid</th>
        <th>Bank Paid</th>
        <th>Mode</th>
        <th>Bank Option</th>
        <th>Date</th>
        <th>Time</th>
        <th>Biller</th>
    </tr>
</thead>
<tbody>
<%
    Vector dueDetails = bill.getDuePaidList(fromDate, toDate, userId);
    double totalCashPaid = 0.0;
    double totalBankPaid = 0.0;
    for (int j = 0; j < dueDetails.size(); j++) {
        Vector row = (Vector) dueDetails.elementAt(j);

        String cusName     = row.elementAt(0).toString();   // Customer
        String mode        = row.elementAt(4).toString();   // Cash / Bank
        String bank        = row.elementAt(5).toString();   // UPI / NEFT / etc.
        String date        = row.elementAt(6).toString();   // Date
        String time        = row.elementAt(7).toString();   // Time
        String userName    = row.elementAt(8).toString();   // Biller
        String billDisplay = row.elementAt(9).toString();   // Bill No

        double balance  = Double.parseDouble(row.elementAt(1).toString());
        double cashPaid = Double.parseDouble(row.elementAt(2).toString());
        double bankPaid = Double.parseDouble(row.elementAt(3).toString());
        int billId      = Integer.parseInt(row.elementAt(10).toString());

        totalCashPaid += cashPaid;
        totalBankPaid += bankPaid;
        double totalPaid = cashPaid + bankPaid;
%>
    <tr style="border-bottom:1px solid var(--bill-border-lt)">
        <td><%= j + 1 %></td>
        <td><%= billDisplay %></td>
        <td><%= cusName %></td>
        <td><%= balance %></td>
        <td><%= cashPaid %></td>
        <td><%= bankPaid %></td>
        <td><%= mode %></td>
        <td><%= bank %></td>
        <td><%= date %></td>
        <td><%= time %></td>
        <td><%= userName %></td>
    </tr>
<%
    } // end for
%>
    <tr style="background:var(--bill-bg);font-weight:700">
        <td colspan="4"><strong>Grand Total</strong></td>
        <td><strong><%= String.format("%.3f", totalCashPaid) %></strong></td>
        <td><strong><%= String.format("%.3f", totalBankPaid) %></strong></td>
        <td colspan="5"></td>
    </tr>
</tbody>




</table>
</div>
</div>

<style>
@media print {
    @page { margin: 0.3cm; size: portrait; }
    body { margin: 0; padding: 0; }
    .no-print { display: none !important; }
    body * { visibility: hidden; }
    #printArea, #printArea * { visibility: visible; }
    #printArea { position: absolute; left: 0; top: 0; width: 100%; }
    #printArea table { width: 100% !important; font-size: 8px !important; }
    #printArea th, #printArea td { padding: 1px 2px !important; font-size: 8px !important; }
}
</style>
        padding: 0;
    }
    #printArea .container {
        max-width: 100% !important;
        margin: 0 !important;
        padding: 0 5px !important;
    }
    #printArea .table-responsive {
        overflow: visible !important;
    }
    #printArea table {
        width: 100% !important;
        font-size: 8px !important;
        table-layout: auto !important;
    }
    #printArea table th,
    #printArea table td {
        padding: 1px 2px !important;
        font-size: 8px !important;
        word-wrap: break-word;
        overflow-wrap: break-word;
        max-width: 80px;
    }
}
</style>

<script>
// Toast notification function
function showToast(message, type = 'success') {
    const toastColors = {
        success: '#10b981',
        error: '#ef4444',
        info: '#3b82f6'
    };
    
    const toast = document.createElement('div');
    toast.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 12px 20px;
        background-color: ${toastColors[type] || toastColors.success};
        color: white;
        border-radius: 6px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        z-index: 10000;
        animation: slideIn 0.3s ease-out;
        font-size: 14px;
    `;
    toast.textContent = message;
    document.body.appendChild(toast);
    
    setTimeout(() => {
        toast.style.animation = 'slideOut 0.3s ease-out';
        setTimeout(() => document.body.removeChild(toast), 300);
    }, 3000);
}

// Direct thermal print function
function directPrint(billNo) {
    fetch('<%=contextPath%>/billing/directPrint.jsp?billNo=' + billNo, {
        credentials: 'same-origin'
    })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                if (data.type === 'a4') {
                    // A4 format selected in company settings - open print.jsp
                    window.open('<%=contextPath%>/billing/print.jsp?billNo=' + encodeURIComponent(data.billNo), '_blank');
                    showToast('✓ Opening A4 print preview', 'info');
                } else if (data.type === 'printed') {
                    showToast('✓ Receipt printed successfully!', 'success');
                } else if (data.type === 'txt') {
                    showToast('ℹ No printer found. Receipt saved as TXT file', 'info');
                    alert('Receipt saved to: ' + data.txtPath + '\n\nFile: ' + data.txtFile + '\n\nYou can open this file with Notepad to see how the receipt looks.');
                }
            } else {
                showToast('✗ Print failed: ' + data.message, 'error');
            }
        })
        .catch(error => {
            console.error('Print error:', error);
            showToast('✗ Print failed: ' + error.message, 'error');
        });
}

function printReport() {
    // Create print area
    var printArea = document.createElement('div');
    printArea.id = 'printArea';
    
    // Fetch and add header
    fetch('<%=contextPath%>/printHeader.jsp')
        .then(response => response.text())
        .then(headerHtml => {
            printArea.innerHTML = headerHtml;
            
            // Add the table content
            var tableContainer = document.querySelector('.mst-page');
            var tableClone = tableContainer.cloneNode(true);
            
            // Remove the button div from clone
            var buttons = tableClone.querySelector('.no-print');
            if(buttons) buttons.remove();
            
            printArea.appendChild(tableClone);
            
            // Append to body and print
            document.body.appendChild(printArea);
            window.print();
            
            // Remove after print
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
    
    // Create a copy of the table
    var tableClone = table.cloneNode(true);
    
    // Create HTML content with proper Excel format
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
