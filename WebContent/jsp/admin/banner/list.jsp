<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html><html lang="zh-CN"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>轮播管理</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"><link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"><link href="${pageContext.request.contextPath}/css/custom.css" rel="stylesheet">
<style>
.upload-area{border:2px dashed #ddd;border-radius:10px;padding:20px;text-align:center;cursor:pointer;transition:all .3s;position:relative;overflow:hidden}
.upload-area:hover{border-color:#FF7800;background:#fff8f0}
.upload-area input[type=file]{position:absolute;top:0;left:0;width:100%;height:100%;opacity:0;cursor:pointer}
.upload-area img{max-width:100%;max-height:120px;border-radius:8px;display:none}
.upload-placeholder{color:#999;font-size:13px}
</style>
</head>
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
<div class="col-md-5">
    <label class="form-label">上传图片 *</label>
    <div class="upload-area" id="uploadArea">
        <input type="file" id="bFile" accept="image/*" onchange="previewImage(this)">
        <img id="uploadPreview">
        <div class="upload-placeholder" id="uploadPlaceholder"><i class="fas fa-cloud-upload-alt fa-2x mb-1"></i><br>点击或拖拽上传图片</div>
    </div>
    <input type="hidden" id="bImageUrl">
    <small class="text-muted">支持 jpg/png/gif，最大 10MB</small>
</div>
<div class="col-md-1"></div>
<div class="col-md-2"><label class="form-label">排序</label><input type="number" class="form-control" id="bSortOrder" value="0"></div>
<div class="col-md-2"><label class="form-label">状态</label><select class="form-select" id="bStatus"><option value="1">启用</option><option value="0">禁用</option></select></div>
<div class="col-md-2 d-flex align-items-end"><button class="btn btn-success w-100" onclick="saveBanner()"><i class="fas fa-save me-1"></i>保存</button></div>
</div>
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
<td><img src="${pageContext.request.contextPath}/${b.imageUrl}" style="width:120px;height:50px;object-fit:cover;border-radius:6px;" onerror="this.style.display='none'"></td>
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
function showAddForm(){document.getElementById('bannerForm').style.display='block';document.getElementById('formTitle').textContent='添加轮播';resetForm();}
function resetForm(){document.getElementById('editBannerId').value='';document.getElementById('bTitle').value='';document.getElementById('bSubtitle').value='';document.getElementById('bImageUrl').value='';document.getElementById('bLinkUrl').value='';document.getElementById('bSortOrder').value='0';document.getElementById('bStatus').value='1';document.getElementById('uploadPreview').style.display='none';document.getElementById('uploadPlaceholder').style.display='';}
function editBanner(id,title,sub,img,link,sort,status){showAddForm();document.getElementById('formTitle').textContent='编辑轮播';document.getElementById('editBannerId').value=id;document.getElementById('bTitle').value=title;document.getElementById('bSubtitle').value=sub;document.getElementById('bImageUrl').value=img;document.getElementById('bLinkUrl').value=link;document.getElementById('bSortOrder').value=sort;document.getElementById('bStatus').value=status;if(img){var preview=document.getElementById('uploadPreview');preview.src='${pageContext.request.contextPath}/'+img;preview.style.display='block';document.getElementById('uploadPlaceholder').style.display='none';}}

// 图片预览 + 自动上传
function previewImage(input){
    if(input.files&&input.files[0]){
        var file=input.files[0];
        if(file.size>10*1024*1024){alert('文件不能超过10MB');return;}
        // 预览
        var reader=new FileReader();
        reader.onload=function(e){
            var preview=document.getElementById('uploadPreview');
            preview.src=e.target.result;
            preview.style.display='block';
            document.getElementById('uploadPlaceholder').style.display='none';
        };
        reader.readAsDataURL(file);
        // 自动上传
        var formData=new FormData();
        formData.append('file',file);
        $.ajax({url:'${pageContext.request.contextPath}/admin/upload',type:'POST',data:formData,processData:false,contentType:false,
            success:function(r){
                if(r.success){document.getElementById('bImageUrl').value=r.url;}
                else{alert(r.message||'上传失败');}
            },
            error:function(){alert('上传异常');}
        });
    }
}

function saveBanner(){
    var imageUrl=document.getElementById('bImageUrl').value;
    if(!imageUrl){alert('请先上传图片');return;}
    var id=document.getElementById('editBannerId').value;
    var data={title:$('#bTitle').val(),subtitle:$('#bSubtitle').val(),imageUrl:imageUrl,linkUrl:$('#bLinkUrl').val(),sortOrder:$('#bSortOrder').val(),status:$('#bStatus').val()};
    var url=id?'${pageContext.request.contextPath}/admin/banner/update':'${pageContext.request.contextPath}/admin/banner/save';
    if(id)data.bannerId=id;
    $.post(url,data,function(r){if(r.success)location.reload();else alert(r.message||'操作失败');},'json');
}
function deleteBanner(id){if(!confirm('确定删除？'))return;$.post('${pageContext.request.contextPath}/admin/banner/delete',{bannerId:id},function(r){if(r.success)location.reload();else alert('删除失败');},'json');}
</script>
</body></html>
