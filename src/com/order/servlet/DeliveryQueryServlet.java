package com.order.servlet;

import com.order.entity.Order;
import com.order.entity.User;
import com.order.service.OrderService;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

/**
 * 配送信息查询Servlet
 * 用户端调用，根据订单ID查询配送状态和位置信息
 */
@WebServlet("/delivery/query")
public class DeliveryQueryServlet extends HttpServlet {
    private OrderService orderService = new OrderService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        HttpSession session = req.getSession();
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            out.print("{\"success\":false,\"message\":\"未登录\"}");
            return;
        }

        String orderIdStr = req.getParameter("orderId");
        if (orderIdStr == null || orderIdStr.isEmpty()) {
            out.print("{\"success\":false,\"message\":\"缺少订单ID\"}");
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdStr);
            Order order = orderService.getOrderById(orderId);
            if (order == null) {
                out.print("{\"success\":false,\"message\":\"订单不存在\"}");
                return;
            }
            if (!order.getUserId().equals(user.getUserId()) && user.getRole() != 1) {
                out.print("{\"success\":false,\"message\":\"无权查看\"}");
                return;
            }

            String statusText;
            switch (order.getDeliveryStatus() != null ? order.getDeliveryStatus() : 0) {
                case 1: statusText = "配送中"; break;
                case 2: statusText = "已送达"; break;
                default: statusText = "待配送"; break;
            }

            out.print("{\"success\":true,\"deliveryStatus\":" + (order.getDeliveryStatus() != null ? order.getDeliveryStatus() : 0)
                + ",\"deliveryStatusText\":\"" + statusText + "\""
                + ",\"deliveryPosition\":\"" + (order.getDeliveryPosition() != null ? order.getDeliveryPosition().replace("\"", "'") : "暂无位置信息") + "\""
                + ",\"orderStatus\":" + order.getOrderStatus() + "}");
        } catch (NumberFormatException e) {
            out.print("{\"success\":false,\"message\":\"参数格式错误\"}");
        } catch (Exception e) {
            out.print("{\"success\":false,\"message\":\"查询失败\"}");
        }
    }
}
