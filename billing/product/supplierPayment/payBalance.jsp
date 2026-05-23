<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, javax.servlet.http.*" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<jsp:useBean id="prodBean" class="product.productBean" />
<%

int billId = Integer.parseInt(request.getParameter("billId"));

// Get supplier ID from bill instead of URL parameter
int supId = bill.getSupplierIdFromBill(billId);

Vector supPayId = bill.getSupplierPaymentId(billId);
int supPayID = Integer.parseInt(supPayId.get(0).toString());

Vector billDetails = bill.getSupplierBillAmount(billId);


       double total = Double.parseDouble(billDetails.get(0).toString());
       double balance = Double.parseDouble(billDetails.get(2).toString());
              double paid = total - balance;



%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Pay Balance - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>
<%
    request.setAttribute("pageTitle",    "Pay Balance");
    request.setAttribute("pageSubtitle", "Product — Supplier Payment");
    request.setAttribute("pageIcon",     "fa-solid fa-money-bill-wave");
%>
<jsp:include page="/assets/common/pageHeader.jsp" />

<div class="container-fluid mt-3 mst-page">

        <form id="payForm" action="<%= request.getContextPath() %>/product/supplierPayment/saveDuePayment.jsp" method="post" class="row g-3">
            <input type="hidden" name="billId" value="<%=billId%>">
            <input type="hidden" name="supPayID" value="<%=supPayID%>">
            <input type="hidden" name="supId" value="<%=supId%>">
            <!-- Totals -->
            <div class="col-md-4">
                <label class="form-label">Total</label>
                <input type="text" class="form-control fg-inp" name="total" id="total"
                       value="<%=total%>" readonly>
            </div>

            <div class="col-md-4">
                <label class="form-label">Paid</label>
                <input type="text" class="form-control fg-inp" name="paid" id="paid"
                       value="<%=paid%>" readonly>
            </div>

            <div class="col-md-4">
                <label class="form-label">Balance</label>
                <input type="text" class="form-control fg-inp" name="balance" id="balance"
                       value="<%=balance%>" readonly>
            </div>

            <!-- Payment Mode -->
            <div class="col-md-4">
                <label class="form-label">Payment Mode</label>
                <select class="form-select fg-inp" id="mode" name="mode">
                    <option value="1">Cash</option>
                    <option value="2">Bank</option>
                </select>
            </div>

            <!-- Bank Options -->
            <div class="col-md-4">
                <label class="form-label">Bank Options</label>
                <select class="form-select fg-inp" id="bankOption" name="bankOption" disabled>
                    <option value="0">--Select--</option>
                    <%
                        Vector paymentTypes = prodBean.getBillPaymentTypes();
                        for (int i = 0; i < paymentTypes.size(); i++) {
                            Vector payType = (Vector) paymentTypes.get(i);
                            int id = Integer.parseInt(payType.get(0).toString());
                            String name = payType.get(1).toString();
                            if (id != 0) { // Exclude id=0
                    %>
                    <option value="<%= id %>"><%= name %></option>
                    <%
                            }
                        }
                    %>
                </select>
            </div>
            <input type="hidden" name="bankOption" value="0">

            <!-- Pay Now -->
            <div class="col-md-4">
                <label class="form-label">Amount to Pay</label>
                <input type="number" class="form-control fg-inp" name="payNow" id="payNow"
                       min="0" step="0.001" placeholder="Enter amount" required>
            </div>

            

            <div class="col-12">
                <button type="submit" class="bb bb-primary">Submit Payment</button>
            </div>
        </form>

        <div class="card mst-card mt-4">
            <div class="card-header mst-card-header">
                <h6>Due Paid List</h6>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                <table class="table mst-table mb-0">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Name</th>
                            
                            <th>Paid</th>
                            
                            <th>Mode</th>
                            
                            <th>Date</th>
                            <th>Time</th>
                            <th>Biller</th>
                        </tr>
                    </thead>
                    <tbody>

                        <%
                            
                            Vector duePaidList = bill.getDueSupplierPaidList(supPayID);
                            for (int i = 0; i < duePaidList.size(); i++) {
                                Vector vec1 = (Vector) duePaidList.get(i); // inner vector (row)
                                String invNo =vec1.elementAt(0).toString();
                                String supName =vec1.elementAt(1).toString();
                                double pay = Double.parseDouble(vec1.elementAt(2).toString());
                                double listpaid = Double.parseDouble(vec1.elementAt(3).toString());
                                double listbalance = Double.parseDouble(vec1.elementAt(4).toString());
                                String mode = vec1.elementAt(5).toString();
                                String listuser = vec1.elementAt(6).toString();
                                String date = vec1.elementAt(7).toString();
                                String time = vec1.elementAt(8).toString();


                        %>
                        <tr>
                            <td><%=i+1%></td>
                            
                            <td><%=supName%></td>
                            
                            <td><%=listpaid%></td>
                            
                            <td><%=mode%></td>
                            
                            <td><%=date%></td>
                            <td><%=time%></td>  
                            <td><%=listuser%></td> 
                        </tr>
                        <%
                    }
                        %>
                        <%-- Dynamic rows will come here --%>
                    </tbody>
                </table>
                </div>
            </div>
        </div>
</div>
<script>
    const payNowInput = document.getElementById("payNow");
    const balanceInput = document.getElementById("balance");
    const modeSelect = document.getElementById("mode");
    const bankOption = document.getElementById("bankOption");

    // Validate amount: cannot exceed balance
    payNowInput.addEventListener("input", function () {
        const entered = parseFloat(this.value) || 0;
        const balance = parseFloat(balanceInput.value) || 0;
        if (entered > balance) {
            alert("Entered amount cannot be greater than the balance!");
            this.value = "";
            this.focus();
        }
    });

    // Enable/disable bank options
    modeSelect.addEventListener("change", function () {
        if (this.value === "2") {
            bankOption.removeAttribute("disabled");
        } else {
            bankOption.value = "";
            bankOption.setAttribute("disabled", "disabled");
        }
    });

    // Auto-select payment mode based on supplier GST status
    function setPaymentModeBasedOnGst(supplierId) {
        if (!supplierId || supplierId == 0) {
            document.getElementById('payNow').focus();
            return;
        }
        
        fetch('<%=contextPath%>/product/purchase/details.jsp?status=7&supplierId=' + supplierId)
            .then(response => response.text())
            .then(data => {
                const isGst = parseInt(data.trim());
                
                const modeSelect = document.getElementById('mode');
                if (isGst === 1) {
                    modeSelect.value = '2'; // Bank
                } else {
                    modeSelect.value = '1'; // Cash
                }
                
                // Trigger change event
                modeSelect.dispatchEvent(new Event('change'));
                
                // Focus on payNow input after setting payment mode
                setTimeout(function() {
                    document.getElementById('payNow').focus();
                }, 100);
            })
            .catch(error => {
                document.getElementById('payNow').focus();
            });
    }

    // Call on page load
    window.addEventListener('DOMContentLoaded', function() {
        const supplierId = <%= supId %>;
        setPaymentModeBasedOnGst(supplierId);
    });
</script>

</body>
</html>
