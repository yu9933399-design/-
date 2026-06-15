package com.order.servlet;

import com.order.entity.User;
import com.order.service.CartService;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/cart/remove")
public class RemoveCartServlet extends HttpServlet {
    private CartService cartService = new CartService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        try {
            HttpSession session = req.getSession(false);
            User user = (session != null) ? (User) session.getAttribute("user") : null;
            if (user == null) {
                out.print("{\"success\":false,\"message\":\"未登录\"}");
                return;
            }

            String cartIdStr = req.getParameter("cartId");
            if (cartIdStr == null || cartIdStr.isEmpty()) {
                out.print("{\"success\":false,\"message\":\"参数错误\"}");
                return;
            }
            int cartId = Integer.parseInt(cartIdStr);

            if (!cartService.isOwnedBy(cartId, user.getUserId())) {
                out.print("{\"success\":false,\"message\":\"无权操作\"}");
                return;
            }

            cartService.removeFromCart(cartId);
            out.print("{\"success\":true}");
        } catch (NumberFormatException e) {
            out.print("{\"success\":false,\"message\":\"参数格式错误\"}");
        } catch (Exception e) {
            String msg = e.getMessage() != null ? e.getMessage().replace("\"", "'") : "操作失败";
            out.print("{\"success\":false,\"message\":\"" + msg + "\"}");
        }
    }
}
