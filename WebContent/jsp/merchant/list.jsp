<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="../common/header.jsp"><jsp:param name="title" value="所有商家"/></jsp:include>

<style>
.filter-bar{display:flex;gap:10px;flex-wrap:wrap;margin-bottom:24px;padding:16px 0;border-bottom:1px solid #eee}
.filter-tag{padding:8px 20px;border-radius:20px;font-size:14px;border:1.5px solid #ddd;color:#666;cursor:pointer;text-decoration:none;transition:all .2s;background:#fff}
.filter-tag:hover{border-color:#FF7800;color:#FF7800}
.filter-tag.active{background:#FF7800;color:#fff;border-color:#FF7800}
.filter-tag.clear{border-style:dashed;color:#999}
.filter-tag.clear:hover{border-color:#FF7800;color:#FF7800}
</style>

<div class="container mt-4">
<h3 class="fw-bold mb-3"><i class="fas fa-store text-primary me-2"></i>所有商家</h3>

<!-- 分类筛选栏 -->
<div class="filter-bar">
    <a href="${pageContext.request.contextPath}/merchant/list" class="filter-tag ${empty selectedCategory ? 'active' : ''}">全部</a>
    <c:forEach items="${allCategories}" var="cat">
    <a href="${pageContext.request.contextPath}/merchant/list?category=${cat}" class="filter-tag ${selectedCategory == cat ? 'active' : ''}">${cat}</a>
    </c:forEach>
</div>

<c:choose>
<c:when test="${empty merchants}">
<div class="text-center py-5">
    <i class="fas fa-store fa-3x text-muted mb-3"></i>
    <p class="text-muted mb-2">暂无该分类商家，切换其他分类查看</p>
    <a href="${pageContext.request.contextPath}/merchant/list" class="btn btn-outline-primary btn-sm">查看全部商家</a>
</div>
</c:when>
<c:otherwise>
<div class="row g-4">
<c:forEach items="${merchants}" var="m">
<div class="col-md-4 col-lg-3">
<div class="card border-0 shadow-sm h-100" style="border-radius:12px;transition:all .3s;">
<div class="card-body text-center p-4">
<div class="rounded-circle bg-light d-inline-flex align-items-center justify-content-center mb-3" style="width:70px;height:70px;">
<i class="fas fa-store text-primary" style="font-size:28px;"></i>
</div>
<h5 class="fw-bold mb-1"><c:out value="${m.realName}"/></h5>
<p class="text-muted small mb-1"><i class="fas fa-user me-1"></i><c:out value="${m.username}"/></p>
<c:if test="${not empty m.shopCategory}">
<p class="small mb-2" style="color:#FF7800;"><i class="fas fa-tag me-1"></i><c:out value="${m.shopCategory}"/></p>
</c:if>
<p class="text-muted small mb-3"><i class="fas fa-utensils me-1"></i>${dishCounts[m.userId]} 件商品</p>
<a href="${pageContext.request.contextPath}/merchant/store?id=${m.userId}" class="btn btn-primary btn-sm px-4"><i class="fas fa-door-open me-1"></i>进入店铺</a>
</div>
</div>
</div>
</c:forEach>
</div>
</c:otherwise>
</c:choose>
<%-- 分页导航：总页数>1时显示，链接携带page/category参数，刷新后保留当前页码和分类筛选 --%>
<c:if test="${totalPages > 1}">
<nav class="mt-3"><ul class="pagination justify-content-center">
<li class="page-item ${currentPage <= 1 ? 'disabled' : ''}"><a class="page-link" href="${pageContext.request.contextPath}/merchant/list?page=${currentPage - 1}<c:if test='${not empty selectedCategory}'>&category=${selectedCategory}</c:if>">上一页</a></li>
<c:forEach begin="1" end="${totalPages}" var="i">
<li class="page-item ${currentPage == i ? 'active' : ''}"><a class="page-link" href="${pageContext.request.contextPath}/merchant/list?page=${i}<c:if test='${not empty selectedCategory}'>&category=${selectedCategory}</c:if>">${i}</a></li>
</c:forEach>
<li class="page-item ${currentPage >= totalPages ? 'disabled' : ''}"><a class="page-link" href="${pageContext.request.contextPath}/merchant/list?page=${currentPage + 1}<c:if test='${not empty selectedCategory}'>&category=${selectedCategory}</c:if>">下一页</a></li>
</ul></nav></c:if>
</div>

<style>.card:hover{transform:translateY(-4px);box-shadow:0 8px 25px rgba(0,0,0,.1)!important}</style>
<jsp:include page="../common/footer.jsp"/>
