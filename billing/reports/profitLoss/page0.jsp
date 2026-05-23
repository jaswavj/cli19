<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<%@ page language="java" import="java.util.*,java.text.*"%>
<jsp:useBean id="bill" class="billing.billingBean" />
<jsp:useBean id="prod" class="product.productBean" />
<%
    String fromDate = request.getParameter("fromDate");
    String toDate = request.getParameter("toDate");
    String reportType = request.getParameter("reportType");

    if (reportType == null) {
        reportType = "summary";
    }

    // Get totals
    double totalSales = bill.getTotalSalesByDateRange(fromDate, toDate);
    double totalPurchases = bill.getTotalPurchasesByDateRange(fromDate, toDate);
    
    // Get total expenses from expense_entry table
    double totalExpenses = 0.0;
    try {
        Vector expenseData = prod.getExpenseReport(fromDate, toDate, 0); // 0 = all types
        if (expenseData != null) {
            for (int i = 0; i < expenseData.size(); i++) {
                Vector row = (Vector) expenseData.get(i);
                if (row.size() > 4) {
                    totalExpenses += Double.parseDouble(row.get(4).toString());
                }
            }
        }
    } catch (Exception e) {
        System.err.println("Error loading expenses for P&L: " + e.getMessage());
        e.printStackTrace();
    }

    // Calculate profit/loss
    double grossProfit = totalSales - totalPurchases;
    double netProfit = grossProfit - totalExpenses;

    // Calculate percentages
    double profitMargin = 0.0;
    double expensePercentage = 0.0;
    if (totalSales > 0) {
        profitMargin = (netProfit / totalSales) * 100;
        expensePercentage = (totalExpenses / totalSales) * 100;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Profit & Loss Report</title>
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>
<%
    request.setAttribute("pageTitle",    "Profit & Loss");
    request.setAttribute("pageSubtitle", "Reports — Financial Summary");
    request.setAttribute("pageIcon",     "fa-solid fa-scale-balanced");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

<div class="container-fluid mt-3 mst-page">
    <p class="mb-1 text-muted"><strong>Period:</strong> <%= fromDate %> — <%= toDate %></p>

    <div class="d-flex gap-2 mb-3 no-print">
        <a href="<%=contextPath%>/reports/profitLoss/page.jsp" class="bb bb-outline"><i class="fa-solid fa-arrow-left me-1"></i>Back</a>
        <button class="bb bb-navy" onclick="printReport()"><i class="fa-solid fa-print me-1"></i>Print</button>
        <button class="bb bb-green" onclick="exportTableToExcel()"><i class="fa-solid fa-file-excel me-1"></i>Export</button>
    </div>

    <%
    if ("summary".equals(reportType)) {
    %>
    <!-- Summary Report -->
    <div class="row">
        <div class="col-md-8">
            <div class="table-responsive">
            <table id="profitLossTable" class="table mst-table">
                <thead>
                    <tr>
                        <th>Description</th>
                        <th class="text-end">Amount (₹)</th>
                        <th class="text-end">Percentage</th>
                    </tr>
                </thead>
                <tbody>
                    <tr class="table-primary">
                        <td><strong>Revenue</strong></td>
                        <td class="text-end"><strong><%= String.format("%.3f", totalSales) %></strong></td>
                        <td class="text-end"><strong>100.00%</strong></td>
                    </tr>
                    <tr>
                        <td>&nbsp;&nbsp;&nbsp;&nbsp;Sales</td>
                        <td class="text-end"><%= String.format("%.3f", totalSales) %></td>
                        <td class="text-end">100.00%</td>
                    </tr>

                    <tr class="table-warning">
                        <td><strong>Cost of Goods Sold</strong></td>
                        <td class="text-end"><strong><%= String.format("%.3f", totalPurchases) %></strong></td>
                        <td class="text-end"><strong><%= String.format("%.3f", (totalSales > 0 ? (totalPurchases/totalSales)*100 : 0)) %>%</strong></td>
                    </tr>
                    <tr>
                        <td>&nbsp;&nbsp;&nbsp;&nbsp;Purchases</td>
                        <td class="text-end"><%= String.format("%.3f", totalPurchases) %></td>
                        <td class="text-end"><%= String.format("%.3f", (totalSales > 0 ? (totalPurchases/totalSales)*100 : 0)) %>%</td>
                    </tr>

                    <tr class="<%= grossProfit >= 0 ? "table-success" : "table-danger" %>">
                        <td><strong>Gross Profit/Loss</strong></td>
                        <td class="text-end"><strong><%= String.format("%.3f", grossProfit) %></strong></td>
                        <td class="text-end"><strong><%= String.format("%.3f", profitMargin) %>%</strong></td>
                    </tr>

                    <tr class="table-info">
                        <td><strong>Operating Expenses</strong></td>
                        <td class="text-end"><strong><%= String.format("%.3f", totalExpenses) %></strong></td>
                        <td class="text-end"><strong><%= String.format("%.3f", expensePercentage) %>%</strong></td>
                    </tr>

                    <tr class="<%= netProfit >= 0 ? "table-success" : "table-danger" %>">
                        <td><strong>Net Profit/Loss</strong></td>
                        <td class="text-end"><strong><%= String.format("%.3f", netProfit) %></strong></td>
                        <td class="text-end"><strong><%= String.format("%.3f", profitMargin) %>%</strong></td>
                    </tr>
                </tbody>
            </table>
            </div>
        </div>

        <div class="col-md-4">
            <div class="card mst-card">
                <div class="card-body p-3" style="background:var(--bill-bg);border-top:3px solid var(--bill-navy);">
                    <h6 class="fw-bold mb-2">Profit/Loss Summary</h6>
                    <div class="mb-3">
                        <strong>Total Revenue:</strong><br>
                        <span class="h4" style="color:var(--bill-navy-mid)">₹<%= String.format("%.3f", totalSales) %></span>
                    </div>
                    <div class="mb-3">
                        <strong>Cost of Goods Sold:</strong><br>
                        <span class="h4" style="color:var(--bill-amber)">₹<%= String.format("%.3f", totalPurchases) %></span>
                    </div>
                    <div class="mb-3">
                        <strong>Operating Expenses:</strong><br>
                        <span class="h4" style="color:var(--bill-slate)">₹<%= String.format("%.3f", totalExpenses) %></span>
                    </div>
                    <hr>
                    <div class="mb-3">
                        <strong>Net Result:</strong><br>
                        <span class="h4" style="color:<%= netProfit >= 0 ? "var(--bill-green)" : "var(--bill-red)" %>">
                            <%= netProfit >= 0 ? "Profit" : "Loss" %>: ₹<%= String.format("%.3f", Math.abs(netProfit)) %>
                        </span>
                    </div>
                    <div class="mb-3">
                        <strong>Profit Margin:</strong><br>
                        <span class="h5" style="color:<%= profitMargin >= 0 ? "var(--bill-green)" : "var(--bill-red)" %>">
                            <%= String.format("%.3f", profitMargin) %>%
                        </span>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <%
    } else if ("productwise".equals(reportType)) {
        // Get product-wise profit/loss data
        Vector productWiseData = bill.getProductWiseProfitLoss(fromDate, toDate);
        
        // Debug output
        System.out.println("Product Wise Data Size: " + productWiseData.size());
        for (int i = 0; i < Math.min(productWiseData.size(), 3); i++) {
            Vector row = (Vector) productWiseData.elementAt(i);
            System.out.println("Row " + i + ": " + row.toString());
        }
    %>
    <!-- Product Wise Report -->
    <div class="alert alert-info">
        <strong>Product Wise Profit & Loss Analysis</strong><br>
        Shows profitability for each product sold within the selected date range.
        Cost price is taken from last purchase or batch cost if no purchase found.
    </div>

    <% if (productWiseData.size() == 0) { %>
    <div class="alert alert-warning">
        <strong>No Data Found</strong><br>
        No product sales were found in the selected date range (<%= fromDate %> to <%= toDate %>).
        Please check if there are sales records for this period.
    </div>
    <% } else { %>

    <table id="profitLossTable" class="table mst-table">
        <thead>
            <tr>
                <th>Product Name</th>
                <th class="text-end">Qty Sold</th>
                <th class="text-end">Avg Sale Price (₹)</th>
                <th class="text-end">Cost Price (₹)</th>
                <th class="text-end">Total Sales (₹)</th>
                <th class="text-end">Total Cost (₹)</th>
                <th class="text-end">Profit/Loss (₹)</th>
                <th class="text-end">Margin (%)</th>
            </tr>
        </thead>
        <tbody>
            <%
            double totalProductProfit = 0.0;
            double totalProductSales = 0.0;
            double totalProductCost = 0.0;
            
            for (int i = 0; i < productWiseData.size(); i++) {
                Vector row = (Vector) productWiseData.elementAt(i);
                String productName = (String) row.elementAt(0);
                String qtySold = (String) row.elementAt(1);
                String avgSalePrice = (String) row.elementAt(2);
                String costPrice = (String) row.elementAt(3);
                String productTotalSales = (String) row.elementAt(4);
                String productTotalCost = (String) row.elementAt(5);
                String productProfitLoss = (String) row.elementAt(6);
                String productProfitMargin = (String) row.elementAt(7);
                
                double profit = Double.parseDouble(productProfitLoss);
                double sales = Double.parseDouble(productTotalSales);
                double cost = Double.parseDouble(productTotalCost);
                
                totalProductProfit += profit;
                totalProductSales += sales;
                totalProductCost += cost;
                
                String rowClass = profit >= 0 ? "table-success" : "table-danger";
            %>
            <tr class="<%= rowClass %>">
                <td><strong><%= productName %></strong></td>
                <td class="text-end"><%= qtySold %></td>
                <td class="text-end"><%= avgSalePrice %></td>
                <td class="text-end"><%= costPrice %></td>
                <td class="text-end"><%= productTotalSales %></td>
                <td class="text-end"><%= productTotalCost %></td>
                <td class="text-end"><strong><%= productProfitLoss %></strong></td>
                <td class="text-end"><strong><%= productProfitMargin %>%</strong></td>
            </tr>
            <%
            }
            %>
        </tbody>
        <tfoot style="background:var(--bill-navy);color:#fff">
            <tr>
                <th><strong>TOTAL</strong></th>
                <th class="text-end">-</th>
                <th class="text-end">-</th>
                <th class="text-end">-</th>
                <th class="text-end"><strong><%= String.format("%.3f", totalProductSales) %></strong></th>
                <th class="text-end"><strong><%= String.format("%.3f", totalProductCost) %></strong></th>
                <th class="text-end" style="color:<%= totalProductProfit >= 0 ? "#6ee7b7" : "#fca5a5" %>"><strong><%= String.format("%.3f", totalProductProfit) %></strong></th>
                <th class="text-end" style="color:<%= totalProductProfit >= 0 ? "#6ee7b7" : "#fca5a5" %>"><strong><%= String.format("%.3f", totalProductSales > 0 ? (totalProductProfit/totalProductSales)*100 : 0) %>%</strong></th>
            </tr>
        </tfoot>
    </table>

    <div class="row mt-3">
        <div class="col-md-6">
            <div class="card mst-card">
                <div class="card-body p-3" style="background:var(--bill-bg);border-top:3px solid var(--bill-navy);">
                    <h6 class="fw-bold mb-2">Product Wise Summary</h6>
                    </div>
                    <div class="mb-2">
                        <strong>Total Sales:</strong> ₹<%= String.format("%.3f", totalProductSales) %>
                    </div>
                    <div class="mb-2">
                        <strong>Total Cost:</strong> ₹<%= String.format("%.3f", totalProductCost) %>
                    </div>
                    <hr>
                    <div class="mb-2">
                        <strong>Net <%= totalProductProfit >= 0 ? "Profit" : "Loss" %>:</strong>
                        <span class="h5" style="color:<%= totalProductProfit >= 0 ? "var(--bill-green)" : "var(--bill-red)" %>">
                            ₹<%= String.format("%.3f", Math.abs(totalProductProfit)) %>
                        </span>
                    </div>
                    <div class="mb-2">
                        <strong>Overall Margin:</strong>
                        <span class="h5" style="color:<%= totalProductProfit >= 0 ? "var(--bill-green)" : "var(--bill-red)" %>">
                            <%= String.format("%.3f", totalProductSales > 0 ? (totalProductProfit/totalProductSales)*100 : 0) %>%
                        </span>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <% } %>
    <%
    } else {
    %>
    <!-- Detailed Report -->
    <div class="alert alert-info">
        <strong>Detailed Profit & Loss Report</strong><br>
        Comprehensive breakdown including sales, purchases, operating expenses, and net profit/loss.
    </div>

    <table id="profitLossTable" class="table mst-table">
        <thead>
            <tr>
                <th>Period</th>
                <th class="text-end">Sales (₹)</th>
                <th class="text-end">Purchases (₹)</th>
                <th class="text-end">Gross Profit (₹)</th>
                <th class="text-end">Expenses (₹)</th>
                <th class="text-end">Net Profit (₹)</th>
                <th class="text-end">Net Margin (%)</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td><strong><%= fromDate %> to <%= toDate %></strong></td>
                <td class="text-end"><%= String.format("%.3f", totalSales) %></td>
                <td class="text-end"><%= String.format("%.3f", totalPurchases) %></td>
                <td class="text-end" style="color:<%= grossProfit >= 0 ? "var(--bill-green)" : "var(--bill-gold)" %>"><%= String.format("%.3f", grossProfit) %></td>
                <td class="text-end" style="color:var(--bill-muted)"><%= String.format("%.3f", totalExpenses) %></td>
                <td class="text-end" style="color:<%= netProfit >= 0 ? "var(--bill-green)" : "var(--bill-red)" %>"><strong><%= String.format("%.3f", netProfit) %></strong></td>
                <td class="text-end" style="color:<%= profitMargin >= 0 ? "var(--bill-green)" : "var(--bill-red)" %>"><strong><%= String.format("%.3f", profitMargin) %>%</strong></td>
            </tr>
        </tbody>
        <tfoot style="background:var(--bill-bg);">
            <tr>
                <th>Summary</th>
                <th class="text-end">Revenue</th>
                <th class="text-end">COGS</th>
                <th class="text-end">Gross P/L</th>
                <th class="text-end">Op. Expenses</th>
                <th class="text-end">Net P/L</th>
                <th class="text-end">Margin</th>
            </tr>
        </tfoot>
    </table>
    
    <!-- Expense Breakdown -->
    <%
    Vector expenseDetails = prod.getExpenseReport(fromDate, toDate, 0);
    if (expenseDetails != null && expenseDetails.size() > 0) {
    %>
    <div class="mt-4">
        <h5>Operating Expenses Breakdown</h5>
        <table class="table mst-table table-sm">
            <thead>
                <tr>
                    <th>Date & Time</th>
                    <th>Expense Type</th>
                    <th>Content</th>
                    <th>Description</th>
                    <th class="text-end">Amount (₹)</th>
                </tr>
            </thead>
            <tbody>
                <%
                DecimalFormat df = new DecimalFormat("#,##0.00");
                for (int i = 0; i < expenseDetails.size(); i++) {
                    Vector row = (Vector) expenseDetails.get(i);
                    String expDateTime = row.get(0).toString();
                    String expenseType = row.get(1).toString();
                    String content = row.get(2).toString();
                    String description = row.get(3).toString();
                    double amount = Double.parseDouble(row.get(4).toString());
                %>
                <tr>
                    <td><%= new SimpleDateFormat("dd MMM yyyy HH:mm").format(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").parse(expDateTime)) %></td>
                    <td><span class="badge" style="background:var(--bill-navy-mid);color:#fff"><%= expenseType %></span></td>
                    <td><%= content %></td>
                    <td><%= description.isEmpty() ? "-" : description %></td>
                    <td class="text-end" style="color:var(--bill-red)">₹ <%= df.format(amount) %></td>
                </tr>
                <%
                }
                %>
            </tbody>
            <tfoot style="background:var(--bill-bg);">
                <tr>
                    <th colspan="4" class="text-end">Total Operating Expenses:</th>
                    <th class="text-end text-danger">₹ <%= String.format("%.3f", totalExpenses) %></th>
                </tr>
            </tfoot>
        </table>
    </div>
    <% } else { %>
    <div class="alert alert-secondary mt-3">
        <i class="fas fa-info-circle"></i> No operating expenses recorded for this period.
    </div>
    <% } %>
    <%
    }
    %>
</div>

<style>
@media print {
    @page { size: portrait; margin: 0.3cm; }
    body * { visibility: hidden; }
    #printArea, #printArea * { visibility: visible; }
    #printArea { position: absolute; left: 0; top: 0; width: 100%; }
    .no-print { display: none !important; }
    body { font-size: 8px; padding: 0; margin: 0; }
    table { font-size: 8px; width: 100%; border-collapse: collapse; }
    th, td { padding: 1px 2px; word-wrap: break-word; max-width: 80px; }
}
</style>

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
        })
        .catch(err => console.error('Print header error:', err));
}

function exportTableToExcel() {
    const table = document.getElementById('profitLossTable');
    const html = '<html xmlns:x="urn:schemas-microsoft-com:office:excel"><head><meta charset="UTF-8"><style>th,td{border:1px solid #000;padding:4px}</style></head><body>' + table.outerHTML + '</body></html>';
    const blob = new Blob(['\ufeff', html], {type: 'application/vnd.ms-excel'});
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = 'Profit_Loss_Report.xls';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(a.href);
}
</script>

</body>
</html>