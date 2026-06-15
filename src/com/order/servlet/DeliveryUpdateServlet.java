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
 * 配送信息更新Servlet
 * 商家/管理员调用，更新配送状态和位置
 * 已送达后不可再修改
 */
@WebServlet("/delivery/update")
public class DeliveryUpdateServlet extends HttpServlet {
    private OrderService orderService = new OrderService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        HttpSession session = req.getSession();
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null || (user.getRole() != 1 && user.getRole() != 2)) {
            out.print("{\"success\":false,\"message\":\"无权限\"}");
            return;
        }

        String orderIdStr = req.getParameter("orderId");
        String deliveryStatusStr = req.getParameter("deliveryStatus");
        String deliveryPosition = req.getParameter("deliveryPosition");

        if (orderIdStr == null || deliveryStatusStr == null) {
            out.print("{\"success\":false,\"message\":\"参数不完整\"}");
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdStr);
            int deliveryStatus = Integer.parseInt(deliveryStatusStr);

            Order order = orderService.getOrderById(orderId);
            if (order == null) {
                out.print("{\"success\":false,\"message\":\"订单不存在\"}");
                return;
            }

            // 已送达后不可再修改
            if (order.getDeliveryStatus() != null && order.getDeliveryStatus() == 2) {
                out.print("{\"success\":false,\"message\":\"已送达订单不可修改配送信息\"}");
                return;
            }

            // 商家只能修改自己店铺的订单
            if (user.getRole() == 2) {
                boolean isMerchantOrder = orderService.getOrderItemsByMerchantId(orderId, user.getUserId()) != null
                    && !orderService.getOrderItemsByMerchantId(orderId, user.getUserId()).isEmpty();
                if (!isMerchantOrder) {
                    out.print("{\"success\":false,\"message\":\"无权操作此订单\"}");
                    return;
                }
            }

            // 只有配送中状态才能标记为已送达
            if (deliveryStatus == 2 && (order.getDeliveryStatus() == null || order.getDeliveryStatus() != 1)) {
                out.print("{\"success\":false,\"message\":\"只有配送中的订单才能标记为已送达\"}");
                return;
            }

            // 位置描述不能为空
            if ((deliveryPosition == null || deliveryPosition.trim().isEmpty()) && deliveryStatus == 1) {
                out.print("{\"success\":false,\"message\":\"配送中必须填写位置描述\"}");
                return;
            }

            orderService.updateDelivery(orderId, deliveryStatus, deliveryPosition);
            out.print("{\"success\":true}");
        } catch (NumberFormatException e) {
            out.print("{\"success\":false,\"message\":\"参数格式错误\"}");
        } catch (Exception e) {
            out.print("{\"success\":false,\"message\":\"" + e.getMessage().replace("\"", "'") + "\"}");
        }
    }
}
