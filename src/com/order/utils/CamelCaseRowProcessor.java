package com.order.utils;

import org.apache.commons.dbutils.RowProcessor;
import org.apache.commons.dbutils.handlers.BeanHandler;
import org.apache.commons.dbutils.handlers.BeanListHandler;

import java.beans.BeanInfo;
import java.beans.Introspector;
import java.beans.PropertyDescriptor;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class CamelCaseRowProcessor implements RowProcessor {

    public Object toBean(ResultSet rs, Class type) throws SQLException {
        try {
            BeanInfo beanInfo = Introspector.getBeanInfo(type);
            PropertyDescriptor[] pds = beanInfo.getPropertyDescriptors();
            Object bean = type.newInstance();

            ResultSetMetaData rsmd = rs.getMetaData();
            int columnCount = rsmd.getColumnCount();

            for (int index = 1; index <= columnCount; index++) {
                String columnName = rsmd.getColumnLabel(index);
                String propertyName = toCamelCase(columnName);

                for (PropertyDescriptor pd : pds) {
                    if (pd.getName().equals(propertyName) && pd.getWriteMethod() != null) {
                        Object value = rs.getObject(index);
                        if (value != null) {
                            Class<?> paramType = pd.getWriteMethod().getParameterTypes()[0];
                            if (value instanceof Timestamp && paramType == LocalDateTime.class) {
                                value = ((Timestamp) value).toLocalDateTime();
                            } else if (value instanceof Boolean && (paramType == Integer.class || paramType == int.class)) {
                                value = ((Boolean) value) ? 1 : 0;
                            } else if (value instanceof Number && (paramType == Boolean.class || paramType == boolean.class)) {
                                value = ((Number) value).intValue() != 0;
                            }
                            pd.getWriteMethod().invoke(bean, value);
                        }
                        break;
                    }
                }
            }
            return bean;
        } catch (Exception e) {
            throw new SQLException("Failed to populate bean: " + e.getMessage(), e);
        }
    }

    public List toBeanList(ResultSet rs, Class type) throws SQLException {
        List list = new ArrayList();
        while (rs.next()) {
            list.add(toBean(rs, type));
        }
        return list;
    }

    public Object[] toArray(ResultSet rs) throws SQLException {
        ResultSetMetaData rsmd = rs.getMetaData();
        int cols = rsmd.getColumnCount();
        Object[] result = new Object[cols];
        for (int i = 0; i < cols; i++) {
            result[i] = rs.getObject(i + 1);
        }
        return result;
    }

    public Map toMap(ResultSet rs) throws SQLException {
        Map map = new HashMap();
        ResultSetMetaData rsmd = rs.getMetaData();
        int cols = rsmd.getColumnCount();
        for (int i = 1; i <= cols; i++) {
            map.put(rsmd.getColumnLabel(i), rs.getObject(i));
        }
        return map;
    }

    private String toCamelCase(String input) {
        if (input == null || input.isEmpty()) return input;
        StringBuilder sb = new StringBuilder();
        boolean nextUpper = false;
        for (char c : input.toCharArray()) {
            if (c == '_') {
                nextUpper = true;
            } else {
                if (nextUpper) {
                    sb.append(Character.toUpperCase(c));
                    nextUpper = false;
                } else {
                    sb.append(Character.toLowerCase(c));
                }
            }
        }
        return sb.toString();
    }

    public static BeanHandler createBeanHandler(Class clazz) {
        return new BeanHandler(clazz, new CamelCaseRowProcessor());
    }

    public static BeanListHandler createBeanListHandler(Class clazz) {
        return new BeanListHandler(clazz, new CamelCaseRowProcessor());
    }
}
