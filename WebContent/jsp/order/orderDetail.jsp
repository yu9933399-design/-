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
<p>订单状态：<c:choose><c:when test="${order.orderStatus == 0 || order.orderStatus == 1}"><span class="badge bg-warning">待支付</span></c:when><c:when test="${order.orderStatus == 2}"><span class="badge bg-info">待接单</span></c:when><c:when test="${order.orderStatus == 4}"><span class="badge bg-primary">已接单</span></c:when><c:when test="${order.orderStatus == 5}"><span class="badge bg-primary">制作中</span></c:when><c:when test="${order.orderStatus == 6}"><span class="badge bg-success">配送中</span></c:when><c:when test="${order.orderStatus == 3 || order.orderStatus == 8}"><span class="badge bg-success">已完成</span></c:when><c:when test="${order.orderStatus == 9}"><span class="badge bg-secondary">已取消</span></c:when><c:otherwise><span class="badge bg-secondary">未知</span></c:otherwise></c:choose></p>
<c:if test="${order.orderStatus == 9 && not empty order.cancelReason}"><p class="text-danger">取消原因：<c:out value="${order.cancelReason}"/></p></c:if>
</div></div>
<c:if test="${not empty items}"><div class="card border-0 shadow-sm"><div class="card-header bg-white fw-bold">商品明细</div><div class="card-body"><table class="table"><thead><tr><th>商品</th><th>单价</th><th>数量</th><th>小计</th></tr></thead>
<tbody><c:forEach items="${items}" var="item"><tr><td><c:out value="${item.dishName}"/></td><td>&#165;${item.price}</td><td>${item.quantity}</td><td class="text-primary fw-bold">&#165;${item.subtotal}</td></tr></c:forEach></tbody></table>
<div class="text-end"><strong>总计：<span class="text-primary fs-5">&#165;${order.totalAmount}</span></strong></div></div></div></c:if>

<c:if test="${order.orderStatus == 0 || order.orderStatus == 1}">
<a href="${pageContext.request.contextPath}/order/pay?id=${order.orderId}" class="btn btn-success mt-3 me-2"><i class="fas fa-qrcode me-1"></i>去支付</a>
</c:if>

<c:if test="${order.orderStatus == 4 && canDirectCancel}">
<form action="${pageContext.request.contextPath}/order/confirm" method="post" style="display:inline;">
    <input type="hidden" name="orderId" value="${order.orderId}"/>
    <input type="hidden" name="action" value="cancel"/>
    <input type="hidden" name="reason" value="用户主动取消"/>
    <button type="submit" class="btn btn-outline-danger mt-3 me-2" onclick="return confirm('确定取消订单？')"><i class="fas fa-times me-1"></i>取消订单</button>
</form>
</c:if>

<c:if test="${order.orderStatus == 6}">
<form action="${pageContext.request.contextPath}/order/confirm" method="post" style="display:inline;">
    <input type="hidden" name="orderId" value="${order.orderId}"/>
    <input type="hidden" name="action" value="confirmReceive"/>
    <button type="submit" class="btn btn-success mt-3 me-2" onclick="return confirm('确认已收到商品？')"><i class="fas fa-check-double me-1"></i>确认收货</button>
</form>
</c:if>

<c:if test="${order.orderStatus == 6}">
<button class="btn btn-outline-info mt-3 me-2" onclick="queryDelivery(${order.orderId})"><i class="fas fa-truck me-1"></i>查看配送位置</button>
</c:if>

<a href="${pageContext.request.contextPath}/order/list" class="btn btn-secondary mt-3">返回订单列表</a>
</c:if></div>

<!-- 配送信息弹窗 -->
<div class="modal fade" id="deliveryModal" tabindex="-1"><div class="modal-dialog"><div class="modal-content">
<div class="modal-header"><h5 class="modal-title"><i class="fas fa-truck me-2"></i>配送信息</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
<div class="modal-body">
<p><strong>配送状态：</strong><span id="dlStatus" class="badge bg-info"></span></p>
<p><strong>当前位置：</strong><span id="dlPosition"></span></p>
</div>
<div class="modal-footer"><button type="button" class="btn btn-secondary" data-bs-dismiss="modal">关闭</button></div>
</div></div></div>

<jsp:include page="../common/footer.jsp"/>
<script>
function queryDelivery(orderId) {
    $.get('${pageContext.request.contextPath}/delivery/query', {orderId: orderId}, function(r) {
        if (r.success) {
            $('#dlStatus').text(r.deliveryStatusText);
            $('#dlPosition').text(r.deliveryPosition);
            new bootstrap.Modal(document.getElementById('deliveryModal')).show();
        } else {
            alert(r.message || '查询失败');
        }
    }, 'json');
}
</script>
