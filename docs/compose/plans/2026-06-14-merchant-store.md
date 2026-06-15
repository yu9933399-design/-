# 多商家店铺模式 — 实现计划

> **For agentic workers:** Implement task-by-task in order.

**Goal:** 将系统从单商家改为多商家模式，首页展示商家列表，每个商家有独立店铺页面

**架构：** dish 表加 merchant_id 字段关联 user 表，首页展示审核通过的商家列表，点击进入商家店铺按分类查看菜品。商家后台仅管理自己的菜品和订单行。

**Tech Stack：** JSP + Servlet + MySQL

---

### Task 1: 数据库 Schema 更新

**Files:**
- Modify: `WebContent/sql/schema.sql`
- Modify: `WebContent/sql/data.sql`

- [ ] **Step 1: dish 表加 merchant_id 字段**

```sql
ALTER TABLE dish ADD COLUMN merchant_id INT NOT NULL AFTER dish_id;
ALTER TABLE dish ADD FOREIGN KEY (merchant_id) REFERENCES user(user_id);
```

在 schema.sql 的 `CREATE TABLE dish` 中 `dish_id` 后加一行：
```sql
`merchant_id` INT NOT NULL,
```

同时在外键区加：
```sql
FOREIGN KEY (`merchant_id`) REFERENCES `user`(`user_id`)
```

- [ ] **Step 2: 更新 data.sql 的 INSERT 语句**

所有 dish 的 INSERT 加上 merchant_id 列，默认先用 admin 用户（user_id=1）作为商家：
```sql
INSERT INTO `dish` (`dish_name`, `merchant_id`, `price`, ...) VALUES
('Spicy Chicken Rice', 1, 28.00, ...),
```

注意 `dish_name` 后面加 `merchant_id` 列，值为 `1`。

---

### Task 2: Entity — Dish.java 加 merchantId

**Files:**
- Modify: `src/com/order/entity/Dish.java`

- [ ] **Step 1: 添加 merchantId 字段**

```java
private Integer merchantId;
```

- [ ] **Step 2: 添加 getter/setter**

```java
public Integer getMerchantId() { return merchantId; }
public void setMerchantId(Integer merchantId) { this.merchantId = merchantId; }
```

- [ ] **Step 3: 添加 merchantName 字段（JOIN 用）**

```java
private String merchantName;
// getter/setter
```

---

### Task 3: DishDAO — 增加商家查询方法

**Files:**
- Modify: `src/com/order/dao/DishDAO.java`

- [ ] **Step 1: addByMerchantId(Integer merchantId)**

```java
public List<Dish> findByMerchantId(Integer merchantId) throws SQLException {
    return queryList(Dish.class, "SELECT d.*, c.category_name, u.username AS merchant_name FROM dish d LEFT JOIN category c ON d.category_id = c.category_id LEFT JOIN user u ON d.merchant_id = u.user_id WHERE d.merchant_id = ? ORDER BY c.sort_order", merchantId);
}
```

- [ ] **Step 2: 更新 findAll() 也 JOIN merchant**

```java
public List<Dish> findAll() throws SQLException {
    return queryList(Dish.class, "SELECT d.*, c.category_name, u.username AS merchant_name FROM dish d LEFT JOIN category c ON d.category_id = c.category_id LEFT JOIN user u ON d.merchant_id = u.user_id ORDER BY d.dish_id DESC");
}
```

- [ ] **Step 3: 更新其他已有查询也 JOIN merchant（findById、search、findByCategory、findRecommend、findByRecommendAndCategory）**

所有 SELECT 加 `LEFT JOIN user u ON d.merchant_id = u.user_id` 和 `u.username AS merchant_name`。

---

### Task 4: DishService — 增加商家方法

**Files:**
- Modify: `src/com/order/service/DishService.java`

- [ ] **Step 1: 新增方法**

```java
public List<Dish> findByMerchantId(Integer merchantId) throws Exception {
    return dishDAO.findByMerchantId(merchantId);
}
```

---

### Task 5: 首页改为商家列表

**Files:**
- Create: `WebContent/jsp/merchant/list.jsp`
- Modify: `WebContent/jsp/index.jsp`

- [ ] **Step 1: 新建 merchant/list.jsp — 商家列表页**

一个 JSP 页面，展示所有审核通过的商家（title="所有商家"），每个商家显示为卡片：
- 商家名称
- 商品数量
- "进入店铺" 按钮 → `/merchant/store?id=X`

- [ ] **Step 2: 修改 index.jsp — 转发到商家列表**

将 index.jsp 改为跳转到 `/merchant/list`，或者直接显示商家列表。

实际上更好的方式是：IndexServlet 改为查询所有审核通过的商家（role=2, status=0），index.jsp 改成展示商家列表。

---

### Task 6: MerchantListServlet — 商家列表接口

**Files:**
- Create: `src/com/order/servlet/MerchantListServlet.java`

- [ ] **Step 1: 创建 Servlet @WebServlet("/merchant/list")**

查询所有 role=2 AND status=0 的用户，查询每个商家的菜品数量，转发到 merchant/list.jsp。

```java
UserService userService = new UserService();
List<User> merchants = userService.findAllByRoleAndStatus(2, 0);
// 需要新增 findAllByRoleAndStatus 方法
```

需要同时更新 UserDAO 和 UserService 添加 `findAllByRoleAndStatus(int role, int status)` 方法。

---

### Task 7: MerchantStoreServlet — 商家店铺接口

**Files:**
- Create: `src/com/order/servlet/MerchantStoreServlet.java`
- Create: `WebContent/jsp/merchant/store.jsp`

- [ ] **Step 1: 创建 Servlet @WebServlet("/merchant/store")**

接收 `id` 参数，查询该商家的所有菜品并按分类分组，转发到 store.jsp。

```java
int merchantId = Integer.parseInt(req.getParameter("id"));
User merchant = userService.getById(merchantId);
List<Dish> dishes = dishService.findByMerchantId(merchantId);
// 按 categoryId 分组放入 Map
```

- [ ] **Step 2: 新建 store.jsp**

展示商家名称，下面按分类分组展示菜品。

---

### Task 8: AdminDishServlet — 商家仅看自己的菜品

**Files:**
- Modify: `src/com/order/servlet/admin/AdminDishServlet.java`

- [ ] **Step 1: 在 doGet 中添加商家过滤**

当前用户 role=2 时，搜索/列表只查 merchant_id = 当前用户。

```java
User currentUser = (User) req.getSession().getAttribute("user");
if (currentUser.getRole() == 2) {
    // 只查自己的菜品
    dishes = dishService.search(keyword, categoryId, status, currentUser.getUserId(), page, 8);
}
```

需要 DishDAO.search 增加 merchant_id 参数的重载方法。最简单的做法：增加一个 `search(keyword, categoryId, status, merchantId, offset, pageSize)` 方法。

- [ ] **Step 2: 在 doPost 的 save/update 中设置 merchant_id**

```java
if (currentUser.getRole() == 2) {
    dish.setMerchantId(currentUser.getUserId());
}
```

---

### Task 9: AdminOrderServlet — 商家仅看自己的订单行

**Files:**
- Modify: `src/com/order/servlet/admin/AdminOrderServlet.java`

- [ ] **Step 1: doGet 中过滤订单**

当 role=2 时，只查包含当前商家菜品的订单：
```java
if (currentUser.getRole() == 2) {
    orders = orderService.getOrdersByMerchantId(currentUser.getUserId());
}
```

- [ ] **Step 2: 订单详情过滤订单行**

在获取 order items 时，role=2 只获取属于该商家的订单行：
```java
if (currentUser.getRole() == 2) {
    items = orderService.getOrderItemsByMerchantId(orderId, currentUser.getUserId());
}
```

需要 OrderDAO 和 OrderService 新增方法。

---

### Task 10: AdminIndexServlet — 商家仪表盘统计

**Files:**
- Modify: `src/com/order/servlet/admin/AdminIndexServlet.java`

- [ ] **Step 1: role=2 时按商家统计**

```java
if (currentUser.getRole() == 2) {
    req.setAttribute("dishCount", dishService.countByMerchantId(currentUser.getUserId()));
    // 订单数、分类数等
}
```

需要 DishDAO 新增 `countByMerchantId(Integer merchantId)` 方法。

---

### Task 11: 登录过滤器适配

**Files:**
- Modify: `src/com/order/filter/LoginFilter.java`

- [ ] **Step 1: 放行 /merchant/* 路径**

```java
path.startsWith("/merchant/")
```

但需要校验：访问 /merchant/store?id=X 时，任意登录用户都可以访问（public）。如果未登录则需登录。

实际上 /merchant/list 和 /merchant/store 应该对所有已登录用户开放。在 LoginFilter 中，如果已登录用户访问 /merchant/* 应该放行。

当前 LoginFilter 的逻辑是：如果未登录跳转登录页。所以只需要确认 /merchant/* 不是 /admin/* 即可，因为只有 /admin/* 做了角色检查。

目前过滤器的逻辑：
- 未登录 → redirect to /login
- role != 1 && != 2 → 不能访问 /admin/*
- merchant/list 和 /merchant/store 不是 /admin/*，所以已登录用户都能访问 ✅

所以不需要改动 LoginFilter。

---

### Task 12: 新增 UserDAO/Service 方法

**Files:**
- Modify: `src/com/order/dao/UserDAO.java`
- Modify: `src/com/order/service/UserService.java`

- [ ] **Step 1: UserDAO 新增方法**

```java
public List<User> findAllByRoleAndStatus(Integer role, Integer status) throws SQLException {
    return queryList(User.class, "SELECT * FROM user WHERE role = ? AND status = ? ORDER BY user_id DESC", role, status);
}
```

- [ ] **Step 2: UserService 新增方法**

```java
public List<User> findAllByRoleAndStatus(Integer role, Integer status) throws Exception {
    return userDAO.findAllByRoleAndStatus(role, status);
}
```
