<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html><html lang="zh-CN"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>分类管理</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"><link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"><link href="${pageContext.request.contextPath}/css/custom.css" rel="stylesheet"></head>
<body class="bg-light"><div class="d-flex"><jsp:include page="/jsp/common/admin-sidebar.jsp"/>
<div class="flex-grow-1 p-4">
<div class="d-flex justify-content-between align-items-center mb-4"><h4 class="fw-bold">分类管理</h4><a href="${pageContext.request.contextPath}/admin/category/add" class="btn btn-primary"><i class="fas fa-plus me-1"></i>添加分类</a></div>
<div class="card border-0 shadow-sm"><div class="card-body"><table class="table table-hover align-middle">
<thead class="table-light"><tr><th>ID</th><th>分类名称</th><th>菜品数量</th><th>排序</th><th>操作</th></tr></thead>
<tbody><c:forEach items="${categories}" var="cat"><tr><td>${cat.categoryId}</td><td><a href="${pageContext.request.contextPath}/admin/dish?categoryId=${cat.categoryId}"><c:out value="${cat.categoryName}"/></a></td><td><span class="badge bg-info">${dishCounts[cat.categoryId]}</span></td><td>${cat.sortOrder}</td>
<td><a href="${pageContext.request.contextPath}/admin/category/edit?id=${cat.categoryId}" class="btn btn-outline-primary btn-sm me-1">编辑</a><button class="btn btn-outline-danger btn-sm delete-btn" data-url="${pageContext.request.contextPath}/admin/category/delete?id=${cat.categoryId}">删除</button></td></tr></c:forEach></tbody></table></div></div>
</div></div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script>$(document).on('click','.delete-btn',function(){if(confirm('确定删除？')){$.post($(this).data('url'),function(r){if(r.success)location.reload();});}});</script>
</body></html>