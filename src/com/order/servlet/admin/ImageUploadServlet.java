package com.order.servlet.admin;

import com.order.entity.User;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.nio.file.*;

@WebServlet("/admin/upload/*")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,
    maxFileSize = 1024 * 1024 * 10,
    maxRequestSize = 1024 * 1024 * 20
)
public class ImageUploadServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        HttpSession session = req.getSession();
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null || user.getRole() != 1) {
            out.print("{\"success\":false,\"message\":\"无权限\"}");
            return;
        }

        try {
            Part filePart = req.getPart("file");
            if (filePart == null || filePart.getSize() == 0) {
                out.print("{\"success\":false,\"message\":\"请选择文件\"}");
                return;
            }

            // 获取原始文件名
            String originalName = filePart.getSubmittedFileName();
            String ext = "";
            if (originalName != null && originalName.contains(".")) {
                ext = originalName.substring(originalName.lastIndexOf("."));
            }

            // 生成唯一文件名
            String fileName = "banner_" + System.currentTimeMillis() + ext;

            // 保存到独立图片目录（永久保存，重部署不丢失）
            String uploadDir = "D:\\upload\\images";
            File dir = new File(uploadDir);
            if (!dir.exists()) dir.mkdirs();
            File file = new File(dir, fileName);
            filePart.write(file.getAbsolutePath());

            String relativePath = "/upload/" + fileName;
            out.print("{\"success\":true,\"url\":\"" + relativePath + "\"}");

        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\":false,\"message\":\"上传失败: " + e.getMessage() + "\"}");
        }
    }
}
