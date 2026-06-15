<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<nav class="sidebar bg-dark text-white" style="width:240px;min-height:100vh;">
<div class="p-3">
    <h5><i class="fas fa-utensils me-2 text-primary"></i>美食点餐系统</h5>
    <c:choose>
        <c:when test="${sessionScope.user.role == 1}"><span class="badge bg-danger mt-1"><i class="fas fa-shield-alt me-1"></i>系统管理员</span></c:when>
        <c:when test="${sessionScope.user.role == 2}"><span class="badge bg-warning mt-1"><i class="fas fa-store me-1"></i>商家</span></c:when>
    </c:choose>
</div>
<div class="list-group list-group-flush">
<a href="${pageContext.request.contextPath}/admin" class="list-group-item bg-dark text-white border-0"><i class="fas fa-home me-2"></i>首页概览</a>
<c:choose>
<c:when test="${sessionScope.user.role == 1}">
<a href="${pageContext.request.contextPath}/admin/merchant" class="list-group-item bg-dark text-white border-0"><i class="fas fa-store me-2"></i>商家管理</a>
<a href="${pageContext.request.contextPath}/admin/user" class="list-group-item bg-dark text-white border-0 d-flex justify-content-between align-items-center"><span><i class="fas fa-users me-2"></i>用户管理</span><c:if test="${pendingMerchantCount > 0}"><span class="badge bg-danger">${pendingMerchantCount}</span></c:if></a>
<a href="${pageContext.request.contextPath}/admin/banner" class="list-group-item bg-dark text-white border-0"><i class="fas fa-images me-2"></i>轮播管理</a>
<a href="${pageContext.request.contextPath}/admin/message/list" class="list-group-item bg-dark text-white border-0"><i class="fas fa-envelope me-2"></i>消息中心</a>
</c:when>
<c:when test="${sessionScope.user.role == 2}">
<a href="${pageContext.request.contextPath}/admin/dish" class="list-group-item bg-dark text-white border-0"><i class="fas fa-utensils me-2"></i>我的菜品</a>
<a href="${pageContext.request.contextPath}/admin/category" class="list-group-item bg-dark text-white border-0"><i class="fas fa-tags me-2"></i>分类管理</a>
<a href="${pageContext.request.contextPath}/admin/order" class="list-group-item bg-dark text-white border-0"><i class="fas fa-receipt me-2"></i>我的订单</a>
<a href="${pageContext.request.contextPath}/merchant/message/list" class="list-group-item bg-dark text-white border-0"><i class="fas fa-envelope me-2"></i>消息中心</a>
<a href="${pageContext.request.contextPath}/merchant/settings" class="list-group-item bg-dark text-white border-0"><i class="fas fa-cog me-2"></i>店铺设置</a>
</c:when>
</c:choose>
<a href="${pageContext.request.contextPath}/logout" class="list-group-item bg-dark text-white border-0 text-danger"><i class="fas fa-sign-out-alt me-2"></i>退出登录</a>
</div></nav>
