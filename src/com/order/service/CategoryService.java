package com.order.service;

import com.order.dao.CategoryDAO;
import com.order.entity.Category;
import java.util.List;

public class CategoryService {
    private CategoryDAO categoryDAO = new CategoryDAO();

    public List<Category> findAll() throws Exception {
        return categoryDAO.findAll();
    }

    public Category getById(Integer categoryId) throws Exception {
        return categoryDAO.findById(categoryId);
    }

    public void save(Category category) throws Exception {
        if (category.getCategoryName() == null || category.getCategoryName().trim().isEmpty()) {
            throw new Exception("分类名称不能为空");
        }
        if (category.getCategoryName().length() > 30) {
            throw new Exception("分类名称长度不能超过30个字符");
        }
        categoryDAO.insert(category);
    }

    public void update(Category category) throws Exception {
        if (category.getCategoryName() == null || category.getCategoryName().trim().isEmpty()) {
            throw new Exception("分类名称不能为空");
        }
        if (category.getCategoryName().length() > 30) {
            throw new Exception("分类名称长度不能超过30个字符");
        }
        categoryDAO.update(category);
    }

    public void delete(Integer categoryId) throws Exception {
        categoryDAO.delete(categoryId);
    }

    public long count() throws Exception {
        return categoryDAO.count();
    }

    public long countByCategoryId(Integer categoryId) throws Exception {
        return categoryDAO.countByCategoryId(categoryId);
    }
}
