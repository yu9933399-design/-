<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html><html lang="zh-CN"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>轮播管理</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"><link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"><link href="${pageContext.request.contextPath}/css/custom.css" rel="stylesheet"></head>
<body class="bg-light"><div class="d-flex"><jsp:include page="/jsp/common/admin-sidebar.jsp"/>
<div class="flex-grow-1 p-4">
<h4 class="fw-bold mb-4"><i class="fas fa-images me-2 text-warning"></i>首页轮播管理</h4>

<!-- 添加按钮 -->
<button class="btn btn-primary mb-3" onclick="showAddForm()"><i class="fas fa-plus me-1"></i>添加轮播</button>

<!-- 添加/编辑表单 -->
<div id="bannerForm" class="card border-0 shadow-sm mb-4" style="display:none;">
<div class="card-header bg-white fw-bold"><span id="formTitle">添加轮播</span></div>
<div class="card-body">
<input type="hidden" id="editBannerId">
<div class="row g-3">
<div class="col-md-4"><label class="form-label">标题</label><input type="text" class="form-control" id="bTitle" placeholder="如：新店开业 满100减30"></div>
<div class="col-md-4"><label class="form-label">副标题</label><input type="text" class="form-control" id="bSubtitle" placeholder="如：精选好店入驻"></div>
<div class="col-md-4"><label class="form-label">跳转链接（可留空）</label><input type="text" class="form-control" id="bLinkUrl" placeholder="如：/merchant/list"></div>
<div class="col-md-6"><label class="form-label">图片地址 *</label><input type="text" class="form-control" id="bImageUrl" placeholder="如：/images/banner1.jpg"></div>
<div class="col-md-2"><label class="form-label">排序</label><input type="number" class="form-control" id="bSortOrder" value="0"></div>
<div class="col-md-2"><label class="form-label">状态</label><select class="form-select" id="bStatus"><option value="1">启用</option><option value="0">禁用</option></select></div>
<div class="col-md-2 d-flex align-items-end"><button class="btn btn-success w-100" onclick="saveBanner()">保存</button></div>
</div>
<div class="mt-2"><small class="text-muted">图片可放在 WebContent/images/ 目录下，地址填相对路径如 /images/banner1.jpg</small></div>
</div>
</div>

<!-- 列表 -->
<div class="card border-0 shadow-sm"><div class="card-body">
<c:choose>
<c:when test="${empty banners}"><div class="text-center py-4 text-muted">暂无轮播图</div></c:when>
<c:otherwise>
<table class="table table-hover align-middle">
<thead class="table-light"><tr><th>预览</th><th>标题</th><th>副标题</th><th>链接</th><th>排序</th><th>状态</th><th>操作</th></tr></thead>
<tbody>
<c:forEach items="${banners}" var="b">
<tr>
<td><img src="${pageContext.request.contextPath}/${b.imageUrl}" style="width:120px;height:50px;object-fit:cover;border-radius:6px;"></td>
<td><c:out value="${b.title}"/></td>
<td class="text-muted"><c:out value="${b.subtitle}"/></td>
<td class="text-muted small"><c:out value="${b.linkUrl}" default="无"/></td>
<td>${b.sortOrder}</td>
<td><span class="badge ${b.status==1?'bg-success':'bg-secondary'}">${b.status==1?'启用':'禁用'}</span></td>
<td>
<button class="btn btn-outline-primary btn-sm me-1" onclick='editBanner(${b.bannerId},"<c:out value="${b.title}"/>","<c:out value="${b.subtitle}"/>","<c:out value="${b.imageUrl}"/>","<c:out value="${b.linkUrl}"/>",${b.sortOrder},${b.status})'><i class="fas fa-edit"></i></button>
<button class="btn btn-outline-danger btn-sm" onclick="deleteBanner(${b.bannerId})"><i class="fas fa-trash"></i></button>
</td>
</tr>
</c:forEach>
</tbody></table>
</c:otherwise>
</c:choose>
</div></div>
</div></div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script>
function showAddForm(){document.getElementById('bannerForm').style.display='block';document.getElementById('formTitle').textContent='添加轮播';document.getElementById('editBannerId').value='';document.getElementById('bTitle').value='';document.getElementById('bSubtitle').value='';document.getElementById('bImageUrl').value='';document.getElementById('bLinkUrl').value='';document.getElementById('bSortOrder').value='0';document.getElementById('bStatus').value='1';}
function editBanner(id,title,sub,img,link,sort,status){showAddForm();document.getElementById('formTitle').textContent='编辑轮播';document.getElementById('editBannerId').value=id;document.getElementById('bTitle').value=title;document.getElementById('bSubtitle').value=sub;document.getElementById('bImageUrl').value=img;document.getElementById('bLinkUrl').value=link;document.getElementById('bSortOrder').value=sort;document.getElementById('bStatus').value=status;}
function saveBanner(){var id=document.getElementById('editBannerId').value;var data={title:$('#bTitle').val(),subtitle:$('#bSubtitle').val(),imageUrl:$('#bImageUrl').val(),linkUrl:$('#bLinkUrl').val(),sortOrder:$('#bSortOrder').val(),status:$('#bStatus').val()};if(!data.imageUrl){alert('请填写图片地址');return;}var url=id?'${pageContext.request.contextPath}/admin/banner/update':'${pageContext.request.contextPath}/admin/banner/save';if(id)data.bannerId=id;$.post(url,data,function(r){if(r.success)location.reload();else alert(r.message||'操作失败');},'json');}
function deleteBanner(id){if(!confirm('确定删除？'))return;$.post('${pageContext.request.contextPath}/admin/banner/delete',{bannerId:id},function(r){if(r.success)location.reload();else alert('删除失败');},'json');}
</script>
</body></html>
