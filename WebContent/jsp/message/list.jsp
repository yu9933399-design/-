<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="/jsp/common/header.jsp">
    <jsp:param name="title" value="我的消息"/>
</jsp:include>

<div class="container py-5">
    <div class="row">
        <div class="col-md-3">
            <div class="card shadow-sm">
                <div class="card-header bg-primary text-white">
                    <h5 class="mb-0"><i class="fas fa-envelope me-2"></i>消息中心</h5>
                </div>
                <div class="list-group list-group-flush">
                    <a href="${pageContext.request.contextPath}/message/list" class="list-group-item list-group-item-action active">
                        <i class="fas fa-inbox me-2"></i>全部消息
                        <c:if test="${totalUnread > 0}">
                            <span class="badge bg-danger float-end">${totalUnread}</span>
                        </c:if>
                    </a>
                    <a href="${pageContext.request.contextPath}/merchant/list" class="list-group-item list-group-item-action">
                        <i class="fas fa-store me-2"></i>联系商家
                    </a>
                </div>
            </div>
        </div>
        <div class="col-md-9">
            <div class="card shadow-sm">
                <div class="card-header">
                    <h5 class="mb-0">消息列表</h5>
                </div>
                <div class="card-body">
                    <c:if test="${error != null}">
                        <div class="alert alert-danger">${error}</div>
                    </c:if>
                    <c:choose>
                        <c:when test="${empty chatUsers}">
                            <div class="text-center py-5">
                                <i class="fas fa-envelope-open-text fa-3x text-muted mb-3"></i>
                                <p class="text-muted">暂无消息记录</p>
                                <a href="${pageContext.request.contextPath}/merchant/list" class="btn btn-primary">
                                    <i class="fas fa-store me-2"></i>浏览商家
                                </a>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="list-group">
                                <c:forEach items="${chatUsers}" var="chatUser">
                                    <a href="${pageContext.request.contextPath}/message/chat?userId=${chatUser.userId}" 
                                       class="list-group-item list-group-item-action d-flex justify-content-between align-items-center">
                                        <div>
                                            <i class="fas fa-user-circle fa-2x text-primary me-3"></i>
                                            <span class="fw-bold">${chatUser.username}</span>
                                            <c:if test="${chatUser.realName != null}">
                                                <small class="text-muted">(${chatUser.realName})</small>
                                            </c:if>
                                        </div>
                                        <c:if test="${chatUser.status > 0}">
                                            <span class="badge bg-danger rounded-pill">${chatUser.status}条未读</span>
                                        </c:if>
                                    </a>
                                </c:forEach>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/jsp/common/footer.jsp"/>
