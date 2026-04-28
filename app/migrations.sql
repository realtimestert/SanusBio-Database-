-- SanusBio Migrations
-- Run AFTER importing sanusbio_database_schema.sql
-- Adds AUTO_INCREMENT to primary key columns that were missing it

USE sanusbio;

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