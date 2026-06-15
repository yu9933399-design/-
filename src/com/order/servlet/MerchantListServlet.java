package com.order.servlet;

import com.order.entity.User;
import com.order.service.DishService;
import com.order.service.UserService;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.*;

@WebServlet("/merchant/list")
public class MerchantListServlet extends HttpServlet {
    private UserService userService = new UserService();
    private DishService dishService = new DishService();

    // 全部分类列表
    private static final String[] ALL_CATEGORIES = {"快餐简餐","奶茶饮品","川湘辣味","粤菜海鲜","甜品小吃","早餐早点","面食粥品","轻食沙拉"};

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            // 接收分类筛选参数
            String category = req.getParameter("category");

            List<User> merchants;
            if (category != null && !category.trim().isEmpty()) {
                merchants = userService.findMerchantsByCategory(category.trim());
            } else {
                merchants = userService.findAllByRoleAndStatus(2, 0);
            }

            Map<Integer, Long> dishCounts = new HashMap<>();
            for (User m : merchants) {
                dishCounts.put(m.getUserId(), dishService.countByMerchantId(m.getUserId()));
            }
            req.setAttribute("merchants", merchants);
            req.setAttribute("dishCounts", dishCounts);
            req.setAttribute("selectedCategory", category);
            req.setAttribute("allCategories", ALL_CATEGORIES);
        } catch (Exception e) {
            e.printStackTrace();
        }
        req.getRequestDispatcher("/jsp/merchant/list.jsp").forward(req, resp);
    }
}
