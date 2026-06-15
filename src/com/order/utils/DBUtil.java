package com.order.utils;

import com.alibaba.druid.pool.DruidDataSourceFactory;
import javax.sql.DataSource;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Properties;

public class DBUtil {
    private static DataSource dataSource;

    static {
        InputStream is = null;
        try {
            Properties props = new Properties();
            is = DBUtil.class.getClassLoader().getResourceAsStream("druid.properties");
            props.load(is);
            dataSource = DruidDataSourceFactory.createDataSource(props);
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("init db failed", e);
        } finally {
            if (is != null) {
                try { is.close(); } catch (Exception e) { e.printStackTrace(); }
            }
        }
    }

    public static Connection getConnection() throws SQLException {
        return dataSource.getConnection();
    }

    public static void close(AutoCloseable... resources) {
        for (AutoCloseable r : resources) {
            if (r != null) {
                try { r.close(); } catch (Exception e) { e.printStackTrace(); }
            }
        }
    }
}
