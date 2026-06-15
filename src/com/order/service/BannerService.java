package com.order.service;

import com.order.dao.BannerDAO;
import com.order.entity.Banner;
import java.util.List;

public class BannerService {
    private BannerDAO bannerDAO = new BannerDAO();

    public List<Banner> findAllActive() throws Exception {
        return bannerDAO.findAllActive();
    }

    public List<Banner> findAll() throws Exception {
        return bannerDAO.findAll();
    }

    public void save(Banner b) throws Exception {
        if (b.getStatus() == null) b.setStatus(1);
        if (b.getSortOrder() == null) b.setSortOrder(0);
        b.setCreateTime(java.time.LocalDateTime.now());
        bannerDAO.insert(b);
    }

    public void update(Banner b) throws Exception {
        bannerDAO.update(b);
    }

    public void delete(Integer bannerId) throws Exception {
        bannerDAO.delete(bannerId);
    }
}
