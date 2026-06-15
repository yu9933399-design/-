package com.order.servlet.admin;

import com.order.entity.Dish;
import com.order.entity.User;
import com.order.service.CategoryService;
import com.order.service.DishService;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@WebServlet("/admin/dish/*")
public class AdminDishServlet extends HttpServlet {
    private DishService dishService = new DishService();
    private CategoryService categoryService = new CategoryService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User currentUser = (User) req.getSession().getAttribute("user");
        if (currentUser == null || (currentUser.getRole() != 1 && currentUser.getRole() != 2)) {
            resp.sendRedirect(req.getContextPath() + "/admin");
            return;
        }

        String path = req.getPathInfo();
        if (path == null) path = "/";

        Integer merchantId = (currentUser.getRole() == 2) ? currentUser.getUserId() : null;

        try {
            req.setAttribute("categories", categoryService.findAll());
            if (currentUser.getRole() == 1) {
                req.setAttribute("merchants", new com.order.service.UserService().findAllByRoleAndStatus(2, 0));
            }
        } catch (Exception e) { e.printStackTrace(); }

        switch (path) {
            case "/add":
                req.getRequestDispatcher("/jsp/admin/dish/form.jsp").forward(req, resp);
                break;
            case "/edit":
                String editId = req.getParameter("id");
                if (editId != null && !editId.isEmpty()) {
                    try {
                        req.setAttribute("dish", dishService.getById(Integer.parseInt(editId)));
                    } catch (Exception e) { e.printStackTrace(); }
                }
                req.getRequestDispatcher("/jsp/admin/dish/form.jsp").forward(req, resp);
                break;
            default:
                String keyword = req.getParameter("keyword");
                Integer categoryId = null;
                Integer status = null;
                int page = 1;

                if (currentUser.getRole() == 1) {
                    String merchIdStr = req.getParameter("merchantId");
                    if (merchIdStr != null && !merchIdStr.isEmpty()) {
                        try { merchantId = Integer.parseInt(merchIdStr); } catch (NumberFormatException e) {}
                    }
                }

                try {
                    String catIdStr = req.getParameter("categoryId");
                    if (catIdStr != null && !catIdStr.isEmpty()) categoryId = Integer.parseInt(catIdStr);
                } catch (NumberFormatException e) {}
                try {
                    String statusStr = req.getParameter("status");
                    if (statusStr != null && !statusStr.isEmpty()) status = Integer.parseInt(statusStr);
                } catch (NumberFormatException e) {}
                try {
                    String pageStr = req.getParameter("page");
                    if (pageStr != null && !pageStr.isEmpty()) page = Integer.parseInt(pageStr);
                } catch (NumberFormatException e) {}

                try {
                    long total = dishService.countSearch(keyword, categoryId, status, merchantId);
                    int totalPages = (int) Math.ceil((double) total / 8);
                    if (totalPages < 1) totalPages = 1;
                    if (page < 1) page = 1;
                    if (page > totalPages) page = totalPages;

                    List<Dish> dishes = dishService.search(keyword, categoryId, status, merchantId, page, 8);
                    req.setAttribute("dishes", dishes);
                    req.setAttribute("keyword", keyword);
                    req.setAttribute("categoryId", categoryId);
                    req.setAttribute("status", status);
                    req.setAttribute("currentPage", page);
                    req.setAttribute("totalPages", totalPages);
                } catch (Exception e) { e.printStackTrace(); }
                req.getRequestDispatcher("/jsp/admin/dish/list.jsp").forward(req, resp);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User currentUser = (User) req.getSession().getAttribute("user");
        if (currentUser == null || (currentUser.getRole() != 1 && currentUser.getRole() != 2)) {
            resp.sendRedirect(req.getContextPath() + "/admin");
            return;
        }

        String path = req.getPathInfo();
        if (path == null) path = "/";

        try {
            switch (path) {
                case "/save":
                    Dish dish = new Dish();
                    if (currentUser != null) dish.setMerchantId(currentUser.getUserId());
                    fillDish(dish, req);
                    dishService.save(dish);
                    resp.sendRedirect(req.getContextPath() + "/admin/dish");
                    break;
                case "/update":
                    String dishIdStr = req.getParameter("dishId");
                    if (dishIdStr != null && !dishIdStr.isEmpty()) {
                        Dish updateDish = new Dish();
                        updateDish.setDishId(Integer.parseInt(dishIdStr));
                        fillDish(updateDish, req);
                        dishService.update(updateDish);
                    }
                    resp.sendRedirect(req.getContextPath() + "/admin/dish");
                    break;
                case "/delete":
                    String deleteId = req.getParameter("id");
                    if (deleteId != null && !deleteId.isEmpty()) {
                        dishService.delete(Integer.parseInt(deleteId));
                    }
                    resp.setContentType("application/json;charset=UTF-8");
                    resp.getWriter().print("{\"success\":true}");
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/admin/dish");
        }
    }

    private void fillDish(Dish dish, HttpServletRequest req) {
        dish.setDishName(req.getParameter("dishName"));
        try {
            String priceStr = req.getParameter("price");
            if (priceStr != null && !priceStr.isEmpty()) dish.setPrice(new BigDecimal(priceStr));
        } catch (NumberFormatException e) {}
        dish.setImageUrl(req.getParameter("imageUrl"));
        dish.setDescription(req.getParameter("description"));
        try {
            String stockStr = req.getParameter("stock");
            if (stockStr != null && !stockStr.isEmpty()) dish.setStock(Integer.parseInt(stockStr));
        } catch (NumberFormatException e) {}
        try {
            String catIdStr = req.getParameter("categoryId");
            if (catIdStr != null && !catIdStr.isEmpty()) dish.setCategoryId(Integer.parseInt(catIdStr));
        } catch (NumberFormatException e) {}
        try {
            String statusStr = req.getParameter("status");
            if (statusStr != null && !statusStr.isEmpty()) dish.setStatus(Integer.parseInt(statusStr));
        } catch (NumberFormatException e) {}
        try {
            String recStr = req.getParameter("isRecommend");
            if (recStr != null && !recStr.isEmpty()) dish.setIsRecommend(Integer.parseInt(recStr));
        } catch (NumberFormatException e) {}

        try {
            String specialPriceStr = req.getParameter("specialPrice");
            if (specialPriceStr != null && !specialPriceStr.isEmpty()) {
                dish.setSpecialPrice(new BigDecimal(specialPriceStr));
            }
        } catch (NumberFormatException e) {}
        String specialEndStr = req.getParameter("specialEnd");
        if (specialEndStr != null && !specialEndStr.isEmpty()) {
            try {
                dish.setSpecialEnd(LocalDateTime.parse(specialEndStr, DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm")));
                if (dish.getSpecialStart() == null) dish.setSpecialStart(LocalDateTime.now());
            } catch (Exception e) {}
        }
    }
}
