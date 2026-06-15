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
<p>支付方式：${order.paymentMethod}</p><p>总金额：<strong class="text-primary">&#165;${order.totalAmount}</strong></p>
<p>订单状态：<c:choose><c:when test="${order.orderStatus == 0 || order.orderStatus == 1}"><span class="badge bg-warning">待支付</span></c:when><c:when test="${order.orderStatus == 2}"><span class="badge bg-info">待接单</span></c:when><c:when test="${order.orderStatus == 4}"><span class="badge bg-primary">已接单</span></c:when><c:when test="${order.orderStatus == 5}"><span class="badge bg-primary">制作中</span></c:when><c:when test="${order.orderStatus == 6}"><span class="badge bg-success">配送中</span></c:when><c:when test="${order.orderStatus == 3 || order.orderStatus == 8}"><span class="badge bg-success">已完成</span></c:when><c:when test="${order.orderStatus == 9}"><span class="badge bg-secondary">已取消</span></c:when><c:otherwise><span class="badge bg-secondary">未知</span></c:otherwise></c:choose></p>
<c:if test="${order.orderStatus == 9 && not empty order.cancelReason}"><p class="text-danger">取消原因：<c:out value="${order.cancelReason}"/></p></c:if>
</div></div>
<c:if test="${not empty items}"><div class="card border-0 shadow-sm"><div class="card-header bg-white fw-bold">商品明细</div><div class="card-body">
<table class="table"><thead><tr><th>商品</th><th>单价</th><th>数量</th><th>小计</th></tr></thead>
<tbody><c:forEach items="${items}" var="item"><tr><td><c:out value="${item.dishName}"/></td><td>&#165;${item.price}</td><td>${item.quantity}</td><td class="text-primary fw-bold">&#165;${item.subtotal}</td></tr></c:forEach></tbody></table></div></div></c:if>

<c:if test="${sessionScope.user.role == 1 && not empty logs}">
<div class="card border-0 shadow-sm mb-3"><div class="card-header bg-white fw-bold"><i class="fas fa-history me-2"></i>操作日志</div><div class="card-body">
<table class="table table-sm"><thead><tr><th>时间</th><th>操作人</th><th>角色</th><th>变更</th><th>原因</th></tr></thead>
<tbody><c:forEach items="${logs}" var="log"><tr>
<td class="small">${log.createTime}</td>
<td><c:out value="${log.operatorName}"/></td>
<td><c:choose><c:when test="${log.operatorRole == 1}">管理员</c:when><c:when test="${log.operatorRole == 2}">商家</c:when><c:otherwise>用户</c:otherwise></c:choose></td>
<td><span class="badge bg-secondary">${log.fromStatus}</span> → <span class="badge bg-primary">${log.toStatus}</span></td>
<td><c:out value="${log.reason}" default="-"/></td>
</tr></c:forEach></tbody></table></div></div>
</c:if>

<c:if test="${order.orderStatus == 6}">
<div class="card border-0 shadow-sm mb-3"><div class="card-header bg-white fw-bold"><i class="fas fa-truck me-2"></i>配送信息</div><div class="card-body">
<p>配送状态：<c:choose><c:when test="${order.deliveryStatus == 1}"><span class="badge bg-info">配送中</span></c:when><c:when test="${order.deliveryStatus == 2}"><span class="badge bg-success">已送达</span></c:when><c:otherwise><span class="badge bg-warning">待配送</span></c:otherwise></c:choose></p>
<p>当前位置：<c:out value="${order.deliveryPosition}" default="暂无"/></p>
<c:if test="${order.deliveryStatus != 2 && (sessionScope.user.role == 1 || sessionScope.user.role == 2)}">
<div class="mt-3">
<div class="mb-2"><label class="form-label">配送状态</label>
<select class="form-select form-select-sm" id="dlStatusInput" style="width:auto;">
<option value="0" ${order.deliveryStatus == 0 ? 'selected' : ''}>待配送</option>
<option value="1" ${order.deliveryStatus == 1 ? 'selected' : ''}>配送中</option>
<option value="2" ${order.deliveryStatus == 2 ? 'selected' : ''}>已送达</option>
</select></div>
<div class="mb-2"><label class="form-label">位置描述</label>
<input type="text" class="form-control form-control-sm" id="dlPositionInput" value="<c:out value="${order.deliveryPosition}" default=""/>" placeholder="例如：骑手已取餐，正在送往目的地"></div>
<button class="btn btn-primary btn-sm" onclick="updateDelivery(${order.orderId})">更新配送信息</button>
</div>
</c:if>
</div></div>
</c:if>
</c:if>
<a href="${pageContext.request.contextPath}/admin/order" class="btn btn-secondary mt-3">返回列表</a></div></div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script>
function updateDelivery(orderId) {
    var status = $('#dlStatusInput').val();
    var position = $('#dlPositionInput').val().trim();
    if (status == '1' && !position) { alert('配送中必须填写位置描述'); return; }
    if (status == '2' && !confirm('确定标记为已送达？标记后不可修改')) return;
    $.post('${pageContext.request.contextPath}/delivery/update', {orderId: orderId, deliveryStatus: status, deliveryPosition: position}, function(r) {
        if (r.success) { location.reload(); } else { alert(r.message || '更新失败'); }
    }, 'json');
}
</script>
</body></html>
