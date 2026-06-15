# 订单状态管理改造 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use compose:subagent (recommended) or compose:execute to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将订单状态从简单的 0/1/2/3 改造为美团风格的 1/2/4/5/6/8/9 状态体系，分别实现商家端、用户端、管理员端的状态操作逻辑。

**Architecture:** 三层改造：DAO层（SQL+日志表）→ Service层（业务规则校验）→ Servlet层（角色权限分发）。新增 `order_log` 表记录所有状态变更，Order 实体增加 `accept_time` 字段支持时间判断。

**Tech Stack:** Java Servlet, JSP, MySQL, Druid Connection Pool, Bootstrap 5

---

## 状态码定义

| 状态码 | 名称 | 说明 |
|--------|------|------|
| 1 | 待支付 | 用户下单后初始状态 |
| 2 | 待商家接单 | 用户支付后等待商家接单 |
| 4 | 已接单 | 商家接单，开始制作 |
| 5 | 制作中 | 商家正在制作 |
| 6 | 配送中 | 已出餐，配送中 |
| 8 | 已完成 | 用户确认收货 |
| 9 | 已取消 | 订单取消 |

---

### Task 1: 数据库改造 — 新增 order_log 表和 order 表字段

**Files:**
- Modify: `WebContent/sql/schema.sql`
- Create: `WebContent/sql/order_status_migration.sql`

- [ ] **Step 1: 创建迁移脚本**

```sql
-- WebContent/sql/order_status_migration.sql
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
```

- [ ] **Step 2: 更新 schema.sql 中的 order 表定义**

在 `order` 表的 `pay_time` 字段后添加 `accept_time` 和 `cancel_reason`，并在末尾添加 `order_log` 表定义。

- [ ] **Step 3: Commit**

---

### Task 2: Order 实体和常量类

**Files:**
- Modify: `src/com/order/entity/Order.java`
- Create: `src/com/order/entity/OrderStatus.java`
- Create: `src/com/order/entity/OrderLog.java`

- [ ] **Step 1: 创建 OrderStatus 常量类**

```java
package com.order.entity;

public class OrderStatus {
    public static final int PENDING_PAYMENT = 1;   // 待支付
    public static final int PENDING_ACCEPT = 2;    // 待商家接单
    public static final int ACCEPTED = 4;           // 已接单
    public static final int PREPARING = 5;          // 制作中
    public static final int DELIVERING = 6;         // 配送中
    public static final int COMPLETED = 8;          // 已完成
    public static final int CANCELLED = 9;          // 已取消

    public static String getName(int status) {
        switch (status) {
            case PENDING_PAYMENT: return "待支付";
            case PENDING_ACCEPT: return "待接单";
            case ACCEPTED: return "已接单";
            case PREPARING: return "制作中";
            case DELIVERING: return "配送中";
            case COMPLETED: return "已完成";
            case CANCELLED: return "已取消";
            default: return "未知";
        }
    }

    public static String getBadgeClass(int status) {
        switch (status) {
            case PENDING_PAYMENT: return "bg-warning";
            case PENDING_ACCEPT: return "bg-info";
            case ACCEPTED: return "bg-primary";
            case PREPARING: return "bg-primary";
            case DELIVERING: return "bg-success";
            case COMPLETED: return "bg-success";
            case CANCELLED: return "bg-secondary";
            default: return "bg-secondary";
        }
    }
}
```

- [ ] **Step 2: 创建 OrderLog 实体**

```java
package com.order.entity;

import java.time.LocalDateTime;

public class OrderLog {
    private Integer logId;
    private Integer orderId;
    private Integer fromStatus;
    private Integer toStatus;
    private Integer operatorId;
    private Integer operatorRole;
    private String reason;
    private LocalDateTime createTime;

    // getters and setters
    public Integer getLogId() { return logId; }
    public void setLogId(Integer logId) { this.logId = logId; }
    public Integer getOrderId() { return orderId; }
    public void setOrderId(Integer orderId) { this.orderId = orderId; }
    public Integer getFromStatus() { return fromStatus; }
    public void setFromStatus(Integer fromStatus) { this.fromStatus = fromStatus; }
    public Integer getToStatus() { return toStatus; }
    public void setToStatus(Integer toStatus) { this.toStatus = toStatus; }
    public Integer getOperatorId() { return operatorId; }
    public void setOperatorId(Integer operatorId) { this.operatorId = operatorId; }
    public Integer getOperatorRole() { return operatorRole; }
    public void setOperatorRole(Integer operatorRole) { this.operatorRole = operatorRole; }
    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
    public LocalDateTime getCreateTime() { return createTime; }
    public void setCreateTime(LocalDateTime createTime) { this.createTime = createTime; }
}
```

- [ ] **Step 3: 修改 Order 实体添加新字段**

在 `Order.java` 中添加：
```java
private LocalDateTime acceptTime;
private String cancelReason;

public LocalDateTime getAcceptTime() { return acceptTime; }
public void setAcceptTime(LocalDateTime acceptTime) { this.acceptTime = acceptTime; }
public String getCancelReason() { return cancelReason; }
public void setCancelReason(String cancelReason) { this.cancelReason = cancelReason; }
```

- [ ] **Step 4: Commit**

---

### Task 3: DAO 层改造 — OrderDAO + OrderLogDAO

**Files:**
- Modify: `src/com/order/dao/OrderDAO.java`
- Create: `src/com/order/dao/OrderLogDAO.java`

- [ ] **Step 1: 创建 OrderLogDAO**

```java
package com.order.dao;

import com.order.entity.OrderLog;
import com.order.utils.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderLogDAO {

    public int insert(OrderLog log) throws SQLException {
        Connection conn = DBUtil.getConnection();
        try {
            PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO order_log (order_id, from_status, to_status, operator_id, operator_role, reason, create_time) VALUES (?,?,?,?,?,?,?)");
            ps.setInt(1, log.getOrderId());
            if (log.getFromStatus() != null) ps.setInt(2, log.getFromStatus()); else ps.setNull(2, Types.TINYINT);
            ps.setInt(3, log.getToStatus());
            ps.setInt(4, log.getOperatorId());
            ps.setInt(5, log.getOperatorRole());
            if (log.getReason() != null) ps.setString(6, log.getReason()); else ps.setNull(6, Types.VARCHAR);
            ps.setTimestamp(7, Timestamp.valueOf(log.getCreateTime()));
            int rows = ps.executeUpdate();
            ps.close();
            return rows;
        } finally {
            DBUtil.close(conn);
        }
    }

    public List<OrderLog> findByOrderId(Integer orderId) throws SQLException {
        Connection conn = DBUtil.getConnection();
        try {
            PreparedStatement ps = conn.prepareStatement(
                "SELECT l.*, u.username AS operator_name FROM order_log l LEFT JOIN user u ON l.operator_id = u.user_id WHERE l.order_id = ? ORDER BY l.create_time DESC");
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            List<OrderLog> list = new ArrayList<>();
            while (rs.next()) {
                OrderLog log = new OrderLog();
                log.setLogId(rs.getInt("log_id"));
                log.setOrderId(rs.getInt("order_id"));
                int fs = rs.getInt("from_status");
                log.setFromStatus(rs.wasNull() ? null : fs);
                log.setToStatus(rs.getInt("to_status"));
                log.setOperatorId(rs.getInt("operator_id"));
                log.setOperatorRole(rs.getInt("operator_role"));
                log.setReason(rs.getString("reason"));
                Timestamp ct = rs.getTimestamp("create_time");
                if (ct != null) log.setCreateTime(ct.toLocalDateTime());
                list.add(log);
            }
            rs.close();
            ps.close();
            return list;
        } finally {
            DBUtil.close(conn);
        }
    }
}
```

- [ ] **Step 2: 修改 OrderDAO.updateStatus 支持 accept_time 和 cancel_reason**

替换 `updateStatus` 方法，添加新方法：

```java
public int updateStatus(Integer orderId, Integer status) throws SQLException {
    Connection conn = DBUtil.getConnection();
    try {
        PreparedStatement ps = conn.prepareStatement("UPDATE `order` SET order_status = ? WHERE order_id = ?");
        ps.setInt(1, status);
        ps.setInt(2, orderId);
        int rows = ps.executeUpdate();
        ps.close();
        return rows;
    } finally {
        DBUtil.close(conn);
    }
}

public int updateStatusWithAcceptTime(Integer orderId, Integer status) throws SQLException {
    Connection conn = DBUtil.getConnection();
    try {
        PreparedStatement ps = conn.prepareStatement(
            "UPDATE `order` SET order_status = ?, accept_time = NOW() WHERE order_id = ?");
        ps.setInt(1, status);
        ps.setInt(2, orderId);
        int rows = ps.executeUpdate();
        ps.close();
        return rows;
    } finally {
        DBUtil.close(conn);
    }
}

public int updateStatusWithCancelReason(Integer orderId, Integer status, String reason) throws SQLException {
    Connection conn = DBUtil.getConnection();
    try {
        PreparedStatement ps = conn.prepareStatement(
            "UPDATE `order` SET order_status = ?, cancel_reason = ? WHERE order_id = ?");
        ps.setInt(1, status);
        ps.setString(2, reason);
        ps.setInt(3, orderId);
        int rows = ps.executeUpdate();
        ps.close();
        return rows;
    } finally {
        DBUtil.close(conn);
    }
}
```

修改 `mapRow` 方法，增加 `accept_time` 和 `cancel_reason` 的读取：

```java
private Order mapRow(ResultSet rs) throws SQLException {
    Order o = new Order();
    o.setOrderId(rs.getInt("order_id"));
    o.setOrderNo(rs.getString("order_no"));
    o.setUserId(rs.getInt("user_id"));
    o.setReceiverName(rs.getString("receiver_name"));
    o.setReceiverPhone(rs.getString("receiver_phone"));
    o.setReceiverAddress(rs.getString("receiver_address"));
    o.setTotalAmount(rs.getBigDecimal("total_amount"));
    o.setPaymentMethod(rs.getString("payment_method"));
    o.setOrderStatus(rs.getInt("order_status"));
    Timestamp ct = rs.getTimestamp("create_time");
    if (ct != null) o.setCreateTime(ct.toLocalDateTime());
    Timestamp pt = rs.getTimestamp("pay_time");
    if (pt != null) o.setPayTime(pt.toLocalDateTime());
    Timestamp at = rs.getTimestamp("accept_time");
    if (at != null) o.setAcceptTime(at.toLocalDateTime());
    o.setCancelReason(rs.getString("cancel_reason"));
    o.setUsername(rs.getString("username"));
    return o;
}
```

- [ ] **Step 3: Commit**

---

### Task 4: Service 层改造 — 商家端状态逻辑

**Files:**
- Modify: `src/com/order/service/OrderService.java`

- [ ] **Step 1: 添加商家端状态更新方法**

在 `OrderService.java` 中添加以下方法（保留现有方法不变）：

```java
private OrderLogDAO orderLogDAO = new OrderLogDAO();

// 商家接单：待接单(2) -> 已接单(4)
public void merchantAccept(Integer orderId, Integer merchantId) throws Exception {
    Order order = orderDAO.findById(orderId);
    if (order == null) throw new Exception("订单不存在");
    if (order.getOrderStatus() != OrderStatus.PENDING_ACCEPT) throw new Exception("当前状态不允许接单");
    orderDAO.updateStatusWithAcceptTime(orderId, OrderStatus.ACCEPTED);
    OrderLog log = new OrderLog();
    log.setOrderId(orderId);
    log.setFromStatus(OrderStatus.PENDING_ACCEPT);
    log.setToStatus(OrderStatus.ACCEPTED);
    log.setOperatorId(merchantId);
    log.setOperatorRole(2);
    log.setCreateTime(LocalDateTime.now());
    orderLogDAO.insert(log);
}

// 商家拒单：待接单(2) -> 已取消(9)
public void merchantReject(Integer orderId, Integer merchantId, String reason) throws Exception {
    Order order = orderDAO.findById(orderId);
    if (order == null) throw new Exception("订单不存在");
    if (order.getOrderStatus() != OrderStatus.PENDING_ACCEPT) throw new Exception("当前状态不允许拒单");
    orderDAO.updateStatusWithCancelReason(orderId, OrderStatus.CANCELLED, reason);
    OrderLog log = new OrderLog();
    log.setOrderId(orderId);
    log.setFromStatus(OrderStatus.PENDING_ACCEPT);
    log.setToStatus(OrderStatus.CANCELLED);
    log.setOperatorId(merchantId);
    log.setOperatorRole(2);
    log.setReason(reason);
    log.setCreateTime(LocalDateTime.now());
    orderLogDAO.insert(log);
}

// 商家开始制作：已接单(4) -> 制作中(5)
public void merchantStartPreparing(Integer orderId, Integer merchantId) throws Exception {
    Order order = orderDAO.findById(orderId);
    if (order == null) throw new Exception("订单不存在");
    if (order.getOrderStatus() != OrderStatus.ACCEPTED) throw new Exception("当前状态不允许开始制作");
    orderDAO.updateStatus(orderId, OrderStatus.PREPARING);
    OrderLog log = new OrderLog();
    log.setOrderId(orderId);
    log.setFromStatus(OrderStatus.ACCEPTED);
    log.setToStatus(OrderStatus.PREPARING);
    log.setOperatorId(merchantId);
    log.setOperatorRole(2);
    log.setCreateTime(LocalDateTime.now());
    orderLogDAO.insert(log);
}

// 商家出餐：制作中(5) -> 配送中(6)
public void merchantDeliver(Integer orderId, Integer merchantId) throws Exception {
    Order order = orderDAO.findById(orderId);
    if (order == null) throw new Exception("订单不存在");
    if (order.getOrderStatus() != OrderStatus.PREPARING) throw new Exception("当前状态不允许出餐");
    orderDAO.updateStatus(orderId, OrderStatus.DELIVERING);
    OrderLog log = new OrderLog();
    log.setOrderId(orderId);
    log.setFromStatus(OrderStatus.PREPARING);
    log.setToStatus(OrderStatus.DELIVERING);
    log.setOperatorId(merchantId);
    log.setOperatorRole(2);
    log.setCreateTime(LocalDateTime.now());
    orderLogDAO.insert(log);
}

// 商家取消：已接单(4)或制作中(5) -> 已取消(9)
public void merchantCancel(Integer orderId, Integer merchantId, String reason) throws Exception {
    Order order = orderDAO.findById(orderId);
    if (order == null) throw new Exception("订单不存在");
    int status = order.getOrderStatus();
    if (status != OrderStatus.ACCEPTED && status != OrderStatus.PREPARING) {
        throw new Exception("当前状态不允许商家取消");
    }
    orderDAO.updateStatusWithCancelReason(orderId, OrderStatus.CANCELLED, reason);
    OrderLog log = new OrderLog();
    log.setOrderId(orderId);
    log.setFromStatus(status);
    log.setToStatus(OrderStatus.CANCELLED);
    log.setOperatorId(merchantId);
    log.setOperatorRole(2);
    log.setReason(reason);
    log.setCreateTime(LocalDateTime.now());
    orderLogDAO.insert(log);
}
```

- [ ] **Step 2: Commit**

---

### Task 5: Service 层改造 — 用户端状态逻辑

**Files:**
- Modify: `src/com/order/service/OrderService.java`

- [ ] **Step 1: 添加用户端状态更新方法**

在 `OrderService.java` 中添加：

```java
// 用户确认收货：配送中(6) -> 已完成(8)
public void userConfirmReceive(Integer orderId, Integer userId) throws Exception {
    Order order = orderDAO.findById(orderId);
    if (order == null) throw new Exception("订单不存在");
    if (!order.getUserId().equals(userId)) throw new Exception("无权操作");
    if (order.getOrderStatus() != OrderStatus.DELIVERING) throw new Exception("当前状态不允许确认收货");
    orderDAO.updateStatus(orderId, OrderStatus.COMPLETED);
    OrderLog log = new OrderLog();
    log.setOrderId(orderId);
    log.setFromStatus(OrderStatus.DELIVERING);
    log.setToStatus(OrderStatus.COMPLETED);
    log.setOperatorId(userId);
    log.setOperatorRole(0);
    log.setCreateTime(LocalDateTime.now());
    orderLogDAO.insert(log);
}

// 用户取消订单（接单1分钟内直接取消，超过1分钟需申请）
public void userCancel(Integer orderId, Integer userId, String reason) throws Exception {
    Order order = orderDAO.findById(orderId);
    if (order == null) throw new Exception("订单不存在");
    if (!order.getUserId().equals(userId)) throw new Exception("无权操作");
    int status = order.getOrderStatus();
    if (status == OrderStatus.COMPLETED || status == OrderStatus.CANCELLED) {
        throw new Exception("已完成或已取消的订单不能操作");
    }
    if (status == OrderStatus.PREPARING || status == OrderStatus.DELIVERING) {
        throw new Exception("制作中和配送中的订单不能取消");
    }
    // 已接单(4)：检查接单时间
    if (status == OrderStatus.ACCEPTED) {
        if (order.getAcceptTime() == null) throw new Exception("接单时间异常");
        long minutes = java.time.Duration.between(order.getAcceptTime(), LocalDateTime.now()).toMinutes();
        if (minutes > 1) {
            throw new Exception("已超过1分钟，需提交取消申请");
        }
    }
    orderDAO.updateStatusWithCancelReason(orderId, OrderStatus.CANCELLED, reason);
    OrderLog log = new OrderLog();
    log.setOrderId(orderId);
    log.setFromStatus(status);
    log.setToStatus(OrderStatus.CANCELLED);
    log.setOperatorId(userId);
    log.setOperatorRole(0);
    log.setReason(reason);
    log.setCreateTime(LocalDateTime.now());
    orderLogDAO.insert(log);
}

// 检查用户是否可直接取消（已接单1分钟内）
public boolean canUserDirectCancel(Integer orderId) throws Exception {
    Order order = orderDAO.findById(orderId);
    if (order == null) return false;
    if (order.getOrderStatus() != OrderStatus.ACCEPTED) return false;
    if (order.getAcceptTime() == null) return false;
    long minutes = java.time.Duration.between(order.getAcceptTime(), LocalDateTime.now()).toMinutes();
    return minutes <= 1;
}
```

- [ ] **Step 2: Commit**

---

### Task 6: Service 层改造 — 管理员端状态逻辑

**Files:**
- Modify: `src/com/order/service/OrderService.java`

- [ ] **Step 1: 添加管理员端状态更新方法**

在 `OrderService.java` 中添加：

```java
// 管理员强制修改状态（全权限）
public void adminForceStatus(Integer orderId, Integer toStatus, Integer adminId, String reason) throws Exception {
    Order order = orderDAO.findById(orderId);
    if (order == null) throw new Exception("订单不存在");
    if (reason == null || reason.trim().isEmpty()) throw new Exception("管理员操作必须填写原因");
    int fromStatus = order.getOrderStatus();
    if (toStatus == OrderStatus.ACCEPTED) {
        orderDAO.updateStatusWithAcceptTime(orderId, toStatus);
    } else if (toStatus == OrderStatus.CANCELLED) {
        orderDAO.updateStatusWithCancelReason(orderId, toStatus, reason);
    } else {
        orderDAO.updateStatus(orderId, toStatus);
    }
    OrderLog log = new OrderLog();
    log.setOrderId(orderId);
    log.setFromStatus(fromStatus);
    log.setToStatus(toStatus);
    log.setOperatorId(adminId);
    log.setOperatorRole(1);
    log.setReason(reason);
    log.setCreateTime(LocalDateTime.now());
    orderLogDAO.insert(log);
}
```

- [ ] **Step 2: Commit**

---

### Task 7: 商家端 Servlet 改造 — AdminOrderServlet

**Files:**
- Modify: `src/com/order/servlet/admin/AdminOrderServlet.java`

- [ ] **Step 1: 重写 doPost 方法，按角色分发状态操作**

替换 `doPost` 方法为：

```java
@Override
protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
    User currentUser = (User) req.getSession().getAttribute("user");
    if (currentUser == null || (currentUser.getRole() != 1 && currentUser.getRole() != 2)) {
        resp.setContentType("application/json;charset=UTF-8");
        resp.getWriter().print("{\"success\":false,\"message\":\"无权限\"}");
        return;
    }
    String path = req.getPathInfo();
    resp.setContentType("application/json;charset=UTF-8");
    try {
        if ("/status".equals(path)) {
            String orderIdStr = req.getParameter("orderId");
            String action = req.getParameter("action");
            String reason = req.getParameter("reason");
            if (orderIdStr == null || action == null) {
                resp.getWriter().print("{\"success\":false,\"message\":\"参数不完整\"}");
                return;
            }
            int orderId = Integer.parseInt(orderIdStr);

            if (currentUser.getRole() == 2) {
                // 商家操作
                switch (action) {
                    case "accept":
                        orderService.merchantAccept(orderId, currentUser.getUserId());
                        break;
                    case "reject":
                        orderService.merchantReject(orderId, currentUser.getUserId(), reason);
                        break;
                    case "startPreparing":
                        orderService.merchantStartPreparing(orderId, currentUser.getUserId());
                        break;
                    case "deliver":
                        orderService.merchantDeliver(orderId, currentUser.getUserId());
                        break;
                    case "cancel":
                        orderService.merchantCancel(orderId, currentUser.getUserId(), reason);
                        break;
                    default:
                        resp.getWriter().print("{\"success\":false,\"message\":\"未知操作\"}");
                        return;
                }
            } else {
                // 管理员操作
                String statusStr = req.getParameter("status");
                if (statusStr == null) {
                    resp.getWriter().print("{\"success\":false,\"message\":\"缺少状态参数\"}");
                    return;
                }
                int toStatus = Integer.parseInt(statusStr);
                orderService.adminForceStatus(orderId, toStatus, currentUser.getUserId(), reason);
            }
            resp.getWriter().print("{\"success\":true}");
        }
    } catch (NumberFormatException e) {
        resp.getWriter().print("{\"success\":false,\"message\":\"参数格式错误\"}");
    } catch (Exception e) {
        resp.getWriter().print("{\"success\":false,\"message\":\"" + e.getMessage().replace("\"", "'") + "\"}");
    }
}
```

- [ ] **Step 2: 在 doGet 中为管理员加载订单日志**

在 `doGet` 的 `/detail` 分支中，添加日志查询：

```java
if ("/detail".equals(path)) {
    // ... 现有代码 ...
    if (order != null) {
        // ... 现有 items 加载 ...
        // 新增：加载订单日志
        if (currentUser.getRole() == 1) {
            List<com.order.entity.OrderLog> logs = new com.order.dao.OrderLogDAO().findByOrderId(orderId);
            req.setAttribute("logs", logs);
        }
    }
}
```

- [ ] **Step 3: Commit**

---

### Task 8: 商家端 JSP 改造 — order/list.jsp

**Files:**
- Modify: `WebContent/jsp/admin/order/list.jsp`

- [ ] **Step 1: 更新订单列表状态列和操作按钮**

替换整个 `<tbody>` 部分：

```jsp
<tbody><c:forEach items="${orders}" var="order"><tr>
<td>${order.orderNo}</td><td>${order.username}</td><td class="text-primary fw-bold">&#165;${order.totalAmount}</td>
<td><span class="badge ${order.orderStatus == 1 ? 'bg-warning' : order.orderStatus == 2 ? 'bg-info' : order.orderStatus == 4 ? 'bg-primary' : order.orderStatus == 5 ? 'bg-primary' : order.orderStatus == 6 ? 'bg-success' : order.orderStatus == 8 ? 'bg-success' : 'bg-secondary'}">
<c:choose><c:when test="${order.orderStatus == 1}">待支付</c:when><c:when test="${order.orderStatus == 2}">待接单</c:when><c:when test="${order.orderStatus == 4}">已接单</c:when><c:when test="${order.orderStatus == 5}">制作中</c:when><c:when test="${order.orderStatus == 6}">配送中</c:when><c:when test="${order.orderStatus == 8}">已完成</c:when><c:when test="${order.orderStatus == 9}">已取消</c:when></c:choose>
</span></td>
<td class="text-muted small">${order.createTime}</td>
<td>
<a href="${pageContext.request.contextPath}/admin/order/detail?id=${order.orderId}" class="btn btn-outline-primary btn-sm me-1">详情</a>
<c:if test="${sessionScope.user.role == 2}">
  <c:if test="${order.orderStatus == 2}">
    <button class="btn btn-success btn-sm me-1 order-action" data-order="${order.orderId}" data-action="accept">接单</button>
    <button class="btn btn-danger btn-sm me-1 order-action" data-order="${order.orderId}" data-action="reject" data-need-reason="true">拒单</button>
  </c:if>
  <c:if test="${order.orderStatus == 4}">
    <button class="btn btn-primary btn-sm me-1 order-action" data-order="${order.orderId}" data-action="startPreparing">开始制作</button>
    <button class="btn btn-danger btn-sm me-1 order-action" data-order="${order.orderId}" data-action="cancel" data-need-reason="true">取消</button>
  </c:if>
  <c:if test="${order.orderStatus == 5}">
    <button class="btn btn-success btn-sm me-1 order-action" data-order="${order.orderId}" data-action="deliver">出餐</button>
    <button class="btn btn-danger btn-sm me-1 order-action" data-order="${order.orderId}" data-action="cancel" data-need-reason="true">取消</button>
  </c:if>
</c:if>
<c:if test="${sessionScope.user.role == 1}">
  <c:if test="${order.orderStatus != 8 && order.orderStatus != 9}">
    <select class="form-select form-select-sm d-inline-block w-auto me-1 admin-status-select" data-order-id="${order.orderId}" style="width:auto;">
      <option value="1" ${order.orderStatus == 1 ? 'selected' : ''}>待支付</option>
      <option value="2" ${order.orderStatus == 2 ? 'selected' : ''}>待接单</option>
      <option value="4" ${order.orderStatus == 4 ? 'selected' : ''}>已接单</option>
      <option value="5" ${order.orderStatus == 5 ? 'selected' : ''}>制作中</option>
      <option value="6" ${order.orderStatus == 6 ? 'selected' : ''}>配送中</option>
      <option value="8" ${order.orderStatus == 8 ? 'selected' : ''}>已完成</option>
      <option value="9" ${order.orderStatus == 9 ? 'selected' : ''}>已取消</option>
    </select>
  </c:if>
</c:if>
</td></tr></c:forEach></tbody>
```

- [ ] **Step 2: 更新 JavaScript 处理商家操作和管理员操作**

替换底部 `<script>` 块：

```jsp
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script>
// 商家操作按钮
$(document).on('click', '.order-action', function(){
  var btn = $(this);
  var orderId = btn.data('order');
  var action = btn.data('action');
  var needReason = btn.data('need-reason');
  if (needReason) {
    var reason = prompt('请输入原因：');
    if (!reason) return;
    $.post('${pageContext.request.contextPath}/admin/order/status', {orderId: orderId, action: action, reason: reason}, function(r){
      if(r.success) location.reload(); else alert(r.message || '操作失败');
    });
  } else {
    if (!confirm('确定执行此操作？')) return;
    $.post('${pageContext.request.contextPath}/admin/order/status', {orderId: orderId, action: action}, function(r){
      if(r.success) location.reload(); else alert(r.message || '操作失败');
    });
  }
});
// 管理员状态修改
$(document).on('change', '.admin-status-select', function(){
  var select = $(this);
  var orderId = select.data('order-id');
  var status = select.val();
  var reason = prompt('请输入操作原因（必填）：');
  if (!reason) { select.val(select.data('orig')); return; }
  select.data('orig', status);
  $.post('${pageContext.request.contextPath}/admin/order/status', {orderId: orderId, status: status, reason: reason}, function(r){
    if(r.success) location.reload(); else alert(r.message || '操作失败');
  });
});
</script>
```

- [ ] **Step 3: Commit**

---

### Task 9: 用户端 Servlet 改造 — ConfirmServlet + OrderDetailServlet

**Files:**
- Modify: `src/com/order/servlet/ConfirmServlet.java`
- Modify: `src/com/order/servlet/OrderDetailServlet.java`

- [ ] **Step 1: 重写 ConfirmServlet 支持取消和确认收货**

```java
package com.order.servlet;

import com.order.entity.Order;
import com.order.entity.User;
import com.order.service.OrderService;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/order/confirm")
public class ConfirmServlet extends HttpServlet {
    private OrderService orderService = new OrderService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String orderIdStr = req.getParameter("orderId");
        String action = req.getParameter("action");
        if (orderIdStr == null || orderIdStr.isEmpty() || action == null) {
            resp.sendRedirect(req.getContextPath() + "/order/list");
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdStr);
            switch (action) {
                case "confirmReceive":
                    orderService.userConfirmReceive(orderId, user.getUserId());
                    resp.sendRedirect(req.getContextPath() + "/order/detail?id=" + orderId + "&success=确认收货成功");
                    break;
                case "cancel":
                    String reason = req.getParameter("reason");
                    orderService.userCancel(orderId, user.getUserId(), reason);
                    resp.sendRedirect(req.getContextPath() + "/order/detail?id=" + orderId + "&success=取消成功");
                    break;
                default:
                    resp.sendRedirect(req.getContextPath() + "/order/list");
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/order/detail?id=" + orderIdStr + "&error=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
        }
    }
}
```

- [ ] **Step 2: 修改 OrderDetailServlet 传递 canDirectCancel 信息**

在 `OrderDetailServlet.doGet` 中，在设置 order 和 items 之后添加：

```java
boolean canDirectCancel = orderService.canUserDirectCancel(orderId);
req.setAttribute("canDirectCancel", canDirectCancel);
```

- [ ] **Step 3: Commit**

---

### Task 10: 用户端 JSP 改造 — orderDetail.jsp

**Files:**
- Modify: `WebContent/jsp/order/orderDetail.jsp`

- [ ] **Step 1: 更新状态显示和操作按钮**

替换整个 `orderDetail.jsp`：

```jsp
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="../common/header.jsp"><jsp:param name="title" value="订单详情"/></jsp:include>
<div class="container mt-4">
<c:if test="${success != null}"><div class="alert alert-success"><c:out value="${success}"/></div></c:if>
<c:if test="${error != null}"><div class="alert alert-danger"><c:out value="${error}"/></div></c:if>
<c:if test="${order != null}">
<div class="card border-0 shadow-sm mb-3"><div class="card-header bg-white fw-bold">订单信息</div><div class="card-body">
<div class="row"><div class="col-md-6"><p>订单号：${order.orderNo}</p><p>下单时间：${order.createTime}</p></div>
<div class="col-md-6"><p>收货人：<c:out value="${order.receiverName}"/> <c:out value="${order.receiverPhone}"/></p><p>地址：<c:out value="${order.receiverAddress}"/></p></div></div>
<p>支付方式：<c:out value="${order.paymentMethod}"/></p>
<p>订单状态：<span class="badge ${order.orderStatus == 1 ? 'bg-warning' : order.orderStatus == 2 ? 'bg-info' : order.orderStatus == 4 ? 'bg-primary' : order.orderStatus == 5 ? 'bg-primary' : order.orderStatus == 6 ? 'bg-success' : order.orderStatus == 8 ? 'bg-success' : 'bg-secondary'}">
<c:choose><c:when test="${order.orderStatus == 1}">待支付</c:when><c:when test="${order.orderStatus == 2}">待接单</c:when><c:when test="${order.orderStatus == 4}">已接单</c:when><c:when test="${order.orderStatus == 5}">制作中</c:when><c:when test="${order.orderStatus == 6}">配送中</c:when><c:when test="${order.orderStatus == 8}">已完成</c:when><c:when test="${order.orderStatus == 9}">已取消</c:when></c:choose>
</span></p>
<c:if test="${order.orderStatus == 9 && not empty order.cancelReason}"><p class="text-danger">取消原因：<c:out value="${order.cancelReason}"/></p></c:if>
</div></div>
<c:if test="${not empty items}"><div class="card border-0 shadow-sm"><div class="card-header bg-white fw-bold">商品明细</div><div class="card-body"><table class="table"><thead><tr><th>商品</th><th>单价</th><th>数量</th><th>小计</th></tr></thead>
<tbody><c:forEach items="${items}" var="item"><tr><td><c:out value="${item.dishName}"/></td><td>&#165;${item.price}</td><td>${item.quantity}</td><td class="text-primary fw-bold">&#165;${item.subtotal}</td></tr></c:forEach></tbody></table>
<div class="text-end"><strong>总计：<span class="text-primary fs-5">&#165;${order.totalAmount}</span></strong></div></div></div></c:if>

<%-- 待支付：去支付 --%>
<c:if test="${order.orderStatus == 1}">
<a href="${pageContext.request.contextPath}/order/pay?id=${order.orderId}" class="btn btn-success mt-3 me-2"><i class="fas fa-qrcode me-1"></i>去支付</a>
</c:if>

<%-- 已接单：1分钟内可直接取消 --%>
<c:if test="${order.orderStatus == 4 && canDirectCancel}">
<form action="${pageContext.request.contextPath}/order/confirm" method="post" style="display:inline;">
    <input type="hidden" name="orderId" value="${order.orderId}"/>
    <input type="hidden" name="action" value="cancel"/>
    <input type="hidden" name="reason" value="用户主动取消"/>
    <button type="submit" class="btn btn-outline-danger mt-3 me-2" onclick="return confirm('确定取消订单？')"><i class="fas fa-times me-1"></i>取消订单</button>
</form>
</c:if>

<%-- 配送中：确认收货 --%>
<c:if test="${order.orderStatus == 6}">
<form action="${pageContext.request.contextPath}/order/confirm" method="post" style="display:inline;">
    <input type="hidden" name="orderId" value="${order.orderId}"/>
    <input type="hidden" name="action" value="confirmReceive"/>
    <button type="submit" class="btn btn-success mt-3 me-2" onclick="return confirm('确认已收到商品？')"><i class="fas fa-check-double me-1"></i>确认收货</button>
</form>
</c:if>

<a href="${pageContext.request.contextPath}/order/list" class="btn btn-secondary mt-3">返回订单列表</a>
</c:if></div>
<jsp:include page="../common/footer.jsp"/>
```

- [ ] **Step 2: 更新 user/orderList.jsp 状态显示**

替换 `user/orderList.jsp` 中的状态 badge 部分：

```jsp
<c:choose><c:when test="${order.orderStatus == 1}"><span class="badge bg-warning">待支付</span></c:when><c:when test="${order.orderStatus == 2}"><span class="badge bg-info">待接单</span></c:when><c:when test="${order.orderStatus == 4}"><span class="badge bg-primary">已接单</span></c:when><c:when test="${order.orderStatus == 5}"><span class="badge bg-primary">制作中</span></c:when><c:when test="${order.orderStatus == 6}"><span class="badge bg-success">配送中</span></c:when><c:when test="${order.orderStatus == 8}"><span class="badge bg-success">已完成</span></c:when><c:when test="${order.orderStatus == 9}"><span class="badge bg-secondary">已取消</span></c:when></c:choose>
```

- [ ] **Step 3: Commit**

---

### Task 11: 管理员端 JSP 改造 — admin/order/detail.jsp

**Files:**
- Modify: `WebContent/jsp/admin/order/detail.jsp`

- [ ] **Step 1: 更新订单详情页，增加日志展示和强制操作**

在订单详情卡片下方，商品明细之后，添加：

```jsp
<%-- 订单状态变更日志（仅管理员可见） --%>
<c:if test="${sessionScope.user.role == 1 && not empty logs}">
<div class="card border-0 shadow-sm mb-3"><div class="card-header bg-white fw-bold"><i class="fas fa-history me-2"></i>操作日志</div><div class="card-body">
<table class="table table-sm"><thead><tr><th>时间</th><th>操作人</th><th>角色</th><th>变更</th><th>原因</th></tr></thead>
<tbody><c:forEach items="${logs}" var="log"><tr>
<td class="small">${log.createTime}</td>
<td><c:out value="${log.operatorName}"/></td>
<td><c:choose><c:when test="${log.operatorRole == 1}">管理员</c:when><c:when test="${log.operatorRole == 2}">商家</c:when><c:otherwise>用户</c:otherwise></c:choose></td>
<td><span class="badge bg-secondary">${log.fromStatus}</span> → <span class="badge bg-primary">${log.toStatus}</span></td>
<td><c:out value="${log.reason}" default="-"/></td>
</tr></c:forEach></tbody></table></div></div>
</c:if>
```

- [ ] **Step 2: Commit**

---

### Task 12: PayServlet 支付成功后状态改为待接单

**Files:**
- Modify: `src/com/order/servlet/PayServlet.java`

- [ ] **Step 1: 修改支付成功后的状态码**

找到支付成功后调用 `updateOrderStatus` 的地方，将状态从 `1` 改为 `2`（待商家接单）。

- [ ] **Step 2: Commit**

---

### Task 13: 全量验证

- [ ] **Step 1: 检查所有 JSP 中的状态码引用**

搜索所有 JSP 文件中的 `orderStatus == 0`, `orderStatus == 1`, `orderStatus == 2`, `orderStatus == 3`，确认全部更新为新状态码。

- [ ] **Step 2: 检查所有 Servlet 中的状态码引用**

搜索所有 Servlet 文件中的 `orderService.updateOrderStatus` 调用，确认全部使用新的业务方法。

- [ ] **Step 3: 最终 Commit**
