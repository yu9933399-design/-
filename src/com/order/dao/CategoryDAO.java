package com.order.dao;

import com.order.entity.Category;
import java.sql.SQLException;
import java.util.List;

public class CategoryDAO extends BaseDAO {

    public List<Category> findAll() throws SQLException {
        return queryList(Category.class, "SELECT * FROM category ORDER BY sort_order ASC");
    }

    public Category findById(Integer categoryId) throws SQLException {
        return queryOne(Category.class, "SELECT * FROM category WHERE category_id = ?", categoryId);
    }

    public int insert(Category category) throws SQLException {
        return update("INSERT INTO category (category_name, sort_order) VALUES (?, ?)",
                category.getCategoryName(), category.getSortOrder());
    }

    public int update(Category category) throws SQLException {
        return update("UPDATE category SET category_name=?, sort_order=? WHERE category_id=?",
                category.getCategoryName(), category.getSortOrder(), category.getCategoryId());
    }

    public int delete(Integer categoryId) throws SQLException {
        long dishCount = queryScalar("SELECT COUNT(*) FROM dish WHERE category_id = ?", categoryId);
        if (dishCount > 0) {
            throw new SQLException("该分类下还有菜品，无法删除");
        }
        return update("DELETE FROM category WHERE category_id = ?", categoryId);
    }

    public long count() throws SQLException {
        return queryScalar("SELECT COUNT(*) FROM category");
    }

    public long countByCategoryId(Integer categoryId) throws SQLException {
        return queryScalar("SELECT COUNT(*) FROM dish WHERE category_id = ?", categoryId);
    }
}
