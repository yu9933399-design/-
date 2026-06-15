<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html><html lang="zh-CN"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>编辑菜品</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.6.1/cropper.min.css" rel="stylesheet">
<link href="${pageContext.request.contextPath}/css/custom.css" rel="stylesheet">
<style>
.upload-area{border:2px dashed #ddd;border-radius:12px;padding:30px;text-align:center;cursor:pointer;transition:all .3s;background:#fafafa;position:relative}
.upload-area:hover{border-color:var(--primary);background:#fff8f0}
.upload-area.has-image{padding:10px}
.upload-placeholder{color:#999}
.upload-placeholder i{font-size:48px;margin-bottom:10px;display:block}
.preview-img{max-width:100%;max-height:300px;border-radius:8px;display:none}
.cropper-modal{position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,.7);z-index:9999;display:none;align-items:center;justify-content:center}
.cropper-modal.show{display:flex}
.cropper-container{background:#fff;border-radius:12px;padding:20px;max-width:700px;width:90%;max-height:90vh;overflow:auto}
.cropper-container img{max-height:60vh}
.btn-upload{position:absolute;top:10px;right:10px;z-index:10}
.image-actions{margin-top:10px;display:none}
.upload-loading{display:none;position:absolute;top:50%;left:50%;transform:translate(-50%,-50%)}
</style>
</head>
<body class="bg-light"><div class="d-flex"><jsp:include page="/jsp/common/admin-sidebar.jsp"/>
<div class="flex-grow-1 p-4"><h4 class="fw-bold mb-4">${dish != null ? '编辑菜品' : '添加菜品'}</h4>
<div class="card border-0 shadow-sm" style="max-width:800px;"><div class="card-body">
<form method="post" action="${pageContext.request.contextPath}/admin/dish/${dish != null ? 'update' : 'save'}" id="dishForm">
<input type="hidden" name="dishId" value="${dish != null ? dish.dishId : ''}">
<input type="hidden" name="imageUrl" id="imageUrl" value="${dish.imageUrl}">

<div class="mb-4">
    <label class="form-label fw-bold">菜品图片</label>
    <div class="upload-area" id="uploadArea" onclick="document.getElementById('fileInput').click()">
        <input type="file" id="fileInput" accept="image/*" style="display:none" onchange="handleFileSelect(event)">
        <div class="upload-placeholder" id="uploadPlaceholder">
            <i class="fas fa-cloud-upload-alt"></i>
            <p class="mb-0">点击上传菜品图片</p>
            <small class="text-muted">支持 jpg/png/gif/webp，最大5MB</small>
        </div>
        <img class="preview-img" id="previewImg">
        <div class="upload-loading" id="uploadLoading">
            <div class="spinner-border text-primary" role="status"></div>
        </div>
    </div>
    <div class="image-actions" id="imageActions">
        <button type="button" class="btn btn-outline-primary btn-sm me-2" onclick="document.getElementById('fileInput').click()">
            <i class="fas fa-exchange-alt me-1"></i>更换图片
        </button>
        <button type="button" class="btn btn-outline-danger btn-sm" onclick="removeImage()">
            <i class="fas fa-trash me-1"></i>删除图片
        </button>
        <button type="button" class="btn btn-outline-success btn-sm ms-2" onclick="openCropper()" id="cropBtn" style="display:none">
            <i class="fas fa-crop-alt me-1"></i>裁剪
        </button>
    </div>
</div>

<div class="row mb-3"><div class="col-md-6"><label class="form-label">菜品名称 *</label><input type="text" class="form-control" name="dishName" value="${dish.dishName}" required></div>
<div class="col-md-6"><label class="form-label">分类 *</label><select class="form-select" name="categoryId" required><c:forEach items="${categories}" var="cat"><option value="${cat.categoryId}" ${dish.categoryId == cat.categoryId ? 'selected' : ''}>${cat.categoryName}</option></c:forEach></select></div></div>
<div class="row mb-3"><div class="col-md-4"><label class="form-label">价格 *</label><input type="number" step="0.01" class="form-control" name="price" value="${dish.price}" required></div>
<div class="col-md-4"><label class="form-label">库存 *</label><input type="number" class="form-control" name="stock" value="${dish.stock}" required></div></div>
<div class="mb-3"><label class="form-label">描述</label><textarea class="form-control" name="description" rows="3">${dish.description}</textarea></div>
<div class="row mb-3"><div class="col-md-3"><label class="form-label">上架</label><select class="form-select" name="status"><option value="1" ${dish.status == 1 ? 'selected' : ''}>上架</option><option value="0" ${dish.status == 0 ? 'selected' : ''}>下架</option></select></div>
<div class="col-md-3"><label class="form-label">推荐</label><select class="form-select" name="isRecommend"><option value="1" ${dish.isRecommend == 1 ? 'selected' : ''}>推荐</option><option value="0" ${dish.isRecommend == 0 ? 'selected' : ''}>不推荐</option></select></div>
<div class="col-md-3"><label class="form-label">特价价格</label><input type="number" step="0.01" class="form-control" name="specialPrice" value="${dish.specialPrice}"></div>
<div class="col-md-3"><label class="form-label">特价结束</label><input type="datetime-local" class="form-control" name="specialEnd"></div></div>
<button type="submit" class="btn btn-primary"><i class="fas fa-save me-1"></i>保存</button><a href="${pageContext.request.contextPath}/admin/dish" class="btn btn-secondary ms-2">返回</a>
</form></div></div></div>

<div class="cropper-modal" id="cropperModal">
    <div class="cropper-container">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h5 class="mb-0"><i class="fas fa-crop-alt me-2"></i>裁剪图片</h5>
            <button type="button" class="btn-close" onclick="closeCropper()"></button>
        </div>
        <div><img id="cropperImage"></div>
        <div class="d-flex justify-content-end mt-3">
            <button type="button" class="btn btn-secondary me-2" onclick="closeCropper()">取消</button>
            <button type="button" class="btn btn-primary" onclick="applyCrop()"><i class="fas fa-check me-1"></i>确认裁剪</button>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.6.1/cropper.min.js"></script>
<script>
var cropper = null;
var currentFile = null;

var imageUrl = document.getElementById('imageUrl').value;
if (imageUrl) {
    var img = document.getElementById('previewImg');
    img.src = '${pageContext.request.contextPath}/' + imageUrl;
    img.style.display = 'block';
    document.getElementById('uploadPlaceholder').style.display = 'none';
    document.getElementById('imageActions').style.display = 'block';
    document.getElementById('uploadArea').classList.add('has-image');
    if (!imageUrl.startsWith('http')) {
        document.getElementById('cropBtn').style.display = 'inline-block';
    }
}

function handleFileSelect(e) {
    var file = e.target.files[0];
    if (!file) return;
    if (!file.type.startsWith('image/')) { alert('请选择图片文件'); return; }
    if (file.size > 5 * 1024 * 1024) { alert('图片不能超过5MB'); return; }
    currentFile = file;
    var reader = new FileReader();
    reader.onload = function(ev) {
        var img = document.getElementById('previewImg');
        img.src = ev.target.result;
        img.style.display = 'block';
        document.getElementById('uploadPlaceholder').style.display = 'none';
        document.getElementById('imageActions').style.display = 'block';
        document.getElementById('cropBtn').style.display = 'inline-block';
        document.getElementById('uploadArea').classList.add('has-image');
    };
    reader.readAsDataURL(file);
    uploadFile(file);
}

function uploadFile(file) {
    var formData = new FormData();
    formData.append('file', file);
    var loading = document.getElementById('uploadLoading');
    loading.style.display = 'block';
    var xhr = new XMLHttpRequest();
    xhr.open('POST', '${pageContext.request.contextPath}/admin/dish/upload', true);
    xhr.onload = function() {
        loading.style.display = 'none';
        if (xhr.status === 200) {
            var res = JSON.parse(xhr.responseText);
            if (res.success) {
                document.getElementById('imageUrl').value = res.url;
            } else {
                alert(res.error || '上传失败');
            }
        } else {
            alert('上传失败');
        }
    };
    xhr.onerror = function() { loading.style.display = 'none'; alert('网络错误'); };
    xhr.send(formData);
}

function removeImage() {
    if (!confirm('确定删除图片？')) return;
    document.getElementById('imageUrl').value = '';
    document.getElementById('previewImg').style.display = 'none';
    document.getElementById('previewImg').src = '';
    document.getElementById('uploadPlaceholder').style.display = 'block';
    document.getElementById('imageActions').style.display = 'none';
    document.getElementById('uploadArea').classList.remove('has-image');
    document.getElementById('fileInput').value = '';
    currentFile = null;
}

function openCropper() {
    var imgSrc = document.getElementById('previewImg').src;
    if (!imgSrc) return;
    var cropperImg = document.getElementById('cropperImage');
    cropperImg.src = imgSrc;
    document.getElementById('cropperModal').classList.add('show');
    if (cropper) cropper.destroy();
    cropper = new Cropper(cropperImg, {
        aspectRatio: 1,
        viewMode: 1,
        minCropBoxWidth: 100,
        minCropBoxHeight: 100,
        ready: function() {}
    });
}

function closeCropper() {
    document.getElementById('cropperModal').classList.remove('show');
    if (cropper) { cropper.destroy(); cropper = null; }
}

function applyCrop() {
    if (!cropper) return;
    var canvas = cropper.getCroppedCanvas({ width: 600, height: 600 });
    canvas.toBlob(function(blob) {
        var file = new File([blob], 'cropped.jpg', { type: 'image/jpeg' });
        currentFile = file;
        var reader = new FileReader();
        reader.onload = function(ev) {
            document.getElementById('previewImg').src = ev.target.result;
        };
        reader.readAsDataURL(file);
        uploadFile(file);
        closeCropper();
    }, 'image/jpeg', 0.9);
}

document.getElementById('dishForm').addEventListener('submit', function(e) {
    if (!document.getElementById('imageUrl').value) {
        e.preventDefault();
        alert('请先上传菜品图片');
    }
});
</script>
</body></html>
