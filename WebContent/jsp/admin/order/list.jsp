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
<tbody><c:forEach items="${orders}" var="order"><tr>
<td>${order.orderNo}</td><td>${order.username}</td><td class="text-primary fw-bold">&#165;${order.totalAmount}</td>
<td><c:choose><c:when test="${order.orderStatus == 1 || order.orderStatus == 0}"><span class="badge bg-warning">待支付</span></c:when><c:when test="${order.orderStatus == 2}"><span class="badge bg-info">待接单</span></c:when><c:when test="${order.orderStatus == 4}"><span class="badge bg-primary">已接单</span></c:when><c:when test="${order.orderStatus == 5}"><span class="badge bg-primary">制作中</span></c:when><c:when test="${order.orderStatus == 6}"><span class="badge bg-success">配送中</span></c:when><c:when test="${order.orderStatus == 3 || order.orderStatus == 8}"><span class="badge bg-success">已完成</span></c:when><c:when test="${order.orderStatus == 9}"><span class="badge bg-secondary">已取消</span></c:when><c:otherwise><span class="badge bg-secondary">未知</span></c:otherwise></c:choose></td>
<td class="text-muted small">${order.createTime}</td>
<td>
<a href="${pageContext.request.contextPath}/admin/order/detail?id=${order.orderId}" class="btn btn-outline-primary btn-sm me-1">详情</a>
<c:if test="${sessionScope.user.role == 2}">
  <c:if test="${order.orderStatus == 2}">
    <button class="btn btn-success btn-sm me-1 order-action" data-order="${order.orderId}" data-action="accept">接单</button>
    <button class="btn btn-danger btn-sm me-1 order-action" data-order="${order.orderId}" data-action="reject" data-need-reason="true">拒单</button>
  </c:if>
  <c:if test="${order.orderStatus == 4}">
    <button class="btn btn-primary btn-sm me-1 order-action" data-order="${order.orderId}" data-action="startPreparing">开始制作</button>
    <button class="btn btn-danger btn-sm me-1 order-action" data-order="${order.orderId}" data-action="cancel" data-need-reason="true">取消</button>
  </c:if>
  <c:if test="${order.orderStatus == 5}">
    <button class="btn btn-success btn-sm me-1 order-action" data-order="${order.orderId}" data-action="deliver">出餐</button>
    <button class="btn btn-danger btn-sm me-1 order-action" data-order="${order.orderId}" data-action="cancel" data-need-reason="true">取消</button>
  </c:if>
</c:if>
<c:if test="${sessionScope.user.role == 1}">
  <c:if test="${order.orderStatus != 3 && order.orderStatus != 8 && order.orderStatus != 9}">
    <select class="form-select form-select-sm d-inline-block w-auto me-1 admin-status-select" data-order-id="${order.orderId}" style="width:auto;">
      <option value="1" ${order.orderStatus == 0 || order.orderStatus == 1 ? 'selected' : ''}>待支付</option>
      <option value="2" ${order.orderStatus == 2 ? 'selected' : ''}>待接单</option>
      <option value="4" ${order.orderStatus == 4 ? 'selected' : ''}>已接单</option>
      <option value="5" ${order.orderStatus == 5 ? 'selected' : ''}>制作中</option>
      <option value="6" ${order.orderStatus == 1 || order.orderStatus == 2 || order.orderStatus == 6 ? 'selected' : ''}>配送中</option>
      <option value="8" ${order.orderStatus == 3 || order.orderStatus == 8 ? 'selected' : ''}>已完成</option>
      <option value="9" ${order.orderStatus == 9 ? 'selected' : ''}>已取消</option>
    </select>
  </c:if>
</c:if>
</td></tr></c:forEach></tbody></table></div></div>
</div></div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script>
$(document).on('click', '.order-action', function(){
  var btn = $(this);
  var orderId = btn.data('order');
  var action = btn.data('action');
  var needReason = btn.data('need-reason');
  if (needReason) {
    var reason = prompt('请输入原因：');
    if (!reason) return;
    $.post('${pageContext.request.contextPath}/admin/order/status', {orderId: orderId, action: action, reason: reason}, function(r){
      if(r.success) location.reload(); else alert(r.message || '操作失败');
    });
  } else {
    if (!confirm('确定执行此操作？')) return;
    $.post('${pageContext.request.contextPath}/admin/order/status', {orderId: orderId, action: action}, function(r){
      if(r.success) location.reload(); else alert(r.message || '操作失败');
    });
  }
});
$(document).on('change', '.admin-status-select', function(){
  var select = $(this);
  var orderId = select.data('order-id');
  var status = select.val();
  var reason = prompt('请输入操作原因（必填）：');
  if (!reason) { location.reload(); return; }
  $.post('${pageContext.request.contextPath}/admin/order/status', {orderId: orderId, status: status, reason: reason}, function(r){
    if(r.success) location.reload(); else alert(r.message || '操作失败');
  });
});
</script>
</body></html>
