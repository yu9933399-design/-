<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
</div><!-- /page-wrap -->
<!-- ========== 粘性底部页脚（flex 自动贴底） ========== -->
<footer class="site-footer">
    <div class="container text-center">
        <p class="mb-0">&copy; 2026 美食点餐系统 All Rights Reserved</p>
    </div>
</footer>
<style>
.site-footer{
    flex-shrink:0;
    background:#1a1a2e;
    color:#ccc;
    padding:18px 0;
    font-size:13px;
}
</style>
<!-- ========== 脚本加载 ========== -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script>var contextPath = "${pageContext.request.contextPath}";</script>
<script src="${pageContext.request.contextPath}/js/custom.js?v=2"></script>
<%@ include file="ai-chat.jsp" %>
</body>
</html>
