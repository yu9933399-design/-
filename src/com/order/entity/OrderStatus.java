package com.order.entity;

public class OrderStatus {
    public static final int PENDING_PAYMENT = 1;
    public static final int PENDING_ACCEPT = 2;
    public static final int ACCEPTED = 4;
    public static final int PREPARING = 5;
    public static final int DELIVERING = 6;
    public static final int COMPLETED = 8;
    public static final int CANCELLED = 9;

    public static String getName(int status) {
        switch (status) {
            case PENDING_PAYMENT: return "待支付";
            case PENDING_ACCEPT: return "待接单";
            case ACCEPTED: return "已接单";
            case PREPARING: return "制作中";
            case DELIVERING: return "配送中";
            case COMPLETED: return "已完成";
            case CANCELLED: return "已取消";
            default: return "未知";
        }
    }

    public static String getBadgeClass(int status) {
        switch (status) {
            case PENDING_PAYMENT: return "bg-warning";
            case PENDING_ACCEPT: return "bg-info";
            case ACCEPTED: return "bg-primary";
            case PREPARING: return "bg-primary";
            case DELIVERING: return "bg-success";
            case COMPLETED: return "bg-success";
            case CANCELLED: return "bg-secondary";
            default: return "bg-secondary";
        }
    }
}
