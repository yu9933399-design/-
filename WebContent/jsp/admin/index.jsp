<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html><html lang="zh-CN"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>后台管理</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"><link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"><link href="${pageContext.request.contextPath}/css/custom.css" rel="stylesheet"></head>
<body class="bg-light"><div class="d-flex">
<jsp:include page="/jsp/common/admin-sidebar.jsp"/>
<div class="flex-grow-1 p-4">
<div class="d-flex justify-content-between align-items-center mb-4">
<h4 class="fw-bold">
<c:choose>
<c:when test="${sessionScope.user.role == 1}"><i class="fas fa-shield-alt text-danger me-2"></i>管理后台</c:when>
<c:when test="${sessionScope.user.role == 2}"><i class="fas fa-store text-warning me-2"></i>商家中心</c:when>
</c:choose>
</h4>
<span><c:choose><c:when test="${sessionScope.user.role == 1}"><span class="badge bg-danger me-2">管理员</span><c:out value="${sessionScope.user.username}"/></c:when><c:when test="${sessionScope.user.role == 2}"><span class="badge bg-warning me-2">商家</span><c:out value="${sessionScope.user.username}"/></c:when></c:choose></span>
</div>

<c:if test="${sessionScope.user.role == 1 && pendingMerchantCount > 0}">
<div class="alert alert-warning d-flex align-items-center mb-4">
<i class="fas fa-bell me-2"></i>
有 <strong>${pendingMerchantCount}</strong> 个商家入驻申请待审核，<a href="${pageContext.request.contextPath}/admin/user" class="alert-link">前往处理</a>
</div>
</c:if>

<div class="row g-4">
<c:if test="${sessionScope.user.role == 1}">
<div class="col-md-3">
<div class="card border-0 shadow-sm text-center p-4 h-100">
<i class="fas fa-store fa-2x text-info mb-2"></i>
<h5>${merchantCount}</h5>
<p class="text-muted">入驻商家</p>
<a href="${pageContext.request.contextPath}/admin/merchant" class="stretched-link"></a>
</div>
</div>
<div class="col-md-3">
<div class="card border-0 shadow-sm text-center p-4 h-100">
<i class="fas fa-users fa-2x text-secondary mb-2"></i>
<h5>${userCount}</h5>
<p class="text-muted">注册用户</p>
<a href="${pageContext.request.contextPath}/admin/user" class="stretched-link"></a>
</div>
</div>
<div class="col-md-3">
<div class="card border-0 shadow-sm text-center p-4 h-100">
<i class="fas fa-utensils fa-2x text-primary mb-2"></i>
<h5>${dishCount}</h5>
<p class="text-muted">全平台菜品</p>
<a href="${pageContext.request.contextPath}/admin/dish" class="stretched-link"></a>
</div>
</div>
<div class="col-md-3">
<div class="card border-0 shadow-sm text-center p-4 h-100">
<i class="fas fa-receipt fa-2x text-warning mb-2"></i>
<h5>${orderCount}</h5>
<p class="text-muted">全平台订单</p>
<a href="${pageContext.request.contextPath}/admin/order" class="stretched-link"></a>
</div>
</div>
</c:if>
<c:if test="${sessionScope.user.role == 2}">
<div class="col-md-4">
<div class="card border-0 shadow-sm text-center p-4 h-100">
<i class="fas fa-utensils fa-2x text-primary mb-2"></i>
<h5>${dishCount}</h5>
<p class="text-muted">我的菜品</p>
<a href="${pageContext.request.contextPath}/admin/dish" class="stretched-link"></a>
</div>
</div>
<div class="col-md-4">
<div class="card border-0 shadow-sm text-center p-4 h-100">
<i class="fas fa-tags fa-2x text-success mb-2"></i>
<h5>${categoryCount}</h5>
<p class="text-muted">菜品分类</p>
<a href="${pageContext.request.contextPath}/admin/category" class="stretched-link"></a>
</div>
</div>
<div class="col-md-4">
<div class="card border-0 shadow-sm text-center p-4 h-100">
<i class="fas fa-receipt fa-2x text-warning mb-2"></i>
<h5>${orderCount}</h5>
<p class="text-muted">我的订单</p>
<a href="${pageContext.request.contextPath}/admin/order" class="stretched-link"></a>
</div>
</div>
</c:if>

<div class="row mt-4">
<div class="col-12">
<div class="card border-0 shadow-sm">
<div class="card-body">
<h5 class="fw-bold mb-3"><i class="fas fa-tasks text-primary me-2"></i>快捷操作</h5>
<div class="d-flex gap-2 flex-wrap">
<c:if test="${sessionScope.user.role == 1}">
<a href="${pageContext.request.contextPath}/admin/merchant" class="btn btn-outline-info"><i class="fas fa-store me-1"></i>商家管理</a>
<a href="${pageContext.request.contextPath}/admin/user" class="btn btn-outline-primary"><i class="fas fa-users me-1"></i>用户管理</a>
<a href="${pageContext.request.contextPath}/register?type=merchant" class="btn btn-outline-warning"><i class="fas fa-store me-1"></i>添加商家</a>
</c:if>
<c:if test="${sessionScope.user.role == 2}">
<a href="${pageContext.request.contextPath}/admin/dish/add" class="btn btn-outline-success"><i class="fas fa-plus me-1"></i>添加菜品</a>
<a href="${pageContext.request.contextPath}/admin/category/add" class="btn btn-outline-info"><i class="fas fa-tag me-1"></i>添加分类</a>
</c:if>
</div>
</div>
</div>
</div>
</div>

</div></div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script></body></html>
