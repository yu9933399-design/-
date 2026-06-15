package com.order.dao;

import com.order.entity.Dish;
import java.sql.SQLException;
import java.util.List;

public class DishDAO extends BaseDAO {

    private static final String BASE_JOIN = " FROM dish d LEFT JOIN category c ON d.category_id = c.category_id LEFT JOIN user u ON d.merchant_id = u.user_id ";

    public Dish findById(Integer dishId) throws SQLException {
        return queryOne(Dish.class, "SELECT d.*, c.category_name, u.username AS merchant_name" + BASE_JOIN + "WHERE d.dish_id = ?", dishId);
    }

    public List<Dish> findByCategory(Integer categoryId) throws SQLException {
        return queryList(Dish.class, "SELECT d.*, c.category_name, u.username AS merchant_name" + BASE_JOIN + "WHERE d.category_id = ? AND d.status = 1 ORDER BY d.dish_id DESC", categoryId);
    }

    public List<Dish> findRecommend() throws SQLException {
        return queryList(Dish.class, "SELECT d.*, c.category_name, u.username AS merchant_name" + BASE_JOIN + "WHERE d.is_recommend = 1 AND d.status = 1 ORDER BY d.dish_id DESC");
    }

    public List<Dish> findByMerchantId(Integer merchantId) throws SQLException {
        return queryList(Dish.class, "SELECT d.*, c.category_name, u.username AS merchant_name" + BASE_JOIN + "WHERE d.merchant_id = ? ORDER BY c.sort_order, d.dish_id", merchantId);
    }

    public List<Dish> findAll() throws SQLException {
        return queryList(Dish.class, "SELECT d.*, c.category_name, u.username AS merchant_name" + BASE_JOIN + "ORDER BY d.dish_id DESC");
    }

    public List<Dish> search(String keyword, Integer categoryId, Integer status, Integer merchantId, int offset, int pageSize) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT d.*, c.category_name, u.username AS merchant_name" + BASE_JOIN + "WHERE 1=1");
        java.util.List<Object> params = new java.util.ArrayList<>();

        if (keyword != null && !keyword.isEmpty()) {
            sql.append(" AND d.dish_name LIKE ?");
            params.add("%" + keyword + "%");
        }
        if (categoryId != null) {
            sql.append(" AND d.category_id = ?");
            params.add(categoryId);
        }
        if (status != null) {
            sql.append(" AND d.status = ?");
            params.add(status);
        }
        if (merchantId != null) {
            sql.append(" AND d.merchant_id = ?");
            params.add(merchantId);
        }
        sql.append(" ORDER BY d.status DESC, d.dish_id DESC LIMIT ?, ?");
        params.add(Math.max(0, offset));
        params.add(pageSize);

        return queryList(Dish.class, sql.toString(), params.toArray());
    }

    public long countSearch(String keyword, Integer categoryId, Integer status, Integer merchantId) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM dish WHERE 1=1");
        java.util.List<Object> params = new java.util.ArrayList<>();

        if (keyword != null && !keyword.isEmpty()) {
            sql.append(" AND dish_name LIKE ?");
            params.add("%" + keyword + "%");
        }
        if (categoryId != null) {
            sql.append(" AND category_id = ?");
            params.add(categoryId);
        }
        if (status != null) {
            sql.append(" AND status = ?");
            params.add(status);
        }
        if (merchantId != null) {
            sql.append(" AND merchant_id = ?");
            params.add(merchantId);
        }
        return queryScalar(sql.toString(), params.toArray());
    }

    public int insert(Dish dish) throws SQLException {
        return update("INSERT INTO dish (merchant_id, dish_name, price, image_url, description, stock, category_id, status, is_recommend, special_price, special_start, special_end) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)",
                dish.getMerchantId(), dish.getDishName(), dish.getPrice(), dish.getImageUrl(), dish.getDescription(),
                dish.getStock(), dish.getCategoryId(), dish.getStatus(), dish.getIsRecommend(),
                dish.getSpecialPrice(), dish.getSpecialStart(), dish.getSpecialEnd());
    }

    public int update(Dish dish) throws SQLException {
        return update("UPDATE dish SET dish_name=?, price=?, image_url=?, description=?, stock=?, category_id=?, status=?, is_recommend=?, special_price=?, special_start=?, special_end=? WHERE dish_id=?",
                dish.getDishName(), dish.getPrice(), dish.getImageUrl(), dish.getDescription(),
                dish.getStock(), dish.getCategoryId(), dish.getStatus(), dish.getIsRecommend(),
                dish.getSpecialPrice(), dish.getSpecialStart(), dish.getSpecialEnd(), dish.getDishId());
    }

    public int delete(Integer dishId) throws SQLException {
        long orderCount = queryScalar("SELECT COUNT(*) FROM order_item WHERE dish_id = ?", dishId);
        if (orderCount > 0) {
            throw new SQLException("该菜品已有订单记录，无法删除");
        }
        update("DELETE FROM cart WHERE dish_id = ?", dishId);
        return update("DELETE FROM dish WHERE dish_id = ?", dishId);
    }

    public boolean updateStock(Integer dishId, int quantity) throws SQLException {
        int rows = update("UPDATE dish SET stock = stock - ? WHERE dish_id = ? AND stock >= ?", quantity, dishId, quantity);
        return rows > 0;
    }

    public long count() throws SQLException {
        return queryScalar("SELECT COUNT(*) FROM dish");
    }

    public long countByMerchantId(Integer merchantId) throws SQLException {
        return queryScalar("SELECT COUNT(*) FROM dish WHERE merchant_id = ?", merchantId);
    }

    public List<Dish> findByRecommendAndCategory(Integer categoryId, int limit) throws SQLException {
        return queryList(Dish.class, "SELECT d.*, c.category_name, u.username AS merchant_name" + BASE_JOIN + "WHERE d.category_id = ? AND d.is_recommend = 1 AND d.status = 1 LIMIT ?", categoryId, limit);
    }

    public List<Dish> findSpecialDishes() throws SQLException {
        return queryList(Dish.class, "SELECT d.*, c.category_name, u.username AS merchant_name" + BASE_JOIN + "WHERE d.status = 1 AND d.special_price IS NOT NULL ORDER BY d.dish_id DESC LIMIT 10");
    }

    // 首页预览：每家店铺取2-3款热销菜品
    public List<Dish> findPreviewDishesByMerchant(Integer merchantId, int limit) throws SQLException {
        return queryList(Dish.class, "SELECT d.*, c.category_name, u.username AS merchant_name" + BASE_JOIN + "WHERE d.merchant_id = ? AND d.status = 1 ORDER BY d.dish_id DESC LIMIT ?", merchantId, limit);
    }

    // 店铺内：查询本店全部上架菜品
    public List<Dish> findByMerchantIdFull(Integer merchantId) throws SQLException {
        return queryList(Dish.class, "SELECT d.*, c.category_name, u.username AS merchant_name" + BASE_JOIN + "WHERE d.merchant_id = ? AND d.status = 1 ORDER BY c.sort_order, d.dish_id", merchantId);
    }
}
