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
  `Animal_ID` INT NOT NULL,
  `Ferret_Name` VARCHAR(45) NOT NULL,
  `RFID_Change_Log` VARCHAR(1000) NULL,
  `Location_Change_Log` VARCHAR(1000) NULL,
  -- Foreign Key `Address` VARCHAR(45) NULL,
  `Birth_Date` DATE NOT NULL,
  `Death_Date` DATE NULL,
  `Acquisition_By` VARCHAR(45) NULL,
  `Weight` INT NOT NULL,
  `Next_Rabies_Vaccine_Due` DATE NOT NULL,
  `Description` VARCHAR(45) NULL,
  `Mother` VARCHAR(45) NULL,
  `Father` VARCHAR(45) NULL,
  `Mother_ID` VARCHAR(45) NULL,
  `Father_ID` VARCHAR(45) NULL,
  `Supplier` VARCHAR(45) NULL,
  `Last_Move_to_Winter` DATE NULL,
  `Last_Winter_Cycle_Completion` DATE NULL,
  `Last_Move_to_Summer` DATE NULL,
  `move_in` DATETIME NULL,
  `move_out` DATETIME NULL,
  `winter_start` DATETIME NULL,
  `winter_end` DATETIME NULL,
  `Time_in_Winter` INT
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
  `Age_wks` INT
    GENERATED ALWAYS AS (
      FLOOR(
        DATEDIFF(
          COALESCE(`Death_Date`, CURDATE()),
          `Birth_Date`
        ) / 7
      )
    ) VIRTUAL,
  `Distribution_Date` DATE NULL,
  `Clip_Nails` ENUM('0','1') NULL,
  `Bath` ENUM('0','1') NULL,
  `Animal_RFID` VARCHAR(15) NULL,
  `Litter_ID` VARCHAR(7) NULL,
  `Litter_Date` DATE NULL,
  `Hob_Code` VARCHAR(8) NOT NULL,
  `Purchase_ID` VARCHAR(45) NULL,
  `Created_By` VARCHAR(45) NULL,
  `Dead` ENUM('0','1') NULL,
  PRIMARY KEY (`Ferret_QR005_id`)
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `SanusBio`.`Medical Info`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SanusBio`.`Medical_Info` (
  `Medical_Info_id` INT NOT NULL,
  `Rabies Vaccination Date` DATE NULL,
  `Rabies Vaccination Date Last` DATE NULL,
  `Distemper Vaccination Date - Last` DATE NULL,
  `Distember Vaccination Date - Previous` DATE NULL,
  `Castration/Spay Date` DATE NULL,
  `Castrated/Spayed` ENUM('y', 'n') NULL,
  `Descent Date` DATE NULL,
  `Test Collected - Last 30 Days` VARCHAR(255) NULL,
  `Test Result - Last 30 Days` VARCHAR(255) NULL,
  -- Big Calculation `Coefficient of Inbreeding` VARCHAR(45) NULL,
  `Weight Loss/Gain` VARCHAR(45) NULL,
  `Lifetime % Litters/Mating` VARCHAR(45) NULL,
  `Surgical_Procedure_Log` VARCHAR(1000) NULL,
  `dead` ENUM('y', 'n'),
  `Date_Of_Death` DATE NULL,
  `Cause_Of_Death` VARCHAR(255) NULL,
  `Treatments` VARCHAR(255) NULL,
  `Exam_Log` VARCHAR(1000) NULL,
  `Last_Exam_Date` DATE NULL,
  `Orders` VARCHAR(200) NULL,
  -- needs foreign keys to populate data
  PRIMARY KEY (`Medical_Info_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `SanusBio`,`Address`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SanusBio`.`Address` (
  `Address_id` INT NOT NULL,
  `Room_id` INT NOT NULL,
  `Cage_Address` VARCHAR(5),
  `Room_Lighting` VARCHAR(45) NULL,
  `Maintenance` VARCHAR(255) NULL,
  PRIMARY KEY (`Address_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `SanusBio`,`Health_Log`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SanusBio`.`Health_Log` (
  `Health_Log_id` INT NOT NULL,
  `Nail_Trim_Log` VARCHAR(1000),
  `Weight_Log` VARCHAR(1000),
  `Bath_History` VARCHAR(1000),
  PRIMARY KEY (`Health_Log_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `SanusBio`.`Estrus & Mating Summary`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SanusBio`.`Estrus & Mating Summary` (
  `Estrus & Mating Summary_id` INT NOT NULL,
  -- foreign key to aninmals `Animal ID` VARCHAR(45) NULL,
  `Mating Restriction` VARCHAR(45) NULL,
  `Unconfirmed Estrus` DATE NULL,
  `Confirmed Estrus Start` DATE NULL,
  `Days in Estrus` VARCHAR(45) NULL,
  `Estimated Mate Date` DATE NULL,
  `Male Cage Mates` VARCHAR(45) NULL,
  `Flag Cage Mates` ENUM('0', '1') NULL,
  `Last Mating Date` DATE NULL,
  `Mating History` VARCHAR(500) NULL, 
  `Male/Female Conflict` ENUM('0', '1') NULL,
  `Created` DATE NULL,
  `Created By` VARCHAR(45) NULL,
  `Modified` DATE NULL,
  PRIMARY KEY (`Estrus & Mating Summary_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `SanusBio`.`Estrus Check Log`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SanusBio`.`Estrus Check Log` (
  `Estrus Check Log_id` INT NOT NULL,
  `ID` VARCHAR(45) NULL,
  -- JILL FOREIGN KEY `Animal ID` VARCHAR(45) NULL,
  `Estrus Status` VARCHAR(45) NULL,
  `Vulva Description` VARCHAR(45) NULL,
  `Formed Observation` DATE NULL,
  `Comments` VARCHAR(255) NULL,
  `Reported By` VARCHAR(45) NULL,
  `Created Date` DATE NULL,
  `Created By` VARCHAR(45) NULL,
  `In Estrus` ENUM('0', '1') NULL,
  PRIMARY KEY (`Estrus Check Log_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `SanusBio`.`Females to Mate`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SanusBio`.`Females to Mate` (
  `Females to Mate_id` INT NOT NULL,
  `Primary` VARCHAR(45) NULL,
  `Location Link` VARCHAR(45) NULL,
  `Mating Link` VARCHAR(45) NULL,
  `Date Identified` DATE NULL,
  `Recent History` VARCHAR(300) NULL,
  `Address` VARCHAR(45) NULL,
  `Coeffiecient of Inbreeding` VARCHAR(45) NULL,
  `Genealogy` VARCHAR(500) NULL,
  `Kits` VARCHAR(45) NULL,
  -- Ferret ID Foreign Key
  PRIMARY KEY (`Females to Mate_id`))
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