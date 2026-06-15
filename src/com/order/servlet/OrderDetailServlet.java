package com.order.servlet;

import com.order.entity.Order;
import com.order.entity.OrderItem;
import com.order.entity.User;
import com.order.service.OrderService;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/order/detail")
public class OrderDetailServlet extends HttpServlet {
    private OrderService orderService = new OrderService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String orderIdStr = req.getParameter("id");
        if (orderIdStr != null && !orderIdStr.isEmpty()) {
            try {
                int orderId = Integer.parseInt(orderIdStr);
                Order order = orderService.getOrderById(orderId);
                if (order != null && order.getUserId().equals(user.getUserId())) {
                    List<OrderItem> items = orderService.getOrderItems(orderId);
                    req.setAttribute("order", order);
                    req.setAttribute("items", items);
                    boolean canDirectCancel = orderService.canUserDirectCancel(orderId);
                    req.setAttribute("canDirectCancel", canDirectCancel);
                } else {
                    req.setAttribute("error", "订单不存在");
                }
            } catch (NumberFormatException e) {
                req.setAttribute("error", "订单ID格式错误");
            } catch (Exception e) {
                e.printStackTrace();
                req.setAttribute("error", "查询订单失败");
            }
        }
        req.getRequestDispatcher("/jsp/order/orderDetail.jsp").forward(req, resp);
    }
}
