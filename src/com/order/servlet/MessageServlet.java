package com.order.servlet;

import com.order.entity.Message;
import com.order.entity.User;
import com.order.service.MessageService;
import com.order.service.UserService;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/message/*")
public class MessageServlet extends HttpServlet {
    private MessageService messageService = new MessageService();
    private UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getPathInfo();
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        try {
            if ("/list".equals(path) || path == null) {
                List<User> chatUsers = messageService.getChatUsers(user.getUserId());
                long totalUnread = messageService.countUnread(user.getUserId());
                req.setAttribute("chatUsers", chatUsers);
                req.setAttribute("totalUnread", totalUnread);
                req.getRequestDispatcher("/jsp/message/list.jsp").forward(req, resp);
            } else if ("/chat".equals(path)) {
                Integer otherId = Integer.parseInt(req.getParameter("userId"));
                User otherUser = userService.getById(otherId);
                if (otherUser == null) {
                    resp.sendRedirect(req.getContextPath() + "/message/list");
                    return;
                }
                req.setAttribute("otherUser", otherUser);
                List<Message> messages = messageService.getConversation(user.getUserId(), otherId);
                req.setAttribute("messages", messages);
                req.getRequestDispatcher("/jsp/message/chat.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/jsp/message/list.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getPathInfo();
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        try {
            if ("/send".equals(path)) {
                Integer receiverId = Integer.parseInt(req.getParameter("receiverId"));
                String content = req.getParameter("content");
                messageService.sendMessage(user.getUserId(), receiverId, content);
                resp.sendRedirect(req.getContextPath() + "/message/chat?userId=" + receiverId);
            }
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/message/list");
        }
    }
}
