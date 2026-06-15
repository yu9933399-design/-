package com.order.servlet;

import com.order.entity.Order;
import com.order.entity.OrderItem;
import com.order.entity.User;
import com.order.service.OrderService;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;

@WebServlet("/order/pay")
public class PayServlet extends HttpServlet {
    private OrderService orderService = new OrderService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String orderIdStr = req.getParameter("id");
        if (orderIdStr == null || orderIdStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/order/list");
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdStr);
            Order order = orderService.getOrderById(orderId);
            if (order != null && order.getUserId().equals(user.getUserId())) {
                List<OrderItem> items = orderService.getOrderItems(orderId);
                req.setAttribute("order", order);
                req.setAttribute("items", items);
            } else {
                req.setAttribute("error", "订单不存在");
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "查询订单失败");
        }

        req.getRequestDispatcher("/jsp/order/payment.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String orderIdStr = req.getParameter("orderId");
        String paymentMethod = req.getParameter("paymentMethod");
        if (orderIdStr == null || orderIdStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/order/list");
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdStr);
            Order order = orderService.getOrderById(orderId);
            if (order != null && order.getUserId().equals(user.getUserId()) && order.getOrderStatus() == 0) {
                if (paymentMethod != null && !paymentMethod.trim().isEmpty()) {
                    orderService.updateOrderPaymentMethod(orderId, paymentMethod.trim());
                }
                orderService.updateOrderStatus(orderId, 2);
            }
            resp.sendRedirect(req.getContextPath() + "/order/detail?id=" + orderId);
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/order/list");
        }
    }
}
