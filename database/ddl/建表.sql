DROP DATABASE IF EXISTS forestry_system;
CREATE DATABASE forestry_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE forestry_system;

-- 1. 创建 用户 表
CREATE TABLE `用户` (
    `用户ID` INT PRIMARY KEY COMMENT '用户ID',
    `用户名` VARCHAR(50) NOT NULL COMMENT '用户名',
    `角色` VARCHAR(20) NOT NULL COMMENT '角色',
    `联系电话` VARCHAR(20) COMMENT '联系电话',
    `创建时间` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. 创建 区域 表 
CREATE TABLE `区域` (
    `区域编号` INT PRIMARY KEY COMMENT '区域编号',
    `区域名称` VARCHAR(100) NOT NULL COMMENT '区域名称',
    `区域类型` VARCHAR(20) NOT NULL COMMENT '区域类型',
    `负责人ID` INT COMMENT '负责人ID',
    `经度` DECIMAL(10, 7) NOT NULL COMMENT '经度',
    `纬度` DECIMAL(9, 7) NOT NULL COMMENT '纬度',
    CONSTRAINT `fk_area_manager` FOREIGN KEY (`负责人ID`) REFERENCES `用户`(`用户ID`),
    CONSTRAINT `chk_longitude` CHECK (`经度` BETWEEN -180 AND 180),
    CONSTRAINT `chk_latitude` CHECK (`纬度` BETWEEN -90 AND 90)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. 创建 林草资源 表
CREATE TABLE `林草资源` (
    `资源编号` BIGINT PRIMARY KEY COMMENT '资源编号',
    `区域编号` INT NOT NULL COMMENT '所属区域',
    `资源类型` ENUM('树木', '草地') NOT NULL COMMENT '资源类型',
    `品种名称` VARCHAR(50) NOT NULL COMMENT '品种名称',
    `数量或面积` DECIMAL(10, 2) NOT NULL COMMENT '数量或面积',
    `生长状态` ENUM('幼苗', '成长期', '成熟期') NOT NULL COMMENT '生长状态',
    `种植时间` DATETIME COMMENT '种植时间',
    `最后更新时间` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后更新时间',
    CONSTRAINT `fk_res_area` FOREIGN KEY (`区域编号`) REFERENCES `区域`(`区域编号`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. 创建 资源变动记录 表
CREATE TABLE `资源变动记录` (
    `变动编号` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '变动编号',
    `资源编号` BIGINT NOT NULL COMMENT '关联资源',
    `变动类型` ENUM('新增', '减少', '状态更新') NOT NULL COMMENT '变动类型',
    `变动原因` VARCHAR(255) COMMENT '变动原因',
    `变动时间` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '变动时间',
    `操作人ID` INT NOT NULL COMMENT '操作人ID',
    CONSTRAINT `fk_log_res` FOREIGN KEY (`资源编号`) REFERENCES `林草资源`(`资源编号`),
    CONSTRAINT `fk_log_operator` FOREIGN KEY (`操作人ID`) REFERENCES `用户`(`用户ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;