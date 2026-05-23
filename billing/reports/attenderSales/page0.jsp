<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<%@ page language="java" import="java.util.*,java.text.*" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<jsp:useBean id="prod" class="product.productBean" />
<%
String fromDate = request.getParameter("fromDate");  
String toDate = request.getParameter("toDate");

String attenderParam = request.getParameter("attenderId");
int attenderId = 0;
String attenderName = "All Attenders";
if (attenderParam != null && !attenderParam.isEmpty()) {
    attenderId = Integer.parseInt(attenderParam);
    if (attenderId > 0) {
        // Get attender name
        Vector attenderList = prod.getActiveAttenders();
        for (int i = 0; i < attenderList.size(); i++) {
            Vector row = (Vector) attenderList.elementAt(i);
            if ((Integer)row.get(0) == attenderId) {
                attenderName = row.get(1).toString();
                String code = row.get(2) != null ? row.get(2).toString() : "";
                if (!code.isEmpty()) {
                    attenderName += " (" + code + ")";
                }
                break;
            }
        }
    }
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Attender-Wise Sales Report</title>
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>
    <jsp:include page="/assets/navbar/navbar.jsp" />
<%
    request.setAttribute("pageTitle",    "Attender-Wise Sales");
    request.setAttribute("pageSubtitle", "Reports — Attender Performance");
    request.setAttribute("pageIcon",     "fa-solid fa-person-chalkboard");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

    <div class="container-fluid mt-3 mst-page">
        <p class="mb-1 text-muted"><strong>Period:</strong> <%= fromDate %> to <%= toDate %> &nbsp;|&nbsp; <strong>Attender:</strong> <%= attenderName %></p>
        <div class="d-flex gap-2 mb-3 no-print">
            <a href="<%=contextPath%>/reports/attenderSales/page.jsp" class="bb bb-outline"><i class="fa-solid fa-arrow-left me-1"></i>Back</a>
            <button class="bb bb-navy" onclick="printReport()"><i class="fa-solid fa-print me-1"></i>Print</button>
            <button class="bb bb-green" onclick="exportTableToExcel('printTable', 'Attender_Sales_Report')"><i class="fa-solid fa-file-excel me-1"></i>Export to Excel</button>
        </div>

        <div class="table-responsive">
            <table id="printTable" class="table mb-0 mst-table">
                <thead>
                    <tr>
                        <th>S.No</th>
                        <th>Bill No</th>
                        <th>Customer Name</th>
                        <th>Total</th>
                        <th>Discount</th>
                        <th>Payable</th>
                        <th>Paid</th>
                        <th>Balance</th>
                        <th>Date</th>
                        <th>Time</th>
                        <th>Attender</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    Vector vec = bill.getAttenderWiseSalesReport(fromDate, toDate, attenderId);
                    double finTotal = 0.0;
                    double finDiscount = 0.0;
                    double finPayable = 0.0; 
                    double finPaid = 0.0;
                    double finBalance = 0.0;
                    
                    for (int i = 0; i < vec.size(); i++) {
                        Vector row = (Vector) vec.elementAt(i);
                        String billNo = row.elementAt(0).toString();
                        double totalAmt = Double.parseDouble(row.elementAt(1).toString());
                        double discount = Double.parseDouble(row.elementAt(2).toString());
                        double payable = Double.parseDouble(row.elementAt(3).toString());
                        double paid = Double.parseDouble(row.elementAt(4).toString());
                        String date = row.elementAt(5).toString();
                        String time = row.elementAt(6).toString();
                        String cusName = row.elementAt(7).toString();
                        double balance = Double.parseDouble(row.elementAt(8).toString());
                        String attender = row.elementAt(9).toString();
                        
                        finTotal += totalAmt;
                        finDiscount += discount;  
                        finPayable += payable;
                        finPaid += paid;
                        finBalance += balance;
                    %>
                    <tr>
                        <td><%=i+1%></td>
                        <td>
                            <a href="<%=contextPath%>/billing/print.jsp?billNo=<%=billNo%>" target="_blank" class="inv-link"><%=billNo%></a>
                        </td>
                        <td><%=cusName%></td>
                        <td><%=String.format("%.2f", totalAmt)%></td>
                        <td><%=String.format("%.2f", discount)%></td>
                        <td><%=String.format("%.2f", payable)%></td>
                        <td><%=String.format("%.2f", paid)%></td>
                        <td><%=String.format("%.2f", balance)%></td>
                        <td><%=date%></td>
                        <td><%=time%></td>
                        <td><%=attender%></td>
                    </tr>
                    <%
                    }
                    %>
                    <tr style="background:var(--bill-bg);font-weight:700">
                        <td colspan="3"><strong>Grand Total</strong></td>
                        <td><strong><%=String.format("%.2f", finTotal)%></strong></td>
                        <td><strong><%=String.format("%.2f", finDiscount)%></strong></td>
                        <td><strong><%=String.format("%.2f", finPayable)%></strong></td>
                        <td><strong><%=String.format("%.2f", finPaid)%></strong></td>
                        <td><strong><%=String.format("%.2f", finBalance)%></strong></td>
                        <td colspan="3"></td>
                    </tr>
                </tbody>
            </table>
        </div>
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
