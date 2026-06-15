<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="../common/header.jsp"><jsp:param name="title" value="订单详情"/></jsp:include>
<div class="container mt-4">
<c:if test="${success != null}"><div class="alert alert-success"><c:out value="${success}"/></div></c:if>
<c:if test="${error != null}"><div class="alert alert-danger"><c:out value="${error}"/></div></c:if>
<c:if test="${order != null}">
<div class="card border-0 shadow-sm mb-3"><div class="card-header bg-white fw-bold">订单信息</div><div class="card-body">
<div class="row"><div class="col-md-6"><p>订单号：${order.orderNo}</p><p>下单时间：${order.createTime}</p></div>
<div class="col-md-6"><p>收货人：<c:out value="${order.receiverName}"/> <c:out value="${order.receiverPhone}"/></p><p>地址：<c:out value="${order.receiverAddress}"/></p></div></div>
<p>支付方式：<c:out value="${order.paymentMethod}"/></p>
<p>订单状态：<c:choose><c:when test="${order.orderStatus == 0}"><span class="badge bg-warning">待支付</span></c:when><c:when test="${order.orderStatus == 1}"><span class="badge bg-primary">配送中</span></c:when><c:when test="${order.orderStatus == 2}"><span class="badge bg-primary">配送中</span></c:when><c:when test="${order.orderStatus == 3}"><span class="badge bg-success">已完成</span></c:when></c:choose></p>
</div></div>
<c:if test="${not empty items}"><div class="card border-0 shadow-sm"><div class="card-header bg-white fw-bold">商品明细</div><div class="card-body"><table class="table"><thead><tr><th>商品</th><th>单价</th><th>数量</th><th>小计</th></tr></thead>
<tbody><c:forEach items="${items}" var="item"><tr><td><c:out value="${item.dishName}"/></td><td>&#165;${item.price}</td><td>${item.quantity}</td><td class="text-primary fw-bold">&#165;${item.subtotal}</td></tr></c:forEach></tbody></table>
<div class="text-end"><strong>总计：<span class="text-primary fs-5">&#165;${order.totalAmount}</span></strong></div></div></div></c:if>
<c:if test="${order.orderStatus == 0}">
<a href="${pageContext.request.contextPath}/order/pay?id=${order.orderId}" class="btn btn-success mt-3 me-2"><i class="fas fa-qrcode me-1"></i>去支付</a>
</c:if>
<c:if test="${order.orderStatus == 1 || order.orderStatus == 2}">
<form action="${pageContext.request.contextPath}/order/confirm" method="post" style="display:inline;">
    <input type="hidden" name="orderId" value="${order.orderId}"/>
    <button type="submit" class="btn btn-success mt-3 me-2" onclick="return confirm('确认已收到商品？')"><i class="fas fa-check-double me-1"></i>确认收货</button>
</form>
</c:if>
<a href="${pageContext.request.contextPath}/order/list" class="btn btn-secondary mt-3">返回订单列表</a>
</c:if></div>
<jsp:include page="../common/footer.jsp"/>