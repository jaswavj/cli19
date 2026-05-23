<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<jsp:useBean id="op1" class="billing.billingBean" />
<jsp:useBean id="prod" class="product.productBean" />
<%
// ── Selected period from GET params (default = current month/year) ──────────
java.util.Calendar nowCal = java.util.Calendar.getInstance();
int curYear  = nowCal.get(java.util.Calendar.YEAR);
int curMonth = nowCal.get(java.util.Calendar.MONTH) + 1; // 1-based

String selYearParam  = request.getParameter("selYear");
String selMonthParam = request.getParameter("selMonth");
int selYear  = (selYearParam  != null && !selYearParam.isEmpty())  ? Integer.parseInt(selYearParam)  : curYear;
int selMonth = (selMonthParam != null && !selMonthParam.isEmpty()) ? Integer.parseInt(selMonthParam) : curMonth;
// clamp
if (selMonth < 1) selMonth = 1;
if (selMonth > 12) selMonth = 12;

// Selected month date range
java.util.Calendar selCal = java.util.Calendar.getInstance();
selCal.set(selYear, selMonth - 1, 1);
String selMonthStart = String.format("%04d-%02d-01", selYear, selMonth);
selCal.set(java.util.Calendar.DAY_OF_MONTH, selCal.getActualMaximum(java.util.Calendar.DAY_OF_MONTH));
String selMonthEnd = new java.text.SimpleDateFormat("yyyy-MM-dd").format(selCal.getTime());

// Previous month date range
java.util.Calendar prevCal = java.util.Calendar.getInstance();
prevCal.set(selYear, selMonth - 1, 1);
prevCal.add(java.util.Calendar.MONTH, -1);
prevCal.set(java.util.Calendar.DAY_OF_MONTH, 1);
String prevMonthStart = new java.text.SimpleDateFormat("yyyy-MM-dd").format(prevCal.getTime());
prevCal.set(java.util.Calendar.DAY_OF_MONTH, prevCal.getActualMaximum(java.util.Calendar.DAY_OF_MONTH));
String prevMonthEnd = new java.text.SimpleDateFormat("yyyy-MM-dd").format(prevCal.getTime());

// Display label for selected period
String[] MONTH_NAMES = {"","January","February","March","April","May","June","July","August","September","October","November","December"};
String selPeriodLabel = MONTH_NAMES[selMonth] + " " + selYear;

///////////////////  Sales  /////////////////
double thisSale  = op1.getTotalSalesByDateRange(selMonthStart, selMonthEnd);
double lastSale  = op1.getTotalSalesByDateRange(prevMonthStart, prevMonthEnd);
double saleMargin = thisSale - lastSale;
double saleMarginPercent = 0;
if (lastSale != 0) saleMarginPercent = (saleMargin / lastSale) * 100;
String saleColor = (saleMarginPercent >= 0) ? "green" : "red";

//////////////////  Purchase  /////////////////
double thisPurchase  = op1.getTotalPurchasesByDateRange(selMonthStart, selMonthEnd);
double lastPurchase  = op1.getTotalPurchasesByDateRange(prevMonthStart, prevMonthEnd);
double purchaseMargin = thisPurchase - lastPurchase;
double purchaseMarginPercent = 0;
if (lastPurchase != 0) purchaseMarginPercent = (purchaseMargin / lastPurchase) * 100;
String PurchaseColor = (purchaseMarginPercent >= 0) ? "green" : "red";

///////////////////  Today's Sales  /////////////////
double todaySales    = op1.getTodaySales();
int    todayBillCount = op1.getTodayBillCount();

///////////////////  Profit  /////////////////
Vector thisMonthProfitData = op1.getProfitAnalysisReport(selMonthStart, selMonthEnd);
double thisProfit = 0.0;
for (int i = 0; i < thisMonthProfitData.size(); i++) {
    Vector row = (Vector) thisMonthProfitData.elementAt(i);
    double totalCost = Double.parseDouble(row.elementAt(4).toString());
    double saleTotal = Double.parseDouble(row.elementAt(5).toString());
    if (totalCost > 0) thisProfit += (saleTotal - totalCost);
}

Vector lastMonthProfitData = op1.getProfitAnalysisReport(prevMonthStart, prevMonthEnd);
double lastProfit = 0.0;
for (int i = 0; i < lastMonthProfitData.size(); i++) {
    Vector row = (Vector) lastMonthProfitData.elementAt(i);
    double totalCost = Double.parseDouble(row.elementAt(4).toString());
    double saleTotal = Double.parseDouble(row.elementAt(5).toString());
    if (totalCost > 0) lastProfit += (saleTotal - totalCost);
}

double profitMargin = thisProfit - lastProfit;
double profitMarginPercent = 0;
if (lastProfit != 0) profitMarginPercent = (profitMargin / lastProfit) * 100;
String profitColor = (profitMarginPercent >= 0) ? "green" : "red";

///////////////////  Expenses  /////////////////
double thisExpense = 0.0;
try {
    Vector thisMonthExpenses = prod.getExpenseReport(selMonthStart, selMonthEnd, 0);
    if (thisMonthExpenses != null) {
        for (int i = 0; i < thisMonthExpenses.size(); i++) {
            Vector row = (Vector) thisMonthExpenses.get(i);
            if (row.size() > 4) thisExpense += Double.parseDouble(row.get(4).toString());
        }
    }
} catch (Exception e) { System.err.println("Error loading expenses: " + e.getMessage()); }

double lastExpense = 0.0;
try {
    Vector lastMonthExpenses = prod.getExpenseReport(prevMonthStart, prevMonthEnd, 0);
    if (lastMonthExpenses != null) {
        for (int i = 0; i < lastMonthExpenses.size(); i++) {
            Vector row = (Vector) lastMonthExpenses.get(i);
            if (row.size() > 4) lastExpense += Double.parseDouble(row.get(4).toString());
        }
    }
} catch (Exception e) { System.err.println("Error loading last expenses: " + e.getMessage()); }

double expenseMargin = thisExpense - lastExpense;
double expenseMarginPercent = 0;
if (lastExpense != 0) expenseMarginPercent = (expenseMargin / lastExpense) * 100;
String expenseColor = (expenseMarginPercent >= 0) ? "red" : "green";

double netProfitWithExpenses = thisProfit - thisExpense;

// Get today's date label
java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd-MMM-yyyy");
String todayDate = sdf.format(new java.util.Date());

/////////////////////  Chart Data — selected month daily breakdown  //////////////////
Vector vec = op1.getDailySalesForMonth(selYear, selMonth);
StringBuilder labels      = new StringBuilder();
StringBuilder salesData   = new StringBuilder();
for (int i = 0; i < vec.size(); i++) {
    Vector row  = (Vector) vec.elementAt(i);
    labels.append("\"").append(row.elementAt(0)).append("\"");
    salesData.append(row.elementAt(1).toString().isEmpty() ? "0" : row.elementAt(1));
    if (i < vec.size() - 1) { labels.append(", "); salesData.append(", "); }
}

Vector vecPurchase = op1.getDailyPurchaseForMonth(selYear, selMonth);
StringBuilder purchaseData = new StringBuilder();
for (int i = 0; i < vecPurchase.size(); i++) {
    Vector row = (Vector) vecPurchase.elementAt(i);
    purchaseData.append(row.elementAt(1).toString().isEmpty() ? "0" : row.elementAt(1));
    if (i < vecPurchase.size() - 1) purchaseData.append(", ");
}

/////////////////////  Top Customers and Suppliers  //////////////////
Vector<Vector> topCustomers         = op1.getTopCustomersByDateRange(selMonthStart, selMonthEnd);
Vector<Vector> topSuppliers         = op1.getTopSuppliersByDateRange(selMonthStart, selMonthEnd);
Vector<Vector> outstandingCustomers = op1.getOutstandingCustomers();
Vector<Vector> outstandingSuppliers = op1.getOutstandingSuppliers();

// Build year options (current year back 5 years, forward 1 year)
int yearMin = curYear - 4;
int yearMax = curYear + 1;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Executive Dashboard</title>
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        .dashboard-card {
            border: none;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(15,27,53,0.07);
            transition: transform 0.2s, box-shadow 0.2s;
            overflow: hidden;
            background: var(--bill-card);
        }
        .dashboard-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 6px 20px rgba(15,27,53,0.13);
        }
        .card-icon {
            position: absolute;
            right: 16px;
            top: 50%;
            transform: translateY(-50%);
            font-size: 2.5rem;
            opacity: 0.12;
        }
        .trend-up   { color: var(--bill-green); font-size: 0.9rem; font-weight: 600; }
        .trend-down { color: var(--bill-red);   font-size: 0.9rem; font-weight: 600; }
        .period-filter select.fg-inp { padding: 0.3rem 0.6rem; font-size: 0.85rem; }
        .period-filter .bb { padding: 0.32rem 0.9rem; font-size: 0.85rem; }
        .chart-container {
            background: var(--bill-card);
            border-radius: 12px;
            padding: 18px 20px;
            border: 1px solid var(--bill-border);
            box-shadow: 0 2px 8px rgba(15,27,53,0.05);
            height: 100%;
        }
        .chart-container h5 { color: var(--bill-navy); font-size: 0.92rem; margin-bottom: 0; }
        .chart-wrapper    { position: relative; height: 260px; width: 100%; }
        .chart-wrapper-sm { position: relative; height: 200px; width: 100%; }
        .dash-badge { display:inline-block; padding:2px 10px; border-radius:20px; font-size:0.78rem; font-weight:600; color:#fff; background: var(--bill-navy); }
    </style>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>
<%
    request.setAttribute("pageTitle",    "Dashboard");
    request.setAttribute("pageSubtitle", "Business Overview — " + selPeriodLabel);
    request.setAttribute("pageIcon",     "fa-solid fa-gauge-high");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

    <div class="container-fluid mt-3 mst-page">

        <!-- Period Filter Bar -->
        <form method="get" id="periodForm" class="d-flex align-items-center gap-3 mb-4 p-3 mst-card" style="flex-wrap:wrap;">
            <span class="fw-semibold" style="color:var(--bill-navy);"><i class="fa-solid fa-calendar-days me-2"></i>Select Period</span>
            <div class="d-flex align-items-center gap-2">
                <label class="fw-semibold" style="font-size:0.85rem;">Year</label>
                <select name="selYear" class="form-select fg-inp" style="width:100px;" onchange="document.getElementById('periodForm').submit()">
                    <% for (int y = yearMax; y >= yearMin; y--) { %>
                    <option value="<%= y %>" <%= (y == selYear ? "selected" : "") %>><%= y %></option>
                    <% } %>
                </select>
            </div>
            <div class="d-flex align-items-center gap-2">
                <label class="fw-semibold" style="font-size:0.85rem;">Month</label>
                <select name="selMonth" class="form-select fg-inp" style="width:130px;" onchange="document.getElementById('periodForm').submit()">
                    <% for (int m = 1; m <= 12; m++) { %>
                    <option value="<%= m %>" <%= (m == selMonth ? "selected" : "") %>><%= MONTH_NAMES[m] %></option>
                    <% } %>
                </select>
            </div>
            <button type="submit" class="bb bb-primary"><i class="fa-solid fa-rotate me-1"></i>Load</button>
            <% if (selYear != curYear || selMonth != curMonth) { %>
            <a href="page.jsp" class="bb bb-outline"><i class="fa-solid fa-house me-1"></i>Current Month</a>
            <% } %>
            <span class="ms-auto text-muted" style="font-size:0.82rem;">Showing data for <strong style="color:var(--bill-navy);"><%= selPeriodLabel %></strong></span>
        </form>

        <!-- Summary Cards -->
        <div class="row g-4 mb-4">
            <!-- Today's Sales Card -->
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6">
                <div class="card dashboard-card h-100 border-start border-4 border-danger">
                    <div class="card-body position-relative" style="padding: 0.75rem;">
                        <h6 class="text-muted text-uppercase fw-bold mb-1" style="font-size: 0.7rem;">Today's Sales</h6>
                        <p class="text-muted mb-2" style="font-size: 0.65rem; margin-top: -2px;">(<%= todayDate %>)</p>
                        <h4 class="fw-bold text-dark mb-2" style="font-size: 1.1rem;">&#8377; <%= String.format("%,.2f", todaySales) %></h4>
                        <div class="d-flex align-items-center">
                            <span class="text-muted" style="font-size: 0.7rem;"><i class="fas fa-receipt me-1"></i> <%= todayBillCount %> Bills</span>
                        </div>
                        <i class="fas fa-calendar-day card-icon text-danger" style="font-size: 2.5rem;"></i>
                    </div>
                </div>
            </div>
            
            <!-- Sales Card -->
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6">
                <div class="card dashboard-card h-100 border-start border-4 border-primary">
                    <div class="card-body position-relative" style="padding: 0.75rem;">
                        <h6 class="text-muted text-uppercase fw-bold mb-2" style="font-size: 0.7rem;">Total Sales (<%= selPeriodLabel %>)</h6>
                        <h4 class="fw-bold text-dark mb-2" style="font-size: 1.1rem;">&#8377; <%= String.format("%,.2f", thisSale) %></h4>
                        <div class="d-flex align-items-center">
                            <span class="<%= saleMarginPercent >= 0 ? "trend-up" : "trend-down" %> me-1" style="font-size: 0.7rem;">
                                <i class="fas <%= saleMarginPercent >= 0 ? "fa-arrow-up" : "fa-arrow-down" %>"></i> 
                                <%= String.format("%.1f", Math.abs(saleMarginPercent)) %>%
                            </span>
                            <span class="text-muted" style="font-size: 0.65rem;">vs last month</span>
                        </div>
                        <i class="fa-solid fa-chart-line card-icon" style="color: var(--bill-gold);"></i>
                    </div>
                </div>
            </div>

            <!-- Purchase Card -->
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6">
                <div class="card dashboard-card h-100 border-start border-4 border-success">
                    <div class="card-body position-relative" style="padding: 0.75rem;">
                        <h6 class="text-muted text-uppercase fw-bold mb-2" style="font-size: 0.7rem;">Total Purchase (<%= selPeriodLabel %>)</h6>
                        <h4 class="fw-bold text-dark mb-2" style="font-size: 1.1rem;">&#8377; <%= String.format("%,.2f", thisPurchase) %></h4>
                        <div class="d-flex align-items-center">
                            <span class="<%= purchaseMarginPercent >= 0 ? "trend-up" : "trend-down" %> me-1" style="font-size: 0.7rem;">
                                <i class="fas <%= purchaseMarginPercent >= 0 ? "fa-arrow-up" : "fa-arrow-down" %>"></i> 
                                <%= String.format("%.1f", Math.abs(purchaseMarginPercent)) %>%
                            </span>
                            <span class="text-muted" style="font-size: 0.65rem;">vs last month</span>
                        </div>
                        <i class="fa-solid fa-cart-shopping card-icon" style="color: var(--bill-green);"></i>
                    </div>
                </div>
            </div>

            <!-- Net Margin Card (Calculated) -->
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6">
                <div class="card dashboard-card h-100 border-start border-4 border-info">
                    <div class="card-body position-relative" style="padding: 0.75rem;">
                        <h6 class="text-muted text-uppercase fw-bold mb-2" style="font-size: 0.7rem;">Net Difference</h6>
                        <h4 class="fw-bold text-dark mb-2" style="font-size: 1.1rem;">&#8377; <%= String.format("%,.2f", thisSale - thisPurchase) %></h4>
                        <div class="d-flex align-items-center">
                            <span class="text-muted" style="font-size: 0.65rem;">Sales - Purchase</span>
                        </div>
                        <i class="fa-solid fa-wallet card-icon" style="color: var(--bill-navy);"></i>
                    </div>
                </div>
            </div>
            
             <!-- Last Month Sales Card -->
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6">
                <div class="card dashboard-card h-100 border-start border-4 border-warning">
                    <div class="card-body position-relative" style="padding: 0.75rem;">
                        <h6 class="text-muted text-uppercase fw-bold mb-2" style="font-size: 0.7rem;">Previous Month Sales</h6>
                        <h4 class="fw-bold text-dark mb-2" style="font-size: 1.1rem;">&#8377; <%= String.format("%,.2f", lastSale) %></h4>
                        <div class="d-flex align-items-center">
                             <span class="text-muted" style="font-size: 0.65rem;"><%= MONTH_NAMES[selMonth == 1 ? 12 : selMonth - 1] %> <%= selMonth == 1 ? selYear - 1 : selYear %></span>
                        </div>
                        <i class="fa-solid fa-clock-rotate-left card-icon" style="color: var(--bill-gold);"></i>
                    </div>
                </div>
            </div>
            
            <!-- Profit Card -->
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6">
                <div class="card dashboard-card h-100 border-start border-4 border-success">
                    <div class="card-body position-relative" style="padding: 0.75rem;">
                        <h6 class="text-muted text-uppercase fw-bold mb-2" style="font-size: 0.7rem;">Gross Profit (<%= selPeriodLabel %>)</h6>
                        <h4 class="fw-bold text-dark mb-2" style="font-size: 1.1rem;">&#8377; <%= String.format("%,.2f", thisProfit) %></h4>
                        <div class="d-flex align-items-center">
                            <span class="<%= profitMarginPercent >= 0 ? "trend-up" : "trend-down" %> me-1" style="font-size: 0.7rem;">
                                <i class="fas <%= profitMarginPercent >= 0 ? "fa-arrow-up" : "fa-arrow-down" %>"></i> 
                                <%= String.format("%.1f", Math.abs(profitMarginPercent)) %>%
                            </span>
                            <span class="text-muted" style="font-size: 0.65rem;">vs last month</span>
                        </div>
                        <i class="fa-solid fa-chart-pie card-icon" style="color: var(--bill-green);"></i>
                    </div>
                </div>
            </div>
            
            <!-- Expenses Card -->
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6">
                <div class="card dashboard-card h-100 border-start border-4" style="border-color: var(--bill-navy) !important;">
                    <div class="card-body position-relative" style="padding: 0.75rem;">
                        <h6 class="text-muted text-uppercase fw-bold mb-2" style="font-size: 0.7rem;">Expenses (<%= selPeriodLabel %>)</h6>
                        <h4 class="fw-bold text-dark mb-2" style="font-size: 1.1rem;">&#8377; <%= String.format("%,.2f", thisExpense) %></h4>
                        <div class="d-flex align-items-center">
                            <span class="<%= expenseMarginPercent < 0 ? "trend-up" : "trend-down" %> me-1" style="font-size: 0.7rem;">
                                <i class="fas <%= expenseMarginPercent >= 0 ? "fa-arrow-up" : "fa-arrow-down" %>"></i> 
                                <%= String.format("%.1f", Math.abs(expenseMarginPercent)) %>%
                            </span>
                            <span class="text-muted" style="font-size: 0.65rem;">vs last month</span>
                        </div>
                        <i class="fas fa-receipt card-icon" style="color: var(--bill-navy);"></i>
                    </div>
                </div>
            </div>
            
            <!-- Net Profit Card -->
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6">
                <div class="card dashboard-card h-100 border-start border-4 <%= netProfitWithExpenses >= 0 ? "border-success" : "border-danger" %>">
                    <div class="card-body position-relative" style="padding: 0.75rem;">
                        <h6 class="text-muted text-uppercase fw-bold mb-2" style="font-size: 0.7rem;">Net Profit (<%= selPeriodLabel %>)</h6>
                        <h4 class="fw-bold mb-2" style="font-size: 1.1rem; color: <%= netProfitWithExpenses >= 0 ? "var(--bill-green)" : "var(--bill-red)" %>;">&#8377; <%= String.format("%,.2f", netProfitWithExpenses) %></h4>
                        <div class="d-flex align-items-center">
                            <span class="text-muted" style="font-size: 0.65rem;">After Expenses</span>
                        </div>
                        <i class="fa-solid fa-coins card-icon" style="color: <%= netProfitWithExpenses >= 0 ? "var(--bill-green)" : "var(--bill-red)" %>;"></i>
                    </div>
                </div>
            </div>
        </div>

        <!-- Charts Section -->
        <div class="row g-4">
            <!-- Main Combined Chart -->
            <div class="col-lg-8">
                <div class="chart-container">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="fw-bold">Financial Overview <small class="text-muted fw-normal" style="font-size:0.8rem;">(<%= selPeriodLabel %> — Daily)</small></h5>
                        <span class="dash-badge"><i class="fa-solid fa-calendar-days me-1"></i>Daily</span>
                    </div>
                    <div class="chart-wrapper">
                        <canvas id="combinedChart"></canvas>
                    </div>
                </div>
            </div>

            <!-- Distribution / Pie Chart (Placeholder or derived data) -->
            <!-- Since we don't have category data here, let's use the Purchase vs Sales comparison bar chart -->
            <div class="col-lg-4">
                <div class="chart-container">
                    <h5 class="fw-bold mb-3">Sales vs Purchase <small class="text-muted">(<%= selPeriodLabel %>)</small></h5>
                    <div class="chart-wrapper">
                        <canvas id="comparisonChart"></canvas>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Detailed Graphs Row -->
        <div class="row g-4 mt-1">
             <div class="col-md-6">
                <div class="chart-container">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="fw-bold">Sales Trend</h5>
                        <button id="downloadMargin" class="bb bb-outline" style="padding:3px 12px;font-size:0.8rem;"><i class="fa-solid fa-download"></i> Save</button>
                    </div>
                    <div class="chart-wrapper-sm">
                        <canvas id="marginChart"></canvas>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="chart-container">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="fw-bold">Purchase Trend</h5>
                        <button id="downloadPurchase" class="bb bb-outline" style="padding:3px 12px;font-size:0.8rem;"><i class="fa-solid fa-download"></i> Save</button>
                    </div>
                    <div class="chart-wrapper-sm">
                        <canvas id="purchaseChart"></canvas>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Customer & Supplier Dashboards -->
        <div class="row g-4 mt-1">
            <!-- Top Customers by Sales -->
            <div class="col-lg-6">
                <div class="chart-container">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="fw-bold"><i class="fa-solid fa-users me-2" style="color:var(--bill-navy);"></i>Top Customers (<%= selPeriodLabel %>)</h5>
                    </div>
                    <div class="table-responsive">
                        <table class="table mb-0 mst-table">
                            <thead>
                                <tr>
                                    <th style="width: 5%;">#</th>
                                    <th>Customer Name</th>
                                    <th class="text-end">Total Sales</th>
                                    <th class="text-center">Bills</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (topCustomers.size() == 0) { %>
                                    <tr><td colspan="4" class="text-center text-muted">No data available</td></tr>
                                <% } else {
                                    for (int i = 0; i < topCustomers.size(); i++) {
                                        Vector row = topCustomers.get(i);
                                        String name = (String) row.get(0);
                                        double sales = (Double) row.get(1);
                                        int billCount = (Integer) row.get(2);
                                %>
                                    <tr>
                                        <td><%= i + 1 %></td>
                                        <td><strong><%= name %></strong></td>
                                        <td class="text-end fw-bold" style="color:var(--bill-navy);">&#8377; <%= String.format("%,.2f", sales) %></td>
                                        <td class="text-center"><span class="dash-badge"><%= billCount %></span></td>
                                    </tr>
                                <% } } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            
            <!-- Top Suppliers by Purchase -->
            <div class="col-lg-6">
                <div class="chart-container">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="fw-bold"><i class="fa-solid fa-truck me-2" style="color:var(--bill-green);"></i>Top Suppliers (<%= selPeriodLabel %>)</h5>
                    </div>
                    <div class="table-responsive">
                        <table class="table mb-0 mst-table">
                            <thead>
                                <tr>
                                    <th style="width: 5%;">#</th>
                                    <th>Supplier Name</th>
                                    <th class="text-end">Total Purchase</th>
                                    <th class="text-center">Orders</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (topSuppliers.size() == 0) { %>
                                    <tr><td colspan="4" class="text-center text-muted">No data available</td></tr>
                                <% } else {
                                    for (int i = 0; i < topSuppliers.size(); i++) {
                                        Vector row = topSuppliers.get(i);
                                        String name = (String) row.get(0);
                                        double purchase = (Double) row.get(1);
                                        int orderCount = (Integer) row.get(2);
                                %>
                                    <tr>
                                        <td><%= i + 1 %></td>
                                        <td><strong><%= name %></strong></td>
                                        <td class="text-end fw-bold" style="color:var(--bill-green);">&#8377; <%= String.format("%,.2f", purchase) %></td>
                                        <td class="text-center"><span class="dash-badge"><%= orderCount %></span></td>
                                    </tr>
                                <% } } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Outstanding Balances -->
        <div class="row g-4 mt-1">
            <!-- Outstanding Customer Balances -->
            <div class="col-lg-6">
                <div class="chart-container">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="fw-bold"><i class="fa-solid fa-money-bill-wave me-2" style="color:var(--bill-gold);"></i>Top Outstanding Customers</h5>
                    </div>
                    <div class="table-responsive">
                        <table class="table mb-0 mst-table">
                            <thead>
                                <tr>
                                    <th style="width: 5%;">#</th>
                                    <th>Customer Name</th>
                                    <th class="text-end">Outstanding Amount</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (outstandingCustomers.size() == 0) { %>
                                    <tr><td colspan="3" class="text-center text-muted">No outstanding balances</td></tr>
                                <% } else {
                                    for (int i = 0; i < outstandingCustomers.size(); i++) {
                                        Vector row = outstandingCustomers.get(i);
                                        String name = (String) row.get(0);
                                        double outstanding = (Double) row.get(1);
                                        double pending = (Double) row.get(2);
                                %>
                                    <tr>
                                        <td><%= i + 1 %></td>
                                        <td><strong><%= name %></strong></td>
                                        
                                        <td class="text-end fw-bold" style="color:var(--bill-gold);">&#8377; <%= String.format("%,.2f", pending) %></td>
                                    </tr>
                                <% } } %>
                            </tbody>
                            <% if (outstandingCustomers.size() > 0) {
                                double totalOutstanding = 0;
                                for (Vector row : outstandingCustomers) {
                                    totalOutstanding += (Double) row.get(1);
                                }
                            %>
                            <tfoot>
                                <tr style="background:var(--bill-bg); font-weight:700;">
                                    <th colspan="2" class="text-end">Total (Top 5):</th>
                                    <th class="text-end" style="color:var(--bill-red);">&#8377; <%= String.format("%,.2f", totalOutstanding) %></th>
                                </tr>
                            </tfoot>
                            <% } %>
                        </table>
                    </div>
                </div>
            </div>
            
            <!-- Outstanding Supplier Balances -->
            <div class="col-lg-6">
                <div class="chart-container">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="fw-bold"><i class="fa-solid fa-file-invoice-dollar me-2" style="color:var(--bill-red);"></i>Top Outstanding Suppliers</h5>
                    </div>
                    <div class="table-responsive">
                        <table class="table mb-0 mst-table">
                            <thead>
                                <tr>
                                    <th style="width: 5%;">#</th>
                                    <th>Supplier Name</th>
                                    <th class="text-end">Outstanding Amount</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (outstandingSuppliers.size() == 0) { %>
                                    <tr><td colspan="3" class="text-center text-muted">No outstanding balances</td></tr>
                                <% } else {
                                    for (int i = 0; i < outstandingSuppliers.size(); i++) {
                                        Vector row = outstandingSuppliers.get(i);
                                        String name = (String) row.get(0);
                                        double outstanding = (Double) row.get(1);
                                %>
                                    <tr>
                                        <td><%= i + 1 %></td>
                                        <td><strong><%= name %></strong></td>
                                        <td class="text-end fw-bold" style="color:var(--bill-red);">&#8377; <%= String.format("%,.2f", outstanding) %></td>
                                    </tr>
                                <% } } %>
                            </tbody>
                            <% if (outstandingSuppliers.size() > 0) {
                                double totalOutstanding = 0;
                                for (Vector row : outstandingSuppliers) {
                                    totalOutstanding += (Double) row.get(1);
                                }
                            %>
                            <tfoot>
                                <tr style="background:var(--bill-bg); font-weight:700;">
                                    <th colspan="2" class="text-end">Total (Top 5):</th>
                                    <th class="text-end" style="color:var(--bill-red);">&#8377; <%= String.format("%,.2f", totalOutstanding) %></th>
                                </tr>
                            </tfoot>
                            <% } %>
                        </table>
                    </div>
                </div>
            </div>
        </div>

    </div>

    <script>
        // Data from Server — selected period: <%= selPeriodLabel %>
        const labels       = [<%= labels.toString() %>];
        const salesData    = [<%= salesData.toString() %>];
        const purchaseData = [<%= purchaseData.toString() %>];

        // Totals for doughnut
        const totalSalesMonth    = <%= thisSale %>;
        const totalPurchaseMonth = <%= thisPurchase %>;

        // Helper: gradient fill
        function makeGradient(ctx, top, bottom) {
            const grad = ctx.createLinearGradient(0, 0, 0, 300);
            grad.addColorStop(0, top);
            grad.addColorStop(1, bottom);
            return grad;
        }

        // Common Chart Options
        const commonOptions = {
            responsive: true,
            maintainAspectRatio: false,
            animation: { duration: 800, easing: 'easeInOutQuart' },
            plugins: {
                legend: {
                    position: 'top',
                    labels: { color: '#0f172a', font: { size: 12, weight: '600' }, boxWidth: 12, padding: 16 }
                },
                tooltip: {
                    mode: 'index',
                    intersect: false,
                    backgroundColor: 'rgba(15,27,53,0.92)',
                    titleColor: '#c9a227',
                    bodyColor: '#e2e8f0',
                    padding: 12,
                    cornerRadius: 8,
                    callbacks: {
                        label: function(ctx) {
                            return ' ₹' + parseFloat(ctx.parsed.y).toLocaleString('en-IN', {minimumFractionDigits: 2, maximumFractionDigits: 2});
                        }
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    grid: { color: 'rgba(209,217,230,0.5)', drawBorder: false },
                    ticks: { color: '#64748b', callback: function(v) { return '₹' + v.toLocaleString('en-IN'); } }
                },
                x: {
                    grid: { display: false },
                    ticks: { color: '#64748b' }
                }
            },
            interaction: { mode: 'nearest', axis: 'x', intersect: false }
        };

        // 1. Combined Chart — area + bar with gradient fill
        const combinedCtx = document.getElementById('combinedChart').getContext('2d');
        new Chart(combinedCtx, {
            data: {
                labels: labels,
                datasets: [
                    {
                        type: 'line',
                        label: 'Sales',
                        data: salesData,
                        borderColor: '#c9a227',
                        backgroundColor: makeGradient(combinedCtx, 'rgba(201,162,39,0.35)', 'rgba(201,162,39,0.01)'),
                        borderWidth: 2.5,
                        fill: true,
                        tension: 0.42,
                        pointRadius: 4,
                        pointBackgroundColor: '#c9a227',
                        pointBorderColor: '#fff',
                        pointBorderWidth: 1.5,
                        pointHoverRadius: 7,
                        order: 1
                    },
                    {
                        type: 'bar',
                        label: 'Purchase',
                        data: purchaseData,
                        backgroundColor: 'rgba(26,37,64,0.70)',
                        borderColor: '#1a2540',
                        borderWidth: 0,
                        borderRadius: 5,
                        barPercentage: 0.5,
                        order: 2
                    }
                ]
            },
            options: {
                ...commonOptions,
                plugins: {
                    ...commonOptions.plugins,
                    annotation: {},
                    title: { display: false }
                }
            }
        });

        // 2. Comparison Chart — doughnut with net-profit arc
        new Chart(document.getElementById('comparisonChart'), {
            type: 'doughnut',
            data: {
                labels: ['Total Sales', 'Total Purchase', 'Net Profit'],
                datasets: [{
                    data: [
                        totalSalesMonth,
                        totalPurchaseMonth,
                        Math.max(0, totalSalesMonth - totalPurchaseMonth)
                    ],
                    backgroundColor: ['#c9a227', '#1a2540', '#059669'],
                    borderColor: ['#c9a227', '#1a2540', '#059669'],
                    borderWidth: 2,
                    hoverOffset: 12
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                animation: { animateRotate: true, duration: 900 },
                plugins: {
                    legend: { position: 'bottom', labels: { color: '#0f172a', font: { size: 11 }, padding: 12, boxWidth: 12 } },
                    tooltip: {
                        backgroundColor: 'rgba(15,27,53,0.92)',
                        titleColor: '#c9a227',
                        bodyColor: '#e2e8f0',
                        callbacks: {
                            label: function(ctx) {
                                const total = ctx.dataset.data.reduce((a,b)=>a+b,0);
                                const pct   = total > 0 ? ((ctx.parsed / total)*100).toFixed(1) : 0;
                                return ' ₹' + ctx.parsed.toLocaleString('en-IN',{minimumFractionDigits:2,maximumFractionDigits:2}) + '  (' + pct + '%)';
                            }
                        }
                    }
                },
                cutout: '65%'
            }
        });

        // 3. Detailed Sales Chart — gradient bar
        const marginCtx = document.getElementById('marginChart').getContext('2d');
        const marginChart = new Chart(marginCtx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Daily Sales',
                    data: salesData,
                    backgroundColor: makeGradient(marginCtx, 'rgba(201,162,39,0.9)', 'rgba(201,162,39,0.4)'),
                    borderColor: '#c9a227',
                    borderWidth: 0,
                    borderRadius: 6,
                    borderSkipped: false,
                    barPercentage: 0.65
                }]
            },
            options: {
                ...commonOptions,
                plugins: {
                    ...commonOptions.plugins,
                    legend: { display: false }
                }
            }
        });

        // 4. Detailed Purchase Chart — gradient bar
        const purchaseCtx = document.getElementById('purchaseChart').getContext('2d');
        const purchaseChart = new Chart(purchaseCtx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Daily Purchase',
                    data: purchaseData,
                    backgroundColor: makeGradient(purchaseCtx, 'rgba(26,37,64,0.88)', 'rgba(26,37,64,0.35)'),
                    borderColor: '#1a2540',
                    borderWidth: 0,
                    borderRadius: 6,
                    borderSkipped: false,
                    barPercentage: 0.65
                }]
            },
            options: {
                ...commonOptions,
                plugins: {
                    ...commonOptions.plugins,
                    legend: { display: false }
                }
            }
        });

        // Download Handlers
        document.getElementById('downloadMargin').addEventListener('click', function() {
            const link = document.createElement('a');
            link.download = 'sales_<%= selYear %>_<%= selMonth %>.png';
            link.href = marginChart.toBase64Image();
            link.click();
        });

        document.getElementById('downloadPurchase').addEventListener('click', function() {
            const link = document.createElement('a');
            link.download = 'purchase_<%= selYear %>_<%= selMonth %>.png';
            link.href = purchaseChart.toBase64Image();
            link.click();
        });
    </script>
</body>
</html>
