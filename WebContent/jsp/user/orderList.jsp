<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="../common/header.jsp"><jsp:param name="title" value="我的订单"/></jsp:include>
<div class="container mt-4">
<div class="d-flex justify-content-between align-items-center mb-4">
<h3 class="fw-bold"><i class="fas fa-list text-primary me-2"></i>我的订单</h3>
<form class="d-flex align-items-center gap-2" method="get" action="${pageContext.request.contextPath}/order/list">
<span class="text-muted" style="font-size:13px;">排序：</span>
<select class="form-select form-select-sm" name="sort" onchange="this.form.submit()" style="width:auto;">
<option value="default" ${empty sort || sort == 'default' ? 'selected' : ''}>默认排序</option>
<option value="time" ${sort == 'time' ? 'selected' : ''}>按时间排序</option>
</select>
</form>
</div>
<c:choose><c:when test="${empty orders}"><div class="text-center py-5"><i class="fas fa-clipboard-list fa-3x text-muted mb-3"></i><p class="text-muted">暂无订单</p><a href="${pageContext.request.contextPath}/" class="btn btn-primary">去点餐</a></div></c:when>
<c:otherwise><c:forEach items="${orders}" var="order"><div class="card border-0 shadow-sm mb-3">
<div class="card-header bg-white d-flex justify-content-between align-items-center flex-wrap"><span>订单号：${order.orderNo}</span><span class="text-muted">${order.createTime}</span>
<c:choose><c:when test="${order.orderStatus == 0 || order.orderStatus == 1}"><span class="badge bg-warning">待支付</span></c:when><c:when test="${order.orderStatus == 2}"><span class="badge bg-info">待接单</span></c:when><c:when test="${order.orderStatus == 4}"><span class="badge bg-primary">已接单</span></c:when><c:when test="${order.orderStatus == 5}"><span class="badge bg-primary">制作中</span></c:when><c:when test="${order.orderStatus == 6}"><span class="badge bg-success">配送中</span></c:when><c:when test="${order.orderStatus == 3 || order.orderStatus == 8}"><span class="badge bg-success">已完成</span></c:when><c:when test="${order.orderStatus == 9}"><span class="badge bg-secondary">已取消</span></c:when></c:choose></div>
<div class="card-body"><div class="d-flex justify-content-between align-items-center"><span>共 &#165;${order.totalAmount} 元</span><a href="${pageContext.request.contextPath}/order/detail?id=${order.orderId}" class="btn btn-outline-primary btn-sm">查看详情</a></div></div>
</div></c:forEach>
<%-- 分页导航：总页数>1时显示，链接携带page/sort参数，刷新后保留当前页码和排序方式 --%>
<c:if test="${totalPages > 1}">
<nav class="mt-3"><ul class="pagination justify-content-center">
<li class="page-item ${currentPage <= 1 ? 'disabled' : ''}"><a class="page-link" href="${pageContext.request.contextPath}/order/list?page=${currentPage - 1}<c:if test='${sort != null && sort != "default"}'>&sort=${sort}</c:if>">上一页</a></li>
<c:forEach begin="1" end="${totalPages}" var="i">
<li class="page-item ${currentPage == i ? 'active' : ''}"><a class="page-link" href="${pageContext.request.contextPath}/order/list?page=${i}<c:if test='${sort != null && sort != "default"}'>&sort=${sort}</c:if>">${i}</a></li>
</c:forEach>
<li class="page-item ${currentPage >= totalPages ? 'disabled' : ''}"><a class="page-link" href="${pageContext.request.contextPath}/order/list?page=${currentPage + 1}<c:if test='${sort != null && sort != "default"}'>&sort=${sort}</c:if>">下一页</a></li>
</ul></nav></c:if>
</c:otherwise></c:choose></div>
<jsp:include page="../common/footer.jsp"/>
