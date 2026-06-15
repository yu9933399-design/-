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
        if (orderIdStr == null || orderIdStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/order/list");
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdStr);
            Order order = orderService.getOrderById(orderId);
            if (order != null && order.getUserId().equals(user.getUserId()) && (order.getOrderStatus() == 1 || order.getOrderStatus() == 2)) {
                orderService.updateOrderStatus(orderId, 3);
                resp.sendRedirect(req.getContextPath() + "/order/detail?id=" + orderId);
            } else {
                resp.sendRedirect(req.getContextPath() + "/order/list");
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/order/list");
        }
    }
}
