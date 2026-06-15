<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html><html lang="zh-CN"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>用户管理</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"><link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"><link href="${pageContext.request.contextPath}/css/custom.css" rel="stylesheet"></head>
<body class="bg-light"><div class="d-flex"><jsp:include page="/jsp/common/admin-sidebar.jsp"/>
<div class="flex-grow-1 p-4"><h4 class="fw-bold mb-4">用户管理</h4>
<c:if test="${not empty pendingMerchants}">
<div class="alert alert-warning d-flex align-items-center mb-3"><i class="fas fa-bell me-2"></i><strong>${pendingMerchants.size()}</strong>&nbsp;个商家入驻申请待审核</div>
</c:if>
<form class="mb-3" method="get" action="${pageContext.request.contextPath}/admin/user"><div class="input-group" style="max-width:400px;"><input type="text" class="form-control" name="keyword" value="<c:out value='${keyword}'/>" placeholder="搜索用户名/手机/姓名..."><button class="btn btn-primary"><i class="fas fa-search"></i></button></div></form>
<div class="card border-0 shadow-sm"><div class="card-body"><table class="table table-hover align-middle">
<thead class="table-light"><tr><th>ID</th><th>用户名</th><th>姓名</th><th>手机</th><th>邮箱</th><th>角色</th><th>状态</th><th>操作</th></tr></thead>
<tbody><c:forEach items="${users}" var="u"><tr><td>${u.userId}</td><td><c:out value="${u.username}"/></td><td><c:out value="${u.realName}"/></td><td><c:out value="${u.phone}"/></td><td><c:out value="${u.email}"/></td>
<td>
<c:choose>
<c:when test="${u.role == 1}"><span class="badge bg-primary">管理员</span></c:when>
<c:when test="${u.role == 2}"><span class="badge bg-warning">商家</span></c:when>
<c:otherwise><span class="badge bg-secondary">用户</span></c:otherwise>
</c:choose>
<c:if test="${u.userId != sessionScope.user.userId && u.status != 2}">
<select class="form-select form-select-sm ms-2 d-inline-block w-auto change-role" data-user-id="${u.userId}" style="vertical-align:middle;">
<option value="" disabled selected>切换</option>
<option value="0">普通用户</option>
<option value="2">商家</option>
<option value="1">管理员</option>
</select>
</c:if>
</td>
<td>
<c:choose>
<c:when test="${u.status == 0}"><span class="badge bg-success">正常</span></c:when>
<c:when test="${u.status == 1}"><span class="badge bg-danger">禁用</span></c:when>
<c:when test="${u.status == 2}"><span class="badge bg-warning">待审核</span></c:when>
</c:choose>
</td>
<td>
<c:if test="${u.status == 2}">
<button class="btn btn-sm btn-success approve-merchant" data-user-id="${u.userId}" title="通过"><i class="fas fa-check"></i> 通过</button>
<button class="btn btn-sm btn-outline-danger reject-merchant" data-user-id="${u.userId}" title="拒绝"><i class="fas fa-times"></i></button>
</c:if>
<c:if test="${u.status == 0 || u.status == 1}">
<button class="btn btn-sm ${u.status == 0 ? 'btn-outline-danger' : 'btn-outline-success'} toggle-status" data-user-id="${u.userId}" data-status="${u.status == 0 ? 1 : 0}">${u.status == 0 ? '禁用' : '启用'}</button>
<button class="btn btn-sm btn-outline-warning reset-pwd" data-user-id="${u.userId}">重置密码</button>
</c:if>
</td></tr></c:forEach></tbody></table></div></div>
</div></div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script>$(document).on('click','.toggle-status',function(){var btn=$(this);$.post('${pageContext.request.contextPath}/admin/user/status',{userId:btn.data('user-id'),status:btn.data('status')},function(){location.reload();});});
$(document).on('click','.reset-pwd',function(){if(confirm('确定重置密码为123456？')){$.post('${pageContext.request.contextPath}/admin/user/resetPassword',{userId:$(this).data('user-id')},function(r){if(r.success)alert('密码已重置');});}});
$(document).on('change','.change-role',function(){var sel=$(this);$.post('${pageContext.request.contextPath}/admin/user/role',{userId:sel.data('user-id'),role:sel.val()},function(){location.reload();});});
$(document).on('click','.approve-merchant',function(){var btn=$(this);$.post('${pageContext.request.contextPath}/admin/user/status',{userId:btn.data('user-id'),status:0},function(){location.reload();});});
$(document).on('click','.reject-merchant',function(){if(confirm('确定拒绝该商家申请？')){$.post('${pageContext.request.contextPath}/admin/user/status',{userId:$(this).data('user-id'),status:1},function(){location.reload();});}});</script>
</body></html>
