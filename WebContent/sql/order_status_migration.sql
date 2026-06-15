-- 订单状态改造迁移脚本
-- 新增 accept_time 字段（商家接单时间）
ALTER TABLE `order` ADD COLUMN `accept_time` DATETIME DEFAULT NULL AFTER `pay_time`;
-- 新增 cancel_reason 字段
ALTER TABLE `order` ADD COLUMN `cancel_reason` VARCHAR(500) DEFAULT NULL AFTER `accept_time`;

-- 订单状态变更日志表
CREATE TABLE IF NOT EXISTS `order_log` (
  `log_id` INT PRIMARY KEY AUTO_INCREMENT,
  `order_id` INT NOT NULL,
  `from_status` TINYINT DEFAULT NULL,
  `to_status` TINYINT NOT NULL,
  `operator_id` INT NOT NULL,
  `operator_role` TINYINT NOT NULL COMMENT '1=管理员 2=商家 0=用户',
  `reason` VARCHAR(500) DEFAULT NULL,
  `create_time` DATETIME NOT NULL,
  FOREIGN KEY (`order_id`) REFERENCES `order`(`order_id`)
);
