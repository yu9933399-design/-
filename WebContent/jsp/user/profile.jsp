<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="../common/header.jsp"><jsp:param name="title" value="个人中心"/></jsp:include>
<div class="container mt-4"><div class="row">
<div class="col-md-3"><div class="card border-0 shadow-sm"><div class="card-body text-center py-4"><div class="bg-primary text-white rounded-circle d-inline-flex align-items-center justify-content-center" style="width:80px;height:80px;"><i class="fas fa-user fa-2x"></i></div><h5 class="mt-3">${user.username}</h5><span class="badge bg-primary">${user.role == 1 ? '管理员' : '普通用户'}</span></div>
<div class="list-group list-group-flush"><a href="${pageContext.request.contextPath}/profile" class="list-group-item list-group-item-action active"><i class="fas fa-user-edit me-2"></i>个人信息</a><a href="${pageContext.request.contextPath}/order/list" class="list-group-item list-group-item-action"><i class="fas fa-list me-2"></i>我的订单</a><a href="${pageContext.request.contextPath}/cart" class="list-group-item list-group-item-action"><i class="fas fa-shopping-cart me-2"></i>购物车</a></div></div></div>
<div class="col-md-9"><div class="card border-0 shadow-sm"><div class="card-header bg-white"><h5 class="mb-0 fw-bold">个人信息</h5></div><div class="card-body">
<c:if test="${success != null}"><div class="alert alert-success">${success}</div></c:if><c:if test="${error != null}"><div class="alert alert-danger">${error}</div></c:if>
<form method="post" action="${pageContext.request.contextPath}/profile"><input type="hidden" name="action" value="updateProfile">
<div class="row mb-3"><div class="col-md-6"><label class="form-label">姓名</label><input type="text" class="form-control" name="realName" value="${user.realName}"></div><div class="col-md-6"><label class="form-label">手机号</label><input type="text" class="form-control" name="phone" value="${user.phone}"></div></div>
<div class="mb-3"><label class="form-label">邮箱</label><input type="email" class="form-control" name="email" value="${user.email}"></div>
<div class="mb-3"><label class="form-label">默认收货地址</label><textarea class="form-control" name="address" rows="2">${user.address}</textarea></div>
<button type="submit" class="btn btn-primary">保存修改</button></form>
<hr><h6 class="fw-bold">修改密码</h6>
<form method="post" action="${pageContext.request.contextPath}/profile"><input type="hidden" name="action" value="updatePassword">
<div class="row mb-3"><div class="col-md-4"><input type="password" class="form-control" name="oldPassword" placeholder="原密码" required></div><div class="col-md-4"><input type="password" class="form-control" name="newPassword" placeholder="新密码" required></div><div class="col-md-4"><button type="submit" class="btn btn-outline-primary">修改密码</button></div></div></form>
</div></div></div></div></div>
<jsp:include page="../common/footer.jsp"/>