package com.order.servlet;

import com.order.entity.Order;
import com.order.entity.User;
import com.order.service.OrderService;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/order/submit")
public class SubmitOrderServlet extends HttpServlet {
    private OrderService orderService = new OrderService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String receiverName = req.getParameter("receiverName");
        String receiverPhone = req.getParameter("receiverPhone");
        String receiverAddress = req.getParameter("receiverAddress");
        String paymentMethod = req.getParameter("paymentMethod");
        Integer shopId = null;
        String shopIdStr = req.getParameter("shopId");
        if (shopIdStr != null && !shopIdStr.isEmpty()) {
            try { shopId = Integer.parseInt(shopIdStr); } catch (NumberFormatException e) {}
        }

        if (receiverName == null || receiverName.trim().isEmpty() ||
            receiverPhone == null || receiverPhone.trim().isEmpty() ||
            receiverAddress == null || receiverAddress.trim().isEmpty()) {
            req.setAttribute("error", "请填写完整的收货信息");
            req.getRequestDispatcher("/jsp/order/checkout.jsp").forward(req, resp);
            return;
        }

        try {
            Order order = orderService.submitOrder(user.getUserId(), receiverName.trim(),
                    receiverPhone.trim(), receiverAddress.trim(), paymentMethod, shopId);
            resp.sendRedirect(req.getContextPath() + "/order/pay?id=" + order.getOrderId());
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/jsp/order/checkout.jsp").forward(req, resp);
        }
    }
}
