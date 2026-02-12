-- Additional tables for authentication and features

-- Users table for authentication
CREATE TABLE IF NOT EXISTS `users` (
  `user_id` INT NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(50) NOT NULL UNIQUE,
  `password` VARCHAR(255) NOT NULL,
  `email` VARCHAR(100) NOT NULL UNIQUE,
  `role` ENUM('admin', 'research', 'maternity', 'caretaker') NOT NULL,
  `full_name` VARCHAR(100) NULL,
  `active` TINYINT(1) DEFAULT 1,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `last_login` TIMESTAMP NULL,
  PRIMARY KEY (`user_id`),
  INDEX `idx_username` (`username`),
  INDEX `idx_role` (`role`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Push notification subscriptions
CREATE TABLE IF NOT EXISTS `push_subscriptions` (
  `subscription_id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `subscription_data` TEXT NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`subscription_id`),
  UNIQUE KEY `unique_user_subscription` (`user_id`),
  FOREIGN KEY (`user_id`) REFERENCES `users`(`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Add photo_url column to ferret table (if not exists)
ALTER TABLE `ferret_qr005` 
ADD COLUMN `photo_url` VARCHAR(255) NULL AFTER `created_by`;

-- Activity log for audit trail
CREATE TABLE IF NOT EXISTS `activity_log` (
  `log_id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `action` VARCHAR(100) NOT NULL,
  `table_name` VARCHAR(50) NULL,
  `record_id` INT NULL,
  `details` TEXT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`),
  FOREIGN KEY (`user_id`) REFERENCES `users`(`user_id`),
  INDEX `idx_user_action` (`user_id`, `action`),
  INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Cleaning/maintenance assignments
CREATE TABLE IF NOT EXISTS `assignments` (
  `assignment_id` INT NOT NULL AUTO_INCREMENT,
  `assigned_to` INT NOT NULL,
  `assignment_type` ENUM('cleaning', 'feeding', 'health_check', 'other') NOT NULL,
  `address_id` INT NULL,
  `ferret_id` INT NULL,
  `description` TEXT NULL,
  `due_date` DATE NULL,
  `completed` TINYINT(1) DEFAULT 0,
  `completed_at` TIMESTAMP NULL,
  `created_by` INT NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`assignment_id`),
  FOREIGN KEY (`assigned_to`) REFERENCES `users`(`user_id`),
  FOREIGN KEY (`created_by`) REFERENCES `users`(`user_id`),
  FOREIGN KEY (`address_id`) REFERENCES `address`(`address_id`),
  FOREIGN KEY (`ferret_id`) REFERENCES `ferret_qr005`(`Ferret_QR005_id`),
  INDEX `idx_assigned_completed` (`assigned_to`, `completed`),
  INDEX `idx_due_date` (`due_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert default admin user (password: admin123)
-- IMPORTANT: Change this password in production!
INSERT INTO `users` (`username`, `password`, `email`, `role`, `full_name`) 
VALUES ('admin', '$2a$10$YourHashedPasswordHere', 'admin@sanusbio.com', 'admin', 'System Administrator')
ON DUPLICATE KEY UPDATE username = username;

-- Sample locations if table is empty
INSERT IGNORE INTO `address` (`address_id`, `room_id`, `cage_address`, `room_lighting`) VALUES
(1, 1, 'A-101', '16:8'),
(2, 1, 'A-102', '16:8'),
(3, 1, 'A-103', '16:8'),
(4, 2, 'B-201', '16:8'),
(5, 2, 'B-202', '16:8'),
(6, 2, 'B-203', '16:8'),
(7, 3, 'C-301', '8:16'),
(8, 3, 'C-302', '8:16');

-- Sample suppliers if table is empty
INSERT IGNORE INTO `supplier` (`supplier_id`, `supplier_name`, `contact_info`) VALUES
(1, 'Marshall Farms', 'contact@marshallfarms.com'),
(2, 'Path Valley', 'info@pathvalley.com'),
(3, 'Triple F Farms', 'sales@tripleffarms.com');
