package com.order.dao;

import com.order.entity.Cart;
import java.sql.SQLException;
import java.util.List;

public class CartDAO extends BaseDAO {

    public List<Cart> findByUserId(Integer userId) throws SQLException {
        return queryList(Cart.class, "SELECT c.*, d.dish_name, d.price, d.image_url FROM cart c LEFT JOIN dish d ON c.dish_id = d.dish_id WHERE c.user_id = ? ORDER BY c.add_time DESC", userId);
    }

    public Cart findByUserAndDish(Integer userId, Integer dishId) throws SQLException {
        return queryOne(Cart.class, "SELECT * FROM cart WHERE user_id = ? AND dish_id = ?", userId, dishId);
    }

    public int insert(Cart cart) throws SQLException {
        return update("INSERT INTO cart (user_id, dish_id, quantity, add_time) VALUES (?,?,?,?)",
                cart.getUserId(), cart.getDishId(), cart.getQuantity(), cart.getAddTime());
    }

    public int updateQuantity(Integer cartId, Integer quantity) throws SQLException {
        return update("UPDATE cart SET quantity = ? WHERE cart_id = ?", quantity, cartId);
    }

    public int delete(Integer cartId) throws SQLException {
        return update("DELETE FROM cart WHERE cart_id = ?", cartId);
    }

    public int deleteByUserId(Integer userId) throws SQLException {
        return update("DELETE FROM cart WHERE user_id = ?", userId);
    }

    public long countByUserId(Integer userId) throws SQLException {
        return queryScalar("SELECT IFNULL(SUM(quantity), 0) FROM cart WHERE user_id = ?", userId);
    }

    public boolean isOwnedBy(Integer cartId, Integer userId) throws SQLException {
        return queryScalar("SELECT COUNT(*) FROM cart WHERE cart_id = ? AND user_id = ?", cartId, userId) > 0;
    }
}
