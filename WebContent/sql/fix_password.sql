-- 修复数据库中非BCrypt格式的密码
-- 将所有用户密码重置为 BCrypt 格式的 123456

USE `online_order_db`;

-- 重置所有用户密码为 123456（BCrypt格式）
UPDATE `user` SET `password` = '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi';

-- 确保所有用户都有有效的 role 和 status 值
UPDATE `user` SET `role` = 0 WHERE `role` IS NULL;
UPDATE `user` SET `status` = 0 WHERE `status` IS NULL;
