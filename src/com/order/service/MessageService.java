package com.order.service;

import com.order.dao.MessageDAO;
import com.order.dao.UserDAO;
import com.order.entity.Message;
import com.order.entity.User;
import java.util.List;

public class MessageService {
    private MessageDAO messageDAO = new MessageDAO();
    private UserDAO userDAO = new UserDAO();

    public void sendMessage(Integer senderId, Integer receiverId, String content) throws Exception {
        if (content == null || content.trim().isEmpty()) {
            throw new Exception("消息内容不能为空");
        }
        if (content.length() > 1000) {
            throw new Exception("消息内容不能超过1000个字符");
        }
        User receiver = userDAO.findById(receiverId);
        if (receiver == null) {
            throw new Exception("接收者不存在");
        }
        Message message = new Message();
        message.setSenderId(senderId);
        message.setReceiverId(receiverId);
        message.setContent(content.trim());
        messageDAO.insert(message);
    }

    public List<Message> getConversation(Integer user1Id, Integer user2Id) throws Exception {
        messageDAO.markAsRead(user2Id, user1Id);
        return messageDAO.findConversation(user1Id, user2Id);
    }

    public List<Message> getRecentMessages(Integer userId) throws Exception {
        return messageDAO.findRecentByUserId(userId);
    }

    public List<Integer> getChatUserIds(Integer userId) throws Exception {
        return messageDAO.findChatUserIds(userId);
    }

    public long countUnread(Integer receiverId) throws Exception {
        return messageDAO.countUnread(receiverId);
    }

    public long countUnreadFrom(Integer senderId, Integer receiverId) throws Exception {
        return messageDAO.countUnreadFrom(senderId, receiverId);
    }

    public List<User> getChatUsers(Integer userId) throws Exception {
        List<Integer> userIds = messageDAO.findChatUserIds(userId);
        List<User> users = new java.util.ArrayList<>();
        for (Integer uid : userIds) {
            User user = userDAO.findById(uid);
            if (user != null) {
                long unread = messageDAO.countUnreadFrom(uid, userId);
                user.setStatus((int) unread);
                users.add(user);
            }
        }
        return users;
    }

    public List<User> getMerchants() throws Exception {
        return userDAO.findAllByRoleAndStatus(2, 0);
    }

    public List<User> getAdmins() throws Exception {
        return userDAO.findAllByRoleAndStatus(1, 0);
    }
}
