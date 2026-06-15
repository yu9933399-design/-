<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!-- ========== AI 智能客服：可拖拽悬浮按钮 + 聊天窗口 ========== -->
<style>
/* AI 按钮：紫色渐变圆形，可拖拽 */
#ai-chat-btn{
    position:fixed;
    z-index:999;
    width:56px;height:56px;border-radius:50%;
    background:linear-gradient(135deg,#9944FF,#7722CC);
    color:#fff;border:none;font-size:22px;cursor:pointer;
    box-shadow:0 4px 16px rgba(153,68,255,.4);
    transition:opacity .2s,box-shadow .2s;
    display:flex;align-items:center;justify-content:center;
    /* 默认位置：右下角，会被 JS 覆盖 */
    bottom:30px;right:30px;
}
#ai-chat-btn:hover{box-shadow:0 6px 24px rgba(153,68,255,.55);transform:scale(1.08)}
/* 拖拽中半透明过渡 */
#ai-chat-btn.dragging{opacity:.75;transition:none;cursor:grabbing}

/* 聊天弹窗：跟随按钮位置 */
#ai-chat-window{
    position:fixed;z-index:998;
    width:360px;height:480px;
    background:#fff;border-radius:14px;
    box-shadow:0 8px 32px rgba(0,0,0,.18);
    display:none;flex-direction:column;overflow:hidden;
    /* 默认位置，会被 JS 覆盖 */
    bottom:100px;right:30px;
}
#ai-chat-header{background:linear-gradient(135deg,#9944FF,#7722CC);color:#fff;padding:14px 18px;display:flex;justify-content:space-between;align-items:center}
#ai-chat-header h6{margin:0;font-size:14px}
#ai-chat-close{background:none;border:none;color:#fff;font-size:18px;cursor:pointer}
#ai-chat-body{flex:1;overflow-y:auto;padding:14px;display:flex;flex-direction:column;gap:10px}
.ai-msg{max-width:82%;padding:10px 14px;border-radius:12px;font-size:13px;line-height:1.5;word-break:break-word}
.ai-msg.bot{align-self:flex-start;background:#f0f2f5;color:#333;border-bottom-left-radius:4px}
.ai-msg.user{align-self:flex-end;background:linear-gradient(135deg,#9944FF,#7722CC);color:#fff;border-bottom-right-radius:4px}
.ai-typing{align-self:flex-start;background:#f0f2f5;padding:10px 14px;border-radius:12px;font-size:12px;color:#999}
#ai-chat-footer{padding:10px 14px;border-top:1px solid #eee;display:flex;gap:8px}
#ai-chat-input{flex:1;border:1px solid #ddd;border-radius:20px;padding:7px 14px;font-size:13px;outline:none}
#ai-chat-input:focus{border-color:#9944FF}
#ai-chat-send{background:linear-gradient(135deg,#9944FF,#7722CC);color:#fff;border:none;border-radius:20px;padding:7px 18px;font-size:13px;cursor:pointer}
#ai-chat-send:disabled{opacity:.5;cursor:not-allowed}
</style>

<!-- AI 悬浮按钮 -->
<button id="ai-chat-btn" title="智能客服 - 可拖拽">💬</button>
<!-- AI 聊天弹窗 -->
<div id="ai-chat-window">
  <div id="ai-chat-header">
    <h6>🤖 智能客服</h6>
    <button id="ai-chat-close" onclick="toggleAiChat()">✕</button>
  </div>
  <div id="ai-chat-body">
    <div class="ai-msg bot">你好！我是美食点餐系统的智能客服，可以帮你查询订单、配送进度、解答取消规则等问题~</div>
  </div>
  <div id="ai-chat-footer">
    <input type="text" id="ai-chat-input" placeholder="输入您的问题..." onkeydown="if(event.key==='Enter')sendAiMsg()">
    <button id="ai-chat-send" onclick="sendAiMsg()">发送</button>
  </div>
</div>

<script>
/* ========== AI 聊天窗口切换 ========== */
var aiChatOpen = false;
function toggleAiChat() {
    aiChatOpen = !aiChatOpen;
    var win = document.getElementById('ai-chat-window');
    win.style.display = aiChatOpen ? 'flex' : 'none';
    if (aiChatOpen) {
        syncWindowPos();
        document.getElementById('ai-chat-input').focus();
    }
}

/* ========== 可拖拽按钮 + localStorage 记忆 ========== */
(function() {
    var btn = document.getElementById('ai-chat-btn');
    var win = document.getElementById('ai-chat-window');
    var STORAGE_KEY = 'ai_chat_btn_pos';
    var isDragging = false;
    var startX, startY, startLeft, startTop;

    // 读取上次保存的位置，默认右下角
    function loadPos() {
        try {
            var saved = JSON.parse(localStorage.getItem(STORAGE_KEY));
            if (saved && typeof saved.x === 'number' && typeof saved.y === 'number') {
                return { x: saved.x, y: saved.y };
            }
        } catch(e) {}
        return null;
    }

    // 设置按钮位置（基于 right/bottom）
    function setBtnPos(x, y) {
        btn.style.right = 'auto';
        btn.style.bottom = 'auto';
        btn.style.left = x + 'px';
        btn.style.top = y + 'px';
    }

    // 保存位置到 localStorage
    function savePos(x, y) {
        try { localStorage.setItem(STORAGE_KEY, JSON.stringify({x:x, y:y})); } catch(e) {}
    }

    // 边界限制：确保按钮在可视区域内
    function clamp(v, min, max) { return Math.max(min, Math.min(max, v)); }

    // 初始化位置
    var initPos = loadPos();
    if (initPos) {
        var bw = btn.offsetWidth || 56, bh = btn.offsetHeight || 56;
        var vw = window.innerWidth, vh = window.innerHeight;
        var x = clamp(initPos.x, 0, vw - bw);
        var y = clamp(initPos.y, 0, vh - bh);
        setBtnPos(x, y);
    }

    // 同步聊天窗口位置：窗口左上角对齐按钮
    window.syncWindowPos = function() {
        var bw = btn.offsetWidth || 56;
        var bh = btn.offsetHeight || 56;
        var bx = parseInt(btn.style.left) || (window.innerWidth - bw - 30);
        var by = parseInt(btn.style.top) || (window.innerHeight - bh - 30);
        var ww = win.offsetWidth || 360;
        var wh = win.offsetHeight || 480;
        var vx = window.innerWidth, vy = window.innerHeight;

        // 窗口优先显示在按钮左侧，放不下则右侧
        var wx = bx - ww - 8;
        if (wx < 8) wx = bx + bw + 8;
        wx = clamp(wx, 0, vx - ww);

        // 窗口顶部与按钮顶部对齐，超出则调整
        var wy = by;
        wy = clamp(wy, 0, vy - wh);

        win.style.left = wx + 'px';
        win.style.top = wy + 'px';
        win.style.right = 'auto';
        win.style.bottom = 'auto';
    };

    // 拖拽事件
    btn.addEventListener('mousedown', function(e) {
        // 如果点击的是按钮本身（不是拖拽），不阻止默认
        isDragging = false;
        startX = e.clientX;
        startY = e.clientY;
        startLeft = parseInt(btn.style.left) || (window.innerWidth - (btn.offsetWidth||56) - 30);
        startTop = parseInt(btn.style.top) || (window.innerHeight - (btn.offsetHeight||56) - 30);
        btn.classList.add('dragging');

        function onMove(ev) {
            var dx = ev.clientX - startX;
            var dy = ev.clientY - startY;
            if (Math.abs(dx) > 3 || Math.abs(dy) > 3) isDragging = true;
            if (!isDragging) return;
            var bw = btn.offsetWidth || 56, bh = btn.offsetHeight || 56;
            var nx = clamp(startLeft + dx, 0, window.innerWidth - bw);
            var ny = clamp(startTop + dy, 0, window.innerHeight - bh);
            setBtnPos(nx, ny);
            if (aiChatOpen) syncWindowPos();
        }

        function onUp() {
            document.removeEventListener('mousemove', onMove);
            document.removeEventListener('mouseup', onUp);
            btn.classList.remove('dragging');
            if (isDragging) {
                var fx = parseInt(btn.style.left);
                var fy = parseInt(btn.style.top);
                savePos(fx, fy);
            }
        }

        document.addEventListener('mousemove', onMove);
        document.addEventListener('mouseup', onUp);
    });

    // 点击切换聊天窗口（非拖拽时）
    btn.addEventListener('click', function(e) {
        if (isDragging) { e.preventDefault(); return; }
        toggleAiChat();
    });

    // 窗口大小变化时重新同步
    window.addEventListener('resize', function() {
        var bw = btn.offsetWidth || 56, bh = btn.offsetHeight || 56;
        var bx = parseInt(btn.style.left);
        var by = parseInt(btn.style.top);
        if (!isNaN(bx) && !isNaN(by)) {
            bx = clamp(bx, 0, window.innerWidth - bw);
            by = clamp(by, 0, window.innerHeight - bh);
            setBtnPos(bx, by);
        }
        if (aiChatOpen) syncWindowPos();
    });
})();

/* ========== 发送消息（原逻辑保留） ========== */
function sendAiMsg() {
    var input = document.getElementById('ai-chat-input');
    var msg = input.value.trim();
    if (!msg) return;
    var body = document.getElementById('ai-chat-body');
    var userDiv = document.createElement('div');
    userDiv.className = 'ai-msg user';
    userDiv.textContent = msg;
    body.appendChild(userDiv);
    input.value = '';
    var typingDiv = document.createElement('div');
    typingDiv.className = 'ai-typing';
    typingDiv.textContent = '正在思考中...';
    body.appendChild(typingDiv);
    body.scrollTop = body.scrollHeight;
    document.getElementById('ai-chat-send').disabled = true;
    var xhr = new XMLHttpRequest();
    xhr.open('POST', '${pageContext.request.contextPath}/aiOrderChat', true);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
    xhr.timeout = 30000;
    xhr.onload = function() {
        body.removeChild(typingDiv);
        var botDiv = document.createElement('div');
        botDiv.className = 'ai-msg bot';
        try {
            var r = JSON.parse(xhr.responseText);
            botDiv.textContent = r.success ? r.answer : (r.message || '暂时无法回答');
        } catch(e) {
            botDiv.textContent = '回复解析失败，请重试~';
        }
        body.appendChild(botDiv);
        body.scrollTop = body.scrollHeight;
        document.getElementById('ai-chat-send').disabled = false;
    };
    xhr.onerror = xhr.ontimeout = function() {
        body.removeChild(typingDiv);
        var botDiv = document.createElement('div');
        botDiv.className = 'ai-msg bot';
        botDiv.textContent = '网络异常，请稍后再试~';
        body.appendChild(botDiv);
        body.scrollTop = body.scrollHeight;
        document.getElementById('ai-chat-send').disabled = false;
    };
    xhr.send('question=' + encodeURIComponent(msg));
}
</script>
