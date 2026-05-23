<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ page language="java" import="java.util.*" %>
    <%@ page language="java" import="java.util.*,java.text.*" %>
      <jsp:useBean id="bill" class="billing.billingBean" />
      <jsp:useBean id="prod" class="product.productBean" />
      <% 
        String fromDate=request.getParameter("fromDate"); 
        String toDate=request.getParameter("toDate"); 
        Vector vec=prod.getCategoryName(); 
      %>
        <!DOCTYPE html>
        <html lang="en">

        <head>

          <meta charset="UTF-8">
          <title>Sales Report</title>
          <%@ include file="/assets/common/head.jsp" %>
            <style>
              .table td, .table th { vertical-align: middle; }
              @media print {
                @page { margin: 0.3cm; size: portrait; }
                body { margin: 0; padding: 0; }
                .no-print { display: none !important; }
                body * { visibility: hidden; }
                #printArea, #printArea * { visibility: visible; }
                #printArea { position: absolute; left: 0; top: 0; width: 100%; }
                #printArea table { width: 100% !important; font-size: 8px !important; }
                #printArea table th, #printArea table td { padding: 1px 2px !important; font-size: 8px !important; }
              }
            </style>
        </head>

        <body>
          <%@ include file="/assets/navbar/navbar.jsp" %>
<%
    request.setAttribute("pageTitle",    "Day Account");
    request.setAttribute("pageSubtitle", "Reports — Daily Account");
    request.setAttribute("pageIcon",     "fa-solid fa-calendar-day");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

            <div class="container-fluid mt-3 mst-page">
                <div class="d-flex justify-content-between align-items-center mb-3">
                <p class="mb-0 text-muted"><strong>Account Report From:</strong> <%= fromDate %> — <%= toDate %></p>
                <div class="d-flex gap-2 no-print">
                  <a href="<%=contextPath%>/reports/dayAccount/page.jsp" class="bb bb-outline"><i class="fa-solid fa-arrow-left me-1"></i>Back</a>
                  <button class="bb bb-navy" onclick="printReport()"><i class="fa-solid fa-print me-1"></i>Print</button>
                  <button class="bb bb-green" onclick="exportTableToExcel('printTable', 'Day_Account_Report')"><i class="fa-solid fa-file-excel me-1"></i>Export</button>
                </div>
              </div>

              <div class="table-responsive">
              <table id="printTable" class="table mst-table mt-3">
                <thead>
                  <tr style="background:var(--bill-bg);font-weight:700">
                    <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600;">Category Name</th>
                    <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; text-align: right;">Collection</th>
                  </tr>
                </thead>
                <tbody>
                  <% double grandTotal=0; for (int i=0; i < vec.size(); i++) { Vector row=(Vector) vec.get(i); String
                    categoryName=row.get(0).toString(); String categoryId=row.get(1).toString(); int
                    categoryIdInt=Integer.parseInt(categoryId); double
                    salesAmount=bill.getSalesByCategory(categoryIdInt, fromDate, toDate); 
                    grandTotal +=salesAmount; %>
                    <tr>
                      <td>
                        <%= categoryName %>
                      </td>
                      <td><a href="<%=contextPath%>/reports/dayAccount/details.jsp?categoryId=<%=categoryIdInt%>&fromDate=<%=fromDate%>&toDate=<%=toDate%>" class="inv-link">
                          <%= salesAmount %>
                        </a>
                      </td>

                    </tr>
                    <% } %>
                    <tr style="background:var(--bill-bg);font-weight:700">
                      <th class="text-end">Collection Total</th>
                      <th><%= grandTotal %></th>
                    </tr>
              </table>
              </div>
              <table class="table table-bordered table-striped mt-3">
                <thead class="table-dark">
                  <tr>
                    <th>Payment Method</th>
                    <th>Amount</th>

                  </tr>
                </thead>
                <tbody>
                  <% double cashAmount=bill.getSalesCashTotal( fromDate, toDate); double
                    bankAmount=bill.getSalesBankTotal( fromDate, toDate); double
                    balanceAmount=bill.getSalesBalanceTotal( fromDate, toDate); double
                    DiscAmount=bill.getSalesDiscountTotal( fromDate, toDate); double totalPaid=cashAmount +
                    bankAmount+balanceAmount+DiscAmount; %>
                    <tr>
                      <td>Cash</td>
                      <td>
                        <%=cashAmount%>
                      </td>
                    </tr>
                    <tr>
                      <td>Bank</td>
                      <td>
                        <%=bankAmount%>
                      </td>
                    </tr>
                    <tr>
                      <td>Disount</td>
                      <td>
                        <%=DiscAmount%>
                      </td>
                    </tr>
                    <tr>
                      <td>Due</td>
                      <td>
                        <%=balanceAmount%>
                      </td>
                    </tr>
                    <tr>
                      <th class="text-end"> Total</th>
                      <th>
                        <%=totalPaid %>
                      </th>
                    </tr>

                </tbody>
              </table>
              <table class="table mst-table mt-3">
                <thead>
                  <tr>
                    <th>Due Collection</th>
                    <th>Amount</th>

                  </tr>
                </thead>
                <tbody>
                  <% double cashDueAmount=bill.getDueCashTotal( fromDate, toDate); double
                    bankDueAmount=bill.getDueBankTotal( fromDate, toDate); double totalDuePaid=cashDueAmount +
                    bankDueAmount; %>
                    <tr>
                      <td>Cash</td>
                      <td>
                        <%=cashDueAmount%>
                      </td>
                    </tr>
                    <tr>
                      <td>Bank</td>
                      <td>
                        <%=bankDueAmount%>
                      </td>
                    </tr>

                    <tr>
                      <th class="text-end"> Total</th>
                      <th>
                        <%=totalDuePaid %>
                      </th>
                    </tr>

                </tbody>
              </table>
            </div>
            <div class="text-center my-3">
              <div class="mt-3 p-3 mst-card d-inline-block">
                <strong>Total Difference:</strong>
                <%= (grandTotal - totalPaid) %>
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