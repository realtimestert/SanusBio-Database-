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
-- Table `SanusBio`.`Litter Log`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SanusBio`.`Litter Log` (
  `Litter Log_id` INT NOT NULL,
  `Litter ID` VARCHAR(45) NULL,
  `Litter Date` DATE NULL,
  `From Most Recent Mating` ENUM('1', '0') NULL,
  `Kit count` INT NULL,
  `Stillborn` INT NULL,
  `Infant Deaths` INT NULL,
  `Surviving Litter Count` INT NULL,
  `Kits Transferred In` INT NULL,
  `Kits Transferred Out` INT NULL,
  `Transfer Date` DATE NULL,
  `Total Litter Size` INT NULL,
  `Recent Nest Count` INT NULL,
  `Jill Removed From Litter Date` DATE NULL,
  `Need IDs` INT NULL,
  `Anomalies and Notes` VARCHAR(500) NULL,
  `Event History` VARCHAR(500) NULL,
  -- Room ID and other things `Address` VARCHAR(45) NULL,
  `Start Kit on Feed (21 days)` DATE NULL,
  `Projected Wean Date (6 weeks)` DATE NULL,
  `Dark Cycle Date (4mo)` DATE NULL,
  `Event Summary` VARCHAR(500) NULL,
  `Transfer Notes` VARCHAR(500) NULL,
  `Transfer Jill-Source` VARCHAR(45) NULL,
  `Transfer Jill-Destination` VARCHAR(45) NULL,
  `Report Event` VARCHAR(45) NULL,
  `Kit Transfer Link` VARCHAR(45) NULL,
  `Create Individuals` VARCHAR(45) NULL,
  `Collect Litter Weight` VARCHAR(45) NULL,
  `Last Weigh Date` DATE NULL,
  -- Calculate growth rate from other variables 
  -- `Growth Rate (g/week)` INT NULL,
  `Functioning Nipples` INT NULL,
  -- Calculate nipple/kit count
  -- `Nipple - Kit Count` INT NULL,
  `Support Feeding` VARCHAR(45) NULL,
  `Support Feed Type` VARCHAR(45) NULL,
  `Today's Feed Count` INT NULL,
  `Form Input Feed Count` INT NULL,
  `Feeding Link` VARCHAR(45) NULL,
  `Individuals Created` INT NULL,
  `Summary Hob` VARCHAR(255) NULL,
  `Summary Jill` VARCHAR(255) NULL,
  `Jill, Hob` VARCHAR(255) NULL,
  `Created` DATE NULL,
  `Created By` VARCHAR(45) NULL,
  `Nest Litter Changed` DATE NULL,
  `Change Nest Litter Box` ENUM('0', '1') NULL,
  `Nest Litter Box Change Link` VARCHAR(45) NULL,
  PRIMARY KEY (`Litter Log_id`))
ENGINE = InnoDB;


---------
  -- Room Table needs to have its own ids
  -- need to get rooms and addresses
  -- IDs are attached to rooms


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;