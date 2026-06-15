package com.order.dao;

import com.order.utils.CamelCaseRowProcessor;
import com.order.utils.DBUtil;
import org.apache.commons.dbutils.QueryRunner;
import org.apache.commons.dbutils.handlers.ScalarHandler;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

public class BaseDAO {
    protected QueryRunner runner = new QueryRunner();

    @SuppressWarnings("unchecked")
    protected <T> T queryOne(Class<T> clazz, String sql, Object... params) throws SQLException {
        Connection conn = DBUtil.getConnection();
        try {
            return (T) runner.query(conn, sql, CamelCaseRowProcessor.createBeanHandler(clazz), params);
        } finally {
            DBUtil.close(conn);
        }
    }

    @SuppressWarnings("unchecked")
    protected <T> List<T> queryList(Class<T> clazz, String sql, Object... params) throws SQLException {
        Connection conn = DBUtil.getConnection();
        try {
            return (List<T>) runner.query(conn, sql, CamelCaseRowProcessor.createBeanListHandler(clazz), params);
        } finally {
            DBUtil.close(conn);
        }
    }

    protected long queryScalar(String sql, Object... params) throws SQLException {
        Connection conn = DBUtil.getConnection();
        try {
            Object result = runner.query(conn, sql, new ScalarHandler<>(), params);
            if (result instanceof Number) {
                return ((Number) result).longValue();
            }
            return 0;
        } finally {
            DBUtil.close(conn);
        }
    }

    protected int update(String sql, Object... params) throws SQLException {
        Connection conn = DBUtil.getConnection();
        try {
            return runner.update(conn, sql, params);
        } finally {
            DBUtil.close(conn);
        }
    }
}
