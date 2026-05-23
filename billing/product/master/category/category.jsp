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
    <title>Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- Bootstrap CSS -->
    <%@ include file="/assets/common/head.jsp" %>

    <style>
        .table td, .table th { vertical-align: middle; }
        .btn-edit, .btn-delete { margin: 0 2px; }
    </style>
    
</head>
<body>
<%
String msg = request.getParameter("msg");
String type = request.getParameter("type"); // success / danger / warning
%>

<% if (msg != null) { %>
<div class="alert alert-<%= (type != null ? type : "info") %> alert-dismissible fade show mt-3" role="alert">
  <%= msg %>
  <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
</div>
<% } %>

    <%@ include file="/assets/navbar/navbar.jsp" %>
    <!-- Top Navbar -->
<%
    request.setAttribute("pageTitle",    "Categories");
    request.setAttribute("pageSubtitle", "Product Master — Categories");
    request.setAttribute("pageIcon",     "fa-solid fa-layer-group");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />


    <div class="container-fluid mt-2 mst-page" style="max-width: 1400px;">
        <div class="row g-2">
            <!-- Left Column - Add Category Form -->
            <div class="col-md-7">
                <div class="card" style="border: none; box-shadow: 0 2px 4px rgba(0,0,0,.07); border-radius: 8px; height: 100%;">
                    <div class="mst-card-header">
                        <h6 class="mb-0" style="font-size: 0.95rem;"><i class="fas fa-plus-circle me-2"></i>Add New <%=head1%></h6>
                    </div>
                    <div class="card-body" style="padding: 1rem;">
                        <form action="<%=contextPath%>/product/master/category/category1.jsp" method="post">
                            <div class="mb-3">
                                <div class="input-outline">
                                    <input type="text" name="catName" class="form-control" placeholder="" required>
                                    <label><%=head1%> Name</label>
                                </div>
                            </div>
                            
                            <button type="submit" class="bb bb-primary w-100">
                                <i class="fas fa-save me-1"></i>Add <%=head1%>
                            </button>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Right Column - Category List Table -->
            <div class="col-md-5">
                <div class="card" style="border: none; box-shadow: 0 2px 4px rgba(0,0,0,.07); border-radius: 8px;">
                    <div class="mst-card-header-light">
                        <h6 class="mb-0" style="font-size: 0.95rem;"><i class="fas fa-list me-2"></i><%=head1%> List</h6>
                    </div>
                    <div class="card-body" style="padding: 0;">

                <table class="table table-hover mb-0 mst-table">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th><i class="fas fa-tag me-1"></i>Name</th>
                            <th style="text-align: center;"><i class="fas fa-cog me-1"></i>Actions</th>
                        </tr>
                    </thead>
                    <tbody>

                        <%
                        try {
                            Vector vec = prod.getCategoryName();
                            if (vec != null && vec.size() > 0) {
                                for (int i = 0; i < vec.size(); i++) {
                                    Vector vec1 = (Vector) vec.get(i); // inner vector (row)
                                    if (vec1 == null || vec1.elementAt(0) == null || vec1.elementAt(1) == null) {
                                        continue; // Skip null entries
                                    }
                                    String categoryName = vec1.elementAt(0).toString();
                                    int categoryId = Integer.parseInt(vec1.elementAt(1).toString());
                        %>
                        <tr>
                            <td><%=i+1%></td>
                            <td style="font-weight: 500;"><%=categoryName%></td>
                            <td style="text-align: center;">
                                <button onclick="openEditModal('<%=categoryName.replace("'", "\\'")%>', <%=categoryId%>)" class="btn btn-sm btn-outline-violet">
                                    <i class="fas fa-edit me-1"></i>Edit
                                </button>
                            </td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="3" class="text-center" style="padding: 2rem;">
                                <i class="fas fa-inbox fa-3x mb-3" style="opacity: 0.3;"></i>
                                <p class="mb-0">No categories found. Add your first category above.</p>
                            </td>
                        </tr>
                        <%
                            }
                        } catch (Exception e) {
                            out.println("<tr><td colspan='3' class='text-center text-danger'>Error loading categories: " + e.getMessage() + "</td></tr>");
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

    <!-- Edit Category Modal -->
    <div class="modal fade" id="editModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content" style="border-radius: 8px; border: none; box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15);">
                <div class="modal-header mst-card-header">
                    <h6 class="modal-title mb-0" style="font-size: 0.95rem;"><i class="fas fa-edit me-2"></i>Edit <%=head1%></h6>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body" style="padding: 1.25rem;">
                    <form id="editForm" action="<%=contextPath%>/product/master/category/editCategory1.jsp" method="post">
                        <input type="hidden" name="categoryId" id="editCategoryId">
                        
                        <div class="mb-2">
                            <label class="form-label" style="font-size: 0.85rem; margin-bottom: 0.3rem;">Current Name</label>
                            <input type="text" id="currentName" class="form-control" disabled>
                        </div>
                        
                        <div class="mb-2">
                            <div class="input-outline">
                                <input type="text" name="newCategory" id="editCategoryName" class="form-control" placeholder="" required>
                                <label>New <%=head1%> Name</label>
                            </div>
                        </div>
                        
                        <div class="mb-2">
                            <div class="form-check" style="padding: 8px; background: #fff5f5; border-radius: 6px; border-left: 3px solid #f56565;">
                                <input class="form-check-input" type="checkbox" name="block" value="block" id="editBlock">
                                <label class="form-check-label" for="editBlock" style="color: #c53030; font-weight: 500; font-size: 0.85rem;">
                                    <i class="fas fa-exclamation-triangle me-1"></i>Block this <%=head1.toLowerCase()%>
                                </label>
                            </div>
                            <small class="text-muted" style="display: block; margin-top: 4px; font-size: 0.75rem;">Blocking will make this category unavailable for selection</small>
                        </div>
                        
                        <div class="d-flex gap-2 justify-content-end">
                            <button type="button" class="bb bb-outline" data-bs-dismiss="modal">
                                <i class="fas fa-times me-1"></i>Cancel
                            </button>
                            <button type="submit" class="bb bb-primary">
                                <i class="fas fa-save me-1"></i>Update
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script>
        function openEditModal(categoryName, categoryId) {
            document.getElementById('currentName').value = categoryName;
            document.getElementById('editCategoryName').value = categoryName;
            document.getElementById('editCategoryId').value = categoryId;
            document.getElementById('editBlock').checked = false;
            
            var editModal = new bootstrap.Modal(document.getElementById('editModal'));
            editModal.show();
            
            // Focus on new name input after modal opens
            setTimeout(() => {
                document.getElementById('editCategoryName').focus();
            }, 500);
        }
    </script>

</body>
</html>
