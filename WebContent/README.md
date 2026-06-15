# 网上订餐管理系统 (OnlineOrder)

基于 JSP + Servlet + JDBC + Druid 连接池的网上订餐系统。

## 技术栈
- JDK 1.8
- Servlet 4.0 / JSP
- MySQL 8.0
- Druid 1.2.8 连接池
- Apache Commons DBUtils 1.7
- BCrypt (jBCrypt) 密码加密
- Bootstrap 5 + jQuery + Font Awesome 6

## 在 Eclipse 中导入项目

1. 打开 Eclipse → File → Import → Existing Projects into Workspace
2. 选择 OnlineOrder 目录，点击 Finish

## 配置 Tomcat 9

1. Window → Preferences → Server → Runtime Environments → Add
2. 选择 Apache Tomcat v9.0，设置安装路径
3. 右键项目 → Properties → Project Facets → 勾选 Dynamic Web Module (4.0)
4. 右键项目 → Properties → Targeted Runtimes → 勾选 Tomcat 9.0
5. 右键项目 → Run As → Run on Server

## 创建 MySQL 数据库

```sql
source sql/schema.sql;
source sql/data.sql;
```

或使用 Navicat 执行这两个 SQL 文件。

## 修改数据库配置

编辑 `src/druid.properties` 中的数据库连接信息：

```properties
url=jdbc:mysql://localhost:3306/online_order_db?...
username=root
password=root
```

## 默认账号

| 角色 | 用户名 | 密码 |
|------|--------|------|
| 管理员 | admin | 123456 |
| 普通用户 | user1 | 123456 |

## 访问地址

- 前台首页：http://localhost:8080/OnlineOrder/
- 后台管理：http://localhost:8080/OnlineOrder/admin

## 功能模块

### 前台
- 用户注册/登录
- 菜品浏览、分类筛选、搜索
- 购物车管理 (Ajax)
- 订单提交 (JDBC 事务)
- 个人中心

### 后台
- 菜品管理 (CRUD)
- 分类管理
- 订单管理 (状态流转)
- 用户管理 (禁用/启用/重置密码)

## 项目结构

```
OnlineOrder/
├── src/
│   └── com/order/
│       ├── dao/          # 数据访问层
│       ├── entity/       # 实体类
│       ├── service/      # 业务逻辑层
│       ├── servlet/      # Servlet 控制器
│       │   └── admin/    # 后台管理 Servlet
│       ├── filter/       # 过滤器
│       └── utils/        # 工具类
├── WebContent/
│   ├── WEB-INF/
│   │   ├── lib/          # JAR 依赖
│   │   ├── web.xml       # 部署描述符
│   │   └── jsp/          # JSP 页面
│   ├── css/              # 样式文件
│   ├── js/               # 脚本文件
│   └── images/           # 图片资源
└── sql/                  # 数据库脚本
```

## JAR 依赖 (WebContent/WEB-INF/lib/)

- mysql-connector-java-8.0.33.jar
- druid-1.2.8.jar
- commons-dbutils-1.7.jar
- jstl-1.2.jar
- jBCrypt (bcrypt-java-0.2.jar)
