<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="../common/header.jsp"><jsp:param name="title" value="所有商家"/></jsp:include>
<div class="container mt-4">
<h3 class="fw-bold mb-4"><i class="fas fa-store text-primary me-2"></i>所有商家</h3>
<c:choose>
<c:when test="${empty merchants}">
<div class="text-center py-5"><i class="fas fa-store fa-3x text-muted mb-3"></i><p class="text-muted">暂无商家入驻</p><a href="${pageContext.request.contextPath}/register?type=merchant" class="btn btn-primary">申请商家入驻</a></div>
</c:when>
<c:otherwise>
<div class="row g-4">
<c:forEach items="${merchants}" var="m">
<div class="col-md-4 col-lg-3">
<div class="card border-0 shadow-sm h-100" style="border-radius:12px;">
<div class="card-body text-center p-4">
<div class="rounded-circle bg-light d-inline-flex align-items-center justify-content-center mb-3" style="width:70px;height:70px;">
<i class="fas fa-store text-primary" style="font-size:28px;"></i>
</div>
<h5 class="fw-bold mb-1"><c:out value="${m.realName}"/></h5>
<p class="text-muted small mb-2"><i class="fas fa-user me-1"></i><c:out value="${m.username}"/></p>
<p class="text-muted small mb-3"><i class="fas fa-utensils me-1"></i>${dishCounts[m.userId]} 件商品</p>
<a href="${pageContext.request.contextPath}/merchant/store?id=${m.userId}" class="btn btn-primary btn-sm px-4"><i class="fas fa-door-open me-1"></i>进入店铺</a>
</div>
</div>
</div>
</c:forEach>
</div>
</c:otherwise>
</c:choose>
</div>
<jsp:include page="../common/footer.jsp"/>
