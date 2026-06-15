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
                             String receiverAddress, String paymentMethod) throws Exception {
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
            order.setOrderStatus(0);
            order.setCreateTime(LocalDateTime.now());
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
}
