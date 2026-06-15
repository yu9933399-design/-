<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="../common/header.jsp"><jsp:param name="title" value="菜品详情"/></jsp:include>
<div class="container mt-4">
<c:if test="${dish != null}">
<div class="row"><div class="col-md-5"><img src="${pageContext.request.contextPath}/${dish.imageUrl}" class="rounded shadow" style="width:100%;object-fit:cover;"></div>
<div class="col-md-7"><h2 class="fw-bold"><c:out value="${dish.dishName}"/></h2>
<c:if test="${dish.merchantName != null}"><p class="text-muted mb-1"><i class="fas fa-store me-1"></i><c:out value="${dish.merchantName}"/></p></c:if>
<p class="text-muted"><c:out value="${dish.description}"/></p>
<div class="mb-3"><c:choose><c:when test="${dish.specialPrice != null}"><span class="text-primary fw-bold fs-3">&#165;${dish.specialPrice}</span><span class="text-decoration-line-through text-muted ms-2">&#165;${dish.price}</span></c:when><c:otherwise><span class="text-primary fw-bold fs-3">&#165;${dish.price}</span></c:otherwise></c:choose></div>
<p>库存：${dish.stock} 份</p>
<button class="btn btn-primary btn-lg px-5 add-to-cart-btn" data-dish-id="${dish.dishId}"><i class="fas fa-cart-plus me-2"></i>加入购物车</button>
</div></div>
</c:if></div>
<jsp:include page="../common/footer.jsp"/>