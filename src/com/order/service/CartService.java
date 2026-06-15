package com.order.service;

import com.order.dao.CartDAO;
import com.order.entity.Cart;
import java.time.LocalDateTime;
import java.util.List;

public class CartService {
    private CartDAO cartDAO = new CartDAO();

    public void addToCart(Integer userId, Integer dishId, Integer quantity) throws Exception {
        if (quantity == null || quantity <= 0) {
            quantity = 1;
        }
        Cart existing = cartDAO.findByUserAndDish(userId, dishId);
        if (existing != null) {
            existing.setQuantity(existing.getQuantity() + quantity);
            cartDAO.updateQuantity(existing.getCartId(), existing.getQuantity());
        } else {
            Cart cart = new Cart();
            cart.setUserId(userId);
            cart.setDishId(dishId);
            cart.setQuantity(quantity);
            cart.setAddTime(LocalDateTime.now());
            cartDAO.insert(cart);
        }
    }

    public List<Cart> getCartByUserId(Integer userId) throws Exception {
        return cartDAO.findByUserId(userId);
    }

    public List<Cart> getCartByUserIdAndShopId(Integer userId, Integer shopId) throws Exception {
        return cartDAO.findByUserIdAndShopId(userId, shopId);
    }

    public void updateQuantity(Integer cartId, Integer quantity) throws Exception {
        if (quantity == null || quantity <= 0) {
            throw new Exception("数量必须大于0");
        }
        cartDAO.updateQuantity(cartId, quantity);
    }

    public void removeFromCart(Integer cartId) throws Exception {
        cartDAO.delete(cartId);
    }

    public void clearCart(Integer userId) throws Exception {
        cartDAO.deleteByUserId(userId);
    }

    public long getCartCount(Integer userId) throws Exception {
        return cartDAO.countByUserId(userId);
    }

    public boolean isOwnedBy(Integer cartId, Integer userId) throws Exception {
        return cartDAO.isOwnedBy(cartId, userId);
    }
}
