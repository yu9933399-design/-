package com.order.dao;

import com.order.entity.Message;
import com.order.utils.DBUtil;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

public class MessageDAO extends BaseDAO {

    public int insert(Message message) throws SQLException {
        return update("INSERT INTO message (sender_id, receiver_id, content, is_read, create_time) VALUES (?,?,?,0,NOW())",
                message.getSenderId(), message.getReceiverId(), message.getContent());
    }

    public List<Message> findByUserId(Integer userId) throws SQLException {
        return queryList(Message.class,
                "SELECT m.*, s.username AS sender_name, r.username AS receiver_name FROM message m " +
                "LEFT JOIN user s ON m.sender_id = s.user_id LEFT JOIN user r ON m.receiver_id = r.user_id " +
                "WHERE m.sender_id = ? OR m.receiver_id = ? ORDER BY m.create_time DESC", userId, userId);
    }

    public List<Message> findConversation(Integer user1Id, Integer user2Id) throws SQLException {
        return queryList(Message.class,
                "SELECT m.*, s.username AS sender_name, r.username AS receiver_name FROM message m " +
                "LEFT JOIN user s ON m.sender_id = s.user_id LEFT JOIN user r ON m.receiver_id = r.user_id " +
                "WHERE (m.sender_id = ? AND m.receiver_id = ?) OR (m.sender_id = ? AND m.receiver_id = ?) " +
                "ORDER BY m.create_time ASC", user1Id, user2Id, user2Id, user1Id);
    }

    public int markAsRead(Integer senderId, Integer receiverId) throws SQLException {
        return update("UPDATE message SET is_read = 1 WHERE sender_id = ? AND receiver_id = ? AND is_read = 0",
                senderId, receiverId);
    }

    public long countUnread(Integer receiverId) throws SQLException {
        return queryScalar("SELECT COUNT(*) FROM message WHERE receiver_id = ? AND is_read = 0", receiverId);
    }

    public long countUnreadFrom(Integer senderId, Integer receiverId) throws SQLException {
        return queryScalar("SELECT COUNT(*) FROM message WHERE sender_id = ? AND receiver_id = ? AND is_read = 0",
                senderId, receiverId);
    }

    public List<Integer> findChatUserIds(Integer userId) throws SQLException {
        Connection conn = DBUtil.getConnection();
        try {
            List<Long> longIds = runner.query(conn,
                    "SELECT other_id FROM ( " +
                    "SELECT IF(sender_id = ?, receiver_id, sender_id) AS other_id, MAX(create_time) AS latest_time " +
                    "FROM message WHERE sender_id = ? OR receiver_id = ? " +
                    "GROUP BY other_id ORDER BY latest_time DESC) t",
                    new org.apache.commons.dbutils.handlers.ColumnListHandler<Long>(), userId, userId, userId);
            List<Integer> result = new java.util.ArrayList<>();
            for (Long lid : longIds) {
                result.add(lid.intValue());
            }
            return result;
        } finally {
            DBUtil.close(conn);
        }
    }

    public List<Message> findRecentByUserId(Integer userId) throws SQLException {
        return queryList(Message.class,
                "SELECT m.*, s.username AS sender_name, r.username AS receiver_name FROM message m " +
                "LEFT JOIN user s ON m.sender_id = s.user_id LEFT JOIN user r ON m.receiver_id = r.user_id " +
                "WHERE m.sender_id = ? OR m.receiver_id = ? ORDER BY m.create_time DESC LIMIT 50", userId, userId);
    }
}
