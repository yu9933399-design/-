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
        String action = req.getParameter("action");
        if (orderIdStr == null || orderIdStr.isEmpty() || action == null) {
            resp.sendRedirect(req.getContextPath() + "/order/list");
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdStr);
            switch (action) {
                case "confirmReceive":
                    orderService.userConfirmReceive(orderId, user.getUserId());
                    resp.sendRedirect(req.getContextPath() + "/order/detail?id=" + orderId + "&success=" + java.net.URLEncoder.encode("确认收货成功", "UTF-8"));
                    break;
                case "cancel":
                    String reason = req.getParameter("reason");
                    orderService.userCancel(orderId, user.getUserId(), reason);
                    resp.sendRedirect(req.getContextPath() + "/order/detail?id=" + orderId + "&success=" + java.net.URLEncoder.encode("取消成功", "UTF-8"));
                    break;
                default:
                    resp.sendRedirect(req.getContextPath() + "/order/list");
            }
        } catch (Exception e) {
            e.printStackTrace();
            String errMsg = e.getMessage() != null ? e.getMessage() : "操作失败";
            resp.sendRedirect(req.getContextPath() + "/order/detail?id=" + orderIdStr + "&error=" + java.net.URLEncoder.encode(errMsg, "UTF-8"));
        }
    }
}
