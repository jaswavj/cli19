<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<jsp:useBean id="prod" class="product.productBean" />
<%

%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Supplier - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    <!-- Bootstrap CSS -->
    <%@ include file="/assets/common/head.jsp" %>

    <style>
        .table td, .table th { vertical-align: middle; }
        .btn-edit, .btn-delete { margin: 0 2px; }
    </style>
    
</head>
<body onload="document.form.opregInput.focus();">

    <%@ include file="/assets/navbar/navbar.jsp" %>
    <!-- Top Navbar -->
<%
    request.setAttribute("pageTitle",    "Suppliers");
    request.setAttribute("pageSubtitle", "Product Master — Suppliers");
    request.setAttribute("pageIcon",     "fa-solid fa-truck");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />
<%
String msg  = request.getParameter("msg");
String type = request.getParameter("type");
%>

<% if (msg != null) { %>
<div class="alert alert-<%= (type != null ? type : "info") %> alert-dismissible fade show mt-3" role="alert">
  <%= msg %>
  <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
</div>
<% } %>


    <div class="container mt-4 mst-page">
        
        <!-- Add Category Form -->
        <div class="card mb-4">
            <div class="card-body">
                <form action="<%=contextPath%>/product/master/supplier/page1.jsp" method="post" class="row g-3">
                    <div class="col-md-6 input-outline">
                        <input type="text" name="supName" class="form-control" placeholder="" required><label >Supplier Name</label>
                    </div>
                    <div class="col-md-6 input-outline">
                        <input type="number" name="supPhn" class="form-control" placeholder="" ><label >Phone Number</label>
                    </div>
                    <div class="col-md-6 input-outline">
                        <textarea name="supDesc" placeholder="Address"></textarea>
                    </div>
                    <div class="col-md-6">
                        <div class="form-check mb-2">
                            <input class="form-check-input" type="checkbox" id="isGst" name="isGst" onchange="toggleGstin()">
                            <label class="form-check-label" for="isGst">
                                GST Registered
                            </label>
                        </div>
                        <div class="input-outline">
                            <input type="text" name="gstin" id="gstin" class="form-control" placeholder="" maxlength="15" disabled><label>GSTIN <span class="text-danger" id="gstinRequired" style="display:none;">*</span></label>
                            <small id="gstinError" class="text-danger" style="display:none;">GSTIN must be exactly 15 characters</small>
                        </div>
                    </div>
                    
                    <div class="col-md-12">
                <button type="submit" class="bb bb-primary">Add Supplier</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Product List Table -->
        
        <div class="card">
            <div class="card-body">
                <h5 class="mb-3">Supplier List</h5>
                
                <div class="table-responsive">
                <table class="table table-hover mb-0 mst-table" style="min-width: 700px;">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Name</th>
                            <th>Phone Number</th>
                            <th>GST Status</th>
                            <th>GSTIN</th>
                            <th>Description</th>
                            <th>Functions</th>
                        </tr>
                    </thead>
                    <tbody>

                        <%
                            
                            Vector vec = prod.getSupplierDetails();
                            for (int i = 0; i < vec.size(); i++) {
                                Vector vec1 = (Vector) vec.get(i); // inner vector (row)
                                String Name =vec1.elementAt(0).toString();
                                int id			= Integer.parseInt(vec1.elementAt(1).toString());
                                String desc =vec1.elementAt(2).toString();
                                String phn =vec1.elementAt(3).toString();
                                String gstin =vec1.elementAt(4).toString();
                                int isGst = Integer.parseInt(vec1.elementAt(5).toString());


                        %>
                        <tr>
                            <td><%=i+1%></td>
                            <td><%=Name%></td>
                            <td><%=vec1.elementAt(3)%></td>
                            <td>
                                <% if (isGst == 1) { %>
                                    <span class="badge bg-success">Registered</span>
                                <% } else { %>
                                    <span class="badge bg-secondary">Not Registered</span>
                                <% } %>
                            </td>
                            <td><%=gstin%></td>
                            <td><%=vec1.elementAt(2)%></td>
                            <td>
                                <a href="<%=contextPath%>/product/master/supplier/edit.jsp?Name=<%=Name%>&id=<%=id%>&desc=<%=desc%>&phn=<%=phn%>&gstin=<%=gstin%>&isGst=<%=isGst%>" class="btn btn-sm btn-outline-warning btn-edit">Edit</a>
                                 
                            </td>
                        </tr>
                        <%
                    }
                        %>
                        <%-- Dynamic rows will come here --%>
                    </tbody>
                </div>
                </table>
            </div>
        </div>
    </div>
</div>
    <!-- Bootstrap JS -->
<script>
  // Toggle GSTIN field based on GST checkbox
  function toggleGstin() {
    var isGstChecked = document.getElementById('isGst').checked;
    var gstinField = document.getElementById('gstin');
    var gstinRequired = document.getElementById('gstinRequired');
    var gstinError = document.getElementById('gstinError');
    
    if (isGstChecked) {
      gstinField.disabled = false;
      gstinField.required = true;
      gstinRequired.style.display = 'inline';
      gstinField.focus();
    } else {
      gstinField.disabled = true;
      gstinField.required = false;
      gstinField.value = '';
      gstinRequired.style.display = 'none';
      gstinError.style.display = 'none';
      gstinField.style.borderColor = '';
    }
  }
  
  // Real-time GSTIN validation
  document.addEventListener('DOMContentLoaded', function() {
    var gstinField = document.getElementById('gstin');
    var gstinError = document.getElementById('gstinError');
    var isGstCheckbox = document.getElementById('isGst');
    var form = document.querySelector('form');
    
    // Real-time validation on input
    gstinField.addEventListener('input', function() {
      if (isGstCheckbox.checked) {
        var length = this.value.length;
        if (length > 0 && length !== 15) {
          this.style.borderColor = '#dc3545';
          gstinError.style.display = 'block';
        } else if (length === 15) {
          this.style.borderColor = '#28a745';
          gstinError.style.display = 'none';
        } else {
          this.style.borderColor = '';
          gstinError.style.display = 'none';
        }
      }
    });
    
    // Form submit validation
    form.addEventListener('submit', function(e) {
      if (isGstCheckbox.checked) {
        var gstinValue = gstinField.value.trim();
        if (gstinValue.length !== 15) {
          e.preventDefault();
          gstinField.style.borderColor = '#dc3545';
          gstinError.style.display = 'block';
          gstinField.focus();
          alert('GSTIN must be exactly 15 characters for GST registered suppliers');
          return false;
        }
      }
    });
  });
  
  // Disable right click for the whole document
  document.addEventListener('contextmenu', function (e) {
    e.preventDefault();
  });
</script>
</body>
</html>
