<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="/jsp/common/header.jsp">
    <jsp:param name="title" value="聊天"/>
</jsp:include>

<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card shadow">
                <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center">
                    <div>
                        <a href="${pageContext.request.contextPath}/message/list" class="text-white me-2">
                            <i class="fas fa-arrow-left"></i>
                        </a>
                        <span>与 <c:out value="${otherUser.username}" default="用户"/> 的对话</span>
                    </div>
                </div>
                <div class="card-body" style="height: 400px; overflow-y: auto;" id="chatBox">
                    <c:choose>
                        <c:when test="${empty messages}">
                            <div class="text-center text-muted py-5">
                                <i class="fas fa-comments fa-3x mb-3"></i>
                                <p>暂无消息，发送第一条消息吧</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach items="${messages}" var="msg">
                                <c:choose>
                                    <c:when test="${msg.senderId == sessionScope.user.userId}">
                                        <div class="d-flex justify-content-end mb-3">
                                            <div class="bg-primary text-white rounded-3 p-3" style="max-width: 70%;">
                                                <div class="mb-1">${msg.content}</div>
                                                        <small class="text-white-50">
                                                            ${msg.createTime}
                                                        </small>
                                            </div>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="d-flex justify-content-start mb-3">
                                            <div class="bg-light rounded-3 p-3" style="max-width: 70%;">
                                                <div class="mb-1">${msg.content}</div>
                                                        <small class="text-muted">
                                                            ${msg.createTime}
                                                        </small>
                                            </div>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="card-footer">
                    <form action="${pageContext.request.contextPath}/message/send" method="post" class="d-flex gap-2">
                        <input type="hidden" name="receiverId" value="${otherUser.userId}">
                        <input type="text" name="content" class="form-control" placeholder="输入消息..." required maxlength="1000" autocomplete="off">
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-paper-plane"></i>
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    var chatBox = document.getElementById('chatBox');
    chatBox.scrollTop = chatBox.scrollHeight;
</script>

<jsp:include page="/jsp/common/footer.jsp"/>
