<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, javax.servlet.http.*" %>
<jsp:useBean id="poBean" class="product.purchaseOrderBean" />
<jsp:useBean id="prodMasterBean" class="product.productBean" />
<%
    // Check if receiving goods from PO
    int poId = 0;
    String mode = "standalone";
    Vector poHeader = null;
    Vector poItems = null;
    Vector advancePayment = null;
    double advancePaid = 0;
    double advanceBalance = 0;
    
    String poIdParam = request.getParameter("poId");
    if (poIdParam != null && !poIdParam.isEmpty()) {
        try {
            poId = Integer.parseInt(poIdParam);
            mode = "from-po";
            
            // Load PO header and pending items
            poHeader = poBean.getPOHeader(poId);
            Vector result = poBean.getPOPendingItems(poId);
            
            if (result.size() > 1) {
                poItems = (Vector) result.get(1); // Items are at index 1
            } else {
                poId = 0;
                mode = "standalone";
            }
            
            // Load advance payment if exists
            if (poId > 0) {
                advancePayment = poBean.getPOAdvancePayment(poId);
                if (advancePayment.size() >= 3) {
                    advancePaid = (Double) advancePayment.get(1);
                    advanceBalance = (Double) advancePayment.get(2);
                }
            }
        } catch (Exception e) {
            poId = 0;
            mode = "standalone";
            out.println("<!-- Error loading PO: " + e.getMessage() + " -->");
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Purchase Item - Billing App</title>
    <%@ include file="/assets/common/head.jsp" %>
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
</head>
<style>
    /* =====================================================
       PURCHASE PAGE LAYOUT — colors via theme.css vars
       ===================================================== */

    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    html, body {
        height: 100%;
        overflow: hidden;
        font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
        font-size: 13px;
        background: var(--bill-bg);
        color: var(--bill-text);
    }

    /* WRAPPER */
    .bw { display: flex; flex-direction: column; height: 100vh; height: 100dvh; overflow: hidden; }
    .bw-nav { flex-shrink: 0; }

    /* TOP PANEL */
    .top-panel {
        flex-shrink: 0;
        background: var(--bill-card);
        border-bottom: 2px solid var(--bill-border-lt);
        padding: 7px 14px 8px;
        box-shadow: 0 1px 4px rgba(0,0,0,.07);
    }
    .tp-row { display: flex; gap: 7px; align-items: flex-end; flex-wrap: wrap; }

    /* FIELD GROUP */
    .fg { display: flex; flex-direction: column; gap: 3px; min-width: 0; position: relative; }
    .fg-lbl {
        font-size: 10px; font-weight: 700; color: var(--bill-muted);
        text-transform: uppercase; letter-spacing: .5px; white-space: nowrap; padding-left: 1px;
    }
    .fg-inp {
        height: 33px; border: 1.5px solid var(--bill-border); border-radius: 5px;
        padding: 0 9px; background: var(--bill-input-bg); color: var(--bill-text);
        font-size: 13px; transition: border-color .15s, box-shadow .15s; outline: none; width: 100%;
    }
    .fg-inp:focus { border-color: var(--bill-gold); box-shadow: 0 0 0 3px rgba(201,162,39,.18); background: #fff; }
    .fg-inp[readonly] { background: #f1f5f9; color: var(--bill-muted); }
    .fg-sel {
        height: 33px; border: 1.5px solid var(--bill-border); border-radius: 5px;
        padding: 0 7px; background: var(--bill-input-bg); color: var(--bill-text);
        font-size: 13px; cursor: pointer; outline: none; transition: border-color .15s; width: 100%;
    }
    .fg-sel:focus { border-color: var(--bill-gold); box-shadow: 0 0 0 3px rgba(201,162,39,.18); }

    /* Compact size override for this page's tight panels */
    .bb { height: 33px; padding: 0 13px; border-radius: 5px; font-size: 12px; }

    /* Icon-only action buttons inside table rows */
    .tbl-icon-btn {
        width: 30px; height: 30px; border-radius: 50%; border: none;
        cursor: pointer; display: inline-flex; align-items: center; justify-content: center;
        font-size: 13px; transition: transform .15s, box-shadow .15s, background .15s;
        flex-shrink: 0;
    }
    .tbl-icon-btn:hover:not(:disabled) { transform: scale(1.13); box-shadow: 0 2px 8px rgba(0,0,0,.18); }
    .tbl-icon-btn:disabled { opacity: .35; cursor: not-allowed; }
    .tbl-icon-btn.add  { background: #dcfce7; color: var(--bill-green); }
    .tbl-icon-btn.add:hover:not(:disabled)  { background: #bbf7d0; }
    .tbl-icon-btn.del  { background: #fee2e2; color: var(--bill-red); }
    .tbl-icon-btn.del:hover:not(:disabled)  { background: #fecaca; }
    .tbl-icon-btn.hist { background: #ede9fe; color: var(--bill-navy); }
    .tbl-icon-btn.hist:hover:not(:disabled) { background: #ddd6fe; }

    /* Bootstrap btn compat for JS-generated rows */
    .btn { display: inline-flex; align-items: center; gap: 3px; cursor: pointer; border: 1px solid transparent; border-radius: 4px; padding: 2px 8px; font-size: 11.5px; font-weight: 600; transition: all .15s; }
    .btn-sm { padding: 2px 7px; font-size: 11px; }

    /* Override Bootstrap form-control inside table rows */
    .btbl .form-control,
    .btbl .form-control-sm {
        height: 36px; font-size: 14px; padding: 0 8px;
        border: 1.5px solid var(--bill-border); border-radius: 5px;
        background: var(--bill-input-bg); color: var(--bill-text);
        width: 100%; box-sizing: border-box;
        transition: border-color .15s, box-shadow .15s; outline: none;
    }
    .btbl .form-control:focus,
    .btbl .form-control-sm:focus {
        border-color: var(--bill-gold);
        box-shadow: 0 0 0 3px rgba(201,162,39,.18);
        background: #fff;
    }
    .btbl label { font-size: 14px; font-weight: 600; }
    .btbl small { font-size: 11px; }
    .btn-success { background: var(--bill-green); color: #fff; border-color: var(--bill-green); }
    .btn-success:hover { background: #047857; }
    .btn-danger  { background: var(--bill-red);   color: #fff; border-color: var(--bill-red); }
    .btn-danger:hover  { background: #b91c1c; }
    .btn-info    { background: #0891b2; color: #fff; border-color: #0891b2; }
    .btn-info:hover    { background: #0e7490; }
    .btn-outline-violet   { background: #fff; color: var(--bill-navy);  border-color: var(--bill-navy); }
    .btn-outline-violet:hover   { background: var(--bill-navy);  color: #fff; }
    .btn-outline-danger   { background: #fff; color: var(--bill-red);   border-color: var(--bill-red); }
    .btn-outline-danger:hover   { background: var(--bill-red);   color: #fff; }
    .btn-outline-success  { background: #fff; color: var(--bill-green); border-color: var(--bill-green); }
    .btn-outline-success:hover  { background: var(--bill-green); color: #fff; }
    .btn-outline-info     { background: #fff; color: #0891b2; border-color: #0891b2; }
    .btn-outline-info:hover     { background: #0891b2; color: #fff; }
    .btn-outline-secondary { background: #fff; color: var(--bill-muted); border-color: var(--bill-border); }
    .btn-primary   { background: var(--bill-navy); color: #fff; border-color: var(--bill-navy); }
    .btn-secondary { background: var(--bill-muted); color: #fff; border-color: var(--bill-muted); }

    /* TABLE PANEL */
    .tbl-panel {
        flex: 1; min-height: 0; display: flex; flex-direction: column;
        margin: 5px 10px; background: var(--bill-card);
        border: 1px solid var(--bill-border); border-radius: 7px;
        box-shadow: 0 1px 4px rgba(0,0,0,.07); overflow: hidden;
    }
    .tbl-scroll { flex: 1; overflow: auto; min-height: 0; }
    .tbl-scroll::-webkit-scrollbar { width: 6px; height: 6px; }
    .tbl-scroll::-webkit-scrollbar-track { background: #f1f5f9; }
    .tbl-scroll::-webkit-scrollbar-thumb { background: var(--bill-gold); border-radius: 3px; }
    .btbl {
        width: 100%; border-collapse: collapse; font-size: 14px;
        min-width: 1240px; table-layout: fixed;
    }
    .btbl thead th {
        position: sticky; top: 0; z-index: 2;
        background: var(--bill-navy); color: #e8f0fe; padding: 10px 7px;
        font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: .4px;
        border: none; border-right: 1px solid rgba(255,255,255,.12);
    }
    .btbl thead th:last-child { border-right: none; }
    .btbl tbody td {
        padding: 7px 6px; border-bottom: 1px solid var(--bill-border-lt);
        border-right: 1px solid var(--bill-border-lt); vertical-align: middle; font-size: 14px;
    }
    .btbl tbody td:last-child { border-right: none; }
    .btbl tbody tr:hover td { background: #e8f0fb; }
    .btbl tbody tr:nth-child(even) td { background: #f5f7fc; }
    .btbl tbody tr:nth-child(even):hover td { background: #e8f0fb; }
    .btbl tfoot td {
        position: sticky; bottom: 0; z-index: 1;
        background: #f1f5f9; font-weight: 700; font-size: 12px; padding: 5px 6px;
        border-top: 2px solid var(--bill-border); border-right: 1px solid var(--bill-border-lt);
    }
    .btbl tfoot td:last-child { border-right: none; }

    /* Column widths */
    .btbl th:nth-child(1),  .btbl td:nth-child(1)  { width: 50px;  text-align: center; }
    .btbl th:nth-child(2),  .btbl td:nth-child(2)  { width: 50px;  text-align: center; }
    .btbl th:nth-child(3),  .btbl td:nth-child(3)  { width: 240px; }
    .btbl th:nth-child(4),  .btbl td:nth-child(4)  { width: 90px;  }
    .btbl th:nth-child(5),  .btbl td:nth-child(5)  { width: 100px; }
    .btbl th:nth-child(6),  .btbl td:nth-child(6)  { width: 80px;  }
    .btbl th:nth-child(7),  .btbl td:nth-child(7)  { width: 80px;  }
    .btbl th:nth-child(8),  .btbl td:nth-child(8)  { width: 60px;  }
    .btbl th:nth-child(9),  .btbl td:nth-child(9)  { width: 60px;  }
    .btbl th:nth-child(10), .btbl td:nth-child(10) { width: 60px;  }
    .btbl th:nth-child(11), .btbl td:nth-child(11) { width: 90px;  }
    .btbl th:nth-child(12), .btbl td:nth-child(12) { width: 90px;  }
    .btbl th:nth-child(13), .btbl td:nth-child(13) { width: 90px;  }
    .btbl th:nth-child(14), .btbl td:nth-child(14) { width: 100px; }
    .btbl th:nth-child(15), .btbl td:nth-child(15) { width: 90px;  }

    /* BOTTOM PANEL */
    .bot-panel {
        flex-shrink: 0; background: var(--bill-card);
        border-top: 2px solid var(--bill-border-lt); padding: 7px 14px;
        box-shadow: 0 -2px 8px rgba(0,0,0,.06);
    }
    .bot-inner { display: flex; gap: 10px; align-items: flex-end; flex-wrap: wrap; }
    .grp { display: flex; gap: 7px; align-items: flex-end; flex-wrap: wrap; }
    .grp-pay { flex: 3; }
    .grp-act { flex: 0 0 auto; }

    /* PO / Advance banners */
    .info-banner {
        margin-bottom: 6px; padding: 5px 10px;
        background: #eff6ff; border: 1px solid #bfdbfe;
        border-radius: 5px; font-size: 12px; color: #1d4ed8;
    }
    .success-banner {
        margin-bottom: 6px; padding: 5px 10px;
        background: #f0fdf4; border: 1px solid #86efac;
        border-radius: 5px; font-size: 12px; color: #15803d;
    }

    /* Mobile */
    @media (max-width: 768px) {
        .bw { height: 100svh; }
        .top-panel { padding: 5px 8px 7px; }
        .tp-row { gap: 5px; }
        .tbl-panel { margin: 4px 6px; }
        .bot-panel { padding: 5px 8px 82px; overflow-y: auto; max-height: 48vh; }
        .bot-inner { flex-direction: column; gap: 5px; align-items: stretch; }
        .grp-pay { flex: none; width: 100%; display: grid; grid-template-columns: repeat(2,1fr); gap: 5px; }
        .grp-act {
            position: fixed; bottom: 0; left: 0; right: 0; z-index: 200;
            background: var(--bill-card); border-top: 2px solid var(--bill-border-lt);
            box-shadow: 0 -3px 10px rgba(0,0,0,.12); padding: 6px 8px;
            display: flex !important; gap: 5px;
        }
        .grp-act .bb { flex: 1; justify-content: center; }
    }
    @media (max-width: 480px) {
        .tp-row { display: grid; grid-template-columns: 1fr 1fr; gap: 5px; }
        .grp-pay { grid-template-columns: repeat(2,1fr); }
    }
</style>
<body onload="Load();loadPOItems()">
<div class="bw">

    <!-- NAVBAR -->
    <div class="bw-nav">
        <%@ include file="/assets/navbar/navbar.jsp" %>
    </div>

    <input type="hidden" id="_proAddRowCount" name="_proAddRowCount" value="0">
    <input type="hidden" id="_proDelRowCount" name="_proDelRowCount" value="0">
    <input type="hidden" id="poId" name="poId" value="<%= poId %>">
    <input type="hidden" id="mode" name="mode" value="<%= mode %>">
    <input type="hidden" id="advancePaid" name="advancePaid" value="<%= advancePaid %>">
    <% if (mode.equals("from-po") && poHeader != null) { %>
    <input type="hidden" id="supplierIdFromPO" value="<%= poHeader.get(10) %>">
    <% } %>

    <!-- TOP PANEL - Supplier Details -->
    <div class="top-panel">
        <% if (mode.equals("from-po")) { %>
        <div class="info-banner">
            <i class="fas fa-truck me-2"></i>
            <strong>Receiving Goods from PO:</strong> <%= poHeader != null ? poHeader.get(0).toString() : "" %>
        </div>
        <% } %>
        <div class="tp-row">
            <div class="fg" style="flex:2;min-width:180px;">
                <span class="fg-lbl">Supplier</span>
                <select class="fg-sel" name="supplier" id="supplier" onchange="setPaymentTypeBasedOnGst();">
                    <option value="0">Select Supplier</option>
                </select>
            </div>
            <div class="fg" style="flex:1.5;min-width:140px;">
                <span class="fg-lbl">Invoice No.</span>
                <input type="text" class="fg-inp" id="invoiceNo" name="invoiceNo">
            </div>
            <div class="fg" style="min-width:150px;">
                <span class="fg-lbl">Invoice Date</span>
                <input type="date" class="fg-inp" id="invoiceDate" name="invoiceDate" value="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
            </div>
        </div>
    </div>

    <!-- TABLE PANEL -->
    <div class="tbl-panel">
      <div class="tbl-scroll">
        <table class="btbl">
            <thead>
                <tr>
                    <th>Add</th>
                    <th>Del</th>
                    <th>Item Name <button type="button" onclick="openAddProductModal()" title="Add New Product" style="margin-left:7px;width:20px;height:20px;border-radius:50%;border:none;background:rgba(255,255,255,0.18);color:#fff;font-size:13px;font-weight:700;line-height:1;cursor:pointer;display:inline-flex;align-items:center;justify-content:center;transition:background .15s;" onmouseover="this.style.background='rgba(255,255,255,0.35)'" onmouseout="this.style.background='rgba(255,255,255,0.18)'">+</button></th>
                    <th>Qty</th>
                    <th>Cost</th>
                    <th>MRP</th>
                    <th>Disc%</th>
                    <th>Tax%</th>
                    <th>Free</th>
                    <th>History</th>
                    <th>Cost Tot</th>
                    <th>MRP Tot</th>
                    <th>Tax Tot</th>
                    <th>Net Tot</th>
                    <th>Unit Cost</th>
                </tr>
            </thead>
            <tbody id="productTable">
            </tbody>
            <tfoot>
                <tr>
                    <td colspan="10" style="text-align:right;padding-right:8px;">Summary Total:</td>
                    <td id="sumCostTotal">0.00</td>
                    <td id="sumMrpTotal">0.00</td>
                    <td id="sumTaxTotal">0.00</td>
                    <td id="sumNetTotal">0.00</td>
                    <td></td>
                </tr>
            </tfoot>
        </table>
      </div>
    </div>

    <!-- BOTTOM PANEL - Payment -->
    <div class="bot-panel">
        <% if (mode.equals("from-po") && advancePaid > 0) { %>
        <div class="success-banner">
            <i class="fas fa-info-circle me-2"></i>
            <strong>Advance Paid:</strong> &#8377;<%= String.format("%.3f", advancePaid) %> &nbsp;|&nbsp;
            <strong>Remaining:</strong> &#8377;<%= String.format("%.3f", advanceBalance) %>
        </div>
        <% } %>
        <div class="bot-inner">
            <div class="grp grp-pay">
                <div class="fg" style="flex:1;min-width:140px;">
                    <span class="fg-lbl">Payment Type</span>
                    <select class="fg-sel" id="payType" name="payType">
                        <option value="0">Select Payment Type</option>
                    </select>
                </div>
                <div class="fg" style="flex:1;min-width:130px;">
                    <span class="fg-lbl">Bank / Mode</span>
                    <select class="fg-sel" id="bank" name="bank">
                        <option value="0">Select Mode</option>
                    </select>
                </div>
                <div class="fg" style="flex:1;min-width:120px;">
                    <span class="fg-lbl">Total Amount</span>
                    <input type="number" class="fg-inp" id="grandTotal" name="grandTotal" step="0.001" readonly value="0.00">
                </div>
                <div class="fg" style="flex:1;min-width:120px;">
                    <span class="fg-lbl">Paid Now</span>
                    <input type="number" class="fg-inp" id="paidAmount" name="paidAmount" step="0.001" value="0.00">
                </div>
                <div class="fg" style="flex:1;min-width:120px;">
                    <span class="fg-lbl">Extra Discount</span>
                    <input type="number" class="fg-inp" id="extraDisc" name="extraDisc" step="0.001" value="0.00">
                </div>
                <div class="fg" style="flex:1;min-width:110px;">
                    <span class="fg-lbl">Balance</span>
                    <input type="number" class="fg-inp" id="balanceAmount" name="balanceAmount" step="0.001" readonly value="0.00">
                </div>
            </div>
            <div class="grp grp-act">
                <button type="button" class="bb bb-navy" id="saveBtn" onclick="savePurchaseBill()">
                    <i class="fas fa-save"></i> SAVE
                </button>
            </div>
        </div>
    </div>

</div><!-- /bw -->

    <!-- Purchase History Modal -->
    <div class="modal fade" id="purchaseHistoryModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Last 6 Purchase History</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div id="historyContent">
                        <div class="text-center">
                            <div class="spinner-border" role="status">
                                <span class="visually-hidden">Loading...</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        var contextPath = '<%=contextPath%>';
    </script>
    <script src="<%=contextPath%>/product/purchase/purchase.js?v=<%= System.currentTimeMillis() %>"></script>
    <script>
        // Set payment type based on supplier GST status
        function setPaymentTypeBasedOnGst() {
            var supplier = $('#supplier').val();
            
            if (!supplier || supplier == '0') {
                return;
            }
            
            // Fetch supplier GST status
            $.ajax({
                type: 'POST',
                url: 'details.jsp',
                data: { 
                    status: 7,
                    supplierId: supplier 
                },
                success: function(result) {
                    var isGst = parseInt(result.trim());
                    
                    if (isGst === 1) {
                        // GST registered - auto-select Bank (assuming Bank is id=2)
                        $('#payType').val('2');
                    } else {
                        // Not GST registered - auto-select Cash (id=1)
                        $('#payType').val('1');
                    }
                    
                    // Trigger change event to enable/disable bank dropdown
                    $('#payType').trigger('change');
                }
            });
        }
        
        // Fix for table header gradient issue if present
        document.addEventListener("DOMContentLoaded", function() {
            setTimeout(function() {
                document.querySelectorAll("table thead th").forEach(th => {
                    th.style.removeProperty("background-color");
                    th.style.removeProperty("color");
                    th.style.removeProperty("background");
                });
            }, 100);
        });
        
        // Function to load PO items into table
        function loadPOItems() {
            var mode = $('#mode').val();
            
            if (mode === 'from-po') {
                // Load items from PO
                <% if (poItems != null && poItems.size() > 0) { %>
                var poItems = [];
                <% for (int i = 0; i < poItems.size(); i++) { 
                    Vector item = (Vector) poItems.get(i);
                %>
                poItems.push({
                    name: '<%= item.get(0).toString().replace("'", "\\'") %>',
                    pack: <%= item.get(12) %>,
                    qtyperpack: <%= item.get(13) %>,
                    free: <%= item.get(14) %>,
                    cost: <%= item.get(3) %>,
                    mrp: <%= item.get(7) %>,
                    disc: <%= item.get(15) %>,
                    tax: <%= item.get(11) %>,
                    productId: <%= item.get(9) %>,
                    poDetailId: <%= item.get(8) %>,
                    pendingQty: <%= item.get(6) %>
                });
                <% } %>
                
                // Populate rows
                for (var i = 0; i < poItems.length; i++) {
                    addProductRowFromPO(i, poItems[i]);
                }
                
                // Focus on invoice field instead
                $('#invoiceNo').focus();
                <% } %>
            } else {
                // Standalone mode - add one empty row
                addProductRow(event, 0);
            }
        }
        
        // Function to add a pre-filled row from PO data
        function addProductRowFromPO(rowIndex, itemData) {
            var proRowCount = rowIndex;
            
            // Escape double quotes in product name to prevent attribute breaking
            var escapedName = itemData.name.replace(/"/g, '&quot;');
            
            $("#productTable").append("<tr id='_productTableRow_" + proRowCount + "'>"
                + "<td class='text-center'><button type='button' class='tbl-icon-btn add' id='_addProcRow_" + proRowCount + "' onclick='addProductRow();' disabled title='Add row'><i class='fas fa-plus' style='font-size:11px;'></i></button></td>"
                + "<td class='text-center'><button type='button' class='tbl-icon-btn del' id='_delProcRow_" + proRowCount + "' onclick='deleteProductRow(this);' title='Delete row'><i class='fas fa-times' style='font-size:12px;'></i></button></td>"
                + '<td><input type="text" class="form-control form-control-sm" id="_productName_' + proRowCount + '" name="_productName_' + proRowCount + '" value="' + escapedName + '" readonly></td>'
                + "<td><div class='d-flex flex-column'><div class='d-flex align-items-center gap-1'><input type='text' class='form-control form-control-sm' id='_totqty_" + proRowCount + "' name='_totqty_" + proRowCount + "' value='" + (((parseFloat(itemData.pack) || 0) * (parseFloat(itemData.qtyperpack) || 0)).toFixed(3)) + "' style='min-width:65px;' onkeyup='calculateRow(" + proRowCount + ");'><span class='text-muted small' id='_totunit_" + proRowCount + "'></span></div><small class='text-primary' id='_convtotqty_" + proRowCount + "'></small><input type='hidden' id='_pack_" + proRowCount + "' name='_pack_" + proRowCount + "' value='1'><input type='hidden' id='_qtyperpack_" + proRowCount + "' name='_qtyperpack_" + proRowCount + "' value='" + (((parseFloat(itemData.pack) || 0) * (parseFloat(itemData.qtyperpack) || 0)).toFixed(3)) + "'></div></td>"
                + "<td><div class='d-flex flex-column'><input type='text' class='form-control form-control-sm' id='_cost_" + proRowCount + "' name='_cost_" + proRowCount + "' value='" + itemData.cost + "' onkeyup='calculateRow(" + proRowCount + ");'><small class='text-info' id='_costperconv_" + proRowCount + "'></small></div></td>"
                + "<td><div class='d-flex flex-column'><input type='text' class='form-control form-control-sm' id='_mrp_" + proRowCount + "' name='_mrp_" + proRowCount + "' value='" + itemData.mrp + "' onkeyup='calculateRow(" + proRowCount + ");'><small class='text-info' id='_mrpperconv_" + proRowCount + "'></small></div></td>"
                + "<td><input type='text' class='form-control form-control-sm' id='_disc_" + proRowCount + "' name='_disc_" + proRowCount + "' value='" + itemData.disc + "' onkeyup='calculateRow(" + proRowCount + ");'></td>"
                + "<td><input type='text' class='form-control form-control-sm' id='_tax_" + proRowCount + "' name='_tax_" + proRowCount + "' value='" + itemData.tax + "' onkeyup='calculateRow(" + proRowCount + ");'></td>"
                + "<td><input type='text' class='form-control form-control-sm' id='_freeqty_" + proRowCount + "' name='_freeqty_" + proRowCount + "' value='" + itemData.free + "' onkeyup='calculateRow(" + proRowCount + ");'></td>"
                + "<td class='text-center'><button type='button' class='tbl-icon-btn hist' id='_historyBtn_" + proRowCount + "' onclick='viewPurchaseHistory(" + proRowCount + ");' title='Purchase history'><i class='fas fa-history' style='font-size:12px;'></i></button></td>"
                + "<td><label id='_costtotal_" + proRowCount + "'>0.00</label></td>"
                + "<td><label id='_mrptotal_" + proRowCount + "'>0.00</label></td>"
                + "<td><label id='_taxtotal_" + proRowCount + "'>0.00</label></td>"
                + "<td><label id='_nettotal_" + proRowCount + "'>0.00</label></td>"
                + "<td><label id='_unitcost_" + proRowCount + "'>0.00</label></td>"
                + "<input type='hidden' id='_productId_" + proRowCount + "' value='" + itemData.productId + "'>"
                + "<input type='hidden' id='_poDetailId_" + proRowCount + "' value='" + itemData.poDetailId + "'>"
                + "<input type='hidden' id='_pendingQty_" + proRowCount + "' value='" + itemData.pendingQty + "'>"
                + "</tr>");
            
            $('#_proAddRowCount').val(proRowCount);
            $('#_proDelRowCount').val(proRowCount + 1);
            
            // Calculate row totals
            calculateRow(proRowCount);
            // Fetch conversion data for this PO item
            fetchConversionData(proRowCount, itemData.name);
        }

        // Fetch conversion unit data for a pre-filled product row (PO items)
        function fetchConversionData(rowIndex, productName) {
            $.ajax({
                type: "POST",
                url: contextPath + "/product/purchase/details.jsp",
                data: { status: 1, productName: productName },
                success: function (_result) {
                    var resArr = _result.trim().split("<#>");
                    if (resArr.length > 1) {
                        var unitName = (resArr.length > 10) ? resArr[10] : '';
                        var convertionUnit = (resArr.length > 11) ? resArr[11].trim() : '';
                        var convertionCalc = (resArr.length > 12) ? parseFloat(resArr[12]) || 1 : 1;
                        $('#_productName_' + rowIndex).data('unitName', unitName);
                        $('#_productName_' + rowIndex).data('convertionUnit', convertionUnit);
                        $('#_productName_' + rowIndex).data('convertionCalc', convertionCalc);
                        if (unitName) {
                            $('#_totunit_' + rowIndex).text(unitName);
                        }
                        calculateRow(rowIndex);
                    }
                }
            });
        }
    </script>

<!-- Add Product Modal -->
<div class="modal fade" id="addProductModal" tabindex="-1" aria-labelledby="addProductModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header py-2" style="background:var(--page-header-card-bg);color:white;">
                <h6 class="modal-title mb-0" id="addProductModalLabel"><i class="fas fa-plus-circle me-2"></i>Add New Product</h6>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body py-2">
                <form id="addProductModalForm" class="row g-2">
                    <div class="col-md-6">
                        <label class="form-label mb-1" style="font-size:0.85rem;">Category <span class="text-danger">*</span></label>
                        <select name="categoryId" id="modal_categoryId" class="form-select form-select-sm" required>
                            <option value="">Select Category</option>
                            <%
                                Vector modalCategories = prodMasterBean.getCategoryName();
                                if (modalCategories != null) {
                                    for (int mi = 0; mi < modalCategories.size(); mi++) {
                                        Vector mcat = (Vector) modalCategories.get(mi);
                                        if (mcat != null && mcat.size() >= 2) {
                            %>
                            <option value="<%=mcat.elementAt(1)%>"><%=mcat.elementAt(0)%></option>
                            <% }}} %>
                        </select>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label mb-1" style="font-size:0.85rem;">Brand <span class="text-danger">*</span></label>
                        <select name="brandId" id="modal_brandId" class="form-select form-select-sm" required>
                            <option value="">Select Brand</option>
                            <%
                                Vector modalBrands = prodMasterBean.getBrandsName();
                                if (modalBrands != null) {
                                    for (int mi = 0; mi < modalBrands.size(); mi++) {
                                        Vector mbrand = (Vector) modalBrands.get(mi);
                                        if (mbrand != null && mbrand.size() >= 2) {
                            %>
                            <option value="<%=mbrand.elementAt(1)%>"><%=mbrand.elementAt(0)%></option>
                            <% }}} %>
                        </select>
                    </div>
                    <div class="col-md-12">
                        <label class="form-label mb-1" style="font-size:0.85rem;">Product Name <span class="text-danger">*</span></label>
                        <input type="text" id="modal_productName" name="productName" class="form-control form-control-sm" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label mb-1" style="font-size:0.85rem;">Product Code</label>
                        <input type="text" id="modal_productCode" name="productCode" class="form-control form-control-sm">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label mb-1" style="font-size:0.85rem;">HSN Code</label>
                        <input type="text" id="modal_hsn" name="hsn" class="form-control form-control-sm">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label mb-1" style="font-size:0.85rem;">Unit/Size</label>
                        <select name="unitId" id="modal_unitId" class="form-select form-select-sm" required>
                            <option value="">Select Unit</option>
                            <%
                                Vector modalUnits = prodMasterBean.getUnits();
                                if (modalUnits != null) {
                                    for (int mi = 0; mi < modalUnits.size(); mi++) {
                                        Vector munit = (Vector) modalUnits.get(mi);
                                        if (munit != null && munit.size() >= 2) {
                                            String mUnitName = munit.elementAt(0).toString();
                                            String mUnitId   = munit.elementAt(1).toString();
                                            boolean mSelected = mUnitName.equalsIgnoreCase("Nos") || mUnitName.equalsIgnoreCase("NOS") || mUnitName.equalsIgnoreCase("PCS");
                            %>
                            <option value="<%=mUnitId%>" <%=mSelected?"selected":""%>><%=mUnitName%></option>
                            <% }}} %>
                        </select>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label mb-1" style="font-size:0.85rem;">Stock</label>
                        <input type="number" id="modal_stock" name="stock" class="form-control form-control-sm" value="0" min="0" step="0.01">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label mb-1" style="font-size:0.85rem;">Cost Price <span class="text-danger">*</span></label>
                        <input type="number" id="modal_cost" name="cost" class="form-control form-control-sm" step="0.001" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label mb-1" style="font-size:0.85rem;">MRP <span class="text-danger">*</span></label>
                        <input type="number" id="modal_mrp" name="mrp" class="form-control form-control-sm" step="0.001" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label mb-1" style="font-size:0.85rem;">GST %</label>
                        <select id="modal_gst" name="gst" class="form-select form-select-sm" required>
                            <option value="0" selected>0%</option>
                            <option value="5">5%</option>
                            <option value="12">12%</option>
                            <option value="18">18%</option>
                            <option value="28">28%</option>
                        </select>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label mb-1" style="font-size:0.85rem;">Discount Type</label>
                        <select id="modal_discType" name="discType" class="form-select form-select-sm" onchange="handleModalDiscTypeChange(this)">
                            <option value="0">None</option>
                            <option value="1">Rs</option>
                            <option value="2">%</option>
                        </select>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label mb-1" style="font-size:0.85rem;">Discount Value</label>
                        <input type="text" id="modal_discValue" name="discValue" class="form-control form-control-sm" value="0.00" readonly>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label mb-1" style="font-size:0.85rem;">Commission (Rs)</label>
                        <input type="number" id="modal_commission" name="commission" class="form-control form-control-sm" step="0.01" value="0.00">
                    </div>
                </form>
            </div>
            <div class="modal-footer py-2">
                <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-primary btn-sm" id="saveNewProductBtn" onclick="saveNewProductModal()">
                    <i class="fas fa-save me-1"></i>Save Product
                </button>
            </div>
        </div>
    </div>
</div>

</body>
</html>
