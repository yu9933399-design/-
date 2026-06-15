package com.order.servlet;

import com.order.entity.User;
import com.order.service.UserService;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {
    private UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        try {
            User fullUser = userService.getById(user.getUserId());
            req.setAttribute("user", fullUser != null ? fullUser : user);
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("user", user);
        }
        req.getRequestDispatcher("/jsp/user/profile.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("user");
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        String action = req.getParameter("action");

        try {
            if ("updateProfile".equals(action)) {
                User user = userService.getById(currentUser.getUserId());
                if (user != null) {
                    user.setRealName(req.getParameter("realName"));
                    user.setPhone(req.getParameter("phone"));
                    user.setEmail(req.getParameter("email"));
                    user.setAddress(req.getParameter("address"));
                    userService.updateProfile(user);
                    session.setAttribute("user", userService.getById(currentUser.getUserId()));
                }
                req.setAttribute("success", "修改成功");
            } else if ("updatePassword".equals(action)) {
                String oldPassword = req.getParameter("oldPassword");
                String newPassword = req.getParameter("newPassword");
                userService.updatePassword(currentUser.getUserId(), oldPassword, newPassword);
                req.setAttribute("success", "密码修改成功");
            }
            User updated = userService.getById(currentUser.getUserId());
            req.setAttribute("user", updated != null ? updated : currentUser);
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            try {
                User fallback = userService.getById(currentUser.getUserId());
                req.setAttribute("user", fallback != null ? fallback : currentUser);
            } catch (Exception ex) {
                req.setAttribute("user", currentUser);
            }
        }
        req.getRequestDispatcher("/jsp/user/profile.jsp").forward(req, resp);
    }
}
