DROP DATABASE IF EXISTS forestry_system;
CREATE DATABASE forestry_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE forestry_system;

-- 1. 创建 User 表
CREATE TABLE User (
    user_id INT PRIMARY KEY COMMENT '用户ID',
    username VARCHAR(50) NOT NULL COMMENT '用户名',
    role VARCHAR(20) NOT NULL COMMENT '角色',
    phone VARCHAR(20) COMMENT '联系电话',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. 创建 Area 表 
CREATE TABLE Area (
    area_id INT PRIMARY KEY COMMENT '区域编号',
    area_name VARCHAR(100) NOT NULL COMMENT '区域名称',
    area_type VARCHAR(20) NOT NULL COMMENT '区域类型',
    manager_id INT COMMENT '负责人ID',
    longitude DECIMAL(10, 7) NOT NULL COMMENT '经度',
    latitude DECIMAL(9, 7) NOT NULL COMMENT '纬度',
    CONSTRAINT fk_area_manager FOREIGN KEY (manager_id) REFERENCES User(user_id),
    CONSTRAINT chk_longitude CHECK (longitude BETWEEN -180 AND 180),
    CONSTRAINT chk_latitude CHECK (latitude BETWEEN -90 AND 90)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. 创建 Resource 表
CREATE TABLE Resource (
    resource_id BIGINT PRIMARY KEY COMMENT '资源编号',
    area_id INT NOT NULL COMMENT '所属区域',
    res_type ENUM('树木', '草地') NOT NULL COMMENT '资源类型',
    variety VARCHAR(50) NOT NULL COMMENT '品种名称',
    amount DECIMAL(10, 2) NOT NULL COMMENT '数量或面积',
    growth_stage ENUM('幼苗', '成长期', '成熟期') NOT NULL COMMENT '生长状态',
    plant_time DATETIME COMMENT '种植时间',
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后更新时间',
    CONSTRAINT fk_res_area FOREIGN KEY (area_id) REFERENCES Area(area_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. 创建 ChangeLog 表
CREATE TABLE ChangeLog (
    log_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '变动编号',
    resource_id BIGINT NOT NULL COMMENT '关联资源',
    change_type ENUM('新增', '减少', '状态更新') NOT NULL COMMENT '变动类型',
    reason VARCHAR(255) COMMENT '变动原因',
    change_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '变动时间',
    operator_id INT NOT NULL COMMENT '操作人ID',
    CONSTRAINT fk_log_res FOREIGN KEY (resource_id) REFERENCES Resource(resource_id),
    CONSTRAINT fk_log_operator FOREIGN KEY (operator_id) REFERENCES User(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;