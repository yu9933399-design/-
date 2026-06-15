<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="../common/header.jsp"><jsp:param name="title" value="我的订单"/></jsp:include>
<div class="container mt-4">
<h3 class="fw-bold mb-4"><i class="fas fa-list text-primary me-2"></i>我的订单</h3>
<c:choose><c:when test="${empty orders}"><div class="text-center py-5"><i class="fas fa-clipboard-list fa-3x text-muted mb-3"></i><p class="text-muted">暂无订单</p><a href="${pageContext.request.contextPath}/dish/list" class="btn btn-primary">去点餐</a></div></c:when>
<c:otherwise><c:forEach items="${orders}" var="order"><div class="card border-0 shadow-sm mb-3">
<div class="card-header bg-white d-flex justify-content-between align-items-center flex-wrap"><span>订单号：${order.orderNo}</span><span class="text-muted">${order.createTime}</span>
<c:choose><c:when test="${order.orderStatus == 0}"><span class="badge bg-warning">待支付</span></c:when><c:when test="${order.orderStatus == 1}"><span class="badge bg-primary">配送中</span></c:when><c:when test="${order.orderStatus == 2}"><span class="badge bg-primary">配送中</span></c:when><c:when test="${order.orderStatus == 3}"><span class="badge bg-success">已完成</span></c:when></c:choose></div>
<div class="card-body"><div class="d-flex justify-content-between align-items-center"><span>共 &#165;${order.totalAmount} 元</span><a href="${pageContext.request.contextPath}/order/detail?id=${order.orderId}" class="btn btn-outline-primary btn-sm">查看详情</a></div></div>
</div></c:forEach></c:otherwise></c:choose></div>
<jsp:include page="../common/footer.jsp"/>