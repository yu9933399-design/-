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
        return update("INSERT INTO user (username, password, real_name, phone, email, address, role, status) VALUES (?,?,?,?,?,?,?,?)",
                user.getUsername(), user.getPassword(), user.getRealName(),
                user.getPhone(), user.getEmail(), user.getAddress(),
                user.getRole(), user.getStatus());
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

    public List<User> findAllByRoleAndStatus(Integer role, Integer status) throws SQLException {
        return queryList(User.class, "SELECT * FROM user WHERE role = ? AND status = ? ORDER BY user_id DESC", role, status);
    }
}
