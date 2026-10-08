/** Add-product modal logic — aligned with product/master/product/product.jsp */
let billAddMaxProductCode = '';

function billAddApplyMaxProductCode() {
    const codeInput = document.getElementById('billAdd_productCode');
    if (codeInput) {
        codeInput.placeholder = billAddMaxProductCode || '';
    }
}

function billAddUpdateStockConversionNote() {
    const unitSelect = document.getElementById('billAdd_unitSelect');
    const stockInput = document.getElementById('billAdd_stockInput');
    const note = document.getElementById('billAdd_stockConversionNote');
    if (!unitSelect || !stockInput || !note) return;

    const selectedOption = unitSelect.options[unitSelect.selectedIndex];
    if (!selectedOption || unitSelect.value === '') {
        note.textContent = '';
        return;
    }

    const convertionUnit = selectedOption.getAttribute('data-convertion-unit') || '';
    const convertionCalculation = parseFloat(selectedOption.getAttribute('data-convertion-calculation') || '0');
    const baseUnitName = selectedOption.text;
    const stockValue = parseFloat(stockInput.value || '0');

    if (convertionUnit.trim() === '' || isNaN(convertionCalculation) || convertionCalculation <= 0) {
        note.textContent = '';
        return;
    }

    if (!isNaN(stockValue) && stockValue > 0) {
        const convertedStock = stockValue * convertionCalculation;
        note.textContent = 'Converted: ' + convertedStock.toFixed(3) + ' ' + convertionUnit + ' (' + stockValue + ' x ' + convertionCalculation + ')';
    } else {
        note.textContent = 'Enter stock: how many ' + convertionUnit + ' per ' + baseUnitName + '.';
    }
}

function billAddUpdateConvertedPriceNotes() {
    const unitSelect = document.getElementById('billAdd_unitSelect');
    const costInput = document.getElementById('billAdd_costInput');
    const mrpInput = document.getElementById('billAdd_mrpInput');
    const commissionInput = document.getElementById('billAdd_commissionInput');
    const costNote = document.getElementById('billAdd_costConversionNote');
    const mrpNote = document.getElementById('billAdd_mrpConversionNote');
    const commissionNote = document.getElementById('billAdd_commissionConversionNote');
    if (!unitSelect || !costInput || !mrpInput || !commissionInput || !costNote || !mrpNote || !commissionNote) return;

    const selectedOption = unitSelect.options[unitSelect.selectedIndex];
    if (!selectedOption || unitSelect.value === '') {
        costNote.textContent = '';
        mrpNote.textContent = '';
        commissionNote.textContent = '';
        return;
    }

    const convertionUnit = selectedOption.getAttribute('data-convertion-unit') || '';
    const convertionCalculation = parseFloat(selectedOption.getAttribute('data-convertion-calculation') || '0');
    const costValue = parseFloat(costInput.value || '0');
    const mrpValue = parseFloat(mrpInput.value || '0');
    const commissionValue = parseFloat(commissionInput.value || '0');

    if (convertionUnit.trim() === '' || isNaN(convertionCalculation) || convertionCalculation <= 0) {
        costNote.textContent = '';
        mrpNote.textContent = '';
        commissionNote.textContent = '';
        return;
    }

    if (!isNaN(costValue) && costValue > 0) {
        costNote.textContent = 'Converted Cost per ' + convertionUnit + ': ' + (costValue / convertionCalculation).toFixed(3);
    } else {
        costNote.textContent = '';
    }

    if (!isNaN(mrpValue) && mrpValue > 0) {
        mrpNote.textContent = 'Converted MRP per ' + convertionUnit + ': ' + (mrpValue / convertionCalculation).toFixed(3);
    } else {
        mrpNote.textContent = '';
    }

    if (!isNaN(commissionValue) && commissionValue > 0) {
        commissionNote.textContent = 'Converted Commission per ' + convertionUnit + ': ' + (commissionValue / convertionCalculation).toFixed(3);
    } else {
        commissionNote.textContent = '';
    }
}

function billAddHandleUnitChange(select) {
    const selectedText = select.options[select.selectedIndex].text;
    const stockLabel = document.getElementById('billAdd_stockLabel');
    const costPriceLabel = document.getElementById('billAdd_costPriceLabel');
    const mrpLabel = document.getElementById('billAdd_mrpLabel');

    if (select.value === '') {
        stockLabel.textContent = 'Stock';
        costPriceLabel.innerHTML = 'Cost Price <span class="text-danger">*</span>';
        mrpLabel.innerHTML = 'MRP <span class="text-danger">*</span>';
    } else {
        stockLabel.textContent = 'Stock (' + selectedText + ')';
        costPriceLabel.innerHTML = 'Cost Price per ' + selectedText + ' <span class="text-danger">*</span>';
        mrpLabel.innerHTML = 'MRP per ' + selectedText + ' <span class="text-danger">*</span>';
    }

    billAddUpdateStockConversionNote();
    billAddUpdateConvertedPriceNotes();
}

function resetBillingAddProductForm() {
    const form = document.getElementById('billAddProductForm');
    if (!form) return;
    form.reset();

    document.getElementById('billAdd_discType').value = '0';
    document.getElementById('billAdd_discValue').value = '0.00';
    document.getElementById('billAdd_stockInput').value = '0';
    document.getElementById('billAdd_commissionInput').value = '0.000';

    const unitSelect = document.getElementById('billAdd_unitSelect');
    for (let opt of unitSelect.options) {
        if (opt.text === 'NOS' || opt.text === 'Nos' || opt.text === 'PCS') {
            opt.selected = true;
            break;
        }
    }

    const brandSelect = document.getElementById('billAdd_brandId');
    for (let opt of brandSelect.options) {
        if (opt.text.toLowerCase() === 'others' || opt.text.toLowerCase() === 'other') {
            opt.selected = true;
            break;
        }
    }

    const gstSelect = document.getElementById('billAdd_gst');
    for (let opt of gstSelect.options) {
        if (opt.value === '0') {
            opt.selected = true;
            break;
        }
    }

    document.getElementById('billAdd_stockConversionNote').textContent = '';
    document.getElementById('billAdd_costConversionNote').textContent = '';
    document.getElementById('billAdd_mrpConversionNote').textContent = '';
    document.getElementById('billAdd_commissionConversionNote').textContent = '';

    billAddHandleUnitChange(unitSelect);
    billAddApplyMaxProductCode();
}

function openBillingAddProductModal() {
    resetBillingAddProductForm();

    const typedName = (document.getElementById('productName').value || '').trim();
    const typedCode = (document.getElementById('productCode').value || '').trim();
    if (typedName) {
        document.getElementById('billAdd_productName').value = typedName;
    }
    if (typedCode) {
        document.getElementById('billAdd_productCode').value = typedCode;
    }

    fetch(contextPath + '/product/master/product/getProducts.jsp?page=1&pageSize=1')
        .then(function (r) { return r.json(); })
        .then(function (data) {
            if (data.success) {
                billAddMaxProductCode = data.maxProductCode || '';
                billAddApplyMaxProductCode();
            }
        })
        .catch(function () { /* ignore */ });

    const modalEl = document.getElementById('addProductModal');
    const modal = bootstrap.Modal.getOrCreateInstance(modalEl);
    modal.show();
    setTimeout(function () {
        const nameField = document.getElementById('billAdd_productName');
        if (nameField) nameField.focus();
    }, 400);
}

function saveBillingAddProductModal() {
    const form = document.getElementById('billAddProductForm');
    if (!form.checkValidity()) {
        form.reportValidity();
        return;
    }

    const btn = document.getElementById('billAdd_saveBtn');
    const btnDefaultHtml = btn.getAttribute('data-default-html') || btn.innerHTML;
    btn.setAttribute('data-default-html', btnDefaultHtml);
    btn.disabled = true;
    btn.innerHTML = '<i class="fas fa-spinner fa-spin me-1"></i>Saving...';

    const payload = {
        productName: document.getElementById('billAdd_productName').value.trim(),
        categoryId: document.getElementById('billAdd_categoryId').value,
        brandId: document.getElementById('billAdd_brandId').value,
        productCode: document.getElementById('billAdd_productCode').value.trim(),
        hsn: document.getElementById('billAdd_hsn').value.trim(),
        unitId: document.getElementById('billAdd_unitSelect').value,
        stock: document.getElementById('billAdd_stockInput').value || '0',
        cost: document.getElementById('billAdd_costInput').value,
        mrp: document.getElementById('billAdd_mrpInput').value,
        gst: document.getElementById('billAdd_gst').value,
        discType: document.getElementById('billAdd_discType').value,
        discValue: document.getElementById('billAdd_discValue').value || '0',
        commission: document.getElementById('billAdd_commissionInput').value || '0'
    };

    $.ajax({
        type: 'POST',
        url: contextPath + '/product/purchase/saveProductAjax.jsp',
        data: payload,
        dataType: 'json',
        success: function (res) {
            if (res.success) {
                bootstrap.Modal.getInstance(document.getElementById('addProductModal')).hide();
                Swal.fire({
                    title: 'Product Added!',
                    text: res.productName + (res.productCode && res.productCode !== '0' ? ' (' + res.productCode + ')' : ''),
                    icon: 'success',
                    timer: 1800,
                    showConfirmButton: false
                });

                if (res.productCode && res.productCode !== '0') {
                    document.getElementById('productCode').value = res.productCode;
                    if (typeof fetchProductDetails === 'function') {
                        fetchProductDetails(res.productCode);
                    }
                } else if (res.productName && typeof fetchProductDetailsByName === 'function') {
                    document.getElementById('productName').value = res.productName;
                    fetchProductDetailsByName(res.productName);
                }
            } else {
                Swal.fire({ title: 'Error', text: res.message || 'Failed to add product.', icon: 'error' });
            }
        },
        error: function () {
            Swal.fire({ title: 'Error', text: 'Server error. Please try again.', icon: 'error' });
        },
        complete: function () {
            btn.disabled = false;
            btn.innerHTML = btn.getAttribute('data-default-html') || btnDefaultHtml;
        }
    });
}

document.addEventListener('DOMContentLoaded', function () {
    const unitSelect = document.getElementById('billAdd_unitSelect');
    const stockInput = document.getElementById('billAdd_stockInput');
    const costInput = document.getElementById('billAdd_costInput');
    const mrpInput = document.getElementById('billAdd_mrpInput');
    const commissionInput = document.getElementById('billAdd_commissionInput');

    if (unitSelect) {
        unitSelect.addEventListener('change', function () { billAddHandleUnitChange(this); });
        billAddHandleUnitChange(unitSelect);
    }
    if (stockInput) stockInput.addEventListener('input', billAddUpdateStockConversionNote);
    if (costInput) costInput.addEventListener('input', billAddUpdateConvertedPriceNotes);
    if (mrpInput) mrpInput.addEventListener('input', billAddUpdateConvertedPriceNotes);
    if (commissionInput) commissionInput.addEventListener('input', billAddUpdateConvertedPriceNotes);
});
