-- Banner 轮播图表
CREATE TABLE IF NOT EXISTS `banner` (
  `banner_id` INT PRIMARY KEY AUTO_INCREMENT,
  `title` VARCHAR(100) DEFAULT NULL COMMENT '标题',
  `subtitle` VARCHAR(200) DEFAULT NULL COMMENT '副标题',
  `image_url` VARCHAR(500) NOT NULL COMMENT '图片路径',
  `link_url` VARCHAR(500) DEFAULT NULL COMMENT '点击跳转链接，为空则不跳转',
  `sort_order` INT DEFAULT 0 COMMENT '排序，越小越靠前',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '1启用 0禁用',
  `create_time` DATETIME NOT NULL
);
