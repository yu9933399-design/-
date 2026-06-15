<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="../common/header.jsp"><jsp:param name="title" value="购物车"/></jsp:include>
<div class="container mt-4">
<h3 class="fw-bold mb-4"><i class="fas fa-shopping-cart text-primary me-2"></i>我的购物车</h3>
<c:choose>
<c:when test="${empty cartItems}"><div class="text-center py-5"><i class="fas fa-shopping-cart fa-3x text-muted mb-3"></i><p class="text-muted">购物车还是空的哦~</p><a href="${pageContext.request.contextPath}/" class="btn btn-primary">去点餐</a></div></c:when>
<c:otherwise>
<div class="card border-0 shadow-sm"><div class="card-body"><table class="table table-hover align-middle">
<thead class="table-light"><tr><th>商品</th><th>单价</th><th>数量</th><th>小计</th><th>操作</th></tr></thead>
<tbody><c:forEach items="${cartItems}" var="item"><tr data-price="${item.price}">
<td><div class="d-flex align-items-center"><img src="${pageContext.request.contextPath}/${item.imageUrl}" class="rounded me-3" style="width:60px;height:60px;object-fit:cover;"><span class="fw-bold">${item.dishName}</span></div></td>
<td class="text-primary fw-bold item-price">&#165;<fmt:formatNumber value="${item.price}" pattern="#,##0.00"/></td>
<td><div class="input-group" style="width:120px;"><button class="btn btn-outline-secondary btn-sm qty-minus" data-cart-id="${item.cartId}">-</button><input type="text" class="form-control form-control-sm text-center qty-input" value="${item.quantity}" data-cart-id="${item.cartId}" readonly><button class="btn btn-outline-secondary btn-sm qty-plus" data-cart-id="${item.cartId}">+</button></div></td>
<td class="text-primary fw-bold subtotal">&#165;<fmt:formatNumber value="${item.price * item.quantity}" pattern="#,##0.00"/></td>
<td><button class="btn btn-outline-danger btn-sm remove-item" data-cart-id="${item.cartId}"><i class="fas fa-trash"></i></button></td>
</tr></c:forEach></tbody></table></div></div>
<div class="card border-0 shadow-sm mt-3"><div class="card-body d-flex justify-content-between align-items-center"><span>商品总额：<strong class="text-primary cart-total">&#165;<fmt:formatNumber value="${total}" pattern="#,##0.00"/></strong></span><a href="${pageContext.request.contextPath}/order/checkout" class="btn btn-primary btn-lg px-5">去结算</a></div></div>
</c:otherwise></c:choose></div>
<script>
$(function(){
    recalcCartTotal();
    function recalcCartTotal(){
        var total=0;
        $('tbody tr').each(function(){
            var tr=$(this);
            var p=parseFloat(tr.attr('data-price'));
            var q=parseInt(tr.find('.qty-input').val());
            if(!isNaN(p)&&!isNaN(q)){total+=p*q;}
        });
        $('.cart-total').text('\u00a5'+total.toFixed(2));
    }
});
</script>
<jsp:include page="../common/footer.jsp"/>