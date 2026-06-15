<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="common/header.jsp"><jsp:param name="title" value="首页"/></jsp:include>
<div class="container mt-4">
    <div id="heroCarousel" class="carousel slide rounded-4 overflow-hidden shadow mb-5" data-bs-ride="carousel">
        <div class="carousel-inner">
            <div class="carousel-item active" style="height:400px;"><div class="d-flex h-100 align-items-center justify-content-center text-white" style="background:linear-gradient(135deg,#ff7a00,#e66000);"><div class="text-center"><h1 class="display-4 fw-bold">美味生活 · 从这里开始</h1><p class="lead mb-4">精选食材 用心烹饪</p><a href="${pageContext.request.contextPath}/dish/list" class="btn btn-light btn-lg px-5">立即点餐</a></div></div></div>
            <div class="carousel-item" style="height:400px;"><div class="d-flex h-100 align-items-center justify-content-center text-white" style="background:linear-gradient(135deg,#28a745,#218838);"><div class="text-center"><h1 class="display-4 fw-bold">新鲜食材 健康美味</h1><p class="lead mb-4">每日精选 品质保证</p><a href="${pageContext.request.contextPath}/dish/list" class="btn btn-light btn-lg px-5">查看菜品</a></div></div></div>
            <div class="carousel-item" style="height:400px;"><div class="d-flex h-100 align-items-center justify-content-center text-white" style="background:linear-gradient(135deg,#dc3545,#c82333);"><div class="text-center"><h1 class="display-4 fw-bold">限时特价 优惠多多</h1><p class="lead mb-4">精选菜品 限时折扣</p><a href="${pageContext.request.contextPath}/dish/list" class="btn btn-light btn-lg px-5">抢购优惠</a></div></div></div>
        </div>
        <button class="carousel-control-prev" type="button" data-bs-target="#heroCarousel" data-bs-slide="prev"><span class="carousel-control-prev-icon"></span></button>
        <button class="carousel-control-next" type="button" data-bs-target="#heroCarousel" data-bs-slide="next"><span class="carousel-control-next-icon"></span></button>
    </div>
    <c:forEach items="${recommendMap}" var="entry">
        <div class="mb-5">
            <div class="d-flex justify-content-between align-items-center mb-4"><h3 class="fw-bold"><i class="fas fa-fire text-primary me-2"></i>${categoryService.getById(entry.key).categoryName}</h3><a href="${pageContext.request.contextPath}/dish/list?categoryId=${entry.key}" class="text-primary text-decoration-none">查看更多 <i class="fas fa-angle-right"></i></a></div>
            <div class="row g-4">
                <c:forEach items="${entry.value}" var="dish">
                    <div class="col-lg-3 col-md-6 col-6"><div class="card dish-card h-100 border-0 shadow-sm"><a href="${pageContext.request.contextPath}/dish/detail?id=${dish.dishId}" class="text-decoration-none"><div class="position-relative"><img src="${pageContext.request.contextPath}/${dish.imageUrl}" class="card-img-top" style="height:200px;object-fit:cover;" alt="${dish.dishName}"><c:if test="${dish.specialPrice != null}"><span class="badge bg-primary position-absolute top-0 end-0 m-2">特价</span></c:if></div><div class="card-body"><h5 class="card-title fw-bold text-dark">${dish.dishName}</h5><div><c:choose><c:when test="${dish.specialPrice != null}"><span class="text-primary fw-bold fs-5">&#165;${dish.specialPrice}</span><span class="text-decoration-line-through text-muted ms-2">&#165;${dish.price}</span></c:when><c:otherwise><span class="text-primary fw-bold fs-5">&#165;${dish.price}</span></c:otherwise></c:choose></div></div></a><div class="card-footer bg-transparent border-0 pb-3"><button class="btn btn-primary w-100 add-to-cart-btn" data-dish-id="${dish.dishId}"><i class="fas fa-cart-plus me-1"></i>加入购物车</button></div></div></div>
                </c:forEach>
            </div>
        </div>
    </c:forEach>
</div>
<jsp:include page="common/footer.jsp"/>