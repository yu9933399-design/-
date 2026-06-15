-- 美团外卖点餐逻辑改造迁移脚本
-- order表新增shop_id，关联下单商家
ALTER TABLE `order` ADD COLUMN `shop_id` INT DEFAULT NULL AFTER `user_id`;
-- cart表新增shop_id，每条商品绑定所属店铺
ALTER TABLE `cart` ADD COLUMN `shop_id` INT DEFAULT NULL AFTER `dish_id`;
