-- 消息功能数据库更新脚本
-- 在已有数据库上执行此脚本即可添加消息功能

USE `online_order_db`;

CREATE TABLE IF NOT EXISTS `message` (
  `message_id` INT PRIMARY KEY AUTO_INCREMENT,
  `sender_id` INT NOT NULL,
  `receiver_id` INT NOT NULL,
  `content` VARCHAR(1000) NOT NULL,
  `is_read` TINYINT NOT NULL DEFAULT 0,
  `create_time` DATETIME NOT NULL,
  FOREIGN KEY (`sender_id`) REFERENCES `user`(`user_id`),
  FOREIGN KEY (`receiver_id`) REFERENCES `user`(`user_id`)
);
