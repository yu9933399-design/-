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

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            List<User> merchants = userService.findAllByRoleAndStatus(2, 0);
            Map<Integer, Long> dishCounts = new HashMap<>();
            for (User m : merchants) {
                dishCounts.put(m.getUserId(), dishService.countByMerchantId(m.getUserId()));
            }
            req.setAttribute("merchants", merchants);
            req.setAttribute("dishCounts", dishCounts);
        } catch (Exception e) {
            e.printStackTrace();
        }
        req.getRequestDispatcher("/jsp/merchant/list.jsp").forward(req, resp);
    }
}
