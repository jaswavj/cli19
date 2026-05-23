<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*" %>
<%@ page language="java" import="java.util.*,java.text.*" %>
<jsp:useBean id="prod" class="product.productBean" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Current Stock Report</title>
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        @media print {
            @page { margin: 0.3cm; size: portrait; }
            body { margin: 0; padding: 0; }
            .no-print { display: none !important; }
            body * { visibility: hidden; }
            #printArea, #printArea * { visibility: visible; }
            #printArea { position: absolute; left: 0; top: 0; width: 100%; margin: 0; padding: 0; }
            #printArea .container { max-width: 100% !important; margin: 0 !important; padding: 0 5px !important; }
            #printArea .table-responsive { overflow: visible !important; }
            #printArea table { width: 100% !important; font-size: 8px !important; }
            #printArea table th, #printArea table td { padding: 1px 2px !important; font-size: 8px !important; word-wrap: break-word; max-width: 80px; }
        }
    </style>
</head>
<body>
    <!--%@ include file="../menu/reportMenu.jsp" %-->
    <%@ include file="/assets/navbar/navbar.jsp" %>
<%
    request.setAttribute("pageTitle",    "Current Stock");
    request.setAttribute("pageSubtitle", "Reports — Stock on Hand");
    request.setAttribute("pageIcon",     "fa-solid fa-warehouse");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

<div class="container-fluid mt-3 mst-page">

    <!-- Filters -->
    <div class="mb-3 no-print row g-2">
        <div class="col-md-3">
            <select id="categoryFilter" class="form-select form-select-sm" onchange="filterByCategory()">
                <option value="">All Categories</option>
                <%
                Vector categories = prod.getCategoryName();
                for(int i = 0; i < categories.size(); i++) {
                    Vector cat = (Vector) categories.elementAt(i);
                    String catName = cat.elementAt(0).toString();
                    String catId = cat.elementAt(1).toString();
                %>
                <option value="<%=catId%>"><%=catName%></option>
                <%
                }
                %>
            </select>
        </div>
        <div class="col-md-9 text-end">
            <a href="<%=contextPath%>/reports/currentStock/page.jsp" class="bb bb-outline me-2"><i class="fa-solid fa-arrow-left"></i> Back</a>
            <button class="bb bb-navy" onclick="printReport()"><i class="fa-solid fa-print"></i> Print</button>
            <button class="bb bb-green" onclick="exportTableToExcel('stockTable', 'Stock_Report')"><i class="fa-solid fa-file-excel"></i> Export</button>
        </div>
    </div>


    <div class="table-responsive">
<table id="stockTable" class="table mb-0 mst-table">
        <thead>
            <tr>
                <th class="text-center">S.No</th>
                <th>Product</th>
                <th>Code</th>
                <th class="text-center">Stock</th>
                <th class="text-end">Cost</th>
                <th class="text-end">MRP</th>
                <th class="text-end">Total Cost</th>
                <th class="text-end">Total MRP</th>
                <th class="text-end">Discount</th>
            </tr>
        </thead>
        <tbody>
            <%
            Vector vec = prod.getCurrentStockDetailsWithCategory();
            double totalCost = 0.0;
            double totalMRP = 0.0;
            
            if (vec.size() == 0) {
            %>
            <tr>
                <td colspan="9" class="text-center text-muted">
                    <strong>No stock data found.</strong><br>
                    There are no products with current stock available.
                </td>
            </tr>
            <%
            } else {
            
            for(int i=0;i< vec.size();i++) {
                Vector row = (Vector)vec.elementAt(i);
                
                // Get stock, cost, and MRP values
                double stock = Double.parseDouble(row.elementAt(2).toString());
                double cost = Double.parseDouble(row.elementAt(3).toString().replace(",", ""));
                double mrp = Double.parseDouble(row.elementAt(4).toString().replace(",", ""));
                
                // Calculate total cost and MRP per item
                double itemTotalCost = stock * cost;
                double itemTotalMRP = stock * mrp;
                
                // Add to grand totals
                totalCost += itemTotalCost;
                totalMRP += itemTotalMRP;
                
                // Get category_id and category_name
                String categoryId = row.elementAt(10) != null ? row.elementAt(10).toString() : "";
                String categoryName = row.elementAt(11) != null ? row.elementAt(11).toString() : "";
            %>
            <tr class="stock-row" data-category="<%=categoryId%>">
                <td class="text-center"><%=i+1%></td>
                <td>
                    <%=row.elementAt(0)%>
                    <% if (!categoryName.isEmpty()) { %>
                        <br><small class="text-muted"><%=categoryName%></small>
                    <% } %>
                </td>
                <td><%=row.elementAt(1)%></td>
                <td class="text-center"><%=row.elementAt(2)%> <%=(row.size() > 12 && row.elementAt(12) != null && !row.elementAt(12).toString().isEmpty()) ? row.elementAt(12) : (row.size() > 9 && row.elementAt(9) != null ? row.elementAt(9) : "")%></td>
                <td class="text-end"><%=row.elementAt(3)%></td>
                <td class="text-end"><%=row.elementAt(4)%></td>
                <td class="text-end"><%=String.format("%.3f", itemTotalCost)%></td>
                <td class="text-end"><%=String.format("%.3f", itemTotalMRP)%></td>
                <td class="text-end"><%=row.elementAt(5)%></td>
            </tr>
            <%
            }
            }
            %>
            <tr id="totalRow" style="background: var(--bill-bg); font-weight: 700;">
                <td colspan="6" class="text-end">Total Value:</td>
                <td class="text-end">&#8377;<%=String.format("%.3f", totalCost)%></td>
                <td class="text-end">&#8377;<%=String.format("%.3f", totalMRP)%></td>
                <td></td>
            </tr>
        </tbody>
    </table>
    </div>
</div>

<script>
    function filterByCategory() {
        const selectedCategory = document.getElementById('categoryFilter').value;
        const rows = document.querySelectorAll('.stock-row');
        let visibleCost = 0.0;
        let visibleMRP = 0.0;
        let visibleCount = 0;
        
        rows.forEach((row, index) => {
            const rowCategory = row.getAttribute('data-category');
            
            if (selectedCategory === '' || rowCategory === selectedCategory) {
                row.style.display = '';
                // Recalculate totals for visible rows
                const costCell = row.cells[6].textContent;
                const mrpCell = row.cells[7].textContent;
                visibleCost += parseFloat(costCell.replace(/,/g, ''));
                visibleMRP += parseFloat(mrpCell.replace(/,/g, ''));
                visibleCount++;
                // Update serial number
                row.cells[0].textContent = visibleCount;
            } else {
                row.style.display = 'none';
            }
        });
        
        // Update total row
        updateTotalRow(visibleCost, visibleMRP);
    }
    
    // Update the total row values
    function updateTotalRow(totalCost, totalMRP) {
        const totalRow = document.getElementById('totalRow');
        if (totalRow) {
            totalRow.cells[1].innerHTML = '&#8377;' + totalCost.toFixed(3);
            totalRow.cells[2].innerHTML = '&#8377;' + totalMRP.toFixed(3);
        }
    }
</script>

<script>
function printReport() {
    var printArea = document.createElement('div');
    printArea.id = 'printArea';
    
    fetch('<%=contextPath%>/printHeader.jsp')
        .then(response => response.text())
        .then(headerHtml => {
            printArea.innerHTML = headerHtml;
            
            var tableContainer = document.querySelector('.container');
            var tableClone = tableContainer.cloneNode(true);
            
            var buttons = tableClone.querySelector('.no-print');
            if(buttons) buttons.remove();
            
            printArea.appendChild(tableClone);
            
            document.body.appendChild(printArea);
            window.print();
            
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
    
    var tableClone = table.cloneNode(true);
    
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
