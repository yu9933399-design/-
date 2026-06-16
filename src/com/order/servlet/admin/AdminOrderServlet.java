package com.order.servlet.admin;

import com.order.entity.Order;
import com.order.entity.OrderItem;
import com.order.entity.OrderLog;
import com.order.entity.User;
import com.order.dao.OrderLogDAO;
import com.order.service.OrderService;
import com.order.service.UserService;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/admin/order/*")
public class AdminOrderServlet extends HttpServlet {
    private OrderService orderService = new OrderService();
    private UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User currentUser = (User) req.getSession().getAttribute("user");
        if (currentUser == null || (currentUser.getRole() != 1 && currentUser.getRole() != 2)) {
            resp.sendRedirect(req.getContextPath() + "/admin");
            return;
        }

        String path = req.getPathInfo();
        if (path == null) path = "/";

        if ("/detail".equals(path)) {
            String orderIdStr = req.getParameter("id");
            if (orderIdStr != null && !orderIdStr.isEmpty()) {
                try {
                    int orderId = Integer.parseInt(orderIdStr);
                    Order order = orderService.getOrderById(orderId);
                    if (order != null) {
                        List<OrderItem> items = (currentUser.getRole() == 2)
                                ? orderService.getOrderItemsByMerchantId(orderId, currentUser.getUserId())
                                : orderService.getOrderItems(orderId);
                        req.setAttribute("order", order);
                        req.setAttribute("items", items);
                        if (currentUser.getRole() == 1) {
                            List<OrderLog> logs = new OrderLogDAO().findByOrderId(orderId);
                            req.setAttribute("logs", logs);
                        }
                    } else {
                        req.setAttribute("error", "订单不存在");
                    }
                } catch (NumberFormatException e) {
                    req.setAttribute("error", "订单ID格式错误");
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            req.getRequestDispatcher("/jsp/admin/order/detail.jsp").forward(req, resp);
        } else {
            try {
                String keyword = req.getParameter("keyword");
                String sort = req.getParameter("sort");
                int page = 1;
                int pageSize = 8;
                try {
                    String pageStr = req.getParameter("page");
                    if (pageStr != null && !pageStr.isEmpty()) page = Integer.parseInt(pageStr);
                } catch (NumberFormatException e) {}
                if (page < 1) page = 1;

                List<Order> orders;
                long total;
                if (currentUser.getRole() == 1) {
                    req.setAttribute("merchants", userService.findAllByRoleAndStatus(2, 0));
                    String merchIdStr = req.getParameter("merchantId");
                    if (merchIdStr != null && !merchIdStr.isEmpty()) {
                        int merchId = Integer.parseInt(merchIdStr);
                        total = orderService.countOrdersByMerchantId(merchId, keyword);
                        int totalPages = (int) Math.ceil((double) total / pageSize);
                        if (totalPages < 1) totalPages = 1;
                        if (page > totalPages) page = totalPages;
                        orders = orderService.getOrdersByMerchantId(merchId, keyword, sort, page, pageSize);
                        req.setAttribute("merchantId", merchId);
                    } else {
                        total = orderService.countAllOrders(keyword);
                        int totalPages = (int) Math.ceil((double) total / pageSize);
                        if (totalPages < 1) totalPages = 1;
                        if (page > totalPages) page = totalPages;
                        orders = orderService.getAllOrders(keyword, sort, page, pageSize);
                    }
                } else {
                    total = orderService.countOrdersByMerchantId(currentUser.getUserId(), keyword);
                    int totalPages = (int) Math.ceil((double) total / pageSize);
                    if (totalPages < 1) totalPages = 1;
                    if (page > totalPages) page = totalPages;
                    orders = orderService.getOrdersByMerchantId(currentUser.getUserId(), keyword, sort, page, pageSize);
                }
                int totalPages = (int) Math.ceil((double) total / pageSize);
                if (totalPages < 1) totalPages = 1;
                req.setAttribute("orders", orders);
                req.setAttribute("keyword", keyword);
                req.setAttribute("sort", sort);
                req.setAttribute("currentPage", page);
                req.setAttribute("totalPages", totalPages);
            } catch (Exception e) { e.printStackTrace(); }
            req.getRequestDispatcher("/jsp/admin/order/list.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User currentUser = (User) req.getSession().getAttribute("user");
        if (currentUser == null || (currentUser.getRole() != 1 && currentUser.getRole() != 2)) {
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().print("{\"success\":false,\"message\":\"无权限\"}");
            return;
        }
        String path = req.getPathInfo();
        resp.setContentType("application/json;charset=UTF-8");
        try {
            if ("/status".equals(path)) {
                String orderIdStr = req.getParameter("orderId");
                String action = req.getParameter("action");
                String reason = req.getParameter("reason");
                String statusStr = req.getParameter("status");
                if (orderIdStr == null) {
                    resp.getWriter().print("{\"success\":false,\"message\":\"参数不完整\"}");
                    return;
                }
                int orderId = Integer.parseInt(orderIdStr);

                if (currentUser.getRole() == 2) {
                    if (action == null) {
                        resp.getWriter().print("{\"success\":false,\"message\":\"参数不完整\"}");
                        return;
                    }
                    switch (action) {
                        case "accept":
                            orderService.merchantAccept(orderId, currentUser.getUserId());
                            break;
                        case "reject":
                            orderService.merchantReject(orderId, currentUser.getUserId(), reason);
                            break;
                        case "startPreparing":
                            orderService.merchantStartPreparing(orderId, currentUser.getUserId());
                            break;
                        case "deliver":
                            orderService.merchantDeliver(orderId, currentUser.getUserId());
                            break;
                        case "cancel":
                            orderService.merchantCancel(orderId, currentUser.getUserId(), reason);
                            break;
                        default:
                            resp.getWriter().print("{\"success\":false,\"message\":\"未知操作\"}");
                            return;
                    }
                } else {
                    if (statusStr == null) {
                        resp.getWriter().print("{\"success\":false,\"message\":\"缺少状态参数\"}");
                        return;
                    }
                    int toStatus = Integer.parseInt(statusStr);
                    orderService.adminForceStatus(orderId, toStatus, currentUser.getUserId(), reason);
                }
                resp.getWriter().print("{\"success\":true}");
            }
        } catch (NumberFormatException e) {
            resp.getWriter().print("{\"success\":false,\"message\":\"参数格式错误\"}");
        } catch (Exception e) {
            resp.getWriter().print("{\"success\":false,\"message\":\"" + e.getMessage().replace("\"", "'") + "\"}");
        }
    }
}
