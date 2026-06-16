package com.order.servlet.admin;

import com.order.entity.User;
import com.order.entity.User;
import com.order.service.UserService;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/admin/user/*")
public class AdminUserServlet extends HttpServlet {
    private UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User currentUser = (User) req.getSession().getAttribute("user");
        if (currentUser == null || currentUser.getRole() == null || currentUser.getRole() != 1) {
            resp.sendRedirect(req.getContextPath() + "/admin");
            return;
        }
        String path = req.getPathInfo();
        if (path == null) path = "/";

        String keyword = req.getParameter("keyword");
        String roleStr = req.getParameter("role");
        String sort = req.getParameter("sort");
        Integer roleFilter = null;
        if ("2".equals(roleStr)) roleFilter = 2;
        else if ("0".equals(roleStr)) roleFilter = 0;

        int page = 1;
        int pageSize = 10;
        try {
            String pageStr = req.getParameter("page");
            if (pageStr != null && !pageStr.isEmpty()) page = Integer.parseInt(pageStr);
        } catch (NumberFormatException e) {}
        if (page < 1) page = 1;

        try {
            long total = (keyword != null && !keyword.isEmpty())
                ? userService.countByRoleWithKeyword(roleFilter, keyword)
                : userService.countByRole(roleFilter);
            int totalPages = (int) Math.ceil((double) total / pageSize);
            if (totalPages < 1) totalPages = 1;
            if (page > totalPages) page = totalPages;

            List<User> users = (keyword != null && !keyword.isEmpty())
                ? userService.findByRoleWithKeywordPaged(roleFilter, keyword, page, pageSize, sort)
                : userService.findByRolePaged(roleFilter, page, pageSize, sort);

            long merchantCount = userService.countByRole(2);
            long userCount = userService.countByRole(0);

            List<User> pendingMerchants = new java.util.ArrayList<>();
            for (User u : users) {
                if (u.getStatus() != null && u.getStatus() == 2) {
                    pendingMerchants.add(u);
                }
            }
            req.setAttribute("users", users);
            req.setAttribute("pendingMerchants", pendingMerchants);
            req.setAttribute("keyword", keyword);
            req.setAttribute("roleFilter", roleFilter);
            req.setAttribute("sort", sort);
            req.setAttribute("currentPage", page);
            req.setAttribute("totalPages", totalPages);
            req.setAttribute("merchantCount", merchantCount);
            req.setAttribute("userCount", userCount);
        } catch (Exception e) { e.printStackTrace(); }
        req.getRequestDispatcher("/jsp/admin/user/list.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User currentUser = (User) req.getSession().getAttribute("user");
        if (currentUser == null || currentUser.getRole() == null || currentUser.getRole() != 1) {
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().print("{\"success\":false,\"message\":\"无权限\"}");
            return;
        }
        String path = req.getPathInfo();
        if (path == null) path = "/";

        try {
            switch (path) {
                case "/status":
                    String userIdStr = req.getParameter("userId");
                    String statusStr = req.getParameter("status");
                    if (userIdStr != null && statusStr != null) {
                        userService.updateStatus(Integer.parseInt(userIdStr), Integer.parseInt(statusStr));
                    }
                    break;
                case "/resetPassword":
                    String resetId = req.getParameter("userId");
                    if (resetId != null) {
                        userService.resetPassword(Integer.parseInt(resetId));
                    }
                    break;
                case "/role":
                    String roleId = req.getParameter("userId");
                    String roleVal = req.getParameter("role");
                    if (roleId != null && roleVal != null) {
                        userService.updateRole(Integer.parseInt(roleId), Integer.parseInt(roleVal));
                    }
                    break;
            }
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().print("{\"success\":true}");
        } catch (NumberFormatException e) {
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().print("{\"success\":false,\"message\":\"参数格式错误\"}");
        } catch (Exception e) {
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().print("{\"success\":false}");
        }
    }
}
