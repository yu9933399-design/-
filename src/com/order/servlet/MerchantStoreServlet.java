package com.order.servlet;

import com.order.entity.Category;
import com.order.entity.Dish;
import com.order.entity.User;
import com.order.service.CategoryService;
import com.order.service.DishService;
import com.order.service.UserService;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.*;

@WebServlet("/merchant/store")
public class MerchantStoreServlet extends HttpServlet {
    private UserService userService = new UserService();
    private DishService dishService = new DishService();
    private CategoryService categoryService = new CategoryService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String merchantIdStr = req.getParameter("id");
        if (merchantIdStr == null || merchantIdStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/merchant/list");
            return;
        }

        try {
            int merchantId = Integer.parseInt(merchantIdStr);
            User merchant = userService.getById(merchantId);
            if (merchant == null || merchant.getRole() != 2 || merchant.getStatus() != 0) {
                resp.sendRedirect(req.getContextPath() + "/merchant/list");
                return;
            }

            List<Dish> dishes = dishService.findByMerchantIdFull(merchantId);
            List<Category> categories = categoryService.findAll();

            Map<Integer, List<Dish>> grouped = new LinkedHashMap<>();
            for (Category cat : categories) {
                grouped.put(cat.getCategoryId(), new ArrayList<>());
            }
            for (Dish d : dishes) {
                int cid = d.getCategoryId();
                if (!grouped.containsKey(cid)) {
                    grouped.put(cid, new ArrayList<>());
                }
                grouped.get(cid).add(d);
            }

            req.setAttribute("merchant", merchant);
            req.setAttribute("grouped", grouped);
            req.setAttribute("categories", categories);
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/merchant/list");
            return;
        }

        req.getRequestDispatcher("/jsp/merchant/store.jsp").forward(req, resp);
    }
}
