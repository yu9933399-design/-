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

    private static final String[] ALL_CATEGORIES = {"快餐简餐","奶茶饮品","川湘辣味","粤菜海鲜","甜品小吃","早餐早点","面食粥品","轻食沙拉"};

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            String category = req.getParameter("category");
            int page = 1;
            int pageSize = 8;
            try {
                String pageStr = req.getParameter("page");
                if (pageStr != null && !pageStr.isEmpty()) page = Integer.parseInt(pageStr);
            } catch (NumberFormatException e) {}
            if (page < 1) page = 1;

            long total = userService.countMerchantsByCategory(category);
            int totalPages = (int) Math.ceil((double) total / pageSize);
            if (totalPages < 1) totalPages = 1;
            if (page > totalPages) page = totalPages;

            List<User> merchants = userService.findMerchantsByCategoryPaged(category, page, pageSize);

            Map<Integer, Long> dishCounts = new HashMap<>();
            for (User m : merchants) {
                dishCounts.put(m.getUserId(), dishService.countByMerchantId(m.getUserId()));
            }
            req.setAttribute("merchants", merchants);
            req.setAttribute("dishCounts", dishCounts);
            req.setAttribute("selectedCategory", category);
            req.setAttribute("allCategories", ALL_CATEGORIES);
            req.setAttribute("currentPage", page);
            req.setAttribute("totalPages", totalPages);
        } catch (Exception e) {
            e.printStackTrace();
        }
        req.getRequestDispatcher("/jsp/merchant/list.jsp").forward(req, resp);
    }
}
