<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html><html lang="zh-CN"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>编辑分类</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"><link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"><link href="${pageContext.request.contextPath}/css/custom.css" rel="stylesheet"></head>
<body class="bg-light"><div class="d-flex"><jsp:include page="/jsp/common/admin-sidebar.jsp"/>
<div class="flex-grow-1 p-4"><h4 class="fw-bold mb-4">${category != null ? '编辑分类' : '添加分类'}</h4>
<div class="card border-0 shadow-sm" style="max-width:500px;"><div class="card-body">
<form method="post" action="${pageContext.request.contextPath}/admin/category/${category != null ? 'update' : 'save'}">
<input type="hidden" name="categoryId" value="${category != null ? category.categoryId : ''}">
<div class="mb-3"><label class="form-label">分类名称 *</label><input type="text" class="form-control" name="categoryName" value="${category != null ? category.categoryName : ''}" required></div>
<div class="mb-3"><label class="form-label">排序</label><input type="number" class="form-control" name="sortOrder" value="${category != null ? category.sortOrder : 0}"></div>
<button type="submit" class="btn btn-primary">保存</button><a href="${pageContext.request.contextPath}/admin/category" class="btn btn-secondary ms-2">返回</a>
</form></div></div></div></div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script></body></html>