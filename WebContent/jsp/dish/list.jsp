<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="../common/header.jsp">
    <jsp:param name="title" value="菜品列表"/>
</jsp:include>
<div class="container mt-4">
    <div class="row">
        <div class="col-md-3">
            <div class="card border-0 shadow-sm mb-3">
                <div class="card-header bg-white fw-bold">菜品分类</div>
                <div class="list-group list-group-flush">
                    <a href="${pageContext.request.contextPath}/dish/list" class="list-group-item list-group-item-action ${categoryId == null ? 'active' : ''}">全部分类</a>
                    <c:forEach items="${categories}" var="cat"><a href="${pageContext.request.contextPath}/dish/list?categoryId=${cat.categoryId}" class="list-group-item list-group-item-action ${categoryId == cat.categoryId ? 'active' : ''}">${cat.categoryName}</a></c:forEach>
                </div>
            </div>
        </div>
        <div class="col-md-9">
            <form class="mb-3" method="get" action="${pageContext.request.contextPath}/dish/list"><div class="input-group"><input type="text" class="form-control" name="keyword" value="${keyword}" placeholder="搜索菜品名称..."><button class="btn btn-primary"><i class="fas fa-search"></i></button></div></form>
            <div class="row g-4">
                <c:forEach items="${dishes}" var="dish">
                    <div class="col-md-4 col-6">
                        <div class="card dish-card h-100 border-0 shadow-sm">
                            <a href="${pageContext.request.contextPath}/dish/detail?id=${dish.dishId}" class="text-decoration-none">
                                <img src="${pageContext.request.contextPath}/${dish.imageUrl}" class="card-img-top" style="height:180px;object-fit:cover;">
                                <div class="card-body"><h6 class="card-title fw-bold text-dark">${dish.dishName}</h6><div><c:choose><c:when test="${dish.specialPrice != null}"><span class="text-primary fw-bold">&#165;${dish.specialPrice}</span><span class="text-decoration-line-through text-muted small">&#165;${dish.price}</span></c:when><c:otherwise><span class="text-primary fw-bold">&#165;${dish.price}</span></c:otherwise></c:choose></div></div>
                            </a>
                            <div class="card-footer bg-transparent border-0 pb-3"><button class="btn btn-primary btn-sm w-100 add-to-cart-btn" data-dish-id="${dish.dishId}"><i class="fas fa-cart-plus me-1"></i>加入购物车</button></div>
                        </div>
                    </div>
                </c:forEach>
            </div>
            <c:if test="${totalPages > 1}"><nav class="mt-4"><ul class="pagination justify-content-center"><c:forEach begin="1" end="${totalPages}" var="i"><li class="page-item ${i == currentPage ? 'active' : ''}"><a class="page-link" href="${pageContext.request.contextPath}/dish/list?page=${i}&keyword=${keyword}&categoryId=${categoryId}">${i}</a></li></c:forEach></ul></nav></c:if>
        </div>
    </div>
</div>
<jsp:include page="../common/footer.jsp"/>
