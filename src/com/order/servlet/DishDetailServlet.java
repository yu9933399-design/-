package com.order.servlet;

import com.order.entity.Dish;
import com.order.service.DishService;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/dish/detail")
public class DishDetailServlet extends HttpServlet {
    private DishService dishService = new DishService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String dishIdStr = req.getParameter("id");
        if (dishIdStr != null && !dishIdStr.isEmpty()) {
            try {
                int dishId = Integer.parseInt(dishIdStr);
                Dish dish = dishService.getById(dishId);
                req.setAttribute("dish", dish);
            } catch (NumberFormatException e) {
                req.setAttribute("error", "菜品ID格式错误");
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        req.getRequestDispatcher("/jsp/dish/detail.jsp").forward(req, resp);
    }
}
