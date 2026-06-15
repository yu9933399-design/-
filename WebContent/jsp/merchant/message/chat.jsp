<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>聊天 - 商家后台</title>
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
            <li class="nav-item"><a class="nav-link text-white" href="${pageContext.request.contextPath}/merchant/message/list"><i class="fas fa-envelope me-2"></i>消息中心</a></li>
            <li class="nav-item"><a class="nav-link text-white" href="${pageContext.request.contextPath}/logout"><i class="fas fa-sign-out-alt me-2"></i>退出登录</a></li>
        </ul>
    </div>
    <div class="flex-grow-1">
        <nav class="navbar navbar-light bg-white shadow-sm">
            <div class="container-fluid">
                <span class="navbar-brand">聊天</span>
                <span class="text-muted">欢迎，${sessionScope.user.username}</span>
            </div>
        </nav>
        <div class="p-4">
            <div class="row justify-content-center">
                <div class="col-md-8">
                    <div class="card shadow">
                        <div class="card-header bg-success text-white d-flex justify-content-between align-items-center">
                            <div>
                                <a href="${pageContext.request.contextPath}/merchant/message/list" class="text-white me-2">
                                    <i class="fas fa-arrow-left"></i>
                                </a>
                                <span>与 <c:out value="${otherUser.username}" default="用户"/> 的对话</span>
                            </div>
                        </div>
                        <div class="card-body" style="height: 400px; overflow-y: auto;" id="chatBox">
                            <c:choose>
                                <c:when test="${empty messages}">
                                    <div class="text-center text-muted py-5">
                                        <i class="fas fa-comments fa-3x mb-3"></i>
                                        <p>暂无消息，发送第一条消息吧</p>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach items="${messages}" var="msg">
                                        <c:choose>
                                            <c:when test="${msg.senderId == sessionScope.user.userId}">
                                                <div class="d-flex justify-content-end mb-3">
                                                    <div class="bg-success text-white rounded-3 p-3" style="max-width: 70%;">
                                                        <div class="mb-1">${msg.content}</div>
                                                        <small class="text-white-50">
                                                            ${msg.createTime}
                                                        </small>
                                                    </div>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="d-flex justify-content-start mb-3">
                                                    <div class="bg-light rounded-3 p-3" style="max-width: 70%;">
                                                        <div class="mb-1">${msg.content}</div>
                                                        <small class="text-muted">
                                                            ${msg.createTime}
                                                        </small>
                                                    </div>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="card-footer">
                            <form action="${pageContext.request.contextPath}/merchant/message/send" method="post" class="d-flex gap-2">
                                <input type="hidden" name="receiverId" value="${otherUser.userId}">
                                <input type="text" name="content" class="form-control" placeholder="输入消息..." required maxlength="1000" autocomplete="off">
                                <button type="submit" class="btn btn-success">
                                    <i class="fas fa-paper-plane"></i>
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    var chatBox = document.getElementById('chatBox');
    chatBox.scrollTop = chatBox.scrollHeight;
</script>
</body>
</html>
