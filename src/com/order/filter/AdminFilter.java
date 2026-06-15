package com.order.filter;

import com.order.entity.User;
import com.order.service.UserService;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter(urlPatterns = {"/admin", "/admin/*"})
public class AdminFilter implements Filter {

    private UserService userService = new UserService();

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest req, ServletResponse resp, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user != null && user.getRole() != null && user.getRole() == 1) {
            try {
                int pendingCount = 0;
                for (User u : userService.findAll()) {
                    if (u.getStatus() != null && u.getStatus() == 2) pendingCount++;
                }
                request.setAttribute("pendingMerchantCount", pendingCount);
            } catch (Exception e) {}
        }

        chain.doFilter(req, resp);
    }

    @Override
    public void destroy() {}
}
