package com.order.servlet;

import com.order.entity.Dish;
import com.order.service.CategoryService;
import com.order.service.DishService;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/dish/list")
public class ListDishServlet extends HttpServlet {
    private DishService dishService = new DishService();
    private CategoryService categoryService = new CategoryService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String keyword = req.getParameter("keyword");
        Integer categoryId = null;
        int page = 1;
        int pageSize = 8;

        try {
            String catIdStr = req.getParameter("categoryId");
            if (catIdStr != null && !catIdStr.isEmpty()) {
                categoryId = Integer.parseInt(catIdStr);
            }
        } catch (NumberFormatException e) {
            // ignore
        }

        try {
            String pageStr = req.getParameter("page");
            if (pageStr != null && !pageStr.isEmpty()) {
                page = Integer.parseInt(pageStr);
            }
        } catch (NumberFormatException e) {
            page = 1;
        }

        try {
            long total = dishService.countSearch(keyword, categoryId, null, null);
            int totalPages = (int) Math.ceil((double) total / pageSize);
            if (totalPages < 1) totalPages = 1;
            if (page < 1) page = 1;
            if (page > totalPages) page = totalPages;

            List<Dish> dishes = dishService.search(keyword, categoryId, null, null, page, pageSize);
            req.setAttribute("dishes", dishes);
            req.setAttribute("categories", categoryService.findAll());
            req.setAttribute("keyword", keyword);
            req.setAttribute("categoryId", categoryId);
            req.setAttribute("currentPage", page);
            req.setAttribute("totalPages", totalPages);
            req.setAttribute("total", total);
        } catch (Exception e) {
            e.printStackTrace();
        }
        req.getRequestDispatcher("/jsp/dish/list.jsp").forward(req, resp);
    }
}
