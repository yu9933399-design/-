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
                log.setOperatorName(rs.getString("operator_name"));
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
