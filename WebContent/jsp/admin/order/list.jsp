<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html><html lang="zh-CN"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>订单管理</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"><link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"><link href="${pageContext.request.contextPath}/css/custom.css" rel="stylesheet"></head>
<body class="bg-light"><div class="d-flex"><jsp:include page="/jsp/common/admin-sidebar.jsp"/>
<div class="flex-grow-1 p-4"><h4 class="fw-bold mb-4"><i class="fas fa-receipt me-2 text-warning"></i><c:choose><c:when test="${sessionScope.user.role == 1}">商家订单（平台监管）</c:when><c:otherwise>我的订单</c:otherwise></c:choose></h4>
<c:if test="${sessionScope.user.role == 1 && not empty merchants}">
<form class="row g-2 mb-3" method="get" action="${pageContext.request.contextPath}/admin/order"><div class="col-auto"><select class="form-select" name="merchantId" onchange="this.form.submit()"><option value="">所有商家</option><c:forEach items="${merchants}" var="m"><option value="${m.userId}" ${param.merchantId == m.userId.toString() ? 'selected' : ''}><c:out value="${m.realName}"/></option></c:forEach></select></div></form>
</c:if>
<div class="card border-0 shadow-sm"><div class="card-body"><table class="table table-hover align-middle">
<thead class="table-light"><tr><th>订单号</th><th>用户</th><th>金额</th><th>状态</th><th>时间</th><th>操作</th></tr></thead>
<tbody><c:forEach items="${orders}" var="order"><tr><td>${order.orderNo}</td><td>${order.username}</td><td class="text-primary fw-bold">&#165;${order.totalAmount}</td>
<td><select class="form-select form-select-sm order-status" data-order-id="${order.orderId}" style="width:auto;"><option value="0" ${order.orderStatus == 0 ? 'selected' : ''}>待支付</option><option value="1" ${order.orderStatus == 1 ? 'selected' : ''}>已支付</option><option value="2" ${order.orderStatus == 2 ? 'selected' : ''}>配送中</option><option value="3" ${order.orderStatus == 3 ? 'selected' : ''}>已完成</option></select></td>
<td class="text-muted small">${order.createTime}</td><td><a href="${pageContext.request.contextPath}/admin/order/detail?id=${order.orderId}" class="btn btn-outline-primary btn-sm">详情</a></td></tr></c:forEach></tbody></table></div></div>
</div></div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script>$(document).on('change','.order-status',function(){$.post('${pageContext.request.contextPath}/admin/order/status',{orderId:$(this).data('order-id'),status:$(this).val()});});</script>
</body></html>