package com.order.servlet;

import com.order.entity.Order;
import com.order.entity.User;
import com.order.service.OrderService;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/order/list")
public class OrderListServlet extends HttpServlet {
    private OrderService orderService = new OrderService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        try {
            String sort = req.getParameter("sort");
            int page = 1;
            int pageSize = 8;
            try {
                String pageStr = req.getParameter("page");
                if (pageStr != null && !pageStr.isEmpty()) page = Integer.parseInt(pageStr);
            } catch (NumberFormatException e) {}
            if (page < 1) page = 1;

            long total = orderService.countOrdersByUserId(user.getUserId());
            int totalPages = (int) Math.ceil((double) total / pageSize);
            if (totalPages < 1) totalPages = 1;
            if (page > totalPages) page = totalPages;

            List<Order> orders = orderService.getOrdersByUserId(user.getUserId(), sort, page, pageSize);
            req.setAttribute("orders", orders);
            req.setAttribute("sort", sort);
            req.setAttribute("currentPage", page);
            req.setAttribute("totalPages", totalPages);
        } catch (Exception e) {
            e.printStackTrace();
        }
        req.getRequestDispatcher("/jsp/user/orderList.jsp").forward(req, resp);
    }
}
