<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${param.title} - 美食点餐系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+SC:wght@300;400;500;700&family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/custom.css" rel="stylesheet">
</head>
<body>
<nav class="navbar navbar-expand-lg navbar-light bg-white shadow-sm sticky-top">
    <div class="container">
        <a class="navbar-brand d-flex align-items-center" href="${pageContext.request.contextPath}/">
            <i class="fas fa-utensils text-primary me-2"></i>
            <span class="fw-bold text-primary">美食点餐系统</span>
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav"><span class="navbar-toggler-icon"></span></button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav me-auto">
<li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/">首页</a></li>
<li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/merchant/list">商家店铺</a></li>
                <c:if test="${sessionScope.user != null}">
                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/order/list">订单中心</a></li>
                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/message/list"><i class="fas fa-envelope me-1"></i>消息</a></li>
                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/profile">会员中心</a></li>
                </c:if>
            </ul>
            <ul class="navbar-nav">
                <c:choose>
                    <c:when test="${sessionScope.user == null}">
                        <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/login"><i class="fas fa-sign-in-alt me-1"></i>登录</a></li>
                        <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/register"><i class="fas fa-user-plus me-1"></i>注册</a></li>
                    </c:when>
                    <c:otherwise>
                        <li class="nav-item"><a class="nav-link position-relative" href="${pageContext.request.contextPath}/cart"><i class="fas fa-shopping-cart"></i><span class="badge bg-primary rounded-pill position-absolute" style="top:-5px;right:-10px;font-size:0.7rem;" id="cartCount">0</span></a></li>
                        <li class="nav-item dropdown"><a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown"><i class="fas fa-user me-1"></i>${sessionScope.user.username}</a>
                            <ul class="dropdown-menu dropdown-menu-end"><li><a class="dropdown-item" href="${pageContext.request.contextPath}/profile">个人中心</a></li><li><a class="dropdown-item" href="${pageContext.request.contextPath}/order/list">我的订单</a></li><li><hr class="dropdown-divider"></li><li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout">退出登录</a></li></ul>
                        </li>
                    </c:otherwise>
                </c:choose>
            </ul>
        </div>
    </div>
</nav>