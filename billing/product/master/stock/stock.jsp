<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<%@ page errorPage="" %>
<jsp:useBean id="prod" class="product.productBean" />
<%
// Session check
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>STOCK - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    <!-- Bootstrap CSS -->
    <%@ include file="/assets/common/head.jsp" %>

    <style>
        .table td, .table th { vertical-align: middle; }
    </style>

    <script>
$(function () {
    $("#catName").autocomplete({
        source: function (request, response) {
            $.ajax({
                url: "auto_complet.jsp",
                type: "GET",
                data: { productSearch: request.term },
                success: function (data) {
                    response($.parseJSON(data));
                    
                }
            });
        },
        minLength: 2,
        select: function (event, ui) {
            // ui.item.label = name, ui.item.value = id
            $("#catName").val(ui.item.label);
            $("#catId").val(ui.item.value); 
            return false;
        }
    });
});

$(document).ready(function(){
    // Click row to select product
    window.selectProduct = function(el) {
        document.getElementById('catId').value = el.getAttribute('data-id');
        document.getElementById('catName').value = el.getAttribute('data-name');
        document.getElementById('stockSearchForm').submit();
    };

    // Product search functionality
    document.getElementById('searchInput').addEventListener('input', function() {
        const searchTerm = this.value.toLowerCase();
        const tableRows = document.querySelectorAll('#productTable tbody tr');
        
        tableRows.forEach(row => {
            // Skip the "no products found" row
            if (row.cells.length === 1 && row.cells[0].colSpan === 5) {
                return;
            }
            
            const productName = row.cells[1].textContent.toLowerCase();
            const productCode = row.cells[2].textContent.toLowerCase();
            const category = row.cells[3].textContent.toLowerCase();
            const brand = row.cells[4].textContent.toLowerCase();
            
            if (productName.includes(searchTerm) || 
                productCode.includes(searchTerm) || 
                category.includes(searchTerm) || 
                brand.includes(searchTerm)) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        });
    });
});
</script>


</head>
<body>

    <%@ include file="/assets/navbar/navbar.jsp" %>
    <!-- Top Navbar -->
<%
    request.setAttribute("pageTitle",    "Stock");
    request.setAttribute("pageSubtitle", "Product Master — Stock Management");
    request.setAttribute("pageIcon",     "fa-solid fa-warehouse");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />


    <div class="container-fluid mt-2 mst-page" style="max-width: 1400px;">
        <div class="row g-2">
            <!-- Product List -->
            <div class="col-md-12">
                <form id="stockSearchForm" action="<%=contextPath%>/product/master/stock/stock1.jsp" method="post" style="display:none;">
                    <input type="hidden" id="catId" name="catId">
                    <input type="hidden" id="catName" name="catName">
                </form>
                <div class="card" style="border: none; box-shadow: 0 2px 4px rgba(0,0,0,.07); border-radius: 8px;">
                    <div class="mst-card-header-light">
                        <div class="d-flex justify-content-between align-items-center">
                            <h6 class="mb-0" style="font-size: 0.95rem;"><i class="fas fa-list me-2"></i><%=head3%> List</h6>
                            <div class="input-group" style="width: 300px;">
                                <span class="input-group-text"><i class="fas fa-search"></i></span>
                                <input type="text" id="searchInput" class="form-control mst-search-input" placeholder="Search products...">
                            </div>
                        </div>
                    </div>
                    <div class="card-body" style="padding: 0; max-height: 600px; overflow-y: auto; overflow-x: auto;">
                        <div class="table-responsive">
                        <table id="productTable" class="table table-hover mb-0 mst-table" style="table-layout: fixed; width: 100%; min-width: 600px;">
                            <thead>
                                <tr>
                                    <th style="width: 5%;">#</th>
                                    <th style="width: 25%;"><i class="fas fa-box me-1"></i>Name</th>
                                    <th style="width: 15%;">Code</th>
                                    <th style="width: 15%;"><%=head1%></th>
                                    <th style="width: 15%;"><%=head2%></th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                try {
                                    Vector productList = prod.getAllProductsReverse();
                                    if (productList != null && productList.size() > 0) {
                                        for (int i = 0; i < productList.size(); i++) {
                                            Vector row = (Vector) productList.get(i);
                                            if (row != null && row.size() > 4) {
                                                String productName = row.elementAt(0).toString();
                                                String categoryName = row.elementAt(1).toString();
                                                String brandName = row.elementAt(2).toString();
                                                int productId = Integer.parseInt(row.elementAt(3).toString());
                                                String prodCode = row.elementAt(4).toString();
                                                String safeProductName = productName.replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;").replace(">", "&gt;");
                                %>
                                <tr style="cursor: pointer;" data-id="<%=productId%>" data-name="<%=safeProductName%>" onclick="selectProduct(this)">
                                    <td style="width: 5%;"><%=i+1%></td>
                                    <td style="font-weight: 500; width: 25%; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="<%=productName%>"><%=productName%></td>
                                    <td style="width: 15%;"><%=prodCode%></td>
                                    <td style="width: 15%;"><%=categoryName%></td>
                                    <td style="width: 15%;"><%=brandName%></td>
                                </tr>
                                <%
                                            }
                                        }
                                    } else {
                                %>
                                <tr>
                                    <td colspan="5" class="text-center" style="padding: 2rem; color: #718096; font-size: 0.85rem;">
                                        <i class="fas fa-inbox fa-3x mb-3" style="opacity: 0.3;"></i>
                                        <p class="mb-0">No products found.</p>
                                    </td>
                                </tr>
                                <%
                                    }
                                } catch (Exception e) {
                                    out.println("<tr><td colspan='5' class='text-center text-danger' style='font-size: 0.85rem;'>Error loading products: " + e.getMessage() + "</td></tr>");
                                    e.printStackTrace();
                                }
                                %>
                            </tbody>
                        </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <!-- Bootstrap JS -->
</body>
</html>
