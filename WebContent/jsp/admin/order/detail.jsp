<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html><html lang="zh-CN"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>订单详情</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"><link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"><link href="${pageContext.request.contextPath}/css/custom.css" rel="stylesheet"></head>
<body class="bg-light"><div class="d-flex"><jsp:include page="/jsp/common/admin-sidebar.jsp"/>
<div class="flex-grow-1 p-4"><h4 class="fw-bold mb-4">订单详情</h4>
<c:if test="${order != null}">
<div class="card border-0 shadow-sm mb-3"><div class="card-header bg-white fw-bold">订单信息</div><div class="card-body">
<div class="row"><div class="col-md-6"><p>订单号：${order.orderNo}</p><p>下单时间：${order.createTime}</p></div>
<div class="col-md-6"><p>收货人：${order.receiverName} ${order.receiverPhone}</p><p>地址：${order.receiverAddress}</p></div></div>
<p>支付方式：${order.paymentMethod}</p><p>总金额：<strong class="text-primary">&#165;${order.totalAmount}</strong></p></div></div>
<c:if test="${not empty items}"><div class="card border-0 shadow-sm"><div class="card-header bg-white fw-bold">商品明细</div><div class="card-body">
<table class="table"><thead><tr><th>商品</th><th>单价</th><th>数量</th><th>小计</th></tr></thead>
<tbody><c:forEach items="${items}" var="item"><tr><td><c:out value="${item.dishName}"/></td><td>&#165;${item.price}</td><td>${item.quantity}</td><td class="text-primary fw-bold">&#165;${item.subtotal}</td></tr></c:forEach></tbody></table></div></div></c:if></c:if>
<a href="${pageContext.request.contextPath}/admin/order" class="btn btn-secondary mt-3">返回列表</a></div></div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script></body></html>