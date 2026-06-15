package com.order.servlet;

import com.order.entity.Order;
import com.order.entity.User;
import com.order.service.OrderService;
import com.order.utils.AiChatUtil;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/aiOrderChat")
public class AiOrderChatServlet extends HttpServlet {
    private OrderService orderService = new OrderService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");

        String jsonResult;
        try {
            HttpSession session = req.getSession(false);
            User user = (session != null) ? (User) session.getAttribute("user") : null;
            if (user == null) {
                jsonResult = "{\"success\":false,\"message\":\"请先登录\"}";
                System.out.println("[AIChat] 未登录用户访问");
                resp.getWriter().write(jsonResult);
                return;
            }

            String question = req.getParameter("question");
            if (question == null || question.trim().isEmpty()) {
                jsonResult = "{\"success\":false,\"message\":\"请输入您的问题\"}";
                resp.getWriter().write(jsonResult);
                return;
            }

            System.out.println("[AIChat] 用户:" + user.getUsername() + " 提问:" + question);

            // 拼接订单上下文
            StringBuilder context = new StringBuilder();
            context.append("【用户当前订单信息】\n");
            try {
                List<Order> orders = orderService.getOrdersByUserId(user.getUserId());
                if (orders == null || orders.isEmpty()) {
                    context.append("该用户暂无订单记录。\n");
                } else {
                    for (Order o : orders) {
                        context.append("订单号：").append(o.getOrderNo())
                               .append("，状态：").append(getOrderStatusText(o.getOrderStatus()))
                               .append("，金额：").append(o.getTotalAmount())
                               .append("，地址：").append(o.getReceiverAddress())
                               .append("，配送：").append(getDeliveryStatusText(o.getDeliveryStatus()))
                               .append("，位置：").append(o.getDeliveryPosition() != null ? o.getDeliveryPosition() : "暂无")
                               .append("\n");
                    }
                }
            } catch (Exception e) {
                System.out.println("[AIChat] 查询订单异常: " + e.getMessage());
                context.append("订单信息获取失败。\n");
            }

            String fullMessage = context + "\n【用户问题】：" + question.trim();

            // 调用 AI
            String answer = AiChatUtil.chat(fullMessage);
            System.out.println("[AIChat] 回答:" + answer);

            jsonResult = buildJsonResponse(answer);
            resp.getWriter().write(jsonResult);

        } catch (Exception e) {
            System.out.println("[AIChat] 未捕获异常: " + e.getClass().getName() + ": " + e.getMessage());
            e.printStackTrace();
            jsonResult = "{\"success\":false,\"message\":\"服务异常\"}";
            resp.getWriter().write(jsonResult);
        }
    }

    /**
     * 安全构建 JSON，逐字符转义
     */
    private String buildJsonResponse(String answer) {
        StringBuilder sb = new StringBuilder("{\"success\":true,\"answer\":\"");
        if (answer != null) {
            for (int i = 0; i < answer.length(); i++) {
                char c = answer.charAt(i);
                switch (c) {
                    case '"': sb.append("\\\""); break;
                    case '\\': sb.append("\\\\"); break;
                    case '\n': sb.append("\\n"); break;
                    case '\r': break;
                    case '\t': sb.append("\\t"); break;
                    case '\b': sb.append("\\b"); break;
                    case '\f': sb.append("\\f"); break;
                    default:
                        if (c < 0x20) {
                            sb.append(String.format("\\u%04x", (int) c));
                        } else {
                            sb.append(c);
                        }
                }
            }
        }
        sb.append("\"}");
        return sb.toString();
    }

    private String getOrderStatusText(Integer status) {
        if (status == null) return "未知";
        switch (status) {
            case 0: case 1: return "待支付";
            case 2: return "待接单";
            case 4: return "已接单";
            case 5: return "制作中";
            case 6: return "配送中";
            case 3: case 8: return "已完成";
            case 9: return "已取消";
            default: return "未知";
        }
    }

    private String getDeliveryStatusText(Integer status) {
        if (status == null) return "待配送";
        switch (status) {
            case 1: return "配送中";
            case 2: return "已送达";
            default: return "待配送";
        }
    }
}
