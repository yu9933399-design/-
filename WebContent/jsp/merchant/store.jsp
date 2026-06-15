<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="../common/header.jsp"><jsp:param name="title" value="${merchant.realName} - 店铺"/></jsp:include>
<style>
    .store-header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 16px; padding: 30px; color: white; margin-bottom: 24px; }
    .dish-card { border: none; border-radius: 12px; transition: all 0.3s; }
    .dish-card:hover { transform: translateY(-3px); box-shadow: 0 8px 25px rgba(0,0,0,0.1); }
    .dish-card .card-img-top { height: 140px; object-fit: cover; border-radius: 12px 12px 0 0; }
    .price-tag { font-size: 18px; font-weight: 700; color: #e4393c; }
    .original-price { text-decoration: line-through; color: #999; font-size: 13px; }
</style>
<div class="container mt-4">
<div class="store-header">
<div class="d-flex align-items-center justify-content-between">
<div class="d-flex align-items-center">
<div class="rounded-circle bg-white d-flex align-items-center justify-content-center me-3" style="width:60px;height:60px;">
<i class="fas fa-store text-primary" style="font-size:24px;"></i>
</div>
<div>
<h3 class="fw-bold mb-1"><c:out value="${merchant.realName}"/></h3>
<p class="mb-0 opacity-75"><i class="fas fa-user me-1"></i><c:out value="${merchant.username}"/> | <i class="fas fa-phone ms-2 me-1"></i><c:out value="${merchant.phone}"/></p>
</div>
</div>
<c:if test="${sessionScope.user != null && sessionScope.user.role == 0}">
<a href="${pageContext.request.contextPath}/message/chat?userId=${merchant.userId}" class="btn btn-light">
<i class="fas fa-envelope me-2"></i>联系商家
</a>
</c:if>
</div>
</div>

<c:if test="${empty grouped}">
<div class="text-center py-5"><i class="fas fa-utensils fa-3x text-muted mb-3"></i><p class="text-muted">该商家暂无上架商品</p></div>
</c:if>

<c:forEach items="${categories}" var="cat">
<c:set var="dishes" value="${grouped[cat.categoryId]}"/>
<c:if test="${not empty dishes}">
<h5 class="fw-bold mt-4 mb-3"><i class="fas fa-tag text-primary me-2"></i><c:out value="${cat.categoryName}"/></h5>
<div class="row g-3">
<c:forEach items="${dishes}" var="d">
<div class="col-md-3 col-6">
<div class="card dish-card h-100">
<div class="card-img-top bg-light d-flex align-items-center justify-content-center" style="height:140px;">
<c:choose>
<c:when test="${not empty d.imageUrl}"><img src="${pageContext.request.contextPath}/${d.imageUrl}" class="w-100 h-100" style="object-fit:cover;"></c:when>
<c:otherwise><i class="fas fa-utensils fa-3x text-muted"></i></c:otherwise>
</c:choose>
</div>
<div class="card-body p-3">
<h6 class="fw-bold mb-1" style="font-size:14px;"><c:out value="${d.dishName}"/></h6>
<c:if test="${not empty d.description}"><p class="text-muted small mb-2" style="font-size:12px;"><c:out value="${d.description}"/></p></c:if>
<div class="d-flex align-items-center justify-content-between">
<div>
<c:if test="${d.specialPrice != null}">
<span class="price-tag">&#165;<fmt:formatNumber value="${d.specialPrice}" pattern="#,##0.00"/></span>
<span class="original-price ms-1">&#165;<fmt:formatNumber value="${d.price}" pattern="#,##0.00"/></span>
</c:if>
<c:if test="${d.specialPrice == null}">
<span class="price-tag">&#165;<fmt:formatNumber value="${d.price}" pattern="#,##0.00"/></span>
</c:if>
</div>
<button class="btn btn-primary btn-sm add-to-cart-btn" data-dish-id="${d.dishId}"><i class="fas fa-cart-plus"></i></button>
</div>
</div>
</div>
</div>
</c:forEach>
</div>
</c:if>
</c:forEach>
</div>
<jsp:include page="../common/footer.jsp"/>
