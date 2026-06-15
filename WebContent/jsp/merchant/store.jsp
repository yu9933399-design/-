<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="../common/header.jsp"><jsp:param name="title" value="${merchant.realName} - 店铺"/></jsp:include>

<style>
:root{--orange:#FF7800;--orange-dark:#e66c00}
.store-wrap{display:flex;height:calc(100vh - 60px);overflow:hidden;margin-top:-16px}
/* 左侧分类栏 */
.cat-sidebar{width:90px;background:#f5f5f5;overflow-y:auto;flex-shrink:0;scrollbar-width:none}
.cat-sidebar::-webkit-scrollbar{display:none}
.cat-item{padding:14px 8px;text-align:center;font-size:13px;color:#666;cursor:pointer;border-left:3px solid transparent;transition:all .2s}
.cat-item:hover,.cat-item.active{background:#fff;color:var(--orange);border-left-color:var(--orange);font-weight:600}
/* 右侧菜品列表 */
.dish-panel{flex:1;overflow-y:auto;padding:16px 20px}
.dish-section-title{font-size:15px;font-weight:700;color:#333;padding:10px 0;border-bottom:1px solid #f0f0f0;margin-bottom:12px}
.dish-row{display:flex;gap:14px;padding:12px 0;border-bottom:1px solid #f5f5f5;align-items:flex-start}
.dish-img{width:100px;height:100px;border-radius:10px;object-fit:cover;flex-shrink:0;background:#f0f0f0}
.dish-info{flex:1;min-width:0}
.dish-name{font-size:15px;font-weight:600;color:#333;margin-bottom:4px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.dish-desc{font-size:12px;color:#999;margin-bottom:6px;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden}
.dish-sales{font-size:12px;color:#999;margin-bottom:6px}
.dish-price-row{display:flex;align-items:center;gap:10px}
.dish-price{font-size:18px;font-weight:700;color:var(--orange)}
.dish-old-price{font-size:13px;color:#999;text-decoration:line-through}
.dish-add{position:absolute;right:0;bottom:0}
/* 菜品卡片容器 */
.dish-row{position:relative}
/* 加购按钮组 */
.qty-ctrl{display:flex;align-items:center;gap:8px}
.qty-btn{width:26px;height:26px;border-radius:50%;border:none;font-size:16px;cursor:pointer;display:flex;align-items:center;justify-content:center;transition:all .2s}
.qty-minus{background:#fff;color:var(--orange);border:1px solid var(--orange)}
.qty-plus{background:var(--orange);color:#fff}
.qty-num{font-size:14px;font-weight:600;min-width:20px;text-align:center}
/* 底部购物车栏 */
.cart-bar{position:fixed;bottom:0;left:0;right:0;height:56px;background:#333;display:flex;align-items:center;padding:0 20px;z-index:100;box-shadow:0 -2px 10px rgba(0,0,0,.15)}
.cart-icon-wrap{width:48px;height:48px;border-radius:50%;background:var(--orange);display:flex;align-items:center;justify-content:center;position:relative;margin-top:-16px;border:3px solid #333}
.cart-icon-wrap i{color:#fff;font-size:20px}
.cart-badge{position:absolute;top:-4px;right:-4px;background:#e4393c;color:#fff;font-size:11px;width:18px;height:18px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-weight:700}
.cart-total{color:#fff;margin-left:14px;font-size:16px;font-weight:600;flex:1}
.cart-total small{font-size:12px;font-weight:400;opacity:.7}
.btn-checkout{padding:10px 28px;background:var(--orange);color:#fff;border:none;border-radius:24px;font-size:15px;font-weight:600;cursor:pointer;transition:all .2s}
.btn-checkout:hover{background:var(--orange-dark)}
.btn-checkout.disabled{background:#666;cursor:not-allowed}
/* 购物车弹窗 */
.cart-popup{position:fixed;bottom:56px;left:0;right:0;background:#fff;border-radius:16px 16px 0 0;max-height:50vh;overflow-y:auto;z-index:99;box-shadow:0 -4px 20px rgba(0,0,0,.1);display:none;padding:16px 20px}
.cart-popup.show{display:block}
.cart-popup-title{font-size:14px;color:#666;margin-bottom:10px;display:flex;justify-content:space-between;align-items:center}
.cart-popup-title .clear-cart{color:var(--orange);font-size:13px;cursor:pointer;border:none;background:none}
.cart-popup-item{display:flex;align-items:center;padding:10px 0;border-bottom:1px solid #f5f5f5}
.cart-popup-item img{width:48px;height:48px;border-radius:8px;object-fit:cover;margin-right:12px}
.cart-popup-item .item-name{flex:1;font-size:14px;color:#333}
.cart-popup-item .item-price{color:var(--orange);font-weight:600;margin-right:12px}
</style>

<div class="store-wrap">
<!-- 左侧分类栏 -->
<div class="cat-sidebar" id="catSidebar">
    <c:forEach items="${categories}" var="cat">
    <c:if test="${not empty grouped[cat.categoryId]}">
    <div class="cat-item" data-cat="${cat.categoryId}" onclick="scrollToCat(${cat.categoryId})"><c:out value="${cat.categoryName}"/></div>
    </c:if>
    </c:forEach>
</div>
<!-- 右侧菜品列表 -->
<div class="dish-panel" id="dishPanel">
    <c:forEach items="${categories}" var="cat">
    <c:set var="dishes" value="${grouped[cat.categoryId]}"/>
    <c:if test="${not empty dishes}">
    <div class="dish-section-title" id="catTitle-${cat.categoryId}"><c:out value="${cat.categoryName}"/></div>
    <c:forEach items="${dishes}" var="d">
    <div class="dish-row" data-dish="${d.dishId}" data-price="${d.specialPrice != null ? d.specialPrice : d.price}">
        <img class="dish-img" src="${pageContext.request.contextPath}/${d.imageUrl}" alt="${d.dishName}">
        <div class="dish-info">
            <div class="dish-name"><c:out value="${d.dishName}"/></div>
            <c:if test="${not empty d.description}"><div class="dish-desc"><c:out value="${d.description}"/></div></c:if>
            <div class="dish-sales">月售 999+</div>
            <div class="dish-price-row">
                <c:choose>
                <c:when test="${d.specialPrice != null}">
                    <span class="dish-price">&#165;<fmt:formatNumber value="${d.specialPrice}" pattern="#,##0.00"/></span>
                    <span class="dish-old-price">&#165;<fmt:formatNumber value="${d.price}" pattern="#,##0.00"/></span>
                </c:when>
                <c:otherwise><span class="dish-price">&#165;<fmt:formatNumber value="${d.price}" pattern="#,##0.00"/></span></c:otherwise>
                </c:choose>
            </div>
        </div>
        <div class="qty-ctrl" id="qty-${d.dishId}" style="display:none;">
            <button class="qty-btn qty-minus" onclick="changeQty(${d.dishId},-1)">-</button>
            <span class="qty-num" id="qtyNum-${d.dishId}">0</span>
            <button class="qty-btn qty-plus" onclick="changeQty(${d.dishId},1)">+</button>
        </div>
        <button class="qty-btn qty-plus" id="addBtn-${d.dishId}" onclick="addToCart(${d.dishId},'${d.dishName}',${d.specialPrice != null ? d.specialPrice : d.price},'${d.imageUrl}')">+</button>
    </div>
    </c:forEach>
    </c:if>
    </c:forEach>
    <div style="height:80px"></div>
</div>
</div>

<!-- 底部购物车栏 -->
<div class="cart-bar">
    <div class="cart-icon-wrap" onclick="toggleCartPopup()">
        <i class="fas fa-shopping-cart"></i>
        <span class="cart-badge" id="cartBadge">0</span>
    </div>
    <div class="cart-total">
        <div>&#165;<span id="cartTotalPrice">0.00</span></div>
        <small>配送费 ¥3</small>
    </div>
    <button class="btn-checkout disabled" id="btnCheckout" onclick="goCheckout()">去结算</button>
</div>

<!-- 购物车弹窗 -->
<div class="cart-popup" id="cartPopup">
    <div class="cart-popup-title">
        <span>已选商品</span>
        <button class="clear-cart" onclick="clearCart()"><i class="fas fa-trash me-1"></i>清空</button>
    </div>
    <div id="cartPopupList"></div>
</div>

<script>
var shopId = ${merchant.userId};
var cartMap = {};

function addToCart(dishId, name, price, img) {
    if (!cartMap[dishId]) {
        cartMap[dishId] = {dishId:dishId, name:name, price:price, img:img, qty:0};
    }
    cartMap[dishId].qty++;
    updateCartUI();
    // 同步到后端
    $.post(contextPath + '/cart/add', {dishId: dishId, quantity: 1}, function(r){
        if (!r.success && r.needLogin) { location.href = contextPath + '/login'; }
    }, 'json');
}

function changeQty(dishId, delta) {
    if (!cartMap[dishId]) return;
    cartMap[dishId].qty += delta;
    if (cartMap[dishId].qty <= 0) delete cartMap[dishId];
    updateCartUI();
}

function clearCart() {
    cartMap = {};
    updateCartUI();
    $.post(contextPath + '/cart', {action: 'clear'}, function(){}, 'json');
}

function updateCartUI() {
    var total = 0, count = 0, items = [];
    for (var id in cartMap) {
        var item = cartMap[id];
        total += item.price * item.qty;
        count += item.qty;
        items.push(item);
        // 更新菜品行的加购按钮
        var qtyEl = document.getElementById('qty-' + id);
        var addBtn = document.getElementById('addBtn-' + id);
        var qtyNum = document.getElementById('qtyNum-' + id);
        if (item.qty > 0) {
            qtyEl.style.display = 'flex';
            addBtn.style.display = 'none';
            qtyNum.textContent = item.qty;
        } else {
            qtyEl.style.display = 'none';
            addBtn.style.display = 'flex';
        }
    }
    document.getElementById('cartBadge').textContent = count;
    document.getElementById('cartTotalPrice').textContent = total.toFixed(2);
    var checkoutBtn = document.getElementById('btnCheckout');
    checkoutBtn.className = count > 0 ? 'btn-checkout' : 'btn-checkout disabled';
    // 更新弹窗列表
    var html = '';
    items.forEach(function(item) {
        html += '<div class="cart-popup-item">'
            + '<img src="' + contextPath + '/' + item.img + '">'
            + '<span class="item-name">' + item.name + '</span>'
            + '<span class="item-price">&#165;' + (item.price * item.qty).toFixed(2) + '</span>'
            + '<div class="qty-ctrl">'
            + '<button class="qty-btn qty-minus" onclick="changeQty(' + item.dishId + ',-1)">-</button>'
            + '<span class="qty-num">' + item.qty + '</span>'
            + '<button class="qty-btn qty-plus" onclick="changeQty(' + item.dishId + ',1)">+</button>'
            + '</div></div>';
    });
    document.getElementById('cartPopupList').innerHTML = html;
}

function toggleCartPopup() {
    document.getElementById('cartPopup').classList.toggle('show');
}

function goCheckout() {
    var count = 0;
    for (var id in cartMap) count += cartMap[id].qty;
    if (count <= 0) return;
    location.href = contextPath + '/order/checkout?shopId=' + shopId;
}

function scrollToCat(catId) {
    var el = document.getElementById('catTitle-' + catId);
    if (el) el.scrollIntoView({behavior:'smooth', block:'start'});
}

// 左侧分类高亮跟随滚动
var dishPanel = document.getElementById('dishPanel');
var catItems = document.querySelectorAll('.cat-item');
dishPanel.addEventListener('scroll', function() {
    var titles = document.querySelectorAll('.dish-section-title');
    var activeIdx = 0;
    titles.forEach(function(t, i) {
        if (t.getBoundingClientRect().top < 200) activeIdx = i;
    });
    catItems.forEach(function(c, i) {
        c.classList.toggle('active', i === activeIdx);
    });
});
</script>

<jsp:include page="../common/footer.jsp"/>
