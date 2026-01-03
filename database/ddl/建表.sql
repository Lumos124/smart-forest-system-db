-- ==========================================
-- 模块：设备管理 - 物理结构设计
-- 依据：严格对照“原始关系模式图”修改
-- ==========================================

DROP TABLE IF EXISTS sys_maintenance_log;
DROP TABLE IF EXISTS sys_device_status;
DROP TABLE IF EXISTS sys_device;

-- 1. 设备档案表 (对照图：设备档案)
CREATE TABLE sys_device (
    device_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '设备编号 (Serial)',
    device_name VARCHAR(100) NOT NULL COMMENT '设备名称 (Variable characters 100)',
    device_type ENUM('传感器', '摄像头', '预警器', '其他') NOT NULL COMMENT '设备类型 (ENUM)',
    model_spec VARCHAR(50) COMMENT '型号规格 (Variable characters 50)',
    purchase_time DATE COMMENT '采购时间 (Date)',
    -- [已删除] install_time (图中无此字段，已移除以保持一致)
    warranty_period INT COMMENT '质保期 (Integer)',
    status ENUM('正常', '停用', '报废', '故障', '离线') DEFAULT '正常' COMMENT '状态 (ENUM)',
    
    -- [必须保留] 图中有连线指向“区域表”，代码必须用外键实现
    area_id INT NOT NULL COMMENT '所属区域ID', 
    
    -- [图中已有] 安装人ID
    installer_id INT COMMENT '安装人ID (Integer)',
    
    FOREIGN KEY (area_id) REFERENCES sys_area(area_id),
    FOREIGN KEY (installer_id) REFERENCES sys_user(user_id)
) COMMENT='设备档案表';

-- 2. 设备状态表 (对照图：设备状态)
CREATE TABLE sys_device_status (
    status_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '状态编号 (Serial)',
    device_id INT NOT NULL COMMENT '设备编号 (外键)',
    collect_time DATETIME NOT NULL COMMENT '采集时间 (Date & Time)',
    run_status ENUM('正常', '故障', '离线') NOT NULL COMMENT '运行状态 (ENUM)',
    battery_level INT COMMENT '电池电量 (Integer)',
    signal_strength INT COMMENT '信号强度 (Integer)',
    FOREIGN KEY (device_id) REFERENCES sys_device(device_id)
) COMMENT='设备实时状态记录表';

-- 3. 维护记录表 (对照图：维护记录)
CREATE TABLE sys_maintenance_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '维护编号 (Serial)',
    device_id INT NOT NULL COMMENT '设备编号 (外键)',
    maint_type ENUM('巡检', '维修', '更换') NOT NULL COMMENT '维护类型 (ENUM)',
    maint_time DATETIME NOT NULL COMMENT '维护时间 (Date & Time)',
    maint_person_id INT COMMENT '维护人ID (Integer)',
    maint_content TEXT COMMENT '维护内容 (Text)',
    maint_result TEXT COMMENT '维护结果 (Text)',
    pre_status ENUM('正常', '故障', '离线') COMMENT '维护前状态 (ENUM)',
    post_status ENUM('正常', '故障', '离线') COMMENT '维护后状态 (ENUM)',
    FOREIGN KEY (device_id) REFERENCES sys_device(device_id),
    FOREIGN KEY (maint_person_id) REFERENCES sys_user(user_id)
) COMMENT='设备维护记录表';
