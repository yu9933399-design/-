package com.order.servlet;

import java.io.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/upload/*")
public class ImageServeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        if (pathInfo == null || pathInfo.isEmpty()) {
            resp.sendError(404);
            return;
        }

        String fileName = pathInfo.startsWith("/") ? pathInfo.substring(1) : pathInfo;
        File file = new File("D:\\upload\\images", fileName);

        if (!file.exists() || !file.isFile()) {
            resp.sendError(404);
            return;
        }

        String ext = fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase();
        switch (ext) {
            case "jpg": case "jpeg": resp.setContentType("image/jpeg"); break;
            case "png": resp.setContentType("image/png"); break;
            case "gif": resp.setContentType("image/gif"); break;
            case "webp": resp.setContentType("image/webp"); break;
            default: resp.setContentType("application/octet-stream");
        }

        try (FileInputStream fis = new FileInputStream(file);
             OutputStream os = resp.getOutputStream()) {
            byte[] buffer = new byte[4096];
            int bytesRead;
            while ((bytesRead = fis.read(buffer)) != -1) {
                os.write(buffer, 0, bytesRead);
            }
        }
    }
}
