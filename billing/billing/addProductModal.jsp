<!-- Add Product Modal (fields & rules aligned with product master) -->
<div class="modal fade" id="addProductModal" tabindex="-1" aria-labelledby="addProductModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header mst-card-header py-2">
                <h6 class="modal-title mb-0" id="addProductModalLabel">
                    <i class="fas fa-plus-circle me-2"></i>Add New <%=head3%>
                </h6>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body py-2">
                <form id="billAddProductForm" class="row g-2">
                    <div class="col-md-6">
                        <label class="form-label mb-1" style="font-size:0.85rem;"><%=head1%> <span class="text-danger">*</span></label>
                        <select name="categoryId" id="billAdd_categoryId" class="form-select form-select-sm" required>
                            <option value="">Select <%=head1%></option>
                            <%
                                Vector billAddCategories = prod.getCategoryName();
                                if (billAddCategories != null) {
                                    for (int i = 0; i < billAddCategories.size(); i++) {
                                        Vector cat = (Vector) billAddCategories.get(i);
                                        if (cat != null && cat.size() >= 2 && cat.elementAt(0) != null && cat.elementAt(1) != null) {
                            %>
                            <option value="<%=cat.elementAt(1)%>"><%=cat.elementAt(0)%></option>
                            <%      }
                                    }
                                }
                            %>
                        </select>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label mb-1" style="font-size:0.85rem;"><%=head2%> <span class="text-danger">*</span></label>
                        <select name="brandId" id="billAdd_brandId" class="form-select form-select-sm" required>
                            <option value="">Select <%=head2%></option>
                            <%
                                Vector billAddBrands = prod.getBrandsName();
                                String billOthersBrandId = "";
                                if (billAddBrands != null) {
                                    for (int i = 0; i < billAddBrands.size(); i++) {
                                        Vector brand = (Vector) billAddBrands.get(i);
                                        if (brand != null && brand.size() >= 2 && brand.elementAt(0) != null && brand.elementAt(1) != null) {
                                            String brandName = brand.elementAt(0).toString();
                                            String brandId = brand.elementAt(1).toString();
                                            if (brandName.equalsIgnoreCase("others") || brandName.equalsIgnoreCase("other")) {
                                                billOthersBrandId = brandId;
                                            }
                            %>
                            <option value="<%=brandId%>" <%=brandId.equals(billOthersBrandId) && !billOthersBrandId.isEmpty() ? "selected" : ""%>><%=brandName%></option>
                            <%      }
                                    }
                                }
                            %>
                        </select>
                    </div>
                    <div class="col-md-12">
                        <label class="form-label mb-1" style="font-size:0.85rem;"><%=head3%> Name <span class="text-danger">*</span></label>
                        <input type="text" name="productName" id="billAdd_productName" class="form-control form-control-sm" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label mb-1" style="font-size:0.85rem;"><%=head3%> Code</label>
                        <input type="text" name="productCode" id="billAdd_productCode" class="form-control form-control-sm" placeholder="">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label mb-1" style="font-size:0.85rem;">HSN Code</label>
                        <input type="text" name="hsn" id="billAdd_hsn" class="form-control form-control-sm">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label mb-1" style="font-size:0.85rem;">Unit/Size <span class="text-danger">*</span></label>
                        <select name="unitId" id="billAdd_unitSelect" class="form-select form-select-sm" required>
                            <option value="">Select Unit/Size</option>
                            <%
                                Vector billAddUnits = prod.getUnits();
                                if (billAddUnits != null) {
                                    for (int i = 0; i < billAddUnits.size(); i++) {
                                        Vector unit = (Vector) billAddUnits.get(i);
                                        if (unit != null && unit.size() >= 2 && unit.elementAt(0) != null && unit.elementAt(1) != null) {
                                            String unitName = unit.elementAt(0).toString();
                                            String unitId = unit.elementAt(1).toString();
                                            String convertionUnit = (unit.size() > 2 && unit.elementAt(2) != null) ? unit.elementAt(2).toString() : "";
                                            String convertionCalculation = (unit.size() > 3 && unit.elementAt(3) != null) ? unit.elementAt(3).toString() : "";
                                            String selected = (unitName.equalsIgnoreCase("Nos") || unitName.equalsIgnoreCase("NOS") || unitName.equalsIgnoreCase("PCS")) ? "selected" : "";
                            %>
                            <option value="<%=unitId%>" data-convertion-unit="<%=convertionUnit%>" data-convertion-calculation="<%=convertionCalculation%>" <%=selected%>><%=unitName%></option>
                            <%      }
                                    }
                                }
                            %>
                        </select>
                    </div>
                    <div class="col-md-6">
                        <label id="billAdd_stockLabel" class="form-label mb-1" style="font-size:0.85rem;">Stock <span class="text-danger">*</span></label>
                        <input type="number" name="stock" id="billAdd_stockInput" class="form-control form-control-sm" min="0" step="0.01" value="0" required>
                        <small id="billAdd_stockConversionNote" class="text-muted d-block mt-1"></small>
                    </div>
                    <div class="col-md-6">
                        <label id="billAdd_costPriceLabel" class="form-label mb-1" style="font-size:0.85rem;">Cost Price <span class="text-danger">*</span></label>
                        <input type="number" name="cost" id="billAdd_costInput" class="form-control form-control-sm" step="0.001" required>
                        <small id="billAdd_costConversionNote" class="text-muted d-block mt-1"></small>
                    </div>
                    <div class="col-md-6">
                        <label id="billAdd_mrpLabel" class="form-label mb-1" style="font-size:0.85rem;">MRP <span class="text-danger">*</span></label>
                        <input type="number" name="mrp" id="billAdd_mrpInput" class="form-control form-control-sm" step="0.001" required>
                        <small id="billAdd_mrpConversionNote" class="text-muted d-block mt-1"></small>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label mb-1" style="font-size:0.85rem;">Commission (Rs)</label>
                        <input type="number" name="commission" id="billAdd_commissionInput" class="form-control form-control-sm" step="0.001" value="0.000">
                        <small id="billAdd_commissionConversionNote" class="text-muted d-block mt-1"></small>
                    </div>
                    <input type="hidden" name="discType" id="billAdd_discType" value="0">
                    <input type="hidden" name="discValue" id="billAdd_discValue" value="0.00">
                    <div class="col-md-6">
                        <label class="form-label mb-1" style="font-size:0.85rem;">GST % <span class="text-danger">*</span></label>
                        <select name="gst" id="billAdd_gst" class="form-select form-select-sm" required>
                            <option value="">Select GST %</option>
                            <option value="0" selected>0%</option>
                            <option value="5">5%</option>
                            <option value="12">12%</option>
                            <option value="18">18%</option>
                            <option value="28">28%</option>
                        </select>
                    </div>
                </form>
            </div>
            <div class="modal-footer py-2">
                <button type="button" class="bb bb-outline btn-sm" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="bb bb-primary btn-sm" id="billAdd_saveBtn" onclick="saveBillingAddProductModal()">
                    <i class="fas fa-save me-1"></i>Save <%=head3%>
                </button>
            </div>
        </div>
    </div>
</div>
