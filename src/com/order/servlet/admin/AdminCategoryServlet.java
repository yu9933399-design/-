package com.order.servlet.admin;

import com.order.entity.Category;
import com.order.entity.User;
import com.order.service.CategoryService;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/admin/category/*")
public class AdminCategoryServlet extends HttpServlet {
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

        switch (path) {
            case "/add":
                req.getRequestDispatcher("/jsp/admin/category/form.jsp").forward(req, resp);
                break;
            case "/edit":
                String editId = req.getParameter("id");
                if (editId != null && !editId.isEmpty()) {
                    try {
                        req.setAttribute("category", categoryService.getById(Integer.parseInt(editId)));
                    } catch (Exception e) { e.printStackTrace(); }
                }
                req.getRequestDispatcher("/jsp/admin/category/form.jsp").forward(req, resp);
                break;
            default:
                try {
                    java.util.List<Category> cats = categoryService.findAll();
                    req.setAttribute("categories", cats);
                    Map<Integer, Long> dishCounts = new HashMap<>();
                    for (Category c : cats) {
                        dishCounts.put(c.getCategoryId(), categoryService.countByCategoryId(c.getCategoryId()));
                    }
                    req.setAttribute("dishCounts", dishCounts);
                } catch (Exception e) { e.printStackTrace(); }
                req.getRequestDispatcher("/jsp/admin/category/list.jsp").forward(req, resp);
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
                    Category category = new Category();
                    category.setCategoryName(req.getParameter("categoryName"));
                    try {
                        String sortStr = req.getParameter("sortOrder");
                        if (sortStr != null && !sortStr.isEmpty()) category.setSortOrder(Integer.parseInt(sortStr));
                    } catch (NumberFormatException e) { category.setSortOrder(0); }
                    categoryService.save(category);
                    resp.sendRedirect(req.getContextPath() + "/admin/category");
                    break;
                case "/update":
                    Category updateCat = new Category();
                    String catIdStr = req.getParameter("categoryId");
                    if (catIdStr != null && !catIdStr.isEmpty()) updateCat.setCategoryId(Integer.parseInt(catIdStr));
                    updateCat.setCategoryName(req.getParameter("categoryName"));
                    try {
                        String sortStr2 = req.getParameter("sortOrder");
                        if (sortStr2 != null && !sortStr2.isEmpty()) updateCat.setSortOrder(Integer.parseInt(sortStr2));
                    } catch (NumberFormatException e) { updateCat.setSortOrder(0); }
                    categoryService.update(updateCat);
                    resp.sendRedirect(req.getContextPath() + "/admin/category");
                    break;
                case "/delete":
                    String deleteId = req.getParameter("id");
                    if (deleteId != null && !deleteId.isEmpty()) {
                        categoryService.delete(Integer.parseInt(deleteId));
                    }
                    resp.setContentType("application/json;charset=UTF-8");
                    resp.getWriter().print("{\"success\":true}");
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/admin/category");
        }
    }
}
