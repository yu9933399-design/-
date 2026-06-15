package com.order.dao;

import com.order.entity.Banner;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BannerDAO extends BaseDAO {

    public List<Banner> findAllActive() throws SQLException {
        return queryList(Banner.class, "SELECT * FROM banner WHERE status = 1 ORDER BY sort_order ASC, banner_id DESC");
    }

    public List<Banner> findAll() throws SQLException {
        return queryList(Banner.class, "SELECT * FROM banner ORDER BY sort_order ASC, banner_id DESC");
    }

    public int insert(Banner b) throws SQLException {
        return update("INSERT INTO banner (title, subtitle, image_url, link_url, sort_order, status, create_time) VALUES (?,?,?,?,?,?,?)",
                b.getTitle(), b.getSubtitle(), b.getImageUrl(), b.getLinkUrl(), b.getSortOrder(), b.getStatus(), b.getCreateTime());
    }

    public int update(Banner b) throws SQLException {
        return update("UPDATE banner SET title=?, subtitle=?, image_url=?, link_url=?, sort_order=?, status=? WHERE banner_id=?",
                b.getTitle(), b.getSubtitle(), b.getImageUrl(), b.getLinkUrl(), b.getSortOrder(), b.getStatus(), b.getBannerId());
    }

    public int delete(Integer bannerId) throws SQLException {
        return update("DELETE FROM banner WHERE banner_id = ?", bannerId);
    }
}
