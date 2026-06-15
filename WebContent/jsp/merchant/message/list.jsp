<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>消息中心 - 商家后台</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/custom.css" rel="stylesheet">
</head>
<body>
<div class="d-flex">
    <div class="bg-dark text-white" style="width: 250px; min-height: 100vh;">
        <div class="p-3">
            <h5><i class="fas fa-store me-2"></i>商家后台</h5>
        </div>
        <ul class="nav flex-column">
            <li class="nav-item"><a class="nav-link text-white" href="${pageContext.request.contextPath}/merchant/store"><i class="fas fa-home me-2"></i>店铺管理</a></li>
            <li class="nav-item"><a class="nav-link text-white" href="${pageContext.request.contextPath}/merchant/orders"><i class="fas fa-shopping-bag me-2"></i>订单管理</a></li>
            <li class="nav-item"><a class="nav-link text-white active" href="${pageContext.request.contextPath}/merchant/message/list"><i class="fas fa-envelope me-2"></i>消息中心
                <c:if test="${totalUnread > 0}"><span class="badge bg-danger">${totalUnread}</span></c:if>
            </a></li>
            <li class="nav-item"><a class="nav-link text-white" href="${pageContext.request.contextPath}/logout"><i class="fas fa-sign-out-alt me-2"></i>退出登录</a></li>
        </ul>
    </div>
    <div class="flex-grow-1">
        <nav class="navbar navbar-light bg-white shadow-sm">
            <div class="container-fluid">
                <span class="navbar-brand">消息中心</span>
                <span class="text-muted">欢迎，${sessionScope.user.username}</span>
            </div>
        </nav>
        <div class="p-4">
            <c:if test="${error != null}">
                <div class="alert alert-danger">${error}</div>
            </c:if>
            
            <div class="row">
                <div class="col-md-4">
                    <div class="card shadow-sm mb-4">
                        <div class="card-header bg-success text-white">
                            <h6 class="mb-0"><i class="fas fa-user-shield me-2"></i>联系管理员</h6>
                        </div>
                        <div class="card-body">
                            <c:choose>
                                <c:when test="${empty admins}">
                                    <p class="text-muted mb-0">暂无可用管理员</p>
                                </c:when>
                                <c:otherwise>
                                    <div class="list-group list-group-flush">
                                        <c:forEach items="${admins}" var="admin">
                                            <a href="${pageContext.request.contextPath}/merchant/message/chat?userId=${admin.userId}" 
                                               class="list-group-item list-group-item-action">
                                                <i class="fas fa-user-shield text-success me-2"></i>${admin.username}
                                            </a>
                                        </c:forEach>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
                <div class="col-md-8">
                    <div class="card shadow-sm">
                        <div class="card-header">
                            <h6 class="mb-0">聊天记录</h6>
                        </div>
                        <div class="card-body">
                            <c:choose>
                                <c:when test="${empty chatUsers}">
                                    <div class="text-center py-5">
                                        <i class="fas fa-envelope-open-text fa-3x text-muted mb-3"></i>
                                        <p class="text-muted">暂无消息记录</p>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="list-group">
                                        <c:forEach items="${chatUsers}" var="chatUser">
                                            <a href="${pageContext.request.contextPath}/merchant/message/chat?userId=${chatUser.userId}" 
                                               class="list-group-item list-group-item-action d-flex justify-content-between align-items-center">
                                                <div>
                                                    <i class="fas fa-user-circle fa-2x text-primary me-3"></i>
                                                    <span class="fw-bold">${chatUser.username}</span>
                                                </div>
                                                <c:if test="${chatUser.status > 0}">
                                                    <span class="badge bg-danger rounded-pill">${chatUser.status}条未读</span>
                                                </c:if>
                                            </a>
                                        </c:forEach>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
