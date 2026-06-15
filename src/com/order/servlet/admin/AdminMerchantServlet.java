package com.order.servlet.admin;

import com.order.entity.Dish;
import com.order.entity.Order;
import com.order.entity.OrderItem;
import com.order.entity.User;
import com.order.service.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/admin/merchant/*")
public class AdminMerchantServlet extends HttpServlet {
    private UserService userService = new UserService();
    private DishService dishService = new DishService();
    private OrderService orderService = new OrderService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User currentUser = (User) req.getSession().getAttribute("user");
        if (currentUser == null || currentUser.getRole() != 1) {
            resp.sendRedirect(req.getContextPath() + "/admin");
            return;
        }

        String path = req.getPathInfo();
        if (path == null || path.equals("/")) {
            try {
                List<User> merchants = userService.findAllByRoleAndStatus(2, 0);
                req.setAttribute("merchants", merchants);
            } catch (Exception e) { e.printStackTrace(); }
            req.getRequestDispatcher("/jsp/admin/merchant/list.jsp").forward(req, resp);
        } else if ("/detail".equals(path)) {
            String merchIdStr = req.getParameter("id");
            if (merchIdStr == null || merchIdStr.isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/admin/merchant");
                return;
            }
            try {
                int merchantId = Integer.parseInt(merchIdStr);
                User merchant = userService.getById(merchantId);
                if (merchant == null || merchant.getRole() != 2) {
                    resp.sendRedirect(req.getContextPath() + "/admin/merchant");
                    return;
                }
                List<Dish> dishes = dishService.findByMerchantId(merchantId);
                List<Order> orders = orderService.getOrdersByMerchantId(merchantId);
                req.setAttribute("merchant", merchant);
                req.setAttribute("dishes", dishes);
                req.setAttribute("orders", orders);
            } catch (Exception e) { e.printStackTrace(); }
            req.getRequestDispatcher("/jsp/admin/merchant/detail.jsp").forward(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/merchant");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User currentUser = (User) req.getSession().getAttribute("user");
        if (currentUser == null || currentUser.getRole() != 1) {
            resp.sendRedirect(req.getContextPath() + "/admin");
            return;
        }
        String path = req.getPathInfo();
        if ("/deleteDish".equals(path)) {
            String idStr = req.getParameter("id");
            if (idStr != null && !idStr.isEmpty()) {
                try {
                    dishService.delete(Integer.parseInt(idStr));
                    resp.setContentType("application/json;charset=UTF-8");
                    resp.getWriter().print("{\"success\":true}");
                } catch (Exception e) {
                    resp.setContentType("application/json;charset=UTF-8");
                    String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'") : "删除失败";
                    resp.getWriter().print("{\"success\":false,\"message\":\"" + msg + "\"}");
                }
            }
        } else if ("/status".equals(path)) {
            String orderIdStr = req.getParameter("orderId");
            String statusStr = req.getParameter("status");
            if (orderIdStr != null && statusStr != null) {
                try {
                    orderService.updateOrderStatus(Integer.parseInt(orderIdStr), Integer.parseInt(statusStr));
                    resp.setContentType("application/json;charset=UTF-8");
                    resp.getWriter().print("{\"success\":true}");
                } catch (Exception e) {
                    resp.setContentType("application/json;charset=UTF-8");
                    resp.getWriter().print("{\"success\":false}");
                }
            }
        } else if ("/updateCategory".equals(path)) {
            String uidStr = req.getParameter("userId");
            String category = req.getParameter("shopCategory");
            resp.setContentType("application/json;charset=UTF-8");
            try {
                int uid = Integer.parseInt(uidStr);
                // 通过 UserService 更新 shop_category
                new com.order.service.UserService().updateShopCategory(uid, category);
                resp.getWriter().print("{\"success\":true}");
            } catch (Exception e) {
                resp.getWriter().print("{\"success\":false,\"message\":\"" + (e.getMessage()!=null ? e.getMessage().replace("\"","'") : "更新失败") + "\"}");
            }
        }
    }
}
