<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="common/header.jsp"><jsp:param name="title" value="首页"/></jsp:include>

<style>
/* ========== 首页全局样式 ========== */
/* 主色调变量 */
:root{--orange:#FF7800;--orange-dark:#e66c00;--purple:#9944FF;--text:#333;--text-secondary:#666;--bg:#f5f5f5}

/* ========== 轮播Banner ========== */
.hero-banner{width:100%;height:260px;position:relative;overflow:hidden;background:#000}
.hero-banner .slide{width:100%;height:260px;display:none;position:relative}
.hero-banner .slide.active{display:block}
.hero-banner .slide-bg{width:100%;height:100%;display:flex;align-items:center;justify-content:center;color:#fff}
.hero-banner .slide-content{text-align:center;z-index:2}
.hero-banner .slide-content h2{font-size:32px;font-weight:700;margin-bottom:10px;text-shadow:0 2px 8px rgba(0,0,0,.3)}
.hero-banner .slide-content p{font-size:16px;margin-bottom:16px;opacity:.9}
.hero-banner .slide-content .btn-banner{display:inline-block;padding:10px 32px;background:#fff;color:var(--orange);border-radius:24px;font-weight:600;text-decoration:none;transition:all .3s}
.hero-banner .slide-content .btn-banner:hover{background:var(--orange);color:#fff;transform:translateY(-2px)}
.hero-arrow{position:absolute;top:50%;transform:translateY(-50%);z-index:10;width:40px;height:40px;background:rgba(255,255,255,.85);border:none;border-radius:50%;font-size:18px;color:var(--orange);cursor:pointer;transition:all .3s;display:flex;align-items:center;justify-content:center}
.hero-arrow:hover{background:var(--orange);color:#fff}
.hero-arrow.prev{left:16px}
.hero-arrow.next{right:16px}
.hero-dots{position:absolute;bottom:14px;left:50%;transform:translateX(-50%);display:flex;gap:8px;z-index:10}
.hero-dots .dot{width:10px;height:10px;border-radius:50%;background:rgba(255,255,255,.5);cursor:pointer;transition:all .3s}
.hero-dots .dot.active{background:#fff;width:28px;border-radius:5px}

/* ========== 快捷分类区 ========== */
.section-title{font-size:22px;font-weight:700;color:var(--text);margin-bottom:20px;padding-left:12px;border-left:4px solid var(--orange)}
.category-scroll{display:flex;gap:16px;overflow-x:auto;padding:8px 0 16px;scrollbar-width:none;-ms-overflow-style:none;cursor:grab}
.category-scroll::-webkit-scrollbar{display:none}
.category-card{flex:0 0 120px;text-align:center;padding:20px 12px;background:#fff;border-radius:12px;border:2px solid transparent;transition:all .3s;cursor:pointer;box-shadow:0 2px 8px rgba(0,0,0,.05)}
.category-card:hover{border-color:var(--orange);transform:translateY(-4px);box-shadow:0 6px 20px rgba(255,120,0,.15)}
.category-card .cat-icon{font-size:36px;margin-bottom:8px}
.category-card .cat-name{font-size:14px;font-weight:600;color:var(--text)}

/* ========== 热门商家 ========== */
.merchant-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:20px}
.merchant-card{background:#fff;border-radius:12px;padding:24px 20px;text-align:center;box-shadow:0 2px 12px rgba(0,0,0,.06);transition:all .3s;border:1px solid #f0f0f0}
.merchant-card:hover{transform:translateY(-6px);box-shadow:0 8px 25px rgba(0,0,0,.1);border-color:var(--orange)}
.merchant-card .shop-icon{width:60px;height:60px;border-radius:50%;background:linear-gradient(135deg,var(--orange),#ffb347);display:flex;align-items:center;justify-content:center;margin:0 auto 14px;font-size:28px;color:#fff}
.merchant-card .shop-name{font-size:17px;font-weight:700;color:var(--text);margin-bottom:4px}
.merchant-card .shop-user{font-size:13px;color:var(--text-secondary);margin-bottom:6px}
.merchant-card .dish-count{font-size:13px;color:var(--text-secondary);margin-bottom:14px}
.merchant-card .btn-enter{display:inline-block;padding:8px 28px;background:var(--orange);color:#fff;border:none;border-radius:20px;font-size:14px;font-weight:600;cursor:pointer;transition:all .3s;text-decoration:none}
.merchant-card .btn-enter:hover{background:var(--orange-dark);transform:translateY(-2px)}

/* ========== 今日特惠 ========== */
.special-scroll{display:flex;gap:16px;overflow-x:auto;padding:8px 0 16px;scrollbar-width:none;cursor:grab}
.special-scroll::-webkit-scrollbar{display:none}
.special-card{flex:0 0 200px;background:#fff;border-radius:12px;overflow:hidden;box-shadow:0 2px 12px rgba(0,0,0,.06);transition:all .3s;border:1px solid #f0f0f0}
.special-card:hover{transform:translateY(-6px);box-shadow:0 8px 25px rgba(0,0,0,.1);border-color:var(--orange)}
.special-card img{width:100%;height:140px;object-fit:cover}
.special-card .card-body{padding:14px}
.special-card .dish-name{font-size:15px;font-weight:600;color:var(--text);margin-bottom:6px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.special-card .price-row{display:flex;align-items:baseline;gap:8px;margin-bottom:10px}
.special-card .price-now{font-size:20px;font-weight:700;color:var(--orange)}
.special-card .price-old{font-size:13px;color:#999;text-decoration:line-through}
.special-card .btn-cart{width:100%;padding:8px;background:var(--orange);color:#fff;border:none;border-radius:8px;font-size:13px;font-weight:600;cursor:pointer;transition:all .3s}
.special-card .btn-cart:hover{background:var(--orange-dark)}

/* ========== 响应式 ========== */
@media(max-width:992px){.merchant-grid{grid-template-columns:repeat(2,1fr)}}
@media(max-width:576px){.merchant-grid{grid-template-columns:1fr}.category-card{flex:0 0 90px}.special-card{flex:0 0 160px}}
</style>

<!-- ========== 全屏轮播Banner（从数据库加载） ========== -->
<div class="hero-banner" id="heroBanner">
    <c:choose>
    <c:when test="${not empty banners}">
    <c:forEach items="${banners}" var="b" varStatus="st">
    <div class="slide ${st.index == 0 ? 'active' : ''}">
        <div class="slide-bg" style="background:linear-gradient(135deg,#FF7800,#ffb347)">
            <c:choose>
            <c:when test="${not empty b.imageUrl}">
            <img src="${pageContext.request.contextPath}/${b.imageUrl}" style="width:100%;height:100%;object-fit:cover;position:absolute;top:0;left:0;">
            </c:when>
            <c:otherwise>
            <div class="slide-content">
                <h2><c:out value="${b.title}"/></h2>
                <p><c:out value="${b.subtitle}"/></p>
                <c:if test="${not empty b.linkUrl}"><a href="${pageContext.request.contextPath}${b.linkUrl}" class="btn-banner">查看详情</a></c:if>
            </div>
            </c:otherwise>
            </c:choose>
            <!-- 如果有标题，覆盖显示在图片上 -->
            <c:if test="${not empty b.imageUrl && not empty b.title}">
            <div class="slide-content" style="position:relative;z-index:2;">
                <h2><c:out value="${b.title}"/></h2>
                <p><c:out value="${b.subtitle}"/></p>
                <c:if test="${not empty b.linkUrl}"><a href="${pageContext.request.contextPath}${b.linkUrl}" class="btn-banner">查看详情</a></c:if>
            </div>
            </c:if>
        </div>
    </div>
    </c:forEach>
    </c:when>
    <c:otherwise>
    <!-- 默认 Banner -->
    <div class="slide active">
        <div class="slide-bg" style="background:linear-gradient(135deg,#FF7800,#ffb347)">
            <div class="slide-content"><h2>🎉 欢迎来到美食点餐系统</h2><p>精选好店，美味直达</p></div>
        </div>
    </div>
    </c:otherwise>
    </c:choose>
    <button class="hero-arrow prev" onclick="changeSlide(-1)"><i class="fas fa-chevron-left"></i></button>
    <button class="hero-arrow next" onclick="changeSlide(1)"><i class="fas fa-chevron-right"></i></button>
    <div class="hero-dots" id="heroDots"></div>
</div>

<div class="container mt-5">

<!-- ========== 快捷美食分类 ========== -->
<h3 class="section-title">快捷分类</h3>
<div class="category-scroll" id="categoryScroll">
    <div class="category-card" onclick="location.href='${pageContext.request.contextPath}/merchant/list?category=快餐简餐'"><div class="cat-icon">🍱</div><div class="cat-name">快餐简餐</div></div>
    <div class="category-card" onclick="location.href='${pageContext.request.contextPath}/merchant/list?category=奶茶饮品'"><div class="cat-icon">🧋</div><div class="cat-name">奶茶饮品</div></div>
    <div class="category-card" onclick="location.href='${pageContext.request.contextPath}/merchant/list?category=川湘辣味'"><div class="cat-icon">🌶️</div><div class="cat-name">川湘辣味</div></div>
    <div class="category-card" onclick="location.href='${pageContext.request.contextPath}/merchant/list?category=粤菜海鲜'"><div class="cat-icon">🦐</div><div class="cat-name">粤菜海鲜</div></div>
    <div class="category-card" onclick="location.href='${pageContext.request.contextPath}/merchant/list?category=甜品小吃'"><div class="cat-icon">🍰</div><div class="cat-name">甜品小吃</div></div>
    <div class="category-card" onclick="location.href='${pageContext.request.contextPath}/merchant/list?category=早餐早点'"><div class="cat-icon">🥣</div><div class="cat-name">早餐早点</div></div>
    <div class="category-card" onclick="location.href='${pageContext.request.contextPath}/merchant/list?category=面食粥品'"><div class="cat-icon">🍜</div><div class="cat-name">面食粥品</div></div>
    <div class="category-card" onclick="location.href='${pageContext.request.contextPath}/merchant/list?category=轻食沙拉'"><div class="cat-icon">🥗</div><div class="cat-name">轻食沙拉</div></div>
</div>

<!-- ========== 热门商家 ========== -->
<h3 class="section-title mt-5">热门商家</h3>
<div class="merchant-grid mb-5">
    <c:forEach items="${merchants}" var="m">
    <a href="${pageContext.request.contextPath}/merchant/store?id=${m.userId}" class="merchant-card text-decoration-none" style="color:inherit;">
        <div class="shop-icon"><i class="fas fa-store"></i></div>
        <div class="shop-name"><c:out value="${m.realName}"/></div>
        <div class="shop-user"><i class="fas fa-user me-1"></i><c:out value="${m.username}"/></div>
        <div class="dish-count"><i class="fas fa-utensils me-1"></i>${dishCounts[m.userId]} 道菜品</div>
        <c:if test="${not empty previewDishes[m.userId]}">
        <div class="d-flex justify-content-center gap-2 mb-3">
            <c:forEach items="${previewDishes[m.userId]}" var="pd">
            <img src="${pageContext.request.contextPath}/${pd.imageUrl}" style="width:50px;height:50px;border-radius:8px;object-fit:cover;" alt="${pd.dishName}">
            </c:forEach>
        </div>
        </c:if>
        <span class="btn-enter">进入店铺</span>
    </a>
    </c:forEach>
</div>

<!-- ========== 今日特惠菜品 ========== -->
<h3 class="section-title">限时特价菜品</h3>
<c:choose>
<c:when test="${not empty specialDishes}">
<div class="special-scroll" id="specialScroll">
    <c:forEach items="${specialDishes}" var="dish">
    <a href="${pageContext.request.contextPath}/merchant/store?id=${dish.merchantId}" class="special-card text-decoration-none" style="color:inherit;">
        <img src="${pageContext.request.contextPath}/${dish.imageUrl}" alt="${dish.dishName}">
        <div class="card-body">
            <div class="dish-name" title="${dish.dishName}"><c:out value="${dish.dishName}"/></div>
            <div class="price-row">
                <span class="price-now">&#165;<fmt:formatNumber value="${dish.specialPrice}" pattern="#,##0.00"/></span>
                <span class="price-old">&#165;<fmt:formatNumber value="${dish.price}" pattern="#,##0.00"/></span>
            </div>
            <div style="font-size:12px;color:#999;margin-top:4px;">点击查看店铺</div>
        </div>
    </a>
    </c:forEach>
</div>
</c:when>
<c:otherwise><div class="text-center text-muted py-4">暂无特价菜品</div></c:otherwise>
</c:choose>

</div><!-- /container -->

<!-- ========== 轮播Banner JS ========== -->
<script>
// 动态生成圆点
(function(){
    var slides=document.querySelectorAll('.hero-banner .slide');
    var dotsContainer=document.getElementById('heroDots');
    var totalSlides=slides.length;
    if(totalSlides>0){
        for(var i=0;i<totalSlides;i++){
            var dot=document.createElement('span');
            dot.className='dot'+(i===0?' active':'');
            dot.setAttribute('onclick','goSlide('+i+')');
            dotsContainer.appendChild(dot);
        }
    }
})();
var currentSlide=0,totalSlides=document.querySelectorAll('.hero-banner .slide').length,timer=null;
function showSlide(n){document.querySelectorAll('.hero-banner .slide').forEach(function(s,i){s.classList.toggle('active',i===n)});document.querySelectorAll('.hero-dots .dot').forEach(function(d,i){d.classList.toggle('active',i===n)});currentSlide=n}
function changeSlide(dir){if(totalSlides<=1)return;showSlide((currentSlide+dir+totalSlides)%totalSlides)}
function goSlide(n){showSlide(n)}
function startAuto(){timer=setInterval(function(){changeSlide(1)},3000)}
function stopAuto(){clearInterval(timer)}
document.getElementById('heroBanner').addEventListener('mouseenter',stopAuto);
document.getElementById('heroBanner').addEventListener('mouseleave',startAuto);
startAuto();
</script>

<!-- ========== 横向拖拽滚动 JS ========== -->
<script>
function enableDragScroll(el){
    var isDown=false,startX,scrollLeft;
    el.addEventListener('mousedown',function(e){isDown=true;el.style.cursor='grabbing';startX=e.pageX-el.offsetLeft;scrollLeft=el.scrollLeft});
    el.addEventListener('mouseleave',function(){isDown=false;el.style.cursor='grab'});
    el.addEventListener('mouseup',function(){isDown=false;el.style.cursor='grab'});
    el.addEventListener('mousemove',function(e){if(!isDown)return;e.preventDefault();var x=e.pageX-el.offsetLeft;el.scrollLeft=scrollLeft-(x-startX)*1.5});
    el.addEventListener('wheel',function(e){if(Math.abs(e.deltaY)>Math.abs(e.deltaX)){e.preventDefault();el.scrollLeft+=e.deltaY}});
}
enableDragScroll(document.getElementById('categoryScroll'));
enableDragScroll(document.getElementById('specialScroll'));
</script>

<jsp:include page="common/footer.jsp"/>
