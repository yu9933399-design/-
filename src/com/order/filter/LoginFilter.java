package com.order.filter;

import com.order.entity.User;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter(urlPatterns = {"/*"})
public class LoginFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest req, ServletResponse resp, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) resp;

        String uri = request.getRequestURI();
        String contextPath = request.getContextPath();

        String path = uri.substring(contextPath.length());

        if (path.equals("/") ||
            path.equals("/login") ||
            path.equals("/register") ||
            path.equals("/index") ||
            path.equals("/admin/login") ||
            path.startsWith("/css/") ||
            path.startsWith("/js/") ||
            path.startsWith("/images/") ||
            path.startsWith("/upload/") ||
            path.endsWith(".ico")) {
            chain.doFilter(req, resp);
            return;
        }

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            if (path.startsWith("/admin")) {
                response.sendRedirect(contextPath + "/admin/login");
            } else {
                response.sendRedirect(contextPath + "/login");
            }
            return;
        }

        if (user.getStatus() != null && user.getStatus() == 2) {
            session.invalidate();
            response.sendRedirect(contextPath + "/login");
            return;
        }

        if (path.startsWith("/admin")) {
            if (user.getRole() == null || (user.getRole() != 1 && user.getRole() != 2)) {
                response.sendRedirect(contextPath + "/");
                return;
            }
        }

        chain.doFilter(req, resp);
    }

    @Override
    public void destroy() {}
}
