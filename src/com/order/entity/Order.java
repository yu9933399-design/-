package com.order.entity;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class Order {
    private Integer orderId;
    private String orderNo;
    private Integer userId;
    private Integer shopId;
    private String receiverName;
    private String receiverPhone;
    private String receiverAddress;
    private BigDecimal totalAmount;
    private String paymentMethod;
    private Integer orderStatus;
    private LocalDateTime createTime;
    private LocalDateTime payTime;
    private LocalDateTime acceptTime;
    private String cancelReason;
    private Integer deliveryStatus;
    private String deliveryPosition;

    private String username;

    public Order() {}

    public Integer getOrderId() { return orderId; }
    public void setOrderId(Integer orderId) { this.orderId = orderId; }
    public String getOrderNo() { return orderNo; }
    public void setOrderNo(String orderNo) { this.orderNo = orderNo; }
    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }
    public Integer getShopId() { return shopId; }
    public void setShopId(Integer shopId) { this.shopId = shopId; }
    public String getReceiverName() { return receiverName; }
    public void setReceiverName(String receiverName) { this.receiverName = receiverName; }
    public String getReceiverPhone() { return receiverPhone; }
    public void setReceiverPhone(String receiverPhone) { this.receiverPhone = receiverPhone; }
    public String getReceiverAddress() { return receiverAddress; }
    public void setReceiverAddress(String receiverAddress) { this.receiverAddress = receiverAddress; }
    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }
    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
    public Integer getOrderStatus() { return orderStatus; }
    public void setOrderStatus(Integer orderStatus) { this.orderStatus = orderStatus; }
    public LocalDateTime getCreateTime() { return createTime; }
    public void setCreateTime(LocalDateTime createTime) { this.createTime = createTime; }
    public LocalDateTime getPayTime() { return payTime; }
    public void setPayTime(LocalDateTime payTime) { this.payTime = payTime; }
    public LocalDateTime getAcceptTime() { return acceptTime; }
    public void setAcceptTime(LocalDateTime acceptTime) { this.acceptTime = acceptTime; }
    public String getCancelReason() { return cancelReason; }
    public void setCancelReason(String cancelReason) { this.cancelReason = cancelReason; }
    public Integer getDeliveryStatus() { return deliveryStatus; }
    public void setDeliveryStatus(Integer deliveryStatus) { this.deliveryStatus = deliveryStatus; }
    public String getDeliveryPosition() { return deliveryPosition; }
    public void setDeliveryPosition(String deliveryPosition) { this.deliveryPosition = deliveryPosition; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
}
