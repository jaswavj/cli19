-- Store the unit shown on billing (e.g. NOS, Gram, KG) with each hold line.
-- Required by saveQuotation / HOLD. Safe to skip if the column already exists.

ALTER TABLE `prod_quotation_details`
  ADD COLUMN `display_unit` VARCHAR(50) NULL DEFAULT NULL AFTER `qty`;
