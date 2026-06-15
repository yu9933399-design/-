package com.order.service;

import com.order.dao.DishDAO;
import com.order.entity.Dish;
import java.util.List;

public class DishService {
    private DishDAO dishDAO = new DishDAO();

    public Dish getById(Integer dishId) throws Exception {
        return dishDAO.findById(dishId);
    }

    public List<Dish> findByCategory(Integer categoryId) throws Exception {
        return dishDAO.findByCategory(categoryId);
    }

    public List<Dish> findRecommend() throws Exception {
        return dishDAO.findRecommend();
    }

    public List<Dish> findByMerchantId(Integer merchantId) throws Exception {
        return dishDAO.findByMerchantId(merchantId);
    }

    public List<Dish> findAll() throws Exception {
        return dishDAO.findAll();
    }

    public List<Dish> search(String keyword, Integer categoryId, Integer status, Integer merchantId, int page, int pageSize) throws Exception {
        if (page < 1) page = 1;
        int offset = (page - 1) * pageSize;
        return dishDAO.search(keyword, categoryId, status, merchantId, offset, pageSize);
    }

    public long countSearch(String keyword, Integer categoryId, Integer status, Integer merchantId) throws Exception {
        return dishDAO.countSearch(keyword, categoryId, status, merchantId);
    }

    public void save(Dish dish) throws Exception {
        validateDish(dish);
        dishDAO.insert(dish);
    }

    public void update(Dish dish) throws Exception {
        validateDish(dish);
        dishDAO.update(dish);
    }

    private void validateDish(Dish dish) throws Exception {
        if (dish.getDishName() == null || dish.getDishName().trim().isEmpty()) {
            throw new Exception("菜品名称不能为空");
        }
        if (dish.getDishName().length() > 50) {
            throw new Exception("菜品名称长度不能超过50个字符");
        }
        if (dish.getPrice() == null || dish.getPrice().doubleValue() <= 0) {
            throw new Exception("菜品价格必须大于0");
        }
        if (dish.getStock() == null || dish.getStock() < 0) {
            throw new Exception("库存不能为负数");
        }
        if (dish.getDescription() != null && dish.getDescription().length() > 500) {
            throw new Exception("菜品描述长度不能超过500个字符");
        }
        if (dish.getImageUrl() != null && dish.getImageUrl().length() > 200) {
            throw new Exception("图片地址长度不能超过200个字符");
        }
    }

    public void delete(Integer dishId) throws Exception {
        dishDAO.delete(dishId);
    }

    public List<Dish> findByRecommendAndCategory(Integer categoryId, int limit) throws Exception {
        return dishDAO.findByRecommendAndCategory(categoryId, limit);
    }

    public long count() throws Exception {
        return dishDAO.count();
    }

    public long countByMerchantId(Integer merchantId) throws Exception {
        return dishDAO.countByMerchantId(merchantId);
    }
}
