<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="../common/header.jsp"><jsp:param name="title" value="订单支付"/></jsp:include>
<style>
    .payment-container { max-width: 500px; margin: 40px auto; }
    .qr-card { border: none; border-radius: 16px; overflow: hidden; box-shadow: 0 8px 30px rgba(0,0,0,0.1); }
    .qr-header { background: linear-gradient(135deg, #07c160, #06ad56); color: white; padding: 24px; text-align: center; transition: background 0.3s; }
    .qr-header.alipay { background: linear-gradient(135deg, #1677ff, #0958d9); }
    .qr-header.cash { background: linear-gradient(135deg, #ff9800, #e67e22); }
    .qr-body { padding: 30px; text-align: center; }
    .qr-code-wrapper { width: 220px; height: 220px; margin: 20px auto; border: 3px solid #07c160; border-radius: 12px; display: flex; align-items: center; justify-content: center; background: #fff; transition: border-color 0.3s; }
    .qr-code-wrapper.alipay { border-color: #1677ff; }
    .qr-tip { color: #666; font-size: 14px; margin-top: 16px; }
    .amount-display { font-size: 36px; font-weight: 700; color: #e4393c; margin: 16px 0; }
    .order-info-row { display: flex; justify-content: space-between; padding: 10px 0; border-bottom: 1px dashed #eee; font-size: 14px; }
    .order-info-row:last-child { border-bottom: none; }
    .order-info-row .label { color: #999; }
    .timer { color: #e4393c; font-weight: 600; }
    .btn-pay { background: #07c160; border: none; padding: 14px 60px; font-size: 18px; border-radius: 30px; margin-top: 20px; transition: all 0.3s; color: #fff; cursor: pointer; }
    .btn-pay:hover { background: #06ad56; transform: translateY(-2px); box-shadow: 0 4px 15px rgba(7,193,96,0.4); color: #fff; }
    .btn-pay.alipay { background: #1677ff; }
    .btn-pay.alipay:hover { background: #0958d9; box-shadow: 0 4px 15px rgba(22,119,255,0.4); }
    .btn-pay.cash { background: #ff9800; }
    .btn-pay.cash:hover { background: #e67e22; box-shadow: 0 4px 15px rgba(255,152,0,0.4); }
    .btn-pay:disabled { background: #ccc; cursor: not-allowed; transform: none; box-shadow: none; }
    .payment-tabs { display: flex; gap: 0; border-radius: 10px; overflow: hidden; margin: 16px 0; border: 1px solid #e8e8e8; }
    .payment-tab { flex: 1; padding: 12px 8px; text-align: center; cursor: pointer; font-size: 14px; font-weight: 500; transition: all 0.3s; background: #fff; color: #666; border: none; outline: none; }
    .payment-tab i { display: block; font-size: 22px; margin-bottom: 4px; }
    .payment-tab.active { color: #07c160; background: #f0fff4; font-weight: 600; }
    .payment-tab.active.alipay { color: #1677ff; background: #e6f4ff; }
    .payment-tab.active.cash { color: #ff9800; background: #fff7e6; }
    .payment-tab:hover:not(.active) { background: #fafafa; }
    .cash-info { text-align: left; background: #fff7e6; border-radius: 10px; padding: 20px; margin: 16px 0; }
    .cash-info h6 { color: #ff9800; margin-bottom: 12px; }
    .cash-info ul { margin: 0; padding-left: 20px; color: #666; }
    .cash-info li { margin-bottom: 6px; font-size: 14px; }
</style>

<div class="container">
    <div class="payment-container">
        <c:if test="${error != null}">
            <div class="alert alert-danger">${error}</div>
        </c:if>
        <c:if test="${order != null}">
            <div class="qr-card card">
                <div class="qr-header" id="qrHeader">
                    <h4 class="mb-0"><i class="fas fa-qrcode me-2" id="headerIcon"></i><span id="headerTitle">扫码支付</span></h4>
                </div>
                <div class="qr-body">
                    <div class="order-info-row">
                        <span class="label">订单编号</span>
                        <span>${order.orderNo}</span>
                    </div>

                    <div class="payment-tabs" id="paymentTabs">
                        <button type="button" class="payment-tab active" data-method="微信支付" onclick="switchMethod(this)">
                            <i class="fab fa-weixin"></i>微信支付
                        </button>
                        <button type="button" class="payment-tab" data-method="支付宝支付" onclick="switchMethod(this)">
                            <i class="fab fa-alipay"></i>支付宝支付
                        </button>
                        <button type="button" class="payment-tab" data-method="货到付款" onclick="switchMethod(this)">
                            <i class="fas fa-money-bill-wave"></i>货到付款
                        </button>
                    </div>

                    <div class="amount-display">&#165;<fmt:formatNumber value="${order.totalAmount}" pattern="#,##0.00"/></div>

                    <div id="qrSection">
                        <div class="qr-code-wrapper" id="qrWrapper">
                            <svg id="qrSvg" viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
                                <rect width="200" height="200" fill="white"/>
                                <g fill="#000">
                                    <rect x="10" y="10" width="50" height="50" rx="4"/>
                                    <rect x="16" y="16" width="38" height="38" rx="2" fill="white"/>
                                    <rect x="22" y="22" width="26" height="26" rx="2" fill="#000"/>
                                    <rect x="140" y="10" width="50" height="50" rx="4"/>
                                    <rect x="146" y="16" width="38" height="38" rx="2" fill="white"/>
                                    <rect x="152" y="22" width="26" height="26" rx="2" fill="#000"/>
                                    <rect x="10" y="140" width="50" height="50" rx="4"/>
                                    <rect x="16" y="146" width="38" height="38" rx="2" fill="white"/>
                                    <rect x="22" y="152" width="26" height="26" rx="2" fill="#000"/>
                                    <rect x="70" y="10" width="8" height="8"/>
                                    <rect x="86" y="10" width="8" height="8"/>
                                    <rect x="102" y="10" width="8" height="8"/>
                                    <rect x="118" y="10" width="8" height="8"/>
                                    <rect x="70" y="26" width="8" height="8"/>
                                    <rect x="102" y="26" width="8" height="8"/>
                                    <rect x="118" y="26" width="8" height="8"/>
                                    <rect x="70" y="42" width="8" height="8"/>
                                    <rect x="86" y="42" width="8" height="8"/>
                                    <rect x="118" y="42" width="8" height="8"/>
                                    <rect x="70" y="70" width="8" height="8"/>
                                    <rect x="86" y="70" width="8" height="8"/>
                                    <rect x="102" y="70" width="8" height="8"/>
                                    <rect x="118" y="70" width="8" height="8"/>
                                    <rect x="134" y="70" width="8" height="8"/>
                                    <rect x="150" y="70" width="8" height="8"/>
                                    <rect x="166" y="70" width="8" height="8"/>
                                    <rect x="182" y="70" width="8" height="8"/>
                                    <rect x="10" y="86" width="8" height="8"/>
                                    <rect x="42" y="86" width="8" height="8"/>
                                    <rect x="70" y="86" width="8" height="8"/>
                                    <rect x="102" y="86" width="8" height="8"/>
                                    <rect x="134" y="86" width="8" height="8"/>
                                    <rect x="166" y="86" width="8" height="8"/>
                                    <rect x="10" y="102" width="8" height="8"/>
                                    <rect x="26" y="102" width="8" height="8"/>
                                    <rect x="58" y="102" width="8" height="8"/>
                                    <rect x="86" y="102" width="8" height="8"/>
                                    <rect x="102" y="102" width="8" height="8"/>
                                    <rect x="134" y="102" width="8" height="8"/>
                                    <rect x="150" y="102" width="8" height="8"/>
                                    <rect x="182" y="102" width="8" height="8"/>
                                    <rect x="10" y="118" width="8" height="8"/>
                                    <rect x="42" y="118" width="8" height="8"/>
                                    <rect x="70" y="118" width="8" height="8"/>
                                    <rect x="86" y="118" width="8" height="8"/>
                                    <rect x="118" y="118" width="8" height="8"/>
                                    <rect x="150" y="118" width="8" height="8"/>
                                    <rect x="166" y="118" width="8" height="8"/>
                                    <rect x="70" y="134" width="8" height="8"/>
                                    <rect x="102" y="134" width="8" height="8"/>
                                    <rect x="134" y="134" width="8" height="8"/>
                                    <rect x="166" y="134" width="8" height="8"/>
                                    <rect x="70" y="150" width="8" height="8"/>
                                    <rect x="86" y="150" width="8" height="8"/>
                                    <rect x="118" y="150" width="8" height="8"/>
                                    <rect x="150" y="150" width="8" height="8"/>
                                    <rect x="182" y="150" width="8" height="8"/>
                                    <rect x="70" y="166" width="8" height="8"/>
                                    <rect x="102" y="166" width="8" height="8"/>
                                    <rect x="118" y="166" width="8" height="8"/>
                                    <rect x="150" y="166" width="8" height="8"/>
                                    <rect x="70" y="182" width="8" height="8"/>
                                    <rect x="86" y="182" width="8" height="8"/>
                                    <rect x="102" y="182" width="8" height="8"/>
                                    <rect x="134" y="182" width="8" height="8"/>
                                    <rect x="166" y="182" width="8" height="8"/>
                                    <rect x="182" y="182" width="8" height="8"/>
                                </g>
                            </svg>
                        </div>
                        <div class="qr-tip" id="qrTip">
                            <i class="fas fa-mobile-alt me-1"></i>
                            请使用<span class="fw-bold" id="tipMethod">微信支付</span>扫描二维码完成支付
                        </div>
                    </div>

                    <div class="cash-info" id="cashInfo" style="display:none;">
                        <h6><i class="fas fa-info-circle me-1"></i>货到付款须知</h6>
                        <ul>
                            <li>配送员到达时请准备好现金</li>
                            <li>支持当面验收商品后再付款</li>
                            <li>如有问题请联系客服</li>
                        </ul>
                    </div>

                    <div class="mt-3" style="color: #999; font-size: 13px;" id="countdownWrap">
                        支付剩余时间：<span class="timer" id="countdown">14:59</span>
                    </div>

                    <form action="${pageContext.request.contextPath}/order/pay" method="post" id="payForm">
                        <input type="hidden" name="orderId" value="${order.orderId}"/>
                        <input type="hidden" name="paymentMethod" id="paymentMethodInput" value="微信支付"/>
                        <button type="submit" class="btn btn-pay" id="btnConfirm">
                            <i class="fas fa-check-circle me-2" id="btnIcon"></i><span id="btnText">我已支付</span>
                        </button>
                    </form>
                </div>
            </div>

            <div class="text-center mt-3">
                <a href="${pageContext.request.contextPath}/order/list" class="text-muted text-decoration-none">
                    <i class="fas fa-arrow-left me-1"></i>返回订单列表
                </a>
            </div>
        </c:if>
    </div>
</div>

<script>
    (function() {
        var totalSeconds = 14 * 60 + 59;
        var countdownEl = document.getElementById('countdown');
        var timer = setInterval(function() {
            if (totalSeconds <= 0) {
                clearInterval(timer);
                countdownEl.textContent = '00:00';
                document.getElementById('btnConfirm').disabled = true;
                return;
            }
            totalSeconds--;
            var m = Math.floor(totalSeconds / 60);
            var s = totalSeconds % 60;
            countdownEl.textContent = (m < 10 ? '0' : '') + m + ':' + (s < 10 ? '0' : '') + s;
        }, 1000);
    })();

    function switchMethod(el) {
        var method = el.getAttribute('data-method');
        document.getElementById('paymentMethodInput').value = method;

        var tabs = document.querySelectorAll('.payment-tab');
        tabs.forEach(function(t) { t.classList.remove('active', 'alipay', 'cash'); });
        el.classList.add('active');

        var header = document.getElementById('qrHeader');
        var qrWrapper = document.getElementById('qrWrapper');
        var btn = document.getElementById('btnConfirm');
        var qrSection = document.getElementById('qrSection');
        var cashInfo = document.getElementById('cashInfo');
        var countdownWrap = document.getElementById('countdownWrap');
        var headerIcon = document.getElementById('headerIcon');
        var headerTitle = document.getElementById('headerTitle');
        var btnText = document.getElementById('btnText');
        var btnIcon = document.getElementById('btnIcon');

        header.className = 'qr-header';
        qrWrapper.className = 'qr-code-wrapper';
        btn.className = 'btn btn-pay';

        if (method === '微信支付') {
            headerIcon.className = 'fas fa-qrcode me-2';
            headerTitle.textContent = '微信支付';
            document.getElementById('tipMethod').textContent = '微信支付';
            qrSection.style.display = '';
            cashInfo.style.display = 'none';
            countdownWrap.style.display = '';
            btnText.textContent = '我已支付';
            btnIcon.className = 'fas fa-check-circle me-2';
        } else if (method === '支付宝支付') {
            header.classList.add('alipay');
            qrWrapper.classList.add('alipay');
            btn.classList.add('alipay');
            el.classList.add('alipay');
            headerIcon.className = 'fab fa-alipay me-2';
            headerTitle.textContent = '支付宝支付';
            document.getElementById('tipMethod').textContent = '支付宝';
            qrSection.style.display = '';
            cashInfo.style.display = 'none';
            countdownWrap.style.display = '';
            btnText.textContent = '我已支付';
            btnIcon.className = 'fas fa-check-circle me-2';
        } else {
            header.classList.add('cash');
            btn.classList.add('cash');
            el.classList.add('cash');
            headerIcon.className = 'fas fa-money-bill-wave me-2';
            headerTitle.textContent = '货到付款';
            qrSection.style.display = 'none';
            cashInfo.style.display = 'block';
            countdownWrap.style.display = 'none';
            btnText.textContent = '确认下单';
            btnIcon.className = 'fas fa-check-circle me-2';
        }
    }
</script>

<jsp:include page="../common/footer.jsp"/>
