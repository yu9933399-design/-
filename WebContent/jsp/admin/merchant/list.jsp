<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html><html lang="zh-CN"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>商家管理</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"><link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"><link href="${pageContext.request.contextPath}/css/custom.css" rel="stylesheet"></head>
<body class="bg-light"><div class="d-flex"><jsp:include page="/jsp/common/admin-sidebar.jsp"/>
<div class="flex-grow-1 p-4">
<h4 class="fw-bold mb-4"><i class="fas fa-store me-2 text-info"></i>商家管理</h4>
<c:choose>
<c:when test="${empty merchants}">
<div class="text-center py-5"><p class="text-muted">暂无入驻商家</p></div>
</c:when>
<c:otherwise>
<div class="row g-3">
<c:forEach items="${merchants}" var="m">
<div class="col-md-4">
<div class="card border-0 shadow-sm h-100">
<div class="card-body d-flex align-items-center p-3">
<div class="rounded-circle bg-light d-flex align-items-center justify-content-center me-3" style="width:50px;height:50px;flex-shrink:0;"><i class="fas fa-store text-info"></i></div>
<div class="flex-grow-1">
<h6 class="fw-bold mb-0"><c:out value="${m.realName}"/></h6>
<small class="text-muted"><c:out value="${m.username}"/></small>
<div class="mt-1">
<select class="form-select form-select-sm shop-cat-select" data-uid="${m.userId}" style="width:auto;font-size:12px;">
<option value="">未分类</option>
<option value="快餐简餐" ${m.shopCategory == '快餐简餐' ? 'selected' : ''}>快餐简餐</option>
<option value="奶茶饮品" ${m.shopCategory == '奶茶饮品' ? 'selected' : ''}>奶茶饮品</option>
<option value="川湘辣味" ${m.shopCategory == '川湘辣味' ? 'selected' : ''}>川湘辣味</option>
<option value="粤菜海鲜" ${m.shopCategory == '粤菜海鲜' ? 'selected' : ''}>粤菜海鲜</option>
<option value="甜品小吃" ${m.shopCategory == '甜品小吃' ? 'selected' : ''}>甜品小吃</option>
<option value="早餐早点" ${m.shopCategory == '早餐早点' ? 'selected' : ''}>早餐早点</option>
<option value="面食粥品" ${m.shopCategory == '面食粥品' ? 'selected' : ''}>面食粥品</option>
<option value="轻食沙拉" ${m.shopCategory == '轻食沙拉' ? 'selected' : ''}>轻食沙拉</option>
</select>
</div>
</div>
<a href="${pageContext.request.contextPath}/admin/merchant/detail?id=${m.userId}" class="btn btn-outline-primary btn-sm"><i class="fas fa-search me-1"></i>查看</a>
</div>
</div>
</div>
</c:forEach>
</div>
</c:otherwise>
</c:choose>
<c:if test="${totalPages > 1}">
<nav class="mt-3"><ul class="pagination justify-content-center">
<li class="page-item ${currentPage <= 1 ? 'disabled' : ''}"><a class="page-link" href="${pageContext.request.contextPath}/admin/merchant?page=${currentPage - 1}">上一页</a></li>
<c:forEach begin="1" end="${totalPages}" var="i">
<li class="page-item ${currentPage == i ? 'active' : ''}"><a class="page-link" href="${pageContext.request.contextPath}/admin/merchant?page=${i}">${i}</a></li>
</c:forEach>
<li class="page-item ${currentPage >= totalPages ? 'disabled' : ''}"><a class="page-link" href="${pageContext.request.contextPath}/admin/merchant?page=${currentPage + 1}">下一页</a></li>
</ul></nav></c:if>
</div></div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script>
$(document).on('change','.shop-cat-select',function(){
    var uid=$(this).data('uid'),cat=$(this).val();
    $.post('${pageContext.request.contextPath}/admin/merchant/updateCategory',{userId:uid,shopCategory:cat},function(r){
        if(!r.success) alert(r.message||'设置失败');
    },'json');
});
</script>
</body></html>
