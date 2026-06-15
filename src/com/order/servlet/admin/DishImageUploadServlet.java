package com.order.servlet.admin;

import com.order.entity.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.util.UUID;

@WebServlet("/admin/dish/upload")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024, maxRequestSize = 10 * 1024 * 1024)
public class DishImageUploadServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || (user.getRole() != 1 && user.getRole() != 2)) {
            resp.setStatus(401);
            resp.getWriter().print("{\"error\":\"未登录\"}");
            return;
        }

        resp.setContentType("application/json;charset=UTF-8");
        try {
            Part filePart = req.getPart("file");
            if (filePart == null || filePart.getSize() == 0) {
                resp.getWriter().print("{\"error\":\"请选择文件\"}");
                return;
            }

            String originalName = filePart.getSubmittedFileName();
            String ext = "";
            if (originalName != null && originalName.contains(".")) {
                ext = originalName.substring(originalName.lastIndexOf(".")).toLowerCase();
            }
            if (!".jpg".equals(ext) && !".jpeg".equals(ext) && !".png".equals(ext) && !".gif".equals(ext) && !".webp".equals(ext)) {
                resp.getWriter().print("{\"error\":\"仅支持 jpg/jpeg/png/gif/webp 格式\"}");
                return;
            }

            String fileName = "dish_" + UUID.randomUUID().toString().replace("-", "") + ext;
            String uploadDir = getServletContext().getRealPath("/images/dishes");
            File dir = new File(uploadDir);
            if (!dir.exists()) dir.mkdirs();

            File file = new File(dir, fileName);
            filePart.write(file.getAbsolutePath());

            String imageUrl = "images/dishes/" + fileName;
            resp.getWriter().print("{\"success\":true,\"url\":\"" + imageUrl + "\"}");
        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().print("{\"error\":\"上传失败: " + escapeJson(e.getMessage()) + "\"}");
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t");
    }
}
