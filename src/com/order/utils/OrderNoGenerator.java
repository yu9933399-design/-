package com.order.utils;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.concurrent.atomic.AtomicInteger;

public class OrderNoGenerator {
    private static final AtomicInteger counter = new AtomicInteger(0);

    public static synchronized String generate() {
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyMMddHHmmss"));
        int seq = counter.incrementAndGet() % 10000;
        return "ORD" + timestamp + String.format("%04d", seq);
    }
}
