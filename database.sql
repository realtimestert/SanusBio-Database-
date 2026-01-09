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
-- Table `SanusBio`.`Medical Info`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SanusBio`.`Medical Info` (
  `table1_id` INT NOT NULL,
  `Rabies Vaccination Date` DATE NULL,
  `Distemper Vaccination Date - Last` DATE NULL,
  `Distember Vaccination Date - Previous` DATE NULL,
  `Castration/Spay Date` DATE NULL,
  `Descent Date` DATE NULL,
  `Test Collected - Last 30 Days` VARCHAR(255) NULL,
  `Test Result - Last 30 Days` VARCHAR(100) NULL,
  `Coefficient of Inbreeding` VARCHAR(45) NULL,
  `Weight Loss/Gain` VARCHAR(45) NULL,
  `Lifetime % Litters/Mating` VARCHAR(45) NULL,
  PRIMARY KEY (`table1_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `SanusBio`.`Cleaning Records`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SanusBio`.`Cleaning Records` (
  `Cleaning Records_id` INT NOT NULL,
  `ID` INT NULL,
  `Serviced By` VARCHAR(45) NULL,
  `Time of Day` ENUM('AM', 'PM') NULL,
  `Moderate or Strong Urea Odor` VARCHAR(45) NULL,
  `Trays Washed` VARCHAR(45) NULL,
  `Trays Vacuumed` VARCHAR(45) NULL,
  `Feed Supplied` VARCHAR(45) NULL,
  `Supplimental Feed Supplied` VARCHAR(45) NULL,
  `Water` VARCHAR(45) NULL,
  `Rooms Swept` VARCHAR(45) NULL,
  `Rooms Mopped` VARCHAR(45) NULL,
  `Urgent Events - Notify Management` VARCHAR(45) NULL,
  `Animal ID` VARCHAR(45) NULL,
  `Affected Animals` VARCHAR(45) NULL,
  `Event Notification Details` VARCHAR(45) NULL,
  `Event Resolution` VARCHAR(45) NULL,
  `Maintenance Needs` VARCHAR(45) NULL,
  `Created` DATE NULL,
  `Created By` VARCHAR(45) NULL,
  PRIMARY KEY (`Cleaning Records_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `SanusBio`.`Estrus & Mating Summary`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SanusBio`.`Estrus & Mating Summary` (
  `Estrus & Mating Summary_id` INT NOT NULL,
  `Animal ID` VARCHAR(45) NULL,
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
  `Animal ID` VARCHAR(45) NULL,
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
  PRIMARY KEY (`Females to Mate_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `SanusBio`.`Litter Log`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SanusBio`.`Litter Log` (
  `Litter Log_id` INT NOT NULL,
  `Litter ID` VARCHAR(45) NULL,
  `Mating ID` VARCHAR(45) NULL,
  `Jill` VARCHAR(45) NULL,
  `Jill ID` VARCHAR(45) NULL,
  `Hob` VARCHAR(45) NULL,
  `Hob ID` VARCHAR(45) NULL,
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
  `Need IDs` ENUM('0', '1') NULL,
  `Anomalies and Notes` VARCHAR(500) NULL,
  `Event History` VARCHAR(500) NULL,
  `Address` VARCHAR(45) NULL,
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
  `Growth Rate (g/week)` INT NULL,
  `Functioning Nipples` INT NULL,
  `Nipple - Kit Count` INT NULL,
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


-- -----------------------------------------------------
-- Table `SanusBio`.`Hob`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SanusBio`.`Hob` (
  `Hob_id` INT NOT NULL,
  `Animal ID` INT NOT NULL,
  `Address` VARCHAR(45) NULL,
  `Birth Date` DATE NOT NULL,
  `Death Date` DATE NULL,
  `Aquisition by` VARCHAR(45) NULL,
  `Weight` INT NOT NULL,
  `Next Rabies Vaccine Due` DATE NOT NULL,
  `Description` VARCHAR(45) NULL,
  `Mother` VARCHAR(45) NULL,
  `Father` VARCHAR(45) NULL,
  `Supplier` VARCHAR(45) NULL,
  `Last Move to Winter` DATE NULL,
  `Last Winter Cycle Completion` DATE NULL,
  `Last Move to Summer` DATE NULL,
  `move_in` DATETIME NULL,
  `move_out` DATETIME NULL,
  `winter_start` DATETIME NULL,
  `winter_end` DATETIME NULL,
  `Time_in_Winter` INT
  GENERATED ALWAYS AS (
    GREATEST(
        0,
        DATEDIFF(
            LEAST(
                COALESCE(move_out, winter_end),
                winter_end
            ),
            GREATEST(
                move_in,
                winter_start
            )
        )
    )
  ) STORED,
  `Age (wks)` INT AS (DATEDIFF(COALESCE(`Death Date`, `Birth Date`), `Birth Date`)
   / 7) VIRTUAL,
  `Distribution Date` DATE NULL,
  `Clip Nails` ENUM('0', '1') NULL,
  `Bath` ENUM('0', '1') NULL,
  `Animal RFID` VARCHAR(15) NULL,
  `Litter ID` VARCHAR(7) NULL,
  `Litter Date` DATE NULL,
  -- `(calc)Litter Age` INT NULL,
  `Hob ID` VARCHAR(8) NOT NULL,
  `Purchase ID` VARCHAR(45) NULL,
  `Created by` VARCHAR(45) NULL,
  `Dead` ENUM('0', '1') NULL,
  PRIMARY KEY (`Hob_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `SanusBio`.`Jill`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `SanusBio`.`Jill` (
  `Jill_id` INT NOT NULL,
  `Animal ID` INT NOT NULL,
  `Birth Date` DATE NOT NULL,
  `Address` VARCHAR(45) NULL,
  `Death Date` DATE NULL,
  `Aquisition by` VARCHAR(45) NULL,
  `Weight` INT NOT NULL,
  `Next Rabies Vaccine Due` DATE NOT NULL,
  `Description` VARCHAR(45) NULL,
  `Mother` VARCHAR(45) NULL,
  `Father` VARCHAR(45) NULL,
  `Supplier` VARCHAR(45) NULL,
  `Last Move to Winter` DATE NULL,
  `Last Winter Cycle Completion` DATE NULL,
  `Last Move to Summer` DATE NULL,
  `move_in` DATETIME NULL,
  `move_out` DATETIME NULL,
  `winter_start` DATETIME NULL,
  `winter_end` DATETIME NULL,
  `Time_in_Winter` INT
  GENERATED ALWAYS AS (
    GREATEST(
        0,
        DATEDIFF(
            LEAST(
                COALESCE(move_out, winter_end),
                winter_end
            ),
            GREATEST(
                move_in,
                winter_start
            )
        )
    )
  ) STORED,
  `Age (wks)` INT AS (DATEDIFF(COALESCE(`Death Date`, `Birth Date`), `Birth Date`)
   / 7) VIRTUAL,
  `Distribution Date` DATE NULL,
  `Clip Nails` ENUM('0', '1') NULL,
  `Bath` ENUM('0', '1') NULL,
  `Animal RFID` VARCHAR(15) NULL,
  `Litter ID` VARCHAR(7) NULL,
  `Litter Date` DATE NULL,
  -- here
  -- `(calc)Litter Age` INT NULL,
  `Jill ID` VARCHAR(8) NOT NULL,
  `Purchase ID` VARCHAR(45) NULL,
  `Created by` VARCHAR(45) NULL,
  `Dead` ENUM('0', '1') NULL,
  PRIMARY KEY (`Jill_id`))
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
