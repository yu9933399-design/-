<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="../common/header.jsp"><jsp:param name="title" value="结算"/></jsp:include>
<div class="container mt-4">
<h3 class="fw-bold mb-4"><i class="fas fa-credit-card text-primary me-2"></i>确认订单</h3>
<c:if test="${error != null}"><div class="alert alert-danger">${error}</div></c:if>
<form method="post" action="${pageContext.request.contextPath}/order/submit">
<c:if test="${shopId != null}"><input type="hidden" name="shopId" value="${shopId}"/></c:if>
<div class="row"><div class="col-md-8">
<div class="card border-0 shadow-sm mb-3"><div class="card-header bg-white fw-bold">收货信息</div><div class="card-body">
<div class="row mb-3"><div class="col-md-6"><label class="form-label">收货人姓名 *</label><input type="text" class="form-control" name="receiverName" value="${user.realName}" required></div><div class="col-md-6"><label class="form-label">手机号码 *</label><input type="text" class="form-control" name="receiverPhone" value="${user.phone}" required></div></div>
<div class="mb-3"><label class="form-label">收货地址 *</label><textarea class="form-control" name="receiverAddress" rows="2" required>${user.address}</textarea></div>
</div></div>
<div class="card border-0 shadow-sm mb-3"><div class="card-header bg-white fw-bold">支付方式</div><div class="card-body">
<div class="form-check mb-2"><input class="form-check-input" type="radio" name="paymentMethod" value="微信支付" id="wechat" checked><label class="form-check-label" for="wechat"><i class="fab fa-weixin text-success me-2"></i>微信支付</label></div>
<div class="form-check"><input class="form-check-input" type="radio" name="paymentMethod" value="支付宝支付" id="alipay"><label class="form-check-label" for="alipay"><i class="fab fa-alipay text-primary me-2"></i>支付宝支付</label></div>
</div></div>
</div><div class="col-md-4"><div class="card border-0 shadow-sm"><div class="card-header bg-white fw-bold">订单摘要</div><div class="card-body">
<c:forEach items="${cartItems}" var="item"><div class="d-flex justify-content-between mb-1"><span class="text-muted">${item.dishName} x${item.quantity}</span><span>&#165;${item.price * item.quantity}</span></div></c:forEach>
<hr><div class="d-flex justify-content-between"><strong>总计：</strong><strong class="text-primary">&#165;${total}</strong></div>
<button type="submit" class="btn btn-primary w-100 py-2 mt-3">提交订单</button>
</div></div></div></div>
</form></div>
<script>
document.querySelector('form').addEventListener('submit',function(){
    var btn=document.querySelector('button[type="submit"]');
    btn.disabled=true;
    btn.textContent='提交中...';
});
</script>
<jsp:include page="../common/footer.jsp"/>