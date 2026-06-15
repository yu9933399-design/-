-- 商家分类字段迁移
ALTER TABLE `user` ADD COLUMN `shop_category` VARCHAR(20) DEFAULT NULL COMMENT '店铺所属品类：快餐简餐/奶茶饮品/川湘辣味/粤菜海鲜/甜品小吃/早餐早点/面食粥品/轻食沙拉' AFTER `status`;
