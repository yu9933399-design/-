package com.order.servlet;

import com.order.entity.User;
import com.order.service.CartService;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/cart/add")
public class AddCartServlet extends HttpServlet {
    private CartService cartService = new CartService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            out.print("{\"success\":false,\"message\":\"请先登录\",\"needLogin\":true}");
            return;
        }

        try {
            String dishIdStr = req.getParameter("dishId");
            String quantityStr = req.getParameter("quantity");
            if (dishIdStr == null || dishIdStr.isEmpty()) {
                out.print("{\"success\":false,\"message\":\"参数错误\"}");
                return;
            }
            int dishId = Integer.parseInt(dishIdStr);
            int quantity = 1;
            if (quantityStr != null && !quantityStr.isEmpty()) {
                quantity = Integer.parseInt(quantityStr);
            }
            if (quantity <= 0) quantity = 1;

            cartService.addToCart(user.getUserId(), dishId, quantity);
            long count = cartService.getCartCount(user.getUserId());
            out.print("{\"success\":true,\"message\":\"已加入购物车\",\"count\":" + count + "}");
        } catch (NumberFormatException e) {
            out.print("{\"success\":false,\"message\":\"参数格式错误\"}");
        } catch (Exception e) {
            String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'") : "操作失败";
            out.print("{\"success\":false,\"message\":\"" + msg + "\"}");
        }
    }
}
