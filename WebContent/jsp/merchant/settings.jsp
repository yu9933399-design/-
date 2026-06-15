<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>店铺设置 - 商家后台</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/custom.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="d-flex">
    <jsp:include page="/jsp/common/admin-sidebar.jsp"/>
    <div class="flex-grow-1">
        <nav class="navbar navbar-light bg-white shadow-sm">
            <div class="container-fluid">
                <span class="navbar-brand fw-bold"><i class="fas fa-cog text-primary me-2"></i>店铺设置</span>
                <span class="text-muted">欢迎，${sessionScope.user.username}</span>
            </div>
        </nav>
        <div class="p-4">
            <div class="row justify-content-center">
                <div class="col-md-6">
                    <div class="card border-0 shadow-sm">
                        <div class="card-header bg-white fw-bold">店铺信息</div>
                        <div class="card-body">
                            <c:if test="${error != null}"><div class="alert alert-danger">${error}</div></c:if>
                            <c:if test="${success != null}"><div class="alert alert-success">${success}</div></c:if>

                            <div class="mb-3">
                                <label class="form-label">店铺名称</label>
                                <input type="text" class="form-control" id="realName" value="<c:out value='${merchant.realName}'/>">
                            </div>
                            <div class="mb-3">
                                <label class="form-label">联系电话</label>
                                <input type="text" class="form-control" id="phone" value="<c:out value='${merchant.phone}'/>">
                            </div>
                            <div class="mb-3">
                                <label class="form-label">店铺分类 <span class="text-danger">*</span></label>
                                <select class="form-select" id="shopCategory">
                                    <option value="">请选择分类（影响首页分类筛选展示）</option>
                                    <c:forEach items="${allCategories}" var="cat">
                                    <option value="${cat}" ${merchant.shopCategory == cat ? 'selected' : ''}>${cat}</option>
                                    </c:forEach>
                                </select>
                                <small class="text-muted">选择分类后，用户在首页通过该分类可以找到您的店铺</small>
                            </div>
                            <button class="btn btn-primary px-4" onclick="saveSettings()"><i class="fas fa-save me-1"></i>保存设置</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script>
function saveSettings() {
    var data = {
        realName: $('#realName').val().trim(),
        phone: $('#phone').val().trim(),
        shopCategory: $('#shopCategory').val()
    };
    if (!data.shopCategory) { alert('请选择店铺分类'); return; }
    $.post('${pageContext.request.contextPath}/merchant/settings', data, function(r) {
        if (r.success) {
            alert('保存成功');
        } else {
            alert(r.message || '保存失败');
        }
    }, 'json');
}
</script>
</body>
</html>
