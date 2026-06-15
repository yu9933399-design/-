<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="common/header.jsp"><jsp:param name="title" value="登录"/></jsp:include>
<div class="container mt-5"><div class="row justify-content-center"><div class="col-md-5"><div class="card shadow-sm border-0"><div class="card-body p-5">
<ul class="nav nav-pills nav-justified mb-4">
<li class="nav-item"><a class="nav-link ${empty param.type || param.type=='user' ? 'active' : ''}" href="${pageContext.request.contextPath}/login?type=user">用户登录</a></li>
<li class="nav-item"><a class="nav-link ${param.type=='merchant' ? 'active' : ''}" href="${pageContext.request.contextPath}/login?type=merchant">商家登录</a></li>
</ul>
<c:if test="${error != null}"><div class="alert alert-danger"><c:out value="${error}"/></div></c:if>
<c:if test="${success != null}"><div class="alert alert-success"><c:out value="${success}"/></div></c:if>
<form method="post" action="${pageContext.request.contextPath}/login">
<input type="hidden" name="type" value="${param.type != null ? param.type : 'user'}"/>
<div class="mb-3"><label class="form-label">用户名</label><div class="input-group"><span class="input-group-text"><i class="fas fa-user"></i></span><input type="text" class="form-control" name="username" required placeholder="请输入用户名"></div></div>
<div class="mb-3"><label class="form-label">密码</label><div class="input-group"><span class="input-group-text"><i class="fas fa-lock"></i></span><input type="password" class="form-control" name="password" required placeholder="请输入密码"></div></div>
<button type="submit" class="btn btn-primary w-100 py-2">登录</button>
</form>
<p class="text-center mt-3">还没有账号？<a href="${pageContext.request.contextPath}/register" class="text-primary">立即注册</a></p>
</div></div></div></div></div>
<jsp:include page="common/footer.jsp"/>
