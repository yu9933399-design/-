# 配送查询 + AI 智能客服 部署说明

## 一、新增文件清单

| 文件 | 说明 |
|------|------|
| `WebContent/sql/delivery_migration.sql` | 配送字段数据库迁移 |
| `src/com/order/entity/Order.java` | 新增 deliveryStatus、deliveryPosition 字段 |
| `src/com/order/dao/OrderDAO.java` | 新增 updateDelivery 方法，mapRow 读取配送字段 |
| `src/com/order/service/OrderService.java` | 新增 updateDelivery 方法 |
| `src/com/order/servlet/DeliveryQueryServlet.java` | 配送信息查询接口 |
| `src/com/order/servlet/DeliveryUpdateServlet.java` | 配送信息更新接口 |
| `src/com/order/config/AiConfig.java` | AI 配置常量类 |
| `src/com/order/utils/AiChatUtil.java` | AI 接口调用工具类 |
| `src/com/order/servlet/AiOrderChatServlet.java` | AI 客服核心 Servlet |
| `WebContent/jsp/common/ai-chat.jsp` | 悬浮聊天窗口组件 |
| `WebContent/jsp/admin/order/detail.jsp` | 新增配送管理卡片 |

## 二、数据库迁移

在 MySQL 中执行：

```sql
-- 配送字段
ALTER TABLE `order` ADD COLUMN `delivery_status` TINYINT NOT NULL DEFAULT 0 AFTER `cancel_reason`;
ALTER TABLE `order` ADD COLUMN `delivery_position` VARCHAR(500) DEFAULT NULL AFTER `delivery_status`;
```

## 三、AI 接口配置

编辑 `src/com/order/config/AiConfig.java`，替换以下两项：

```java
public static final String AI_API_URL = "https://api.openai.com/v1/chat/completions";  // 你的 AI 接口地址
public static final String AI_API_KEY = "sk-your-api-key-here";  // 你的 API Key
```

如使用其他大模型（如通义千问、文心一言等），需同步修改：
- `AiConfig.MODEL` — 模型名称
- `AiConfig.AI_API_URL` — 接口地址
- `AiChatUtil.buildRequestBody()` — 请求体格式（如需要）
- `AiChatUtil.parseContent()` — 响应解析逻辑

## 四、依赖包

项目 `WebContent/WEB-INF/lib/` 下已有：
- `druid-1.2.8.jar` — 数据库连接池
- `commons-dbutils-1.7.jar` — SQL 工具
- `mysql-connector-java-8.0.33.jar` — MySQL 驱动

**无需额外依赖** — HTTP 请求使用 JDK 原生 `HttpURLConnection`，JSON 解析使用简易字符串处理。

如需使用 httpclient 和 fastjson，可自行下载放入 lib 目录。

## 五、访问路径

| 功能 | 路径 | 方法 |
|------|------|------|
| 配送查询 | `/delivery/query?orderId=xxx` | GET |
| 配送更新 | `/delivery/update` | POST |
| AI 客服 | `/aiOrderChat` | POST |

## 六、功能说明

### 配送位置查询（第三部分）
- **用户端**：订单详情页 → 配送中订单显示「查看配送位置」按钮 → 弹窗查看
- **商家端**：订单详情页 → 可编辑配送状态和位置 → 已送达后锁定
- **管理员端**：同商家端，可查看所有订单配送信息并协助修改

### AI 智能客服（第四部分）
- **入口**：页面右下角悬浮聊天按钮 💬
- **功能**：自动读取用户全部订单信息，结合配送数据回答问题
- **约束**：仅回答订单、配送相关问题，无关问题固定回复
- **注意**：需配置 AiConfig 中的 API Key 才能使用
