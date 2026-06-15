CREATE DATABASE IF NOT EXISTS `online_order_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `online_order_db`;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `order_item`;
DROP TABLE IF EXISTS `order`;
DROP TABLE IF EXISTS `cart`;
DROP TABLE IF EXISTS `dish`;
DROP TABLE IF EXISTS `category`;
DROP TABLE IF EXISTS `user`;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE `user` (
  `user_id` INT PRIMARY KEY AUTO_INCREMENT,
  `username` VARCHAR(30) NOT NULL UNIQUE,
  `password` VARCHAR(255) NOT NULL,
  `real_name` VARCHAR(20),
  `phone` VARCHAR(15),
  `email` VARCHAR(50),
  `address` VARCHAR(200),
  `role` TINYINT NOT NULL DEFAULT 0,
  `status` TINYINT NOT NULL DEFAULT 0
);

CREATE TABLE `category` (
  `category_id` INT PRIMARY KEY AUTO_INCREMENT,
  `category_name` VARCHAR(30) NOT NULL,
  `sort_order` INT DEFAULT 0
);

CREATE TABLE `dish` (
  `dish_id` INT PRIMARY KEY AUTO_INCREMENT,
  `merchant_id` INT NOT NULL,
  `dish_name` VARCHAR(50) NOT NULL,
  `price` DECIMAL(10,2) NOT NULL,
  `image_url` VARCHAR(200),
  `description` VARCHAR(500),
  `stock` INT NOT NULL,
  `category_id` INT NOT NULL,
  `status` TINYINT NOT NULL DEFAULT 1,
  `is_recommend` TINYINT NOT NULL DEFAULT 0,
  `special_price` DECIMAL(10,2),
  `special_start` DATETIME,
  `special_end` DATETIME,
  FOREIGN KEY (`merchant_id`) REFERENCES `user`(`user_id`),
  FOREIGN KEY (`category_id`) REFERENCES `category`(`category_id`)
);

CREATE TABLE `cart` (
  `cart_id` INT PRIMARY KEY AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `dish_id` INT NOT NULL,
  `quantity` INT NOT NULL,
  `add_time` DATETIME NOT NULL,
  FOREIGN KEY (`user_id`) REFERENCES `user`(`user_id`),
  FOREIGN KEY (`dish_id`) REFERENCES `dish`(`dish_id`)
);

CREATE TABLE `order` (
  `order_id` INT PRIMARY KEY AUTO_INCREMENT,
  `order_no` VARCHAR(20) NOT NULL UNIQUE,
  `user_id` INT NOT NULL,
  `receiver_name` VARCHAR(20) NOT NULL,
  `receiver_phone` VARCHAR(15) NOT NULL,
  `receiver_address` VARCHAR(200) NOT NULL,
  `total_amount` DECIMAL(10,2) NOT NULL,
  `payment_method` VARCHAR(20) NOT NULL,
  `order_status` TINYINT NOT NULL DEFAULT 0,
  `create_time` DATETIME NOT NULL,
  `pay_time` DATETIME,
  FOREIGN KEY (`user_id`) REFERENCES `user`(`user_id`)
);

CREATE TABLE `order_item` (
  `item_id` INT PRIMARY KEY AUTO_INCREMENT,
  `order_id` INT NOT NULL,
  `dish_id` INT NOT NULL,
  `dish_name` VARCHAR(50) NOT NULL,
  `price` DECIMAL(10,2) NOT NULL,
  `quantity` INT NOT NULL,
  `subtotal` DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (`order_id`) REFERENCES `order`(`order_id`),
  FOREIGN KEY (`dish_id`) REFERENCES `dish`(`dish_id`)
);

CREATE TABLE `message` (
  `message_id` INT PRIMARY KEY AUTO_INCREMENT,
  `sender_id` INT NOT NULL,
  `receiver_id` INT NOT NULL,
  `content` VARCHAR(1000) NOT NULL,
  `is_read` TINYINT NOT NULL DEFAULT 0,
  `create_time` DATETIME NOT NULL,
  FOREIGN KEY (`sender_id`) REFERENCES `user`(`user_id`),
  FOREIGN KEY (`receiver_id`) REFERENCES `user`(`user_id`)
);
