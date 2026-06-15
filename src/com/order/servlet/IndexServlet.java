package com.order.servlet;

import com.order.entity.Banner;
import com.order.entity.Dish;
import com.order.entity.User;
import com.order.service.BannerService;
import com.order.service.CategoryService;
import com.order.service.DishService;
import com.order.service.UserService;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.*;

@WebServlet("/index")
public class IndexServlet extends HttpServlet {
    private UserService userService = new UserService();
    private DishService dishService = new DishService();
    private CategoryService categoryService = new CategoryService();
    private BannerService bannerService = new BannerService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            // 加载审核通过的商家列表
            List<User> merchants = userService.findAllByRoleAndStatus(2, 0);
            Map<Integer, Long> dishCounts = new HashMap<>();
            // 每家商家附带2-3款热销菜品预览
            Map<Integer, List<Dish>> previewDishes = new HashMap<>();
            for (User m : merchants) {
                dishCounts.put(m.getUserId(), dishService.countByMerchantId(m.getUserId()));
                previewDishes.put(m.getUserId(), dishService.findPreviewDishesByMerchant(m.getUserId(), 3));
            }
            req.setAttribute("merchants", merchants);
            req.setAttribute("dishCounts", dishCounts);
            req.setAttribute("previewDishes", previewDishes);

            // 加载特价菜品
            req.setAttribute("specialDishes", dishService.findSpecialDishes());
            req.setAttribute("categories", categoryService.findAll());

            // 加载轮播Banner
            List<Banner> banners = bannerService.findAllActive();
            req.setAttribute("banners", banners);
        } catch (Exception e) {
            e.printStackTrace();
        }
        req.getRequestDispatcher("/jsp/index.jsp").forward(req, resp);
    }
}
