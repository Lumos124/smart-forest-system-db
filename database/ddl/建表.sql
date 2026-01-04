
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `维护记录`;
DROP TABLE IF EXISTS `设备状态`;
DROP TABLE IF EXISTS `设备档案`;

-- 1. 设备档案表
CREATE TABLE `设备档案` (
  `设备编号` INT NOT NULL AUTO_INCREMENT COMMENT '设备编号 (主键)',
  `设备名称` VARCHAR(100) NOT NULL COMMENT '设备名称',
  `设备类型` ENUM('传感器', '摄像头', '预警器', '其他') NOT NULL COMMENT '设备类型',
  `型号规格` VARCHAR(50) COMMENT '型号规格',
  `采购时间` DATE COMMENT '采购时间',
  `质保期` INT COMMENT '质保期(月)',
  `状态` ENUM('正常', '停用', '报废', '故障', '离线') DEFAULT '正常' COMMENT '当前状态',
  `区域编号` INT NOT NULL COMMENT '安装区域ID (外键)',
  `安装人ID` INT COMMENT '安装人员ID (外键)',
  PRIMARY KEY (`设备编号`),
  KEY `idx_设备_区域` (`区域编号`),
  CONSTRAINT `fk_设备_区域` FOREIGN KEY (`区域编号`) REFERENCES `区域` (`区域编号`),
  CONSTRAINT `fk_设备_安装人` FOREIGN KEY (`安装人ID`) REFERENCES `用户` (`用户ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='设备档案表';

-- 2. 设备状态表
CREATE TABLE `设备状态` (
  `状态编号` INT NOT NULL AUTO_INCREMENT COMMENT '状态编号 (主键)',
  `设备编号` INT NOT NULL COMMENT '设备编号 (外键)',
  `采集时间` DATETIME NOT NULL COMMENT '采集时间',
  `运行状态` ENUM('正常', '故障', '离线') NOT NULL COMMENT '运行状态',
  `电池电量` INT COMMENT '电池电量(%)',
  `信号强度` INT COMMENT '信号强度',
  PRIMARY KEY (`状态编号`),
  CONSTRAINT `fk_状态_设备` FOREIGN KEY (`设备编号`) REFERENCES `设备档案` (`设备编号`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='设备实时状态记录表';

-- 3. 维护记录表
CREATE TABLE `维护记录` (
  `维护编号` INT NOT NULL AUTO_INCREMENT COMMENT '维护编号 (主键)',
  `设备编号` INT NOT NULL COMMENT '设备编号 (外键)',
  `维护类型` ENUM('巡检', '维修', '更换') NOT NULL COMMENT '维护类型',
  `维护时间` DATETIME NOT NULL COMMENT '维护时间',
  `维护人ID` INT COMMENT '维护人员ID (外键)',
  `维护内容` TEXT COMMENT '维护内容',
  `维护结果` TEXT COMMENT '维护结果',
  `维护前状态` ENUM('正常', '故障', '离线') COMMENT '维护前状态',
  `维护后状态` ENUM('正常', '故障', '离线') COMMENT '维护后状态',
  PRIMARY KEY (`维护编号`),
  CONSTRAINT `fk_维护_设备` FOREIGN KEY (`设备编号`) REFERENCES `设备档案` (`设备编号`),
  CONSTRAINT `fk_维护_人员` FOREIGN KEY (`维护人ID`) REFERENCES `用户` (`用户ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='设备维护记录表';

SET FOREIGN_KEY_CHECKS = 1;
