package com.order.servlet.admin;

import com.order.entity.User;
import com.order.service.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/admin")
public class AdminIndexServlet extends HttpServlet {
    private UserService userService = new UserService();
    private DishService dishService = new DishService();
    private CategoryService categoryService = new CategoryService();
    private OrderService orderService = new OrderService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("user");

        try {
            List<User> allUsers = userService.findAll();
            int pendingCount = 0;
            for (User u : allUsers) {
                if (u.getStatus() != null && u.getStatus() == 2) pendingCount++;
            }
            req.setAttribute("pendingMerchantCount", pendingCount);

            if (currentUser.getRole() == 2) {
                req.setAttribute("dishCount", dishService.countByMerchantId(currentUser.getUserId()));
                req.setAttribute("categoryCount", categoryService.count());
                req.setAttribute("orderCount", orderService.getOrdersByMerchantId(currentUser.getUserId()).size());
            } else {
                req.setAttribute("merchantCount", userService.findAllByRoleAndStatus(2, 0).size());
                req.setAttribute("userCount", userService.count());
                req.setAttribute("dishCount", dishService.count());
                req.setAttribute("categoryCount", categoryService.count());
                req.setAttribute("orderCount", orderService.getAllOrders().size());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        req.getRequestDispatcher("/jsp/admin/index.jsp").forward(req, resp);
    }
}
