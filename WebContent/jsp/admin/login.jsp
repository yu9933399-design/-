<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>管理后台登录</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        body { background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%); min-height: 100vh; display: flex; align-items: center; justify-content: center; }
        .login-card { max-width: 400px; width: 100%; border-radius: 16px; overflow: hidden; box-shadow: 0 20px 60px rgba(0,0,0,0.3); }
        .login-header { background: linear-gradient(135deg, #1a1a2e, #0f3460); color: white; padding: 30px; text-align: center; }
        .login-header i { font-size: 40px; margin-bottom: 10px; color: #e94560; }
        .login-body { padding: 30px; }
        .btn-login { background: linear-gradient(135deg, #e94560, #c23152); border: none; padding: 12px; font-size: 16px; border-radius: 8px; }
        .btn-login:hover { background: linear-gradient(135deg, #c23152, #a02040); transform: translateY(-1px); }
    </style>
</head>
<body>
<div class="login-card card border-0">
    <div class="login-header">
        <i class="fas fa-shield-alt"></i>
        <h4 class="mb-0 fw-bold">管理后台</h4>
        <small class="text-white-50">Admin Control Panel</small>
    </div>
    <div class="login-body">
        <c:if test="${error != null}"><div class="alert alert-danger py-2">${error}</div></c:if>
        <form method="post" action="${pageContext.request.contextPath}/admin/login">
            <div class="mb-3">
                <label class="form-label fw-bold">管理员账号</label>
                <div class="input-group"><span class="input-group-text"><i class="fas fa-user-shield"></i></span><input type="text" class="form-control" name="username" required placeholder="请输入管理员账号"></div>
            </div>
            <div class="mb-3">
                <label class="form-label fw-bold">密码</label>
                <div class="input-group"><span class="input-group-text"><i class="fas fa-lock"></i></span><input type="password" class="form-control" name="password" required placeholder="请输入密码"></div>
            </div>
            <button type="submit" class="btn btn-login text-white w-100"><i class="fas fa-sign-in-alt me-2"></i>登录后台</button>
        </form>
        <div class="text-center mt-3"><a href="${pageContext.request.contextPath}/login" class="text-muted text-decoration-none" style="font-size:13px;"><i class="fas fa-arrow-left me-1"></i>返回用户登录</a></div>
    </div>
</div>
</body>
</html>
