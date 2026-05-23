// Enable/disable bank based on payType selection
$('#payType').on('change', function() {
    var payTypeVal = $('#payType').val();
    if (payTypeVal !== '0' && payTypeVal !== '1') {
        $('#bank').prop('disabled', false);
    } else {
        $('#bank').val('0').prop('disabled', true);
    }
});

// On page load, set bank disabled if payType is '0' or '1'
$(document).ready(function() {
    var payTypeVal = $('#payType').val();
    if (payTypeVal === '0' || payTypeVal === '1') {
        $('#bank').val('0').prop('disabled', true);
    } else {
        $('#bank').prop('disabled', false);
    }
});
function Load() {
  	
  	var status = 0;
    var param = 'status=' + status;
	
    $.ajax({
        type: "POST",
        url: contextPath + "/product/purchase/details.jsp",
        data: param,
        success: function (result) {
		var res	= result.trim().split('<@>');
	//$("#supplier").empty();
 	///////////////////Supplier
        //$("<option value='0'>Select Supplier Name</option>").appendTo("#supplier");
        if (parseFloat(res.length) > 1) {
            for (var i = 0; i < parseFloat(res.length) - 1; i++) {
                var arr1 = res[i].split("<#>");
                $("<option value='" + parseInt(arr1[0]) + "'>" + arr1[1] + "</option>").appendTo("#supplier");
            }
        }
        
        // If loading from PO, pre-select supplier and disable
        var mode = $('#mode').val();
        if (mode === 'from-po') {
            var supplierIdFromPO = $('#supplierIdFromPO').val();
            if (supplierIdFromPO && supplierIdFromPO !== '0') {
                $('#supplier').val(supplierIdFromPO).prop('disabled', true);
            }
        }
    //////////////////
    },
    });
 ///////////////////////PaymeType
    var status = 2;
    var param = 'status=' + status;
    
    $.ajax({
        type: "POST",
        url: contextPath + "/product/purchase/details.jsp",
        data: param,
        success: function (result) {
            var res = result.trim().split('<@>');
            if (parseFloat(res.length) > 1) {
                for (var i = 0; i < parseFloat(res.length) - 1; i++) {
                    var arr1 = res[i].split("<#>");
                    $("<option value='" + parseInt(arr1[0]) + "'>" + arr1[1] + "</option>").appendTo("#payType");
                }
            }
            $('#payType').val('1'); // Auto-select Cash
            $('#payType').trigger('change'); // Trigger change to update bank field
        },
    });
    ///////////////////////Bank Details (from prod_bill_payment_type)
    var status = 6;
    var param = 'status=' + status;
    
    $.ajax({
        type: "POST",
        url: contextPath + "/product/purchase/details.jsp",
        data: param,
        success: function (result) {
            var res = result.trim().split('<@>');
            $("<option value='0'>Select Bank Name</option>").appendTo("#bank");
            if (parseFloat(res.length) > 1) {
                for (var i = 0; i < parseFloat(res.length) - 1; i++) {
                    var arr1 = res[i].split("<#>");
                    $("<option value='" + parseInt(arr1[0]) + "'>" + arr1[1] + "</option>").appendTo("#bank");
                }
            }
        },
    });
    ///////////////////////    
}
/////////////////////////////
function disableProductInputs(rowIndex) {
    $('#_cost_' + rowIndex).prop('readonly', true).val('');
    $('#_mrp_' + rowIndex).prop('readonly', true).val('');
}
function enableProductInputs(rowIndex) {
    $('#_cost_' + rowIndex).prop('readonly', false);
    $('#_mrp_' + rowIndex).prop('readonly', false);
}
/////////////////////////////
function openAddProductModal() {
    // Pre-fill product name from the currently active row if it has a typed value
    var activeRow = (typeof window._activeProductRow !== 'undefined') ? window._activeProductRow : -1;
    var typedName = '';
    if (activeRow >= 0) {
        var raw = $('#_productName_' + activeRow).val().trim();
        // Strip "Name (Code)" format back to just name
        var storedName = $('#_productName_' + activeRow).data('productName');
        typedName = storedName || raw.replace(/\s*\([^)]*\)\s*$/, '');
    }
    $('#modal_productName').val(typedName);
    $('#modal_productCode').val('');
    $('#modal_hsn').val('');
    $('#modal_stock').val('0');
    $('#modal_cost').val('');
    $('#modal_mrp').val('');
    $('#modal_gst').val('0');
    $('#modal_discType').val('0');
    $('#modal_discValue').val('0.00').prop('readonly', true);
    $('#modal_commission').val('0.00');
    $('#modal_categoryId').val('');
    $('#modal_brandId').val('');
    var modal = new bootstrap.Modal(document.getElementById('addProductModal'));
    modal.show();
    setTimeout(function() { $('#modal_productName').focus(); }, 400);
}
/////////////////////////////
function handleModalDiscTypeChange(sel) {
    if (sel.value === '0') {
        $('#modal_discValue').val('0.00').prop('readonly', true);
    } else {
        $('#modal_discValue').val('').prop('readonly', false).focus();
    }
}
/////////////////////////////
function saveNewProductModal() {
    var form = document.getElementById('addProductModalForm');
    if (!form.checkValidity()) {
        form.reportValidity();
        return;
    }
    var btn = $('#saveNewProductBtn');
    btn.prop('disabled', true).html('<i class="fas fa-spinner fa-spin me-1"></i>Saving...');

    var data = {
        productName  : $('#modal_productName').val().trim(),
        categoryId   : $('#modal_categoryId').val(),
        brandId      : $('#modal_brandId').val(),
        productCode  : $('#modal_productCode').val().trim(),
        hsn          : $('#modal_hsn').val().trim(),
        unitId       : $('#modal_unitId').val(),
        stock        : $('#modal_stock').val() || '0',
        cost         : $('#modal_cost').val(),
        mrp          : $('#modal_mrp').val(),
        gst          : $('#modal_gst').val(),
        discType     : $('#modal_discType').val(),
        discValue    : $('#modal_discValue').val() || '0',
        commission   : $('#modal_commission').val() || '0'
    };

    $.ajax({
        type   : 'POST',
        url    : contextPath + '/product/purchase/saveProductAjax.jsp',
        data   : data,
        dataType: 'json',
        success: function(res) {
            if (res.success) {
                bootstrap.Modal.getInstance(document.getElementById('addProductModal')).hide();
                Swal.fire({
                    title: 'Product Added!',
                    text : res.productName + (res.productCode && res.productCode !== '0' ? ' (' + res.productCode + ')' : '') + ' added successfully.',
                    icon : 'success',
                    timer: 1800,
                    showConfirmButton: false
                });
                // Auto-select the new product into the active row
                var targetRow = (typeof window._activeProductRow !== 'undefined') ? window._activeProductRow : -1;
                if (targetRow >= 0 && res.productId > 0) {
                    var displayVal = res.productCode && res.productCode !== '0'
                        ? res.productName + ' (' + res.productCode + ')'
                        : res.productName;
                    $('#_productName_' + targetRow).val(displayVal);
                    $('#_productName_' + targetRow).data('productId',   res.productId);
                    $('#_productName_' + targetRow).data('productName', res.productName);
                    $('#_productName_' + targetRow).data('productCode', res.productCode);
                    getProductDetailsById(targetRow, res.productId);
                }
            } else {
                Swal.fire({ title: 'Error', text: res.message || 'Failed to add product.', icon: 'error', confirmButtonText: 'OK' });
            }
        },
        error: function() {
            Swal.fire({ title: 'Error', text: 'Server error. Please try again.', icon: 'error', confirmButtonText: 'OK' });
        },
        complete: function() {
            btn.prop('disabled', false).html('<i class="fas fa-save me-1"></i>Save Product');
        }
    });
}
/////////////////////////////
function autoComplete(event, str, str1) {
	var unicode = event.keyCode ? event.keyCode : event.charCode;

	if (unicode != 38 && unicode != 40) {
		if (str1 == 1) {
			$("#_productName_" + str).autocomplete({
				source: function (request, response) {
					$.ajax({
						url: contextPath + "/product/purchase/auto_complete.jsp",
						data: {
							typeId: str1,
							q: request.term
						},
						dataType: "text",
						success: function (data) {
							if (data) {
								var suggestions = data.split("\n").map(function (item) {
									var trimmed = item.trim();
									if (trimmed.length === 0) return null;
									var parts = trimmed.split("<#>");
									var name = parts[0] || trimmed;
									var code = parts[1] || "";
									var id   = parts[2] || "0";
									return {
										label: code ? name + " (" + code + ")" : name,
										value: name,
										productCode: code,
										productId: id,
										productName: name
									};
								}).filter(function (item) {
									return item !== null;
								});
								if (suggestions.length > 0) {
									response(suggestions);
								} else {
									response([{label: 'No Product Found', value: ''}]);
									$(".ui-menu-item:contains('No Product Found')")
										.css('color', 'red')
										.css('pointer-events', 'none')
										.addClass('no-select');
								}
							}
						},
						error: function (xhr, status, error) {
							console.error("Autocomplete error:", status, error);
							response([]);
						}
					});
				},
				minLength: 1,
				select: function(event, ui) {
					var rowIdx = str;
					var displayVal = ui.item.productCode
						? ui.item.productName + ' (' + ui.item.productCode + ')'
						: ui.item.productName;
					$(this).val(displayVal);
					$(this).data('productId',   ui.item.productId);
					$(this).data('productCode', ui.item.productCode);
					$(this).data('productName', ui.item.productName);
					// Fetch details by ID so same-name products resolve correctly
					getProductDetailsById(rowIdx, parseInt(ui.item.productId));
					return false;
				},
				change: function(event, ui) {
					if (!ui.item) {
						if ($(this).val().trim() !== '') {
							Swal.fire({
								title: 'Invalid Product',
								text: 'Please select a valid product from the list.',
								icon: 'warning',
								confirmButtonText: 'OK'
							});
						}
						$(this).val('');
						$(this).data('productId', 0);
						$(this).data('productCode', '');
						$(this).data('productName', '');
						disableProductInputs(str);
					}
				}
			});
			
			// Add keydown handler for Tab key to select first item
			$("#_productName_" + str).on('keydown', function(e) {
				if (e.keyCode === 9) { // Tab key
					var autocomplete = $(this).data('ui-autocomplete');
					if (autocomplete && autocomplete.menu.element.is(':visible')) {
						e.preventDefault();
						// Select the first item
						var firstItem = autocomplete.menu.element.find('.ui-menu-item:first');
						if (firstItem.length) {
							autocomplete.menu.focus(e, firstItem);
							autocomplete.menu.select(e);
						}
					}
				}
			});
		}
	}

	return false;
}

/////////////////////////////
function applyProductDetails(str, resArr) {
    var productName = resArr[0] || '';
    var code        = (resArr.length > 14) ? resArr[14].trim() : '';
    var displayVal  = code ? productName + ' (' + code + ')' : productName;
    $('#_productName_' + str).val(displayVal);
    $('#_productName_' + str).data('productName', productName);
    $('#_productName_' + str).data('productCode', code);
    $('#_productName_' + str).data('productId',   parseInt(resArr[6]) || 0);

    var convertionUnit = (resArr.length > 11) ? resArr[11].trim() : '';
    var convertionCalc = (resArr.length > 12) ? parseFloat(resArr[12]) || 1 : 1;
    $('#_productName_' + str).data('convertionUnit', convertionUnit);
    $('#_productName_' + str).data('convertionCalc', convertionCalc);

    var rawCost = parseFloat(resArr[4]) || 0;
    var rawMrp  = parseFloat(resArr[5]) || 0;
    enableProductInputs(str);
    $('#_cost_' + str).val(convertionCalc > 1 ? (rawCost * convertionCalc).toFixed(3) : rawCost);
    $('#_mrp_' + str).val(convertionCalc > 1 ? (rawMrp * convertionCalc).toFixed(3) : rawMrp);

    if (resArr.length > 13 && resArr[13].trim() !== '') {
        $('#_tax_' + str).val(resArr[13].trim());
    }
    var unitName = (resArr.length > 10) ? resArr[10] : '';
    $('#_productName_' + str).data('unitName', unitName);
    if (unitName) {
        $('#_totunit_' + str).text(unitName);
    } else {
        $('#_totunit_' + str).text('');
    }
    calculateRow(str);
}
/////////////////////////////
function getProductDetailsById(str, productId) {
    if (!productId || productId <= 0) {
        disableProductInputs(str);
        return;
    }
    $.ajax({
        type: "POST",
        url: contextPath + "/product/purchase/details.jsp",
        data: { status: 8, productId: productId },
        success: function (_result) {
            var resArr = _result.trim().split("<#>");
            if (resArr.length > 1 && resArr[0] !== 'Invalid Input') {
                applyProductDetails(str, resArr);
            } else {
                disableProductInputs(str);
            }
        }
    });
}
/////////////////////////////
function getProductDetails(str, str1) {
    // If product was selected via autocomplete, details already loaded by ID
    var productId = parseInt($('#_productName_' + str).data('productId')) || 0;
    if (productId > 0) {
        return; // already fetched correctly by ID during select
    }

    var productName = $('#_productName_' + str).val().trim();
    if (!productName) {
        disableProductInputs(str);
        return;
    }

    $.ajax({
        type: "POST",
        url: contextPath + "/product/purchase/details.jsp",
        data: { status: 1, productName: productName },
        success: function (_result) {
            var resArr = _result.trim().split("<#>");
            if (resArr.length > 1 && resArr[0] !== 'Invalid Input') {
                applyProductDetails(str, resArr);
            } else {
                disableProductInputs(str);
            }
        }
    });
}

//////////////////////////////////
function addProductRow(event, str) {
    var unicode = 0;
    if (str == 1)
        unicode = event.keyCode ? event.keyCode : event.charCode;
    else
        unicode = 13;

    if (parseFloat(unicode) == 13) {
        var proRowCount = parseFloat($('#_proAddRowCount').val());
        var proDelRowCount = parseFloat($('#_proDelRowCount').val());

        // Optional: Capture values if needed
        if (proRowCount >= 0) {
            for (var i = 0; i <= proRowCount; i++) {
                if ($('#_productTableRow_' + i).length) {
                    var _productName = $('#_productName_' + i).val();
                    var _pack = $('#_pack_' + i).val();
                    var _qtyperpack = $('#_qtyperpack_' + i).val();
                    var _totqty = $('#_totqty_' + i).val();
                    var _freeqty = $('#_freeqty_' + i).val();                  
                    var _cost = $('#_cost_' + i).val();
                    var _mrp = $('#_mrp_' + i).val();
                    var _disc = $('#_disc_' + i).val();
                    var _tax = $('#_tax_' + i).val();
                    var _taxtotal = $('#_taxtotal_' + i).text();
                    var _unitcost = $('#_unitcost_' + i).text();

                    // Optionally do something with these values
                    //console.log(_productName + " added");
                }
            }
        }

        proRowCount++;
        proDelRowCount++;

        $("#productTable").append("<tr id='_productTableRow_" + proRowCount + "'>"
            + "<td class='text-center'><button type='button' class='tbl-icon-btn add' id='_addProcRow_" + proRowCount + "' name='_addProcRow_" + proRowCount + "' onclick='addProductRow();' disabled title='Add row'><i class='fas fa-plus' style='font-size:11px;'></i></button></td>"
            + "<td class='text-center'><button type='button' class='tbl-icon-btn del' id='_delProcRow_" + proRowCount + "' name='_delProcRow_" + proRowCount + "' onclick='deleteProductRow(this);' title='Delete row'><i class='fas fa-times' style='font-size:12px;'></i></button></td>"
            + "<td ><input type='text' class='form-control form-control-sm' id='_productName_" + proRowCount + "' name='_productName_" + proRowCount + "' placeholder='Product' onfocus='window._activeProductRow=" + proRowCount + ";autoComplete(event," + proRowCount + ",1);' onblur='getProductDetails(" + proRowCount + ",1);calculateRow(" + proRowCount + ");enableAddButton(" + proRowCount + ");'></td>"
            + "<td ><div class='d-flex flex-column'><div class='d-flex align-items-center gap-1'><input type='text' class='form-control form-control-sm' id='_totqty_" + proRowCount + "' name='_totqty_" + proRowCount + "' placeholder='Qty' value='0' style='min-width:0;width:100%;' onkeyup='calculateRow(" + proRowCount + ");tryAddProductRow(event," + proRowCount + ");'><span class='text-muted small' id='_totunit_" + proRowCount + "'></span></div><small class='text-primary' id='_convtotqty_" + proRowCount + "'></small><input type='hidden' id='_pack_" + proRowCount + "' name='_pack_" + proRowCount + "' value='1'><input type='hidden' id='_qtyperpack_" + proRowCount + "' name='_qtyperpack_" + proRowCount + "' value='0'></div></td>"
            + "<td ><div class='d-flex flex-column'><input type='text' class='form-control form-control-sm' id='_cost_" + proRowCount + "' name='_cost_" + proRowCount + "' placeholder='Cost' value='0.00' onkeyup='calculateRow(" + proRowCount + ");tryAddProductRow(event," + proRowCount + ");'><small class='text-info' id='_costperconv_" + proRowCount + "'></small></div></td>"
            + "<td ><div class='d-flex flex-column'><input type='text' class='form-control form-control-sm' id='_mrp_" + proRowCount + "' name='_mrp_" + proRowCount + "' placeholder='Mrp' value='0.00' onkeyup='calculateRow(" + proRowCount + ");tryAddProductRow(event," + proRowCount + ");'><small class='text-info' id='_mrpperconv_" + proRowCount + "'></small></div></td>"
            + "<td ><input type='text' class='form-control form-control-sm' id='_disc_" + proRowCount + "' name='_disc_" + proRowCount + "' placeholder='Disc' value='0' onkeyup='calculateRow(" + proRowCount + ");tryAddProductRow(event," + proRowCount + ");'></td>"
            + "<td ><input type='text' class='form-control form-control-sm' id='_tax_" + proRowCount + "' name='_tax_" + proRowCount + "' placeholder='Tax' value='0' onkeyup='calculateRow(" + proRowCount + ");tryAddProductRow(event," + proRowCount + ");'></td>"
            + "<td ><input type='text' class='form-control form-control-sm' id='_freeqty_" + proRowCount + "' name='_freeqty_" + proRowCount + "' placeholder='Free' value='0' onkeyup='calculateRow(" + proRowCount + ");tryAddProductRow(event," + proRowCount + ");'></td>"
            + "<td class='text-center'><button type='button' class='tbl-icon-btn hist' id='_historyBtn_" + proRowCount + "' onclick='viewPurchaseHistory(" + proRowCount + ");' title='Purchase history'><i class='fas fa-history' style='font-size:12px;'></i></button></td>"
            + "<td ><label id='_costtotal_" + proRowCount + "' name='costtotal" + proRowCount + "'>0.00</label></td>"
            + "<td ><label id='_mrptotal_" + proRowCount + "' name='_mrptotal_" + proRowCount + "'>0.00</label></td>"
            + "<td ><label id='_taxtotal_" + proRowCount + "' name='_taxtotal_" + proRowCount + "'>0.00</label></td>"
            + "<td ><label id='_nettotal_" + proRowCount + "' name='_nettotal_" + proRowCount + "'>0.00</label></td>"
            + "<td ><label id='_unitcost_" + proRowCount + "' name='_unitcost_" + proRowCount + "'>0.00</label></td>"
            + "</tr>");
            
        $('#_productTableRow_' + proRowCount).removeAttr('style'); // Remove any inline styles
        disableProductInputs(proRowCount);
        $('#_productName_' + proRowCount).focus();
        $('#_proAddRowCount').val(proRowCount);
        $('#_proDelRowCount').val(proDelRowCount);
    }
    
}
///////////////////////////////
function viewPurchaseHistory(rowIndex) {
    var productName = $('#_productName_' + rowIndex).val();
    
    if (!productName || productName.trim() == '') {
        Swal.fire({
            title: 'Product Required',
            text: 'Please select a product first.',
            icon: 'warning',
            confirmButtonText: 'OK'
        });
        $('#_productName_' + rowIndex).focus();
        return;
    }
    
    // Show modal
    var modal = new bootstrap.Modal(document.getElementById('purchaseHistoryModal'));
    modal.show();
    
    // Fetch history
    $.ajax({
        type: 'POST',
        url: contextPath + '/product/purchase/details.jsp',
        data: {
            status: 5,
            productName: productName
        },
        success: function(response) {
            $('#historyContent').html(response);
        },
        error: function() {
            $('#historyContent').html('<div class="alert alert-danger">Error loading purchase history</div>');
        }
    });
}
///////////////////////////////
function tryAddProductRow(event, rowIndex) {
    if ((event.keyCode || event.charCode) !== 13) return;
    var productId = parseInt($('#_productName_' + rowIndex).data('productId') || 0);
    if (productId > 0) addProductRow();
}
///////////////////////////////
function enableAddButton(rowIndex) {
    var productName = $('#_productName_' + rowIndex).val();
    if (productName && productName.trim() !== '') {
        $('#_addProcRow_' + rowIndex).prop('disabled', false);
    } else {
        $('#_addProcRow_' + rowIndex).prop('disabled', true);
    }
}
///////////////////////////////
function deleteProductRow(str) {

	var proDelRowCount = parseFloat($('#_proDelRowCount').val());

	if (proDelRowCount > 1) {
		$(str).closest('tr').remove();
		proDelRowCount--;
		$('#_proDelRowCount').val(proDelRowCount);
		calculateGrandTotal();
	}
}

////////////////////////////
// Calculate totals for a single product row
function calculateRow(rowIndex) {
    // Get values from inputs
    var totalQty = parseFloat($('#_totqty_' + rowIndex).val()) || 0;
    var free = parseFloat($('#_freeqty_' + rowIndex).val()) || 0;
    var cost = parseFloat($('#_cost_' + rowIndex).val()) || 0;
    var mrp = parseFloat($('#_mrp_' + rowIndex).val()) || 0;
    var disc = parseFloat($('#_disc_' + rowIndex).val()) || 0;
    var tax = parseFloat($('#_tax_' + rowIndex).val()) || 0;

    if (totalQty < 0) totalQty = 0;
    var qty = totalQty - free;
    if (qty < 0) qty = 0;
    $('#_pack_' + rowIndex).val(1);
    $('#_qtyperpack_' + rowIndex).val(totalQty.toFixed(3));

    // Calculate cost total
    var costTotal = qty * cost;
    // Discount amount
    var discAmt = costTotal * (disc / 100);
    // Tax amount
    var taxAmt = (costTotal - discAmt) * (tax / 100);
    // Net total
    var netTotal = costTotal - discAmt + taxAmt;
    // MRP total
    var mrpTotal = qty * mrp;
    // Unit price
    var unitPrice = (qty + free) > 0 ? netTotal / (qty + free) : 0;

    // Update labels
    $('#_costtotal_' + rowIndex).text(costTotal.toFixed(3));
    $('#_mrptotal_' + rowIndex).text(mrpTotal.toFixed(3));
    $('#_taxtotal_' + rowIndex).text(taxAmt.toFixed(3));
    $('#_nettotal_' + rowIndex).text(netTotal.toFixed(3));
    $('#_unitcost_' + rowIndex).text(unitPrice.toFixed(3));

    // Conversion unit display
    var convertionUnit = $('#_productName_' + rowIndex).data('convertionUnit') || '';
    var convertionCalc = parseFloat($('#_productName_' + rowIndex).data('convertionCalc')) || 1;
    if (convertionUnit && convertionCalc > 1) {
        var convQty = qty * convertionCalc;
        $('#_convtotqty_' + rowIndex).text('= ' + convQty.toFixed(2) + ' ' + convertionUnit);
        $('#_costperconv_' + rowIndex).text('/' + convertionUnit + ':' + (cost / convertionCalc).toFixed(3));
        $('#_mrpperconv_' + rowIndex).text('/' + convertionUnit + ':' + (mrp / convertionCalc).toFixed(3));
    } else {
        $('#_convtotqty_' + rowIndex).text('');
        $('#_costperconv_' + rowIndex).text('');
        $('#_mrpperconv_' + rowIndex).text('');
    }

    // Recalculate grand total
    calculateGrandTotal();
}

// Calculate grand total and update payment fields
function calculateGrandTotal() {
    var sumCostTotal = 0, sumMrpTotal = 0, sumTaxTotal = 0, sumNetTotal = 0;
    $('#productTable tr').each(function() {
        var rowId = $(this).attr('id');
        if (rowId) {
            var idx = rowId.split('_').pop();
            var cost = parseFloat($('#_costtotal_' + idx).text()) || 0;
            var mrp = parseFloat($('#_mrptotal_' + idx).text()) || 0;
            var tax = parseFloat($('#_taxtotal_' + idx).text()) || 0;
            var net = parseFloat($('#_nettotal_' + idx).text()) || 0;
            sumCostTotal += cost;
            sumMrpTotal += mrp;
            sumTaxTotal += tax;
            sumNetTotal += net;
        }
    });

    // Update summary fields in table footer
    $('#sumCostTotal').text(sumCostTotal.toFixed(3));
    $('#sumMrpTotal').text(sumMrpTotal.toFixed(3));
    $('#sumTaxTotal').text(sumTaxTotal.toFixed(3));
    $('#sumNetTotal').text(sumNetTotal.toFixed(3));

    // Extra discount
    var extraDisc = parseFloat($('#extraDisc').val()) || 0;
    var grandTotal = sumNetTotal - extraDisc;
    var paidAmount = parseFloat($('#paidAmount').val()) || 0;
    var advancePaid = parseFloat($('#advancePaid').val()) || 0;
    
    // Calculate balance: grand total - paid now - advance paid
    var balance = grandTotal - paidAmount - advancePaid;

    $('#grandTotal').val(grandTotal.toFixed(3));
    $('#balanceAmount').val(balance.toFixed(3));
}

// Recalculate totals when payment fields change
$('#paidAmount, #extraDisc').on('input', function() {
    calculateGrandTotal();
});
//////////////////////////
function savePurchaseBill()
{
    var btn = $('#saveBtn');
    var invArr = '';
    var payArr = '';
    var prodArr= '';

    var supplier    = $('#supplier').val() || '0';
    var invoiceNo   = $('#invoiceNo').val();
    var invoiceDate = $('#invoiceDate').val();
    var offer       = $('#offer').val() || '';
    var offerDate   = $('#offerDate').val() || '';
    var lrNo        = $('#lrNo').val() || '';
    var lrDate      = $('#lrDate').val() || '';
    var lrName      = $('#lrName').val() || '';
    var payType     = $('#payType').val() || '0';
    var bank        = $('#bank').val() || '0';
    var paidAmount  = parseFloat($('#paidAmount').val()) || 0;
    var extraDisc   = parseFloat($('#extraDisc').val()) || 0;
    var grandTotal  = parseFloat($('#grandTotal').val()) || 0;
    var balanceAmount= parseFloat($('#balanceAmount').val()) || 0;

    if (supplier == '0') {
        Swal.fire({
            title: 'Validation Error',
            text: 'Please select supplier name.',
            icon: 'error',
            confirmButtonText: 'OK'
        });
        $('#supplier').focus();
        return false;
    }
    
    // Proceed with purchase save
    btn.prop('disabled', true);
    proceedWithPurchaseSave();
}

function proceedWithPurchaseSave() {
    var btn = $('#saveBtn');
    var invArr = '';
    var payArr = '';
    var prodArr= '';

    var supplier    = $('#supplier').val() || '0';
    var invoiceNo   = $('#invoiceNo').val();
    var invoiceDate = $('#invoiceDate').val();
    var offer       = $('#offer').val() || '';
    var offerDate   = $('#offerDate').val() || '';
    var lrNo        = $('#lrNo').val() || '';
    var lrDate      = $('#lrDate').val() || '';
    var lrName      = $('#lrName').val() || '';
    var payType     = $('#payType').val() || '0';
    var bank        = $('#bank').val() || '0';
    var paidAmount  = parseFloat($('#paidAmount').val()) || 0;
    var extraDisc   = parseFloat($('#extraDisc').val()) || 0;
    var grandTotal  = parseFloat($('#grandTotal').val()) || 0;
    var balanceAmount= parseFloat($('#balanceAmount').val()) || 0;
    
    if (invoiceNo.trim() == '') {
        Swal.fire({
            title: 'Validation Error',
            text: 'Please enter invoice number.',
            icon: 'error',
            confirmButtonText: 'OK'
        });
        $('#invoiceNo').focus();
        btn.prop('disabled', false);
        return false;
    }
    if (invoiceDate.trim() == '') {
        Swal.fire({
            title: 'Validation Error',
            text: 'Please select invoice date.',
            icon: 'error',
            confirmButtonText: 'OK'
        });
        $('#invoiceDate').focus();
        btn.prop('disabled', false);
        return false;
    }
    if (payType == '0') {
        Swal.fire({
            title: 'Validation Error',
            text: 'Please select payment mode.',
            icon: 'error',
            confirmButtonText: 'OK'
        });
        $('#payType').focus();
        btn.prop('disabled', false);
        return false;
    }
    if (payType != '0' && payType != '1' && bank == '0') {
        Swal.fire({
            title: 'Validation Error',
            text: 'Please select payment mode (Bank details).',
            icon: 'error',
            confirmButtonText: 'OK'
        });
        $('#bank').focus();
        btn.prop('disabled', false);
        return false;
    }
    if (paidAmount >= 1) {
        if (payType != '1' && bank == '0') {
            Swal.fire({
                title: 'Validation Error',
                
                icon: 'error',
                confirmButtonText: 'OK'
            });
            $('#bank').focus();
            btn.prop('disabled', false);
            return false;
        }
    }
    if (grandTotal <= 0) {
        Swal.fire({
            title: 'Validation Error',
            text: 'Grand total must be greater than zero.',
            icon: 'error',
            confirmButtonText: 'OK'
        });
        return false;
    } 
    if (paidAmount < 0) {
        Swal.fire({
            title: 'Validation Error',
            text: 'Paid amount cannot be negative.',
            icon: 'error',
            confirmButtonText: 'OK'
        });
        $('#paidAmount').focus();
        return false;
    }
    if (balanceAmount < 0) {
        Swal.fire({
            title: 'Validation Error',
            text: 'Balance amount cannot be negative.',
            icon: 'error',
            confirmButtonText: 'OK'
        });
        $('#paidAmount').focus();
        return false;
    }
    btn.prop('disabled', true);

    var proRowCount = parseFloat($('#_proAddRowCount').val());
    var mode = $('#mode').val() || 'standalone';
    
    if(proRowCount < 0) { 
        Swal.fire({
            title: 'Validation Error',
            text: 'Please add at least one product.',
            icon: 'error',
            confirmButtonText: 'OK'
        });
        btn.prop('disabled', false);
        return false;
    }
    
    if(proRowCount >=0) { 
        for (var i = 0; i <= proRowCount; i++) {
            if ($('#_productTableRow_' + i).length) {
                var _productName = $('#_productName_' + i).data('productName') || $('#_productName_' + i).val().trim();
                var _pack = parseFloat($('#_pack_' + i).val()) || 0;
                var _qtyperpack = parseFloat($('#_qtyperpack_' + i).val()) || 0;
                var _totqty = parseFloat($('#_totqty_' + i).val()) || 0;
                var _freeqty = parseFloat($('#_freeqty_' + i).val()) || 0;                  
                var _cost = parseFloat($('#_cost_' + i).val()) || 0;
                var _mrp = parseFloat($('#_mrp_' + i).val()) || 0;
                var _disc = parseFloat($('#_disc_' + i).val()) || 0;
                var _tax = parseFloat($('#_tax_' + i).val()) || 0;
                var _poDetailId = $('#_poDetailId_' + i).val() || '0';
                var _pendingQty = parseFloat($('#_pendingQty_' + i).val()) || 0;
                
                // Skip products with 0 quantity
                if (_totqty <= 0) {
                    continue;
                }
                
                // Skip if product name is empty
                if (_productName == '') {
                    continue;
                }
                
                // Validate MRP is filled
                if (_mrp <= 0) {
                    Swal.fire({
                        title: 'Validation Error',
                        text: 'Product "' + _productName + '" - Please enter MRP (Maximum Retail Price).',
                        icon: 'error',
                        confirmButtonText: 'OK'
                    });
                    $('#_mrp_' + i).focus();
                    btn.prop('disabled', false);
                    return false;
                }
                
                // Validate pending quantity for PO items
                if (mode === 'from-po' && _poDetailId !== '0' && _pendingQty > 0) {
                    if (_totqty > _pendingQty) {
                        Swal.fire({
                            title: 'Validation Error',
                            text: 'Product "' + _productName + '" - Cannot receive ' + _totqty + ' units. Pending quantity is only ' + _pendingQty + ' units.',
                            icon: 'error',
                            confirmButtonText: 'OK'
                        });
                        btn.prop('disabled', false);
                        return false;
                    }
                }

                // Add product to array
                var _convertionCalc = parseFloat($('#_productName_' + i).data('convertionCalc')) || 1;
                var _productId = parseInt($('#_productName_' + i).data('productId')) || 0;
                prodArr += _productName + '<#>' + _pack + '<#>' + _qtyperpack + '<#>' + _totqty + '<#>' + _freeqty + '<#>' + _cost + '<#>' + _mrp + '<#>' + _disc + '<#>' + _tax + '<#>' + _poDetailId + '<#>' + _convertionCalc + '<#>' + _productId + '<@>';
            }
        }
        
        // Validate product array
        if (prodArr.trim() === '') {
            Swal.fire({
                title: 'Validation Error',
                text: 'Please add at least one product with quantity.',
                icon: 'error',
                confirmButtonText: 'OK'
            });
            btn.prop('disabled', false);
            return false;
        }
        
        var status = 4;
        var poId = $('#poId').val() || '0';
        var mode = $('#mode').val() || 'standalone';
        
        // Debug: Log offer values
        console.log('Offer:', offer, 'Offer Date:', offerDate);
        
        //var param = 'status=' + status + '&productName=' + encodeURIComponent(productName.trim());
        invArr  = supplier + '<#>' +invoiceNo+ '<#>' +invoiceDate+ '<#>' +offer+ '<#>' +offerDate+ '<#>' +lrNo+ '<#>' +lrDate+ '<#>' +lrName;
        
        // Debug: Log invArr
        console.log('invArr:', invArr);
        
        payArr  = payType+ '<#>' +bank+ '<#>' +grandTotal+ '<#>' +paidAmount+ '<#>' +extraDisc+ '<#>' +balanceAmount;
        var param   = 'status=' +status+ '&invArr=' +encodeURIComponent(invArr)+ '&payArr=' +encodeURIComponent(payArr)+ '&prodArr=' +encodeURIComponent(prodArr)+ '&poId=' +poId+ '&mode=' +mode;

        $.ajax({
            type: "POST",
            url: contextPath + "/product/purchase/details.jsp",
            data: param,
            success: function (_result) {
                console.log("Server response:", _result);
                
                // Check for error message
                if (_result && _result.trim().startsWith('ERROR:')) {
                    var errorMsg = _result.trim().substring(7); // Remove 'ERROR: ' prefix
                    Swal.fire({
                        title: 'Error',
                        text: errorMsg,
                        icon: 'error',
                        confirmButtonText: 'OK'
                    });
                    btn.prop('disabled', false);
                } else if (_result && _result.trim() !== '' && _result.trim() !== '0') {
                    Swal.fire({
                        title: 'Purchase Saved!',
                        text: 'Purchase bill saved successfully. Bill No: ' + _result.trim(),
                        icon: 'success',
                        confirmButtonText: 'OK'
                    }).then(function() {
                        // Redirect to standalone purchase page (remove poId from URL)
                        window.location.href = contextPath + '/product/purchase/page.jsp';
                    });
                } else {
                    Swal.fire({
                        title: 'Error',
                        text: 'Failed to save purchase. Server returned: ' + _result,
                        icon: 'error',
                        confirmButtonText: 'OK'
                    });
                    btn.prop('disabled', false);
                }
            },
            error: function(xhr, status, error) {
                console.error("AJAX Error:", status, error);
                console.error("Response:", xhr.responseText);
                Swal.fire({
                    title: 'Error',
                    text: 'Failed to save purchase bill. Error: ' + error,
                    icon: 'error',
                    confirmButtonText: 'OK'
                });
                btn.prop('disabled', false);
            }
        });
    } else {
        Swal.fire({
            title: 'Validation Error',
            text: 'Please add products to save.',
            icon: 'warning',
            confirmButtonText: 'OK'
        });
        btn.prop('disabled', false);
    }
}
