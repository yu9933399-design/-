package com.order.servlet;

import com.order.entity.User;
import com.order.service.CartService;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/cart/count")
public class CartCountServlet extends HttpServlet {
    private CartService cartService = new CartService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            out.print("{\"count\":0}");
            return;
        }

        try {
            long count = cartService.getCartCount(user.getUserId());
            out.print("{\"count\":" + count + "}");
        } catch (Exception e) {
            out.print("{\"count\":0}");
        }
    }
}
