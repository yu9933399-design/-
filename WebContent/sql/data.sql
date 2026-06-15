USE `online_order_db`;

-- 密码统一使用 BCrypt 格式，以下是 123456 的 BCrypt 哈希值
-- $2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi

INSERT INTO `user` (`username`, `password`, `real_name`, `phone`, `email`, `role`) VALUES
('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', 'Admin', '13800138000', 'admin@example.com', 1);

INSERT INTO `user` (`username`, `password`, `real_name`, `phone`, `email`, `address`) VALUES
('user1', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', 'Test User', '13900139000', 'user1@example.com', 'Beijing');

INSERT INTO `category` (`category_name`, `sort_order`) VALUES
('Sichuan', 1), ('Cantonese', 2), ('Dessert', 3), ('Drinks', 4);

INSERT INTO `dish` (`merchant_id`, `dish_name`, `price`, `image_url`, `description`, `stock`, `category_id`, `status`, `is_recommend`, `special_price`, `special_start`, `special_end`) VALUES
(1, 'Spicy Chicken Rice', 28.00, 'https://img.icons8.com/color/200/food.png', 'Spicy chicken rice with fresh vegetables', 100, 1, 1, 1, 25.00, '2026-06-01 00:00:00', '2026-12-31 23:59:59'),
(1, 'Boiled Fish', 48.00, 'https://img.icons8.com/color/200/food.png', 'Fresh fish slices in spicy broth', 60, 1, 1, 1, NULL, NULL, NULL),
(1, 'Kung Pao Chicken', 32.00, 'https://img.icons8.com/color/200/food.png', 'Classic Sichuan dish with peanuts', 80, 1, 1, 0, 29.00, '2026-06-01 00:00:00', '2026-12-31 23:59:59'),
(1, 'Mapo Tofu', 22.00, 'https://img.icons8.com/color/200/food.png', 'Silky tofu with minced meat', 90, 1, 1, 0, NULL, NULL, NULL);

INSERT INTO `dish` (`merchant_id`, `dish_name`, `price`, `image_url`, `description`, `stock`, `category_id`, `status`, `is_recommend`, `special_price`, `special_start`, `special_end`) VALUES
(1, 'Tomato Beef Noodles', 26.00, 'https://img.icons8.com/color/200/noodles.png', 'Rich tomato broth with tender beef', 80, 2, 1, 1, NULL, NULL, NULL),
(1, 'White Cut Chicken', 38.00, 'https://img.icons8.com/color/200/food.png', 'Poached chicken with ginger sauce', 50, 2, 1, 1, 35.00, '2026-06-01 00:00:00', '2026-12-31 23:59:59'),
(1, 'Roast Goose Rice', 42.00, 'https://img.icons8.com/color/200/food.png', 'Crispy roast goose with rice', 40, 2, 1, 0, NULL, NULL, NULL),
(1, 'Rice Rolls', 18.00, 'https://img.icons8.com/color/200/food.png', 'Steamed rice rolls with soy sauce', 100, 2, 1, 0, NULL, NULL, NULL);

INSERT INTO `dish` (`merchant_id`, `dish_name`, `price`, `image_url`, `description`, `stock`, `category_id`, `status`, `is_recommend`, `special_price`, `special_start`, `special_end`) VALUES
(1, 'Mango Pudding', 16.00, 'https://img.icons8.com/color/200/food.png', 'Fresh mango pudding', 120, 3, 1, 1, 13.00, '2026-06-01 00:00:00', '2026-12-31 23:59:59'),
(1, 'Red Bean Double Skin Milk', 14.00, 'https://img.icons8.com/color/200/food.png', 'Traditional Cantonese dessert', 100, 3, 1, 0, NULL, NULL, NULL),
(1, 'Mango Pomelo Sago', 18.00, 'https://img.icons8.com/color/200/food.png', 'Mango coconut dessert with pomelo', 80, 3, 1, 0, 15.00, '2026-06-01 00:00:00', '2026-12-31 23:59:59');

INSERT INTO `dish` (`merchant_id`, `dish_name`, `price`, `image_url`, `description`, `stock`, `category_id`, `status`, `is_recommend`, `special_price`, `special_start`, `special_end`) VALUES
(1, 'Lemon Honey Water', 12.00, 'https://img.icons8.com/color/200/cocktail.png', 'Fresh lemon with pure honey', 200, 4, 1, 1, 10.00, '2026-06-01 00:00:00', '2026-12-31 23:59:59'),
(1, 'Bubble Tea', 15.00, 'https://img.icons8.com/color/200/cocktail.png', 'Handmade tapioca pearls with milk tea', 150, 4, 1, 0, NULL, NULL, NULL);
