<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html><html lang="zh-CN"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>菜品管理</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"><link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"><link href="${pageContext.request.contextPath}/css/custom.css" rel="stylesheet"></head>
<body class="bg-light"><div class="d-flex"><jsp:include page="/jsp/common/admin-sidebar.jsp"/>
<div class="flex-grow-1 p-4">
<div class="d-flex justify-content-between align-items-center mb-4">
<h4 class="fw-bold"><i class="fas fa-utensils me-2 text-primary"></i><c:choose><c:when test="${sessionScope.user.role == 1}">商家菜品（平台监管）</c:when><c:otherwise>我的菜品</c:otherwise></c:choose></h4>
<c:if test="${sessionScope.user.role == 2}"><a href="${pageContext.request.contextPath}/admin/dish/add" class="btn btn-primary"><i class="fas fa-plus me-1"></i>添加菜品</a></c:if>
</div>
<c:if test="${sessionScope.user.role == 1 && not empty merchants}">
<form class="row g-2 mb-3" method="get" action="${pageContext.request.contextPath}/admin/dish">
<div class="col-auto"><select class="form-select" name="merchantId" onchange="this.form.submit()"><option value="">所有商家</option><c:forEach items="${merchants}" var="m"><option value="${m.userId}" ${param.merchantId == m.userId.toString() ? 'selected' : ''}><c:out value="${m.realName}"/></option></c:forEach></select></div>
</form>
</c:if>
<div class="card border-0 shadow-sm"><div class="card-body"><table class="table table-hover align-middle">
<thead class="table-light"><tr><th>ID</th><th>图片</th><th>菜品名称</th><th>商家</th><th>价格</th><th>分类</th><th>状态</th><th>操作</th></tr></thead>
<tbody><c:forEach items="${dishes}" var="dish"><tr><td>${dish.dishId}</td><td><img src="${pageContext.request.contextPath}/${dish.imageUrl}" style="width:50px;height:50px;object-fit:cover;" class="rounded"></td><td><c:out value="${dish.dishName}"/></td><td><c:out value="${dish.merchantName}"/></td><td class="text-primary fw-bold">&#165;${dish.price}</td><td><c:out value="${dish.categoryName}"/></td>
<td><span class="badge ${dish.status == 1 ? 'bg-success' : 'bg-secondary'}">${dish.status == 1 ? '上架' : '下架'}</span></td>
<td><a href="${pageContext.request.contextPath}/admin/dish/edit?id=${dish.dishId}" class="btn btn-outline-primary btn-sm me-1">编辑</a><button class="btn btn-outline-danger btn-sm delete-btn" data-url="${pageContext.request.contextPath}/admin/dish/delete?id=${dish.dishId}">删除</button></td></tr></c:forEach></tbody></table></div></div>
<c:if test="${totalPages > 1}">
<nav class="mt-3"><ul class="pagination justify-content-center">
<li class="page-item ${currentPage <= 1 ? 'disabled' : ''}"><a class="page-link" href="?page=${currentPage - 1}<c:if test='${not empty keyword}'>&keyword=${keyword}</c:if><c:if test='${categoryId != null}'>&categoryId=${categoryId}</c:if><c:if test='${status != null}'>&status=${status}</c:if><c:if test='${param.merchantId != null}'>&merchantId=${param.merchantId}</c:if>">上一页</a></li>
<c:forEach begin="1" end="${totalPages}" var="i">
<li class="page-item ${currentPage == i ? 'active' : ''}"><a class="page-link" href="?page=${i}<c:if test='${not empty keyword}'>&keyword=${keyword}</c:if><c:if test='${categoryId != null}'>&categoryId=${categoryId}</c:if><c:if test='${status != null}'>&status=${status}</c:if><c:if test='${param.merchantId != null}'>&merchantId=${param.merchantId}</c:if>">${i}</a></li>
</c:forEach>
<li class="page-item ${currentPage >= totalPages ? 'disabled' : ''}"><a class="page-link" href="?page=${currentPage + 1}<c:if test='${not empty keyword}'>&keyword=${keyword}</c:if><c:if test='${categoryId != null}'>&categoryId=${categoryId}</c:if><c:if test='${status != null}'>&status=${status}</c:if><c:if test='${param.merchantId != null}'>&merchantId=${param.merchantId}</c:if>">下一页</a></li>
</ul></nav></c:if>
</div></div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script>$(document).on('click','.delete-btn',function(){if(confirm('确定删除？')){$.post($(this).data('url'),function(r){if(r.success)location.reload();});}});</script>
</body></html>