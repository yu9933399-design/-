-- 配送位置查询功能迁移脚本
-- 配送状态：0 待配送 1 配送中 2 已送达
ALTER TABLE `order` ADD COLUMN `delivery_status` TINYINT NOT NULL DEFAULT 0 AFTER `cancel_reason`;
ALTER TABLE `order` ADD COLUMN `delivery_position` VARCHAR(500) DEFAULT NULL AFTER `delivery_status`;
