package com.order.servlet.admin;

import com.order.entity.Banner;
import com.order.entity.User;
import com.order.service.BannerService;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/admin/banner/*")
public class AdminBannerServlet extends HttpServlet {
    private BannerService bannerService = new BannerService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User currentUser = (User) req.getSession().getAttribute("user");
        if (currentUser == null || currentUser.getRole() != 1) {
            resp.sendRedirect(req.getContextPath() + "/admin");
            return;
        }
        try {
            List<Banner> banners = bannerService.findAll();
            req.setAttribute("banners", banners);
        } catch (Exception e) { e.printStackTrace(); }
        req.getRequestDispatcher("/jsp/admin/banner/list.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        User currentUser = (User) req.getSession().getAttribute("user");
        if (currentUser == null || currentUser.getRole() != 1) {
            out.print("{\"success\":false,\"message\":\"无权限\"}");
            return;
        }

        String path = req.getPathInfo();
        try {
            if ("/save".equals(path)) {
                Banner b = new Banner();
                b.setTitle(req.getParameter("title"));
                b.setSubtitle(req.getParameter("subtitle"));
                b.setImageUrl(req.getParameter("imageUrl"));
                b.setLinkUrl(req.getParameter("linkUrl"));
                String sortStr = req.getParameter("sortOrder");
                if (sortStr != null && !sortStr.isEmpty()) b.setSortOrder(Integer.parseInt(sortStr));
                String statusStr = req.getParameter("status");
                if (statusStr != null) b.setStatus(Integer.parseInt(statusStr));
                bannerService.save(b);
                out.print("{\"success\":true}");
            } else if ("/update".equals(path)) {
                Banner b = new Banner();
                String idStr = req.getParameter("bannerId");
                if (idStr != null) b.setBannerId(Integer.parseInt(idStr));
                b.setTitle(req.getParameter("title"));
                b.setSubtitle(req.getParameter("subtitle"));
                b.setImageUrl(req.getParameter("imageUrl"));
                b.setLinkUrl(req.getParameter("linkUrl"));
                String sortStr = req.getParameter("sortOrder");
                if (sortStr != null && !sortStr.isEmpty()) b.setSortOrder(Integer.parseInt(sortStr));
                String statusStr = req.getParameter("status");
                if (statusStr != null) b.setStatus(Integer.parseInt(statusStr));
                bannerService.update(b);
                out.print("{\"success\":true}");
            } else if ("/delete".equals(path)) {
                String idStr = req.getParameter("bannerId");
                if (idStr != null) bannerService.delete(Integer.parseInt(idStr));
                out.print("{\"success\":true}");
            } else {
                out.print("{\"success\":false,\"message\":\"未知操作\"}");
            }
        } catch (Exception e) {
            out.print("{\"success\":false,\"message\":\"" + (e.getMessage()!=null?e.getMessage().replace("\"","'"):"操作失败") + "\"}");
        }
    }
}
