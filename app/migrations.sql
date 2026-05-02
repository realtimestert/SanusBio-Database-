-- SanusBio Migrations
-- Run AFTER importing sanusbio_database_schema.sql
-- Safe to re-run: uses IF NOT EXISTS where possible

USE sanusbio;

SET FOREIGN_KEY_CHECKS=0;

-- Add AUTO_INCREMENT to primary keys that were missing it
ALTER TABLE `address`
  MODIFY COLUMN `address_id` INT NOT NULL AUTO_INCREMENT;

ALTER TABLE `medical_info`
  MODIFY COLUMN `medical_info_id` INT NOT NULL AUTO_INCREMENT;

ALTER TABLE `estrus_check_log`
  MODIFY COLUMN `estrus_check_log_id` INT NOT NULL AUTO_INCREMENT;

ALTER TABLE `females_to_mate`
  MODIFY COLUMN `females_to_mate_id` INT NOT NULL AUTO_INCREMENT;

ALTER TABLE `health_log`
  MODIFY COLUMN `health_log_id` INT NOT NULL AUTO_INCREMENT;

ALTER TABLE `ferret_qr005`
  MODIFY COLUMN `Ferret_QR005_id` INT NOT NULL AUTO_INCREMENT;

-- Add sex column
ALTER TABLE `ferret_qr005`
  ADD COLUMN IF NOT EXISTS `sex` ENUM('male','female') NULL DEFAULT NULL;

-- Fix supplier phone: INT overflows on 10-digit numbers
ALTER TABLE `supplier`
  MODIFY COLUMN `supplier_phone_number` VARCHAR(20) NULL DEFAULT NULL;

SET FOREIGN_KEY_CHECKS=1;