<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html><html lang="zh-CN"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>商家详情</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"><link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"><link href="${pageContext.request.contextPath}/css/custom.css" rel="stylesheet"></head>
<body class="bg-light"><div class="d-flex"><jsp:include page="/jsp/common/admin-sidebar.jsp"/>
<div class="flex-grow-1 p-4">
<div class="d-flex align-items-center mb-4">
<a href="${pageContext.request.contextPath}/admin/merchant" class="btn btn-outline-secondary btn-sm me-3"><i class="fas fa-arrow-left me-1"></i>返回</a>
<div class="rounded-circle bg-info d-flex align-items-center justify-content-center me-3" style="width:50px;height:50px;"><i class="fas fa-store text-white"></i></div>
<div><h4 class="fw-bold mb-0"><c:out value="${merchant.realName}"/></h4>
<small class="text-muted"><i class="fas fa-user me-1"></i><c:out value="${merchant.username}"/> | <i class="fas fa-phone ms-2 me-1"></i><c:out value="${merchant.phone}"/></small></div>
</div>

<ul class="nav nav-tabs mb-3" id="merchantTab">
<li class="nav-item"><a class="nav-link active" href="#" data-target="dishes" onclick="switchTab(event,this)"><i class="fas fa-utensils me-1"></i>菜品管理（${dishes.size()}）</a></li>
<li class="nav-item"><a class="nav-link" href="#" data-target="orders" onclick="switchTab(event,this)"><i class="fas fa-receipt me-1"></i>订单管理（${orders.size()}）</a></li>
</ul>

<div id="tabDishes">
<div class="card border-0 shadow-sm"><div class="card-body">
<div class="d-flex justify-content-between align-items-center mb-2"><span class="text-muted">共 ${dishes.size()} 个菜品，鼠标悬停可查看详情</span></div>
<table class="table table-hover align-middle"><thead class="table-light"><tr><th>菜品名</th><th>价格</th><th>分类</th><th>库存</th><th>状态</th><th>操作</th></tr></thead>
<tbody>
<c:forEach items="${dishes}" var="d"><tr><td><c:out value="${d.dishName}"/></td><td class="text-primary fw-bold">&#165;<fmt:formatNumber value="${d.price}" pattern="#,##0.00"/></td><td><c:out value="${d.categoryName}"/></td><td>${d.stock}</td>
<td><span class="badge ${d.status == 1 ? 'bg-success' : 'bg-secondary'}">${d.status == 1 ? '上架' : '下架'}</span></td>
<td><button class="btn btn-outline-danger btn-sm" onclick="if(confirm('确定下架该菜品？'))$.post('${pageContext.request.contextPath}/admin/merchant/deleteDish',{id:${d.dishId}},function(r){if(r.success)location.reload();})"><i class="fas fa-times me-1"></i>下架</button></td></tr></c:forEach>
</tbody></table></div></div>
</div>

<div id="tabOrders" style="display:none;">
<div class="card border-0 shadow-sm"><div class="card-body">
<table class="table table-hover align-middle"><thead class="table-light"><tr><th>订单号</th><th>用户</th><th>金额</th><th>状态</th><th>时间</th><th>操作</th></tr></thead>
<tbody>
<c:forEach items="${orders}" var="o"><tr><td>${o.orderNo}</td><td><c:out value="${o.username}"/></td><td class="text-primary fw-bold">&#165;<fmt:formatNumber value="${o.totalAmount}" pattern="#,##0.00"/></td>
<td><c:choose><c:when test="${o.orderStatus == 0 || o.orderStatus == 1}"><span class="badge bg-warning">待支付</span></c:when><c:when test="${o.orderStatus == 2}"><span class="badge bg-info">待接单</span></c:when><c:when test="${o.orderStatus == 4}"><span class="badge bg-primary">已接单</span></c:when><c:when test="${o.orderStatus == 5}"><span class="badge bg-primary">制作中</span></c:when><c:when test="${o.orderStatus == 6}"><span class="badge bg-success">配送中</span></c:when><c:when test="${o.orderStatus == 3 || o.orderStatus == 8}"><span class="badge bg-success">已完成</span></c:when><c:when test="${o.orderStatus == 9}"><span class="badge bg-secondary">已取消</span></c:when><c:otherwise><span class="badge bg-secondary">未知</span></c:otherwise></c:choose></td>
<td class="text-muted small">${o.createTime}</td>
<td><a href="${pageContext.request.contextPath}/admin/order/detail?id=${o.orderId}" class="btn btn-outline-primary btn-sm">详情</a></td></tr></c:forEach>
</tbody></table></div></div>
</div>

</div></div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script>
function switchTab(e,el){
    e.preventDefault();
    document.querySelectorAll('#merchantTab .nav-link').forEach(function(t){t.classList.remove('active');});
    el.classList.add('active');
    document.getElementById('tabDishes').style.display='none';
    document.getElementById('tabOrders').style.display='none';
    document.getElementById('tab'+el.getAttribute('data-target').replace(/^./,function(c){return c.toUpperCase();})).style.display='';
}
</script>
</body></html>
