<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, javax.servlet.http.*" %>
<jsp:useBean id="prod" class="product.productBean" />
<%
Integer uid = (Integer) session.getAttribute("userId");
if (uid == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
}
Vector categories = prod.getCategoryName();
Vector brands = prod.getBrandsName();
String today = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sales Statistics</title>
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        .stat-card {
            border-radius: 8px;
            padding: 1rem 1.2rem;
            text-align: center;
            color: #fff;
            transition: transform 0.18s ease, box-shadow 0.18s ease;
        }
        .stat-card:hover { transform: translateY(-3px); box-shadow: 0 6px 16px rgba(0,0,0,0.18); }
        .stat-value { font-size: 1.45rem; font-weight: 700; margin: 6px 0 2px; }
        .stat-label { font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.6px; opacity: 0.88; }
        .stat-card-navy  { background: var(--bill-navy); }
        .stat-card-gold  { background: var(--bill-gold); }
        .stat-card-green { background: var(--bill-green); }
        .stat-card-mid   { background: var(--bill-navy-mid); }
    </style>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>
<%
    request.setAttribute("pageTitle",    "Sales Statistics");
    request.setAttribute("pageSubtitle", "Reports \u2014 Sales Analysis");
    request.setAttribute("pageIcon",     "fa-solid fa-chart-line");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

<div class="container-fluid mt-3 mst-page">

    <!-- Filters -->
    <div class="mst-filter-card mb-3">
        <h6 class="mb-3" style="color:var(--bill-navy);font-weight:700;"><i class="fas fa-filter me-1"></i>Statistics Filters</h6>
        <div class="row g-3">
            <div class="col-md-3">
                <div class="input-outline">
                    <label>From Date</label>
                    <input type="date" id="fromDate" class="form-control" value="<%=today%>">
                </div>
            </div>
            <div class="col-md-3">
                <div class="input-outline">
                    <label>To Date</label>
                    <input type="date" id="toDate" class="form-control" value="<%=today%>">
                </div>
            </div>
            <div class="col-md-2">
                <div class="input-outline">
                    <label>Category</label>
                    <select id="categoryId" class="form-select" onchange="loadBrandsByCategory()">
                        <option value="">All Categories</option>
                        <%
                        if (categories != null) {
                            for (int i = 0; i < categories.size(); i++) {
                                Vector row = (Vector) categories.elementAt(i);
                        %>
                        <option value="<%=row.get(1)%>"><%=row.get(0)%></option>
                        <% }} %>
                    </select>
                </div>
            </div>
            <div class="col-md-2">
                <div class="input-outline">
                    <label>Brand</label>
                    <select id="brandId" class="form-select" onchange="loadProductsByFilters()">
                        <option value="">All Brands</option>
                        <%
                        if (brands != null) {
                            for (int i = 0; i < brands.size(); i++) {
                                Vector row = (Vector) brands.elementAt(i);
                        %>
                        <option value="<%=row.get(1)%>"><%=row.get(0)%></option>
                        <% }} %>
                    </select>
                </div>
            </div>
            <div class="col-md-2">
                <div class="input-outline">
                    <label>Product</label>
                    <select id="productId" class="form-select">
                        <option value="">All Products</option>
                    </select>
                </div>
            </div>
        </div>
        <div class="d-flex gap-2 mt-3">
            <button class="bb bb-primary" onclick="loadStatistics()">
                <i class="fas fa-search"></i> Generate Report
            </button>
            <button class="bb bb-outline" onclick="resetFilters()">
                <i class="fas fa-redo"></i> Reset
            </button>
        </div>
    </div>

    <!-- Statistics Cards -->
    <div class="row g-3 mb-3" id="statsCards">
        <div class="col-6 col-md-3">
            <div class="stat-card stat-card-navy">
                <i class="fas fa-receipt fa-lg mb-1"></i>
                <div class="stat-label">Total Bills</div>
                <div class="stat-value" id="totalBills">0</div>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="stat-card stat-card-gold">
                <i class="fas fa-rupee-sign fa-lg mb-1"></i>
                <div class="stat-label">Total Sales</div>
                <div class="stat-value" id="totalSales">&#8377;0</div>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="stat-card stat-card-green">
                <i class="fas fa-boxes fa-lg mb-1"></i>
                <div class="stat-label">Total Quantity</div>
                <div class="stat-value" id="totalQty">0</div>
            </div>
        </div>
        <div class="col-6 col-md-3">
            <div class="stat-card stat-card-mid">
                <i class="fas fa-chart-bar fa-lg mb-1"></i>
                <div class="stat-label">Avg Bill Value</div>
                <div class="stat-value" id="avgBill">&#8377;0</div>
            </div>
        </div>
    </div>

    <!-- Detailed Table -->
    <div class="mst-filter-card">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h6 class="mb-0" style="color:var(--bill-navy);font-weight:700;"><i class="fas fa-table me-1"></i>Detailed Report</h6>
            <span class="badge" style="background:var(--bill-navy);" id="recordCount">0 records</span>
        </div>
        <div class="table-responsive">
            <table class="table mb-0 mst-table" id="detailsTable">
                <thead>
                    <tr>
                        <th>Bill No</th>
                        <th>Date</th>
                        <th>Product</th>
                        <th>Category</th>
                        <th>Brand</th>
                        <th class="text-end">Qty</th>
                        <th class="text-end">Price (&#8377;)</th>
                        <th class="text-end">Discount (&#8377;)</th>
                        <th class="text-end">Total (&#8377;)</th>
                    </tr>
                </thead>
                <tbody id="detailsBody">
                    <tr>
                        <td colspan="9" class="text-center text-muted py-4">No data available. Please select filters and generate report.</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>

</div>

<script>
    const contextPath = '<%=contextPath%>';

    $(document).ready(function() {
        loadProductsByFilters();
        loadStatistics();
    });

    function loadBrandsByCategory() {
        const categoryId = $('#categoryId').val();
        if (!categoryId) {
            $('#brandId').val('');
            loadProductsByFilters();
            return;
        }
        $.get(contextPath + '/product/master/getBrandsByCategory.jsp', { categoryId: categoryId }, function(data) {
            $('#brandId').html('<option value="">All Brands</option>' + data);
            loadProductsByFilters();
        });
    }

    function loadProductsByFilters() {
        const categoryId = $('#categoryId').val();
        const brandId = $('#brandId').val();
        $.get(contextPath + '/reports/statistics/getProducts.jsp', {
            categoryId: categoryId,
            brandId: brandId
        }, function(data) {
            $('#productId').html('<option value="">All Products</option>' + data);
        });
    }

    function loadStatistics() {
        const fromDate = $('#fromDate').val();
        const toDate = $('#toDate').val();
        const categoryId = $('#categoryId').val();
        const brandId = $('#brandId').val();
        const productId = $('#productId').val();

        if (!fromDate || !toDate) {
            alert('Please select date range');
            return;
        }

        $('#statsCards').css('opacity', '0.5');
        $('#detailsBody').html('<tr><td colspan="9" class="text-center py-3"><div class="spinner-border spinner-border-sm" role="status"></div> Loading...</td></tr>');

        $.ajax({
            url: contextPath + '/reports/statistics/getData.jsp',
            type: 'GET',
            dataType: 'json',
            data: { fromDate, toDate, categoryId, brandId, productId },
            success: function(data) {
                $('#statsCards').css('opacity', '1');
                updateStatistics(data);
            },
            error: function(xhr, status, error) {
                $('#statsCards').css('opacity', '1');
                console.error('Error:', error, xhr.responseText);
                alert('Error loading statistics: ' + error);
            }
        });
    }

    function updateStatistics(data) {
        $('#totalBills').text(data.totalBills || 0);
        $('#totalSales').text('₹' + (data.totalSales || 0).toLocaleString('en-IN', {minimumFractionDigits: 2, maximumFractionDigits: 2}));
        $('#totalQty').text((data.totalQty || 0).toLocaleString('en-IN', {minimumFractionDigits: 2, maximumFractionDigits: 2}));
        $('#avgBill').text('₹' + (data.avgBill || 0).toLocaleString('en-IN', {minimumFractionDigits: 2, maximumFractionDigits: 2}));

        let html = '';
        let recordCount = 0;
        if (data.details && data.details.length > 0) {
            recordCount = data.details.length;
            data.details.forEach(function(row) {
                html += '<tr>';
                html += '<td>' + row.billNo + '</td>';
                html += '<td>' + row.date + '</td>';
                html += '<td>' + row.productName + '</td>';
                html += '<td>' + row.categoryName + '</td>';
                html += '<td>' + row.brandName + '</td>';
                html += '<td class="text-end">' + parseFloat(row.qty).toFixed(2) + '</td>';
                html += '<td class="text-end">&#8377;' + parseFloat(row.price).toFixed(2) + '</td>';
                html += '<td class="text-end">&#8377;' + parseFloat(row.disc).toFixed(2) + '</td>';
                html += '<td class="text-end">&#8377;' + parseFloat(row.total).toFixed(2) + '</td>';
                html += '</tr>';
            });
        } else {
            html = '<tr><td colspan="9" class="text-center py-4 text-muted"><i class="fas fa-inbox fs-5 d-block mb-1"></i>No data found for selected filters</td></tr>';
        }
        $('#detailsBody').html(html);
        $('#recordCount').text(recordCount + ' record' + (recordCount !== 1 ? 's' : ''));
    }

    function resetFilters() {
        const today = new Date().toISOString().split('T')[0];
        $('#fromDate').val(today);
        $('#toDate').val(today);
        $('#categoryId').val('');
        $('#brandId').val('');
        $('#productId').html('<option value="">All Products</option>');
        loadStatistics();
    }
</script>
</body>
</html>
