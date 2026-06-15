package com.order.service;

import com.order.dao.*;
import com.order.entity.*;
import com.order.utils.DBUtil;
import com.order.utils.OrderNoGenerator;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.List;

public class OrderService {
    private OrderDAO orderDAO = new OrderDAO();
    private OrderItemDAO orderItemDAO = new OrderItemDAO();
    private CartDAO cartDAO = new CartDAO();
    private DishDAO dishDAO = new DishDAO();
    private OrderLogDAO orderLogDAO = new OrderLogDAO();

    public Order submitOrder(Integer userId, String receiverName, String receiverPhone,
                             String receiverAddress, String paymentMethod, Integer shopId) throws Exception {
        if (receiverName == null || receiverName.trim().isEmpty()) {
            throw new Exception("收货人姓名不能为空");
        }
        if (receiverName.trim().length() > 20) {
            throw new Exception("收货人姓名长度不能超过20个字符");
        }
        if (receiverPhone == null || receiverPhone.trim().isEmpty()) {
            throw new Exception("手机号不能为空");
        }
        if (receiverPhone.trim().length() > 15) {
            throw new Exception("手机号长度不能超过15个字符");
        }
        if (receiverAddress == null || receiverAddress.trim().isEmpty()) {
            throw new Exception("收货地址不能为空");
        }
        if (receiverAddress.trim().length() > 200) {
            throw new Exception("收货地址长度不能超过200个字符");
        }

        List<Cart> cartItems = cartDAO.findByUserId(userId);
        if (cartItems == null || cartItems.isEmpty()) {
            throw new Exception("购物车为空");
        }

        Connection conn = DBUtil.getConnection();
        try {
            conn.setAutoCommit(false);

            // 跨店校验：如果指定了shopId，检查购物车中是否有其他店铺的商品
            if (shopId != null) {
                for (Cart item : cartItems) {
                    PreparedStatement psShop = conn.prepareStatement("SELECT merchant_id FROM dish WHERE dish_id = ?");
                    psShop.setInt(1, item.getDishId());
                    java.sql.ResultSet rsShop = psShop.executeQuery();
                    if (rsShop.next()) {
                        int itemShopId = rsShop.getInt("merchant_id");
                        if (itemShopId != shopId) {
                            rsShop.close(); psShop.close();
                            conn.rollback();
                            throw new Exception("购物车中包含其他店铺商品，请先清空后再结算本店订单");
                        }
                    }
                    rsShop.close();
                    psShop.close();
                }
            }

            BigDecimal totalAmount = BigDecimal.ZERO;
            for (Cart item : cartItems) {
                PreparedStatement psCheck = conn.prepareStatement(
                        "SELECT d.*, c.category_name FROM dish d LEFT JOIN category c ON d.category_id = c.category_id WHERE d.dish_id = ?");
                psCheck.setInt(1, item.getDishId());
                java.sql.ResultSet rs = psCheck.executeQuery();
                if (!rs.next()) {
                    rs.close(); psCheck.close();
                    conn.rollback();
                    throw new Exception("菜品不存在");
                }
                int stock = rs.getInt("stock");
                int quantity = item.getQuantity() != null ? item.getQuantity() : 0;
                if (stock < quantity) {
                    String dishName = rs.getString("dish_name");
                    rs.close(); psCheck.close();
                    conn.rollback();
                    throw new Exception("商品库存不足: " + dishName);
                }
                BigDecimal price = rs.getBigDecimal("special_price");
                if (price == null) price = rs.getBigDecimal("price");
                totalAmount = totalAmount.add(price.multiply(BigDecimal.valueOf(quantity)));
                rs.close();
                psCheck.close();
            }

            Order order = new Order();
            order.setOrderNo(OrderNoGenerator.generate());
            order.setUserId(userId);
            order.setReceiverName(receiverName);
            order.setReceiverPhone(receiverPhone);
            order.setReceiverAddress(receiverAddress);
            order.setTotalAmount(totalAmount);
            order.setPaymentMethod(paymentMethod);
            order.setOrderStatus(OrderStatus.PENDING_PAYMENT);
            order.setCreateTime(LocalDateTime.now());
            order.setShopId(shopId);
            int orderId = orderDAO.insert(order, conn);

            for (Cart item : cartItems) {
                PreparedStatement psDish = conn.prepareStatement(
                        "SELECT dish_name, price, special_price FROM dish WHERE dish_id = ?");
                psDish.setInt(1, item.getDishId());
                java.sql.ResultSet rsDish = psDish.executeQuery();
                if (rsDish.next()) {
                    String dishName = rsDish.getString("dish_name");
                    BigDecimal price = rsDish.getBigDecimal("special_price");
                    if (price == null) price = rsDish.getBigDecimal("price");
                    int quantity = item.getQuantity() != null ? item.getQuantity() : 0;

                    OrderItem orderItem = new OrderItem();
                    orderItem.setOrderId(orderId);
                    orderItem.setDishId(item.getDishId());
                    orderItem.setDishName(dishName);
                    orderItem.setPrice(price);
                    orderItem.setQuantity(quantity);
                    orderItem.setSubtotal(price.multiply(BigDecimal.valueOf(quantity)));
                    orderItemDAO.insert(orderItem, conn);

                    PreparedStatement psUpdate = conn.prepareStatement(
                            "UPDATE dish SET stock = stock - ? WHERE dish_id = ? AND stock >= ?");
                    psUpdate.setInt(1, quantity);
                    psUpdate.setInt(2, item.getDishId());
                    psUpdate.setInt(3, quantity);
                    int rows = psUpdate.executeUpdate();
                    if (rows == 0) {
                        rsDish.close(); psDish.close(); psUpdate.close();
                        conn.rollback();
                        throw new Exception("库存不足，下单失败");
                    }
                    psUpdate.close();
                }
                rsDish.close();
                psDish.close();
            }

            PreparedStatement psCart = conn.prepareStatement("DELETE FROM cart WHERE user_id = ?");
            psCart.setInt(1, userId);
            psCart.executeUpdate();
            psCart.close();

            conn.commit();

            order.setOrderId(orderId);
            return order;
        } catch (Exception e) {
            try { conn.rollback(); } catch (Exception ex) { ex.printStackTrace(); }
            throw e;
        } finally {
            try { conn.setAutoCommit(true); } catch (Exception ex) { ex.printStackTrace(); }
            DBUtil.close(conn);
        }
    }

    public List<Order> getOrdersByUserId(Integer userId) throws Exception {
        return orderDAO.findByUserId(userId);
    }

    public List<Order> getOrdersByMerchantId(Integer merchantId) throws Exception {
        return orderDAO.findOrdersByMerchantId(merchantId);
    }

    public List<Order> getAllOrders() throws Exception {
        return orderDAO.findAll();
    }

    public Order getOrderById(Integer orderId) throws Exception {
        return orderDAO.findById(orderId);
    }

    public List<OrderItem> getOrderItems(Integer orderId) throws Exception {
        return orderItemDAO.findByOrderId(orderId);
    }

    public List<OrderItem> getOrderItemsByMerchantId(Integer orderId, Integer merchantId) throws Exception {
        return orderItemDAO.findByOrderIdAndMerchantId(orderId, merchantId);
    }

    public void updateOrderStatus(Integer orderId, Integer status) throws Exception {
        orderDAO.updateStatus(orderId, status);
    }

    public void updateOrderPaymentMethod(Integer orderId, String paymentMethod) throws Exception {
        orderDAO.updatePaymentMethod(orderId, paymentMethod);
    }

    public void updatePayTime(Integer orderId, java.time.LocalDateTime payTime) throws Exception {
        orderDAO.updatePayTime(orderId, payTime);
    }

    public OrderLogDAO getOrderLogDAO() { return orderLogDAO; }

    // ========== 商家端操作 ==========

    public void merchantAccept(Integer orderId, Integer merchantId) throws Exception {
        Order order = orderDAO.findById(orderId);
        if (order == null) throw new Exception("订单不存在");
        if (order.getOrderStatus() != OrderStatus.PENDING_ACCEPT) throw new Exception("当前状态不允许接单");
        orderDAO.updateStatusWithAcceptTime(orderId, OrderStatus.ACCEPTED);
        writeLog(orderId, OrderStatus.PENDING_ACCEPT, OrderStatus.ACCEPTED, merchantId, 2, null);
    }

    public void merchantReject(Integer orderId, Integer merchantId, String reason) throws Exception {
        Order order = orderDAO.findById(orderId);
        if (order == null) throw new Exception("订单不存在");
        if (order.getOrderStatus() != OrderStatus.PENDING_ACCEPT) throw new Exception("当前状态不允许拒单");
        orderDAO.updateStatusWithCancelReason(orderId, OrderStatus.CANCELLED, reason);
        writeLog(orderId, OrderStatus.PENDING_ACCEPT, OrderStatus.CANCELLED, merchantId, 2, reason);
    }

    public void merchantStartPreparing(Integer orderId, Integer merchantId) throws Exception {
        Order order = orderDAO.findById(orderId);
        if (order == null) throw new Exception("订单不存在");
        if (order.getOrderStatus() != OrderStatus.ACCEPTED) throw new Exception("当前状态不允许开始制作");
        orderDAO.updateStatus(orderId, OrderStatus.PREPARING);
        writeLog(orderId, OrderStatus.ACCEPTED, OrderStatus.PREPARING, merchantId, 2, null);
    }

    public void merchantDeliver(Integer orderId, Integer merchantId) throws Exception {
        Order order = orderDAO.findById(orderId);
        if (order == null) throw new Exception("订单不存在");
        if (order.getOrderStatus() != OrderStatus.PREPARING) throw new Exception("当前状态不允许出餐");
        orderDAO.updateStatus(orderId, OrderStatus.DELIVERING);
        writeLog(orderId, OrderStatus.PREPARING, OrderStatus.DELIVERING, merchantId, 2, null);
    }

    public void merchantCancel(Integer orderId, Integer merchantId, String reason) throws Exception {
        Order order = orderDAO.findById(orderId);
        if (order == null) throw new Exception("订单不存在");
        int status = order.getOrderStatus();
        if (status != OrderStatus.ACCEPTED && status != OrderStatus.PREPARING) {
            throw new Exception("当前状态不允许商家取消");
        }
        orderDAO.updateStatusWithCancelReason(orderId, OrderStatus.CANCELLED, reason);
        writeLog(orderId, status, OrderStatus.CANCELLED, merchantId, 2, reason);
    }

    // ========== 用户端操作 ==========

    public void userConfirmReceive(Integer orderId, Integer userId) throws Exception {
        Order order = orderDAO.findById(orderId);
        if (order == null) throw new Exception("订单不存在");
        if (!order.getUserId().equals(userId)) throw new Exception("无权操作");
        int status = order.getOrderStatus();
        System.out.println("[Order] confirmReceive orderId=" + orderId + " userId=" + userId + " orderStatus=" + status);
        if (status != OrderStatus.DELIVERING && status != 1 && status != 2) {
            throw new Exception("当前状态不允许确认收货，当前状态：" + status);
        }
        orderDAO.updateStatus(orderId, OrderStatus.COMPLETED);
        writeLog(orderId, status, OrderStatus.COMPLETED, userId, 0, null);
    }

    public void userCancel(Integer orderId, Integer userId, String reason) throws Exception {
        Order order = orderDAO.findById(orderId);
        if (order == null) throw new Exception("订单不存在");
        if (!order.getUserId().equals(userId)) throw new Exception("无权操作");
        int status = order.getOrderStatus();
        if (status == OrderStatus.COMPLETED || status == OrderStatus.CANCELLED || status == 3) {
            throw new Exception("已完成或已取消的订单不能操作");
        }
        if (status == OrderStatus.PREPARING || status == OrderStatus.DELIVERING || status == 1 || status == 2) {
            throw new Exception("制作中和配送中的订单不能取消");
        }
        if (status == OrderStatus.ACCEPTED) {
            if (order.getAcceptTime() == null) throw new Exception("接单时间异常");
            long minutes = Duration.between(order.getAcceptTime(), LocalDateTime.now()).toMinutes();
            if (minutes > 1) {
                throw new Exception("已超过1分钟，需提交取消申请");
            }
        }
        orderDAO.updateStatusWithCancelReason(orderId, OrderStatus.CANCELLED, reason);
        writeLog(orderId, status, OrderStatus.CANCELLED, userId, 0, reason);
    }

    public boolean canUserDirectCancel(Integer orderId) throws Exception {
        Order order = orderDAO.findById(orderId);
        if (order == null) return false;
        if (order.getOrderStatus() != OrderStatus.ACCEPTED) return false;
        if (order.getAcceptTime() == null) return false;
        long minutes = Duration.between(order.getAcceptTime(), LocalDateTime.now()).toMinutes();
        return minutes <= 1;
    }

    // ========== 管理员端操作 ==========

    public void adminForceStatus(Integer orderId, int toStatus, Integer adminId, String reason) throws Exception {
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
        writeLog(orderId, fromStatus, toStatus, adminId, 1, reason);
    }

    // ========== 配送 ==========

    public void updateDelivery(Integer orderId, Integer deliveryStatus, String deliveryPosition) throws Exception {
        orderDAO.updateDelivery(orderId, deliveryStatus, deliveryPosition);
    }

    // ========== 日志 ==========

    private void writeLog(Integer orderId, Integer fromStatus, int toStatus, Integer operatorId, int operatorRole, String reason) throws Exception {
        OrderLog log = new OrderLog();
        log.setOrderId(orderId);
        log.setFromStatus(fromStatus);
        log.setToStatus(toStatus);
        log.setOperatorId(operatorId);
        log.setOperatorRole(operatorRole);
        log.setReason(reason);
        log.setCreateTime(LocalDateTime.now());
        orderLogDAO.insert(log);
    }
}
