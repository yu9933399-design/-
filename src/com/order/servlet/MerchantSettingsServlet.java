package com.order.servlet;

import com.order.entity.User;
import com.order.service.UserService;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/merchant/settings")
public class MerchantSettingsServlet extends HttpServlet {
    private UserService userService = new UserService();

    // 全部分类
    private static final String[] ALL_CATEGORIES = {"快餐简餐","奶茶饮品","川湘辣味","粤菜海鲜","甜品小吃","早餐早点","面食粥品","轻食沙拉"};

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null || user.getRole() != 2) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        try {
            User merchant = userService.getById(user.getUserId());
            req.setAttribute("merchant", merchant);
            req.setAttribute("allCategories", ALL_CATEGORIES);
        } catch (Exception e) {
            e.printStackTrace();
        }
        req.getRequestDispatcher("/jsp/merchant/settings.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        HttpSession session = req.getSession();
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null || user.getRole() != 2) {
            out.print("{\"success\":false,\"message\":\"无权限\"}");
            return;
        }

        String shopCategory = req.getParameter("shopCategory");
        String realName = req.getParameter("realName");
        String phone = req.getParameter("phone");

        try {
            if (realName != null && !realName.trim().isEmpty()) {
                user.setRealName(realName.trim());
            }
            if (phone != null && !phone.trim().isEmpty()) {
                user.setPhone(phone.trim());
            }
            user.setShopCategory(shopCategory);
            userService.updateMerchantSettings(user);
            // 同步 session
            session.setAttribute("user", user);
            out.print("{\"success\":true}");
        } catch (Exception e) {
            out.print("{\"success\":false,\"message\":\"" + (e.getMessage()!=null ? e.getMessage().replace("\"","'") : "保存失败") + "\"}");
        }
    }
}
