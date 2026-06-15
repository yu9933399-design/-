package com.order.service;

import com.order.dao.UserDAO;
import com.order.entity.User;
import com.order.utils.BCryptUtil;
import java.util.List;

public class UserService {
    private UserDAO userDAO = new UserDAO();

    public User register(String username, String password, String phone, String email, boolean isMerchant, String shopName) throws Exception {
        if (username == null || username.trim().isEmpty()) {
            throw new Exception("用户名不能为空");
        }
        if (username.trim().length() > 30) {
            throw new Exception("用户名长度不能超过30个字符");
        }
        if (password == null || password.trim().isEmpty()) {
            throw new Exception("密码不能为空");
        }
        if (phone == null || phone.trim().isEmpty()) {
            throw new Exception("手机号不能为空");
        }
        if (phone.trim().length() > 15) {
            throw new Exception("手机号长度不能超过15个字符");
        }
        if (email != null && email.length() > 50) {
            throw new Exception("邮箱长度不能超过50个字符");
        }
        if (shopName != null && shopName.length() > 20) {
            throw new Exception("店铺名称长度不能超过20个字符");
        }
        if (userDAO.findByUsername(username) != null) {
            throw new Exception("用户名已存在");
        }
        User user = new User();
        user.setUsername(username.trim());
        user.setPassword(BCryptUtil.hashPassword(password));
        user.setPhone(phone);
        user.setEmail(email);
        user.setRealName(shopName);
        if (isMerchant) {
            user.setRole(2);
            user.setStatus(2);
        } else {
            user.setRole(0);
            user.setStatus(0);
        }
        userDAO.insert(user);
        return user;
    }

    public User login(String username, String password, String loginType) throws Exception {
        if (username == null || password == null) {
            throw new Exception("用户名或密码错误");
        }
        User user = userDAO.findByUsername(username);
        if (user == null) {
            throw new Exception("用户名或密码错误");
        }
        if (user.getPassword() == null || !BCryptUtil.checkPassword(password, user.getPassword())) {
            throw new Exception("用户名或密码错误");
        }
        if (user.getStatus() != null && user.getStatus() == 1) {
            throw new Exception("账号已被禁用");
        }
        if (user.getStatus() != null && user.getStatus() == 2) {
            throw new Exception("商家账号正在审核中，请等待管理员审核");
        }
        if ("admin".equals(loginType)) {
            if (user.getRole() == null || user.getRole() != 1) {
                throw new Exception("账号不是管理员，无法登录管理后台");
            }
        } else if ("merchant".equals(loginType)) {
            if (user.getRole() == null || user.getRole() != 2) {
                throw new Exception("账号不是商家，请使用用户登录");
            }
        } else {
            if (user.getRole() != null && user.getRole() != 0) {
                throw new Exception("请使用对应的登录入口");
            }
        }
        return user;
    }

    public User getById(Integer userId) throws Exception {
        return userDAO.findById(userId);
    }

    public void updateProfile(User user) throws Exception {
        userDAO.update(user);
    }

    public void updatePassword(Integer userId, String oldPassword, String newPassword) throws Exception {
        User user = userDAO.findById(userId);
        if (user == null) {
            throw new Exception("用户不存在");
        }
        if (user.getPassword() == null || !BCryptUtil.checkPassword(oldPassword, user.getPassword())) {
            throw new Exception("原密码错误");
        }
        userDAO.updatePassword(userId, BCryptUtil.hashPassword(newPassword));
    }

    public List<User> findAll() throws Exception {
        return userDAO.findAll();
    }

    public List<User> search(String keyword) throws Exception {
        return userDAO.search(keyword);
    }

    public void updateStatus(Integer userId, Integer status) throws Exception {
        userDAO.updateStatus(userId, status);
    }

    public void resetPassword(Integer userId) throws Exception {
        userDAO.updatePassword(userId, BCryptUtil.hashPassword("123456"));
    }

    public void updateRole(Integer userId, Integer role) throws Exception {
        userDAO.updateRole(userId, role);
    }

    public long count() throws Exception {
        return userDAO.count();
    }

    public List<User> findAllByRoleAndStatus(Integer role, Integer status) throws Exception {
        return userDAO.findAllByRoleAndStatus(role, status);
    }
}
