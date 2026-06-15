package com.order.entity;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class Dish {
    private Integer dishId;
    private Integer merchantId;
    private String dishName;
    private BigDecimal price;
    private String imageUrl;
    private String description;
    private Integer stock;
    private Integer categoryId;
    private Integer status;
    private Integer isRecommend;
    private BigDecimal specialPrice;
    private LocalDateTime specialStart;
    private LocalDateTime specialEnd;

    private String categoryName;
    private String merchantName;

    public Dish() {}

    public Integer getDishId() { return dishId; }
    public void setDishId(Integer dishId) { this.dishId = dishId; }
    public Integer getMerchantId() { return merchantId; }
    public void setMerchantId(Integer merchantId) { this.merchantId = merchantId; }
    public String getDishName() { return dishName; }
    public void setDishName(String dishName) { this.dishName = dishName; }
    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public Integer getStock() { return stock; }
    public void setStock(Integer stock) { this.stock = stock; }
    public Integer getCategoryId() { return categoryId; }
    public void setCategoryId(Integer categoryId) { this.categoryId = categoryId; }
    public Integer getStatus() { return status; }
    public void setStatus(Integer status) { this.status = status; }
    public Integer getIsRecommend() { return isRecommend; }
    public void setIsRecommend(Integer isRecommend) { this.isRecommend = isRecommend; }
    public BigDecimal getSpecialPrice() { return specialPrice; }
    public void setSpecialPrice(BigDecimal specialPrice) { this.specialPrice = specialPrice; }
    public LocalDateTime getSpecialStart() { return specialStart; }
    public void setSpecialStart(LocalDateTime specialStart) { this.specialStart = specialStart; }
    public LocalDateTime getSpecialEnd() { return specialEnd; }
    public void setSpecialEnd(LocalDateTime specialEnd) { this.specialEnd = specialEnd; }
    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }
    public String getMerchantName() { return merchantName; }
    public void setMerchantName(String merchantName) { this.merchantName = merchantName; }
}
