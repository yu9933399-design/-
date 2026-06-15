package com.order.dao;

import com.order.entity.OrderItem;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderItemDAO {

    public int insert(OrderItem item, Connection conn) throws SQLException {
        PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO order_item (order_id, dish_id, dish_name, price, quantity, subtotal) VALUES (?,?,?,?,?,?)");
        ps.setInt(1, item.getOrderId());
        ps.setInt(2, item.getDishId());
        ps.setString(3, item.getDishName());
        ps.setBigDecimal(4, item.getPrice());
        ps.setInt(5, item.getQuantity());
        ps.setBigDecimal(6, item.getSubtotal());
        int rows = ps.executeUpdate();
        ps.close();
        return rows;
    }

    public List<OrderItem> findByOrderId(Integer orderId) throws SQLException {
        Connection conn = com.order.utils.DBUtil.getConnection();
        try {
            PreparedStatement ps = conn.prepareStatement(
                    "SELECT oi.*, d.image_url FROM order_item oi LEFT JOIN dish d ON oi.dish_id = d.dish_id WHERE oi.order_id = ?");
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            List<OrderItem> list = new ArrayList<>();
            while (rs.next()) {
                OrderItem item = new OrderItem();
                item.setItemId(rs.getInt("item_id"));
                item.setOrderId(rs.getInt("order_id"));
                item.setDishId(rs.getInt("dish_id"));
                item.setDishName(rs.getString("dish_name"));
                item.setPrice(rs.getBigDecimal("price"));
                item.setQuantity(rs.getInt("quantity"));
                item.setSubtotal(rs.getBigDecimal("subtotal"));
                item.setImageUrl(rs.getString("image_url"));
                list.add(item);
            }
            rs.close();
            ps.close();
            return list;
        } finally {
            com.order.utils.DBUtil.close(conn);
        }
    }

    public List<OrderItem> findByOrderIdAndMerchantId(Integer orderId, Integer merchantId) throws SQLException {
        Connection conn = com.order.utils.DBUtil.getConnection();
        try {
            PreparedStatement ps = conn.prepareStatement(
                    "SELECT oi.*, d.image_url FROM order_item oi "
                    + "LEFT JOIN dish d ON oi.dish_id = d.dish_id "
                    + "WHERE oi.order_id = ? AND d.merchant_id = ?");
            ps.setInt(1, orderId);
            ps.setInt(2, merchantId);
            ResultSet rs = ps.executeQuery();
            List<OrderItem> list = new ArrayList<>();
            while (rs.next()) {
                OrderItem item = new OrderItem();
                item.setItemId(rs.getInt("item_id"));
                item.setOrderId(rs.getInt("order_id"));
                item.setDishId(rs.getInt("dish_id"));
                item.setDishName(rs.getString("dish_name"));
                item.setPrice(rs.getBigDecimal("price"));
                item.setQuantity(rs.getInt("quantity"));
                item.setSubtotal(rs.getBigDecimal("subtotal"));
                item.setImageUrl(rs.getString("image_url"));
                list.add(item);
            }
            rs.close();
            ps.close();
            return list;
        } finally {
            com.order.utils.DBUtil.close(conn);
        }
    }
}
