package com.order.dao;

import com.order.entity.User;
import java.sql.SQLException;
import java.util.List;

public class UserDAO extends BaseDAO {

    public User findByUsername(String username) throws SQLException {
        return queryOne(User.class, "SELECT * FROM user WHERE username = ?", username);
    }

    public User findByEmail(String email) throws SQLException {
        return queryOne(User.class, "SELECT * FROM user WHERE email = ?", email);
    }

    public User findById(Integer userId) throws SQLException {
        return queryOne(User.class, "SELECT * FROM user WHERE user_id = ?", userId);
    }

    public int insert(User user) throws SQLException {
        return update("INSERT INTO user (username, password, real_name, phone, email, address, role, status, shop_category) VALUES (?,?,?,?,?,?,?,?,?)",
                user.getUsername(), user.getPassword(), user.getRealName(),
                user.getPhone(), user.getEmail(), user.getAddress(),
                user.getRole(), user.getStatus(), user.getShopCategory());
    }

    public int update(User user) throws SQLException {
        return update("UPDATE user SET real_name=?, phone=?, email=?, address=? WHERE user_id=?",
                user.getRealName(), user.getPhone(), user.getEmail(), user.getAddress(), user.getUserId());
    }

    public int updatePassword(Integer userId, String password) throws SQLException {
        return update("UPDATE user SET password=? WHERE user_id=?", password, userId);
    }

    public int updateStatus(Integer userId, Integer status) throws SQLException {
        return update("UPDATE user SET status=? WHERE user_id=?", status, userId);
    }

    public int updateRole(Integer userId, Integer role) throws SQLException {
        return update("UPDATE user SET role=? WHERE user_id=?", role, userId);
    }

    public List<User> findAll() throws SQLException {
        return queryList(User.class, "SELECT * FROM user ORDER BY user_id DESC");
    }

    public List<User> search(String keyword) throws SQLException {
        return queryList(User.class, "SELECT * FROM user WHERE username LIKE ? OR real_name LIKE ? OR phone LIKE ? ORDER BY user_id DESC",
                "%" + keyword + "%", "%" + keyword + "%", "%" + keyword + "%");
    }

    public long count() throws SQLException {
        return queryScalar("SELECT COUNT(*) FROM user");
    }

    public long countByRole(Integer role) throws SQLException {
        if (role == null) return count();
        return queryScalar("SELECT COUNT(*) FROM user WHERE role = ?", role);
    }

    public long countWithKeyword(String keyword) throws SQLException {
        if (keyword == null || keyword.trim().isEmpty()) return count();
        return queryScalar("SELECT COUNT(*) FROM user WHERE username LIKE ? OR real_name LIKE ? OR phone LIKE ?",
                "%" + keyword + "%", "%" + keyword + "%", "%" + keyword + "%");
    }

    public long countByRoleWithKeyword(Integer role, String keyword) throws SQLException {
        if (role == null) return countWithKeyword(keyword);
        if (keyword == null || keyword.trim().isEmpty()) return countByRole(role);
        return queryScalar("SELECT COUNT(*) FROM user WHERE role = ? AND (username LIKE ? OR real_name LIKE ? OR phone LIKE ?)",
                role, "%" + keyword + "%", "%" + keyword + "%", "%" + keyword + "%");
    }

    public List<User> findAllPaged(int page, int pageSize) throws SQLException {
        int offset = (page - 1) * pageSize;
        return queryList(User.class, "SELECT * FROM user ORDER BY user_id DESC LIMIT ?, ?", offset, pageSize);
    }

    public List<User> findByRolePaged(Integer role, int page, int pageSize, String sort) throws SQLException {
        int offset = (page - 1) * pageSize;
        String orderClause = "time".equals(sort) ? " ORDER BY user_id DESC" : " ORDER BY role ASC, user_id DESC";
        if (role == null) {
            return queryList(User.class, "SELECT * FROM user" + orderClause + " LIMIT ?, ?", offset, pageSize);
        }
        return queryList(User.class, "SELECT * FROM user WHERE role = ?" + orderClause + " LIMIT ?, ?", role, offset, pageSize);
    }

    public List<User> findByRoleWithKeywordPaged(Integer role, String keyword, int page, int pageSize, String sort) throws SQLException {
        int offset = (page - 1) * pageSize;
        String orderClause = "time".equals(sort) ? " ORDER BY user_id DESC" : " ORDER BY role ASC, user_id DESC";
        if (role == null) {
            return queryList(User.class, "SELECT * FROM user WHERE username LIKE ? OR real_name LIKE ? OR phone LIKE ?" + orderClause + " LIMIT ?, ?",
                    "%" + keyword + "%", "%" + keyword + "%", "%" + keyword + "%", offset, pageSize);
        }
        return queryList(User.class, "SELECT * FROM user WHERE role = ? AND (username LIKE ? OR real_name LIKE ? OR phone LIKE ?)" + orderClause + " LIMIT ?, ?",
                role, "%" + keyword + "%", "%" + keyword + "%", "%" + keyword + "%", offset, pageSize);
    }

    public List<User> findAllByRoleAndStatus(Integer role, Integer status) throws SQLException {
        return queryList(User.class, "SELECT * FROM user WHERE role = ? AND status = ? ORDER BY user_id DESC", role, status);
    }

    public List<User> findMerchantsByCategory(String category) throws SQLException {
        if (category == null || category.trim().isEmpty()) {
            return findAllByRoleAndStatus(2, 0);
        }
        return queryList(User.class, "SELECT * FROM user WHERE role = 2 AND status = 0 AND shop_category = ? ORDER BY user_id DESC", category.trim());
    }

    public List<User> findMerchantsByCategoryPaged(String category, int page, int pageSize) throws SQLException {
        int offset = (page - 1) * pageSize;
        if (category == null || category.trim().isEmpty()) {
            return queryList(User.class, "SELECT * FROM user WHERE role = 2 AND status = 0 ORDER BY user_id DESC LIMIT ?, ?", offset, pageSize);
        }
        return queryList(User.class, "SELECT * FROM user WHERE role = 2 AND status = 0 AND shop_category = ? ORDER BY user_id DESC LIMIT ?, ?", category.trim(), offset, pageSize);
    }

    public long countMerchantsByCategory(String category) throws SQLException {
        if (category == null || category.trim().isEmpty()) {
            return queryScalar("SELECT COUNT(*) FROM user WHERE role = 2 AND status = 0");
        }
        return queryScalar("SELECT COUNT(*) FROM user WHERE role = 2 AND status = 0 AND shop_category = ?", category.trim());
    }

    public int updateShopCategory(Integer userId, String shopCategory) throws SQLException {
        return update("UPDATE user SET shop_category = ? WHERE user_id = ?", shopCategory, userId);
    }

    public int updateMerchantSettings(User user) throws SQLException {
        return update("UPDATE user SET real_name = ?, phone = ?, shop_category = ? WHERE user_id = ?",
                user.getRealName(), user.getPhone(), user.getShopCategory(), user.getUserId());
    }
}
