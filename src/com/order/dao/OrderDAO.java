package com.order.dao;

import com.order.entity.Order;
import com.order.utils.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderDAO {

    public int insert(Order order, Connection conn) throws SQLException {
        PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO `order` (order_no, user_id, shop_id, receiver_name, receiver_phone, receiver_address, total_amount, payment_method, order_status, create_time) VALUES (?,?,?,?,?,?,?,?,?,?)",
                Statement.RETURN_GENERATED_KEYS);
        ps.setString(1, order.getOrderNo());
        ps.setInt(2, order.getUserId());
        if (order.getShopId() != null) ps.setInt(3, order.getShopId()); else ps.setNull(3, java.sql.Types.INTEGER);
        ps.setString(4, order.getReceiverName());
        ps.setString(5, order.getReceiverPhone());
        ps.setString(6, order.getReceiverAddress());
        ps.setBigDecimal(7, order.getTotalAmount());
        ps.setString(8, order.getPaymentMethod());
        ps.setInt(9, order.getOrderStatus());
        ps.setTimestamp(10, Timestamp.valueOf(order.getCreateTime()));
        ps.executeUpdate();
        ResultSet rs = ps.getGeneratedKeys();
        int id = 0;
        if (rs.next()) id = rs.getInt(1);
        rs.close();
        ps.close();
        return id;
    }

    public List<Order> findByUserId(Integer userId) throws SQLException {
        return findByUserId(userId, null);
    }

    public List<Order> findByUserId(Integer userId, String sort) throws SQLException {
        return findByUserId(userId, sort, 1, 9999);
    }

    public List<Order> findByUserId(Integer userId, String sort, int page, int pageSize) throws SQLException {
        Connection conn = DBUtil.getConnection();
        try {
            String orderClause = "time".equals(sort) ? " ORDER BY o.create_time DESC"
                : " ORDER BY CASE WHEN o.order_status IN (3,8,9) THEN 1 ELSE 0 END, o.create_time DESC";
            int offset = (page - 1) * pageSize;
            PreparedStatement ps = conn.prepareStatement(
                    "SELECT o.*, u.username FROM `order` o LEFT JOIN `user` u ON o.user_id = u.user_id WHERE o.user_id = ?" + orderClause + " LIMIT ?, ?");
            ps.setInt(1, userId);
            ps.setInt(2, offset);
            ps.setInt(3, pageSize);
            ResultSet rs = ps.executeQuery();
            List<Order> list = new ArrayList<>();
            while (rs.next()) list.add(mapRow(rs));
            rs.close();
            ps.close();
            return list;
        } finally {
            DBUtil.close(conn);
        }
    }

    // 管理员查询：支持用户名搜索 + 排序 + 分页
    public List<Order> findAll(String keyword, String sort, int page, int pageSize) throws SQLException {
        Connection conn = DBUtil.getConnection();
        try {
            StringBuilder sql = new StringBuilder("SELECT o.*, u.username FROM `order` o LEFT JOIN `user` u ON o.user_id = u.user_id WHERE 1=1");
            java.util.List<Object> params = new java.util.ArrayList<>();
            if (keyword != null && !keyword.trim().isEmpty()) {
                sql.append(" AND u.username LIKE ?");
                params.add("%" + keyword.trim() + "%");
            }
            sql.append(getOrderSortClause(sort));
            int offset = (page - 1) * pageSize;
            sql.append(" LIMIT ?, ?");
            params.add(offset);
            params.add(pageSize);
            PreparedStatement ps = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            ResultSet rs = ps.executeQuery();
            List<Order> list = new ArrayList<>();
            while (rs.next()) list.add(mapRow(rs));
            rs.close();
            ps.close();
            return list;
        } finally {
            DBUtil.close(conn);
        }
    }

    public List<Order> findAll(String keyword, String sort) throws SQLException {
        return findAll(keyword, sort, 1, 9999);
    }

    // 商家查询：支持用户名搜索 + 排序 + 分页
    public List<Order> findOrdersByMerchantId(Integer merchantId, String keyword, String sort, int page, int pageSize) throws SQLException {
        Connection conn = DBUtil.getConnection();
        try {
            StringBuilder sql = new StringBuilder(
                "SELECT DISTINCT o.*, u.username FROM `order` o LEFT JOIN `user` u ON o.user_id = u.user_id "
                + "LEFT JOIN order_item oi ON o.order_id = oi.order_id "
                + "WHERE oi.dish_id IN (SELECT dish_id FROM dish WHERE merchant_id = ?)");
            java.util.List<Object> params = new java.util.ArrayList<>();
            params.add(merchantId);
            if (keyword != null && !keyword.trim().isEmpty()) {
                sql.append(" AND u.username LIKE ?");
                params.add("%" + keyword.trim() + "%");
            }
            sql.append(getOrderSortClause(sort));
            int offset = (page - 1) * pageSize;
            sql.append(" LIMIT ?, ?");
            params.add(offset);
            params.add(pageSize);
            PreparedStatement ps = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            ResultSet rs = ps.executeQuery();
            List<Order> list = new ArrayList<>();
            while (rs.next()) list.add(mapRow(rs));
            rs.close();
            ps.close();
            return list;
        } finally {
            DBUtil.close(conn);
        }
    }

    public List<Order> findOrdersByMerchantId(Integer merchantId, String keyword, String sort) throws SQLException {
        return findOrdersByMerchantId(merchantId, keyword, sort, 1, 9999);
    }

    // 排序逻辑：默认排序（未完成优先+时间倒序）或仅按时间倒序
    private String getOrderSortClause(String sort) {
        if ("time".equals(sort)) {
            return " ORDER BY o.create_time DESC";
        }
        return " ORDER BY CASE WHEN o.order_status IN (3,8,9) THEN 1 ELSE 0 END, o.create_time DESC";
    }

    // 用户订单计数
    public long countByUserId(Integer userId) throws SQLException {
        Connection conn = DBUtil.getConnection();
        try {
            PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM `order` WHERE user_id = ?");
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            long count = 0;
            if (rs.next()) count = rs.getLong(1);
            rs.close(); ps.close();
            return count;
        } finally { DBUtil.close(conn); }
    }

    // 管理员订单计数
    public long countAll(String keyword) throws SQLException {
        Connection conn = DBUtil.getConnection();
        try {
            StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM `order` o LEFT JOIN `user` u ON o.user_id = u.user_id WHERE 1=1");
            java.util.List<Object> params = new java.util.ArrayList<>();
            if (keyword != null && !keyword.trim().isEmpty()) {
                sql.append(" AND u.username LIKE ?");
                params.add("%" + keyword.trim() + "%");
            }
            PreparedStatement ps = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            ResultSet rs = ps.executeQuery();
            long count = 0;
            if (rs.next()) count = rs.getLong(1);
            rs.close(); ps.close();
            return count;
        } finally { DBUtil.close(conn); }
    }

    // 商家订单计数
    public long countByMerchantId(Integer merchantId, String keyword) throws SQLException {
        Connection conn = DBUtil.getConnection();
        try {
            StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM `order` o LEFT JOIN `user` u ON o.user_id = u.user_id "
                + "LEFT JOIN order_item oi ON o.order_id = oi.order_id "
                + "WHERE oi.dish_id IN (SELECT dish_id FROM dish WHERE merchant_id = ?)");
            java.util.List<Object> params = new java.util.ArrayList<>();
            params.add(merchantId);
            if (keyword != null && !keyword.trim().isEmpty()) {
                sql.append(" AND u.username LIKE ?");
                params.add("%" + keyword.trim() + "%");
            }
            PreparedStatement ps = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            ResultSet rs = ps.executeQuery();
            long count = 0;
            if (rs.next()) count = rs.getLong(1);
            rs.close(); ps.close();
            return count;
        } finally { DBUtil.close(conn); }
    }

    public Order findById(Integer orderId) throws SQLException {
        Connection conn = DBUtil.getConnection();
        try {
            PreparedStatement ps = conn.prepareStatement(
                    "SELECT o.*, u.username FROM `order` o LEFT JOIN `user` u ON o.user_id = u.user_id WHERE o.order_id = ?");
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            Order order = rs.next() ? mapRow(rs) : null;
            rs.close();
            ps.close();
            return order;
        } finally {
            DBUtil.close(conn);
        }
    }

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

    public int updatePaymentMethod(Integer orderId, String paymentMethod) throws SQLException {
        Connection conn = DBUtil.getConnection();
        try {
            PreparedStatement ps = conn.prepareStatement("UPDATE `order` SET payment_method = ? WHERE order_id = ?");
            ps.setString(1, paymentMethod);
            ps.setInt(2, orderId);
            int rows = ps.executeUpdate();
            ps.close();
            return rows;
        } finally {
            DBUtil.close(conn);
        }
    }

    public int updatePayTime(Integer orderId, java.time.LocalDateTime payTime) throws SQLException {
        Connection conn = DBUtil.getConnection();
        try {
            PreparedStatement ps = conn.prepareStatement("UPDATE `order` SET pay_time = ? WHERE order_id = ?");
            ps.setTimestamp(1, Timestamp.valueOf(payTime));
            ps.setInt(2, orderId);
            int rows = ps.executeUpdate();
            ps.close();
            return rows;
        } finally {
            DBUtil.close(conn);
        }
    }

    private Order mapRow(ResultSet rs) throws SQLException {
        Order o = new Order();
        o.setOrderId(rs.getInt("order_id"));
        o.setOrderNo(rs.getString("order_no"));
        o.setUserId(rs.getInt("user_id"));
        int sid = rs.getInt("shop_id");
        o.setShopId(rs.wasNull() ? null : sid);
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
        o.setDeliveryStatus(rs.getInt("delivery_status"));
        o.setDeliveryPosition(rs.getString("delivery_position"));
        o.setUsername(rs.getString("username"));
        return o;
    }

    public int updateDelivery(Integer orderId, Integer deliveryStatus, String deliveryPosition) throws SQLException {
        Connection conn = DBUtil.getConnection();
        try {
            PreparedStatement ps = conn.prepareStatement(
                "UPDATE `order` SET delivery_status = ?, delivery_position = ? WHERE order_id = ?");
            ps.setInt(1, deliveryStatus);
            ps.setString(2, deliveryPosition);
            ps.setInt(3, orderId);
            int rows = ps.executeUpdate();
            ps.close();
            return rows;
        } finally {
            DBUtil.close(conn);
        }
    }
}
