package com.order.servlet;

import com.order.entity.Cart;
import com.order.entity.User;
import com.order.service.CartService;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@WebServlet("/cart")
public class CartServlet extends HttpServlet {
    private CartService cartService = new CartService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        try {
            List<Cart> cartItems = cartService.getCartByUserId(user.getUserId());
            BigDecimal total = BigDecimal.ZERO;
            if (cartItems != null) {
                for (Cart item : cartItems) {
                    if (item.getPrice() != null) {
                        total = total.add(item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity() != null ? item.getQuantity() : 0)));
                    }
                }
            }
            req.setAttribute("cartItems", cartItems);
            req.setAttribute("total", total);
        } catch (Exception e) {
            e.printStackTrace();
        }
        req.getRequestDispatcher("/jsp/user/cart.jsp").forward(req, resp);
    }
}
