<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="common/header.jsp"><jsp:param name="title" value="注册"/></jsp:include>
<div class="container mt-5"><div class="row justify-content-center"><div class="col-md-5"><div class="card shadow-sm border-0"><div class="card-body p-5">
<ul class="nav nav-pills nav-justified mb-4">
<li class="nav-item"><a class="nav-link ${(empty param.type && empty type) || type=='user' || param.type=='user' ? 'active' : ''}" href="${pageContext.request.contextPath}/register?type=user">用户注册</a></li>
<li class="nav-item"><a class="nav-link ${type=='merchant' || param.type=='merchant' ? 'active' : ''}" href="${pageContext.request.contextPath}/register?type=merchant">商家注册</a></li>
</ul>
<c:if test="${error != null}"><div class="alert alert-danger"><c:out value="${error}"/></div></c:if>
<c:if test="${success != null}"><div class="alert alert-success"><c:out value="${success}"/></div></c:if>
<form method="post" action="${pageContext.request.contextPath}/register">
<input type="hidden" name="type" value="${type != null ? type : (param.type != null ? param.type : 'user')}"/>
<div class="mb-3"><label class="form-label">用户名 *</label><input type="text" class="form-control" name="username" required placeholder="请输入用户名"></div>
<div class="mb-3"><label class="form-label">密码 *</label><input type="password" class="form-control" name="password" required placeholder="请输入密码"></div>
<div class="mb-3"><label class="form-label">手机号 *</label><input type="text" class="form-control" name="phone" required placeholder="请输入手机号"></div>
<div class="mb-3"><label class="form-label">邮箱</label><input type="email" class="form-control" name="email" placeholder="请输入邮箱"></div>
<c:if test="${param.type == 'merchant'}">
<div class="mb-3"><label class="form-label">店铺名称 *</label><input type="text" class="form-control" name="shopName" required placeholder="请输入店铺名称"></div>
<div class="mb-3"><label class="form-label">店铺分类 *</label>
<select class="form-select" name="shopCategory" required>
<option value="">请选择分类</option>
<option value="快餐简餐">快餐简餐</option>
<option value="奶茶饮品">奶茶饮品</option>
<option value="川湘辣味">川湘辣味</option>
<option value="粤菜海鲜">粤菜海鲜</option>
<option value="甜品小吃">甜品小吃</option>
<option value="早餐早点">早餐早点</option>
<option value="面食粥品">面食粥品</option>
<option value="轻食沙拉">轻食沙拉</option>
</select></div>
</c:if>
<button type="submit" class="btn btn-primary w-100 py-2">${param.type == 'merchant' ? '申请商家入驻' : '注册'}</button>
</form>
<c:if test="${param.type == 'merchant'}"><p class="text-center mt-3 text-muted" style="font-size:13px;">商家注册需管理员审核通过后方可登录</p></c:if>
<p class="text-center mt-3">已有账号？<a href="${pageContext.request.contextPath}/login" class="text-primary">立即登录</a></p>
</div></div></div></div></div>
<jsp:include page="common/footer.jsp"/>
