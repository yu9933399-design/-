package com.order.servlet;

import com.order.service.UserService;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/jsp/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String phone = req.getParameter("phone");
        String email = req.getParameter("email");
        String type = req.getParameter("type");
        String shopName = req.getParameter("shopName");
        String shopCategory = req.getParameter("shopCategory");
        boolean isMerchant = "merchant".equals(type);

        try {
            userService.register(username, password, phone, email, isMerchant, shopName, shopCategory);
            if (isMerchant) {
                req.setAttribute("success", "商家入驻申请已提交，管理员审核通过后方可登录，请耐心等待");
                req.setAttribute("type", "merchant");
                req.getRequestDispatcher("/jsp/register.jsp").forward(req, resp);
            } else {
                req.setAttribute("success", "注册成功，请登录");
                req.getRequestDispatcher("/jsp/login.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/jsp/register.jsp").forward(req, resp);
        }
    }
}
