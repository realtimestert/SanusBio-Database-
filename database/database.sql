-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema SanusBio
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema SanusBio
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `SanusBio` DEFAULT CHARACTER SET utf8 ;
USE `SanusBio` ;


-- -----------------------------------------------------
-- Table `SanusBio`.`Ferret_QR005`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SanusBio`.`Ferret_QR005` (
  `Ferret_QR005_id` INT NOT NULL,
  `animal_id` INT NOT NULL,
  `ferret_name` VARCHAR(45) NOT NULL,
  `rfid_change_log` VARCHAR(1000) NULL,
  `location_change_log` VARCHAR(1000) NULL,
  -- Foreign Key `Address` VARCHAR(45) NULL,
  `birth_date` DATE NOT NULL,
  `death_date` DATE NULL,
  `acquisition_by` VARCHAR(45) NULL,
  `weight` INT NOT NULL,
  `next_rabies_vaccine_due` DATE NOT NULL,
  `description` VARCHAR(45) NULL,
  `mother` VARCHAR(45) NULL,
  `father` VARCHAR(45) NULL,
  `mother_id` VARCHAR(45) NULL,
  `father_id` VARCHAR(45) NULL,
  `supplier` VARCHAR(45) NULL,
  `last_move_to_winter` DATE NULL,
  `last_winter_cycle_completion` DATE NULL,
  `last_move_to_summer` DATE NULL,
  `move_in` DATETIME NULL,
  `move_out` DATETIME NULL,
  `winter_start` DATETIME NULL,
  `winter_end` DATETIME NULL,
  `time_in_winter` INT
    GENERATED ALWAYS AS (
      GREATEST(
        0,
        DATEDIFF(
          LEAST(COALESCE(move_out, winter_end), winter_end),
          GREATEST(move_in, winter_start)
        )
      )
    ) STORED,
  
  /* Age in weeks – stops aging after death */
  `age_wks` INT
    GENERATED ALWAYS AS (
      FLOOR(
        DATEDIFF(
          COALESCE(`death_date`, CURDATE()),
          `birth_date`
        ) / 7
      )
    ) VIRTUAL,
  `distribution_date` DATE NULL,
  `clip_nails` ENUM('0','1') NULL,
  `bath` ENUM('0','1') NULL,
  `animal_rfid` VARCHAR(15) NULL,
  `litter_id` VARCHAR(7) NULL,
  `litter_date` DATE NULL,
  `hob_code` VARCHAR(8) NOT NULL,
  `purchase_id` VARCHAR(45) NULL,
  `created_by` VARCHAR(45) NULL,
  `dead` ENUM('0','1') NULL,
  PRIMARY KEY (`Ferret_QR005_id`)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `SanusBio`.`medical_info`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SanusBio`.`medical_info` (
  `medical_info_id` INT NOT NULL,
  `rabies_vaccination_date` DATE NULL,
  `rabies_vaccination_date_last` DATE NULL,
  `distemper_vaccination_date_last` DATE NULL,
  `distember_vaccination_date_previous` DATE NULL,
  `castration_or_spay_date` DATE NULL,
  `castrated_or_spayed` ENUM('y', 'n') NULL,
  `descent_date` DATE NULL,
  `test_collected_last_30_days` VARCHAR(255) NULL,
  `test_result_last_30_days` VARCHAR(255) NULL,
  -- Big Calculation `Coefficient of Inbreeding` VARCHAR(45) NULL,
  `weight_loss_or_gain` VARCHAR(45) NULL,
  `lifetime_%_litters/mating` VARCHAR(45) NULL,
  `surgical_procedure_log` VARCHAR(1000) NULL,
  `dead` ENUM('y', 'n'),
  `date_of_death` DATE NULL,
  `cause_of_death` VARCHAR(255) NULL,
  `treatments` VARCHAR(255) NULL,
  `exam_log` VARCHAR(1000) NULL,
  `last_exam_date` DATE NULL,
  `orders` VARCHAR(200) NULL,
  -- needs foreign keys to populate data
  PRIMARY KEY (`medical_info_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `SanusBio`,`address`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SanusBio`.`address` (
  `address_id` INT NOT NULL,
  `room_id` INT NOT NULL,
  `cage_address` VARCHAR(5),
  `room_lighting` VARCHAR(45) NULL,
  `maintenance` VARCHAR(255) NULL,
  PRIMARY KEY (`address_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `SanusBio`,`health_log`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SanusBio`.`health_log` (
  `health_log_id` INT NOT NULL,
  `nail_trim_log` VARCHAR(1000),
  `weight_log` VARCHAR(1000),
  `bath_history` VARCHAR(1000),
  PRIMARY KEY (`health_log_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `SanusBio`.`estrus_&_mating_summary`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SanusBio`.`estrus_&_mating_summary` (
  `estrus_&_mating_summary_id` INT NOT NULL,
  -- foreign key to aninmals `animal_id` VARCHAR(45) NULL,
  `mating_restriction` VARCHAR(45) NULL,
  `unconfirmed_estrus` DATE NULL,
  `confirmed_estrus_start` DATE NULL,
  `days_in_estrus` VARCHAR(45) NULL,
  `estimated_mate_date` DATE NULL,
  `male_cage_mates` VARCHAR(45) NULL,
  `flag_cage_mates` ENUM('0', '1') NULL,
  `last_mating_date` DATE NULL,
  `mating_history` VARCHAR(500) NULL, 
  `male_female_conflict` ENUM('0', '1') NULL,
  `created` DATE NULL,
  `created_by` VARCHAR(45) NULL,
  `modified` DATE NULL,
  PRIMARY KEY (`estrus_&_mating_summary_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `SanusBio`.`estrus_check_log`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SanusBio`.`estrus_check_log` (
  `estrus_check_log_id` INT NOT NULL,
  -- `ID` VARCHAR(45) NULL,
  -- JILL FOREIGN KEY `Animal ID` VARCHAR(45) NULL,
  `estrus_status` VARCHAR(45) NULL,
  `vulva_description` VARCHAR(45) NULL,
  `formed_observation` DATE NULL,
  `comments` VARCHAR(255) NULL,
  `reported_by` VARCHAR(45) NULL,
  `created_date` DATE NULL,
  `created_by` VARCHAR(45) NULL,
  `in_estrus` ENUM('0', '1') NULL,
  PRIMARY KEY (`estrus_check_log_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `SanusBio`.`females_to_mate`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SanusBio`.`females_to_mate` (
  `females_to_mate_id` INT NOT NULL,
  `primary` VARCHAR(45) NULL,
  -- Link to other tables `location_link` VARCHAR(45) NULL,
  `mating_link` VARCHAR(45) NULL,
  `date_identified` DATE NULL,
  `recent_history` VARCHAR(300) NULL,
  `address` VARCHAR(45) NULL,
  -- Calculate `Coeffiecient_of_Inbreeding` VARCHAR(45) NULL,
  `genealogy` VARCHAR(500) NULL,
  `kits` VARCHAR(45) NULL,
  -- Ferret ID Foreign Key
  PRIMARY KEY (`females_to_mate_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `SanusBio`.`litter_log`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SanusBio`.`litter_log` (
  `litter_log_id` INT NOT NULL AUTO_INCREMENT,
  `litter_id` VARCHAR(45) NULL,
  `litter_date` DATE NULL,
  `from_recent_mating` ENUM('1', '0') NULL,
  `kit_count` INT NULL,
  `stillborn` INT NULL,
  `infant_deaths` INT NULL,
  `surviving_litter_count` INT NULL,
  `kits_transferred_in` INT NULL,
  `kits_transferred_out` INT NULL,
  `transfer_date` DATE NULL,
  `total_litter_size` INT NULL GENERATED ALWAYS AS (
    IFNULL(kit_count, 0)
    + IFNULL(kits_transferred_in, 0)
    - IFNULL(kits_transferred_out, 0)
  ) STORED,
  `functioning_nipples` INT NULL,

  -- Nipple minus kit count calculation
  `nipple_kit_count` INT NULL GENERATED ALWAYS AS (
    IFNULL(functioning_nipples, 0)
    - IFNULL(surviving_litter_count, 0)
  ) STORED,

  `last_weight_grams` INT NULL,
  `previous_weight_grams` INT NULL,
  `last_weigh_date` DATE NULL,
  `previous_weigh_date` DATE NULL,

  -- Growth rate (grams per week)
  `growth_rate_g_per_week` DECIMAL(6,2) GENERATED ALWAYS AS (
    CASE 
      WHEN previous_weigh_date IS NULL THEN NULL
      WHEN DATEDIFF(last_weigh_date, previous_weigh_date) <= 0 THEN NULL
      ELSE
        ((last_weight_grams - previous_weight_grams)
        / DATEDIFF(last_weigh_date, previous_weigh_date)) * 7
    END
  ) STORED,

  `recent_nest_count` INT NULL,
  `jill_removed_from_litter_date` DATE NULL,
  `need_ids` INT NULL,
  `anomalies_and_notes` VARCHAR(500) NULL,
  `event_history` VARCHAR(1000) NULL, 
  `start_kit_on_feed_(21_days)` DATE NULL,
  `dark_cycle_date_(4mo)` DATE NULL,
  `event_summary` VARCHAR(500) NULL,
  `transfer_notes` VARCHAR(500) NULL,
  `transfer_jill_source` VARCHAR(45) NULL,
  `transfer_jill_destination` VARCHAR(45) NULL,
  `report_event` VARCHAR(45) NULL,
  `create_individuals` ENUM('y', 'n') NULL,
  `collect_litter_weight` VARCHAR(45) NULL,
  `support_feeding` VARCHAR(45) NULL,
  `support_feed_type` VARCHAR(45) NULL,
  `today_feed_count` INT NULL,
  `syringe_feeding_log` VARCHAR(1000) NULL,
  `individuals_created` INT NULL,
  `summary_hob` VARCHAR(255) NULL,
  `summary_jill` VARCHAR(255) NULL,
  `father` VARCHAR(50) NULL,
  `mother` VARCHAR(50) NULL,
  `created` DATE NULL,
  `created_by` VARCHAR(100) NULL,
  `nest_litter_changed` DATE NULL,
  `change_nest_litter_box` ENUM('0', '1') NULL,
  `nest_box_change_log` VARCHAR(1000) NULL,
  -- `Nest Litter Box Change Link` VARCHAR(45) NULL, foreign keys
  -- `address` VARCHAR(45) NULL, Foreign Key
  -- Calculation from other tables `Feeding Link` VARCHAR(45) NULL,
  -- `Form Input Feed Count` INT NULL,
  -- Today's Feed Count
  -- `kit_transfer_link` VARCHAR(45) NULL,
  -- calculate `Projected Wean Date (6 weeks)` DATE NULL,
  PRIMARY KEY (`litter_log_id`))
ENGINE = InnoDB;


---------
  -- Room Table needs to have its own ids
  -- need to get rooms and addresses
  -- IDs are attached to rooms


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;