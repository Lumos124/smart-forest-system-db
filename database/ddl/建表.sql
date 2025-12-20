USE `env-monitoring`;
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `监测数据`;
DROP TABLE IF EXISTS `传感器`;
DROP TABLE IF EXISTS `区域`;

CREATE TABLE `区域` (
  `区域编号` INT NOT NULL AUTO_INCREMENT COMMENT '区域编号（主键）',
  `区域名称` VARCHAR(50) NOT NULL COMMENT '区域名称',
  `区域类型` ENUM('森林','草地') NOT NULL COMMENT '区域类型（森林/草地）',
  `经度` DECIMAL(10,7) NOT NULL COMMENT '经度（建议：-180~180）',
  `纬度` DECIMAL(10,7) NOT NULL COMMENT '纬度（建议：-90~90）',
  `负责人ID` INT NOT NULL COMMENT '负责人ID',
  PRIMARY KEY (`区域编号`),
  KEY `idx_区域_负责人ID` (`负责人ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='区域';

CREATE TABLE `传感器` (
  `传感器编号` BIGINT NOT NULL AUTO_INCREMENT COMMENT '传感器编号（主键）',
  `区域编号` INT NOT NULL COMMENT '区域编号（外键）',
  `设备型号` VARCHAR(50) NOT NULL COMMENT '设备型号',
  `监测类型` ENUM('温度','湿度','图像','其他') NOT NULL COMMENT '监测类型',
  `安装时间` DATETIME NOT NULL COMMENT '安装时间',
  `通信协议` ENUM('MQTT','HTTP','CoAP','LoRa','NB-IoT','其他') NOT NULL COMMENT '通信协议',
  PRIMARY KEY (`传感器编号`),
  KEY `idx_传感器_区域编号` (`区域编号`),
  CONSTRAINT `fk_传感器_区域`
    FOREIGN KEY (`区域编号`) REFERENCES `区域` (`区域编号`)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='传感器';

CREATE TABLE `监测数据` (
  `数据编号` BIGINT NOT NULL AUTO_INCREMENT COMMENT '数据编号（主键）',
  `数据采集时间` DATETIME(3) NOT NULL COMMENT '数据采集时间（毫秒）',
  `传感器编号` BIGINT NOT NULL COMMENT '传感器编号（外键）',
  `监测数值` DECIMAL(10,3) NULL COMMENT '监测数值（温度/湿度等）',
  `图像存储路径` VARCHAR(255) NULL COMMENT '图像存储路径（图像类数据）',
  `数据状态` ENUM('有效','无效') NOT NULL COMMENT '数据状态（有效/无效）',
  PRIMARY KEY (`数据编号`),
  KEY `idx_监测数据_传感器编号_采集时间` (`传感器编号`, `数据采集时间`),
  KEY `idx_监测数据_采集时间` (`数据采集时间`),
  CONSTRAINT `fk_监测数据_传感器`
    FOREIGN KEY (`传感器编号`) REFERENCES `传感器` (`传感器编号`)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  -- 约束：至少要有“监测数值”或“图像存储路径”之一
  CONSTRAINT `ck_监测数据_值或路径` CHECK (`监测数值` IS NOT NULL OR `图像存储路径` IS NOT NULL)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='监测数据';区域

SET FOREIGN_KEY_CHECKS = 1;
