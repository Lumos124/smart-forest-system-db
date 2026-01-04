-- DROP TABLE IF EXISTS sys_maintenance_log;
-- DROP TABLE IF EXISTS sys_device_status;
-- DROP TABLE IF EXISTS sys_device;

-- 1. 设备档案表 
CREATE TABLE sys_device (
    device_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '设备编号',
    device_name VARCHAR(100) NOT NULL COMMENT '设备名称',
    device_type ENUM('传感器', '摄像头', '预警器', '其他') NOT NULL COMMENT '设备类型',
    model_spec VARCHAR(50) COMMENT '型号规格',
    purchase_time DATE COMMENT '采购时间',
    -- [已修正] 删除了 install_time，与图保持一致
    warranty_period INT COMMENT '质保期(月)',
    status ENUM('正常', '停用', '报废', '故障', '离线') DEFAULT '正常' COMMENT '状态',

    area_id INT NOT NULL COMMENT '所属区域ID',
    installer_id INT COMMENT '安装人ID',
    
    FOREIGN KEY (area_id) REFERENCES sys_area(area_id),
    FOREIGN KEY (installer_id) REFERENCES sys_user(user_id)
) COMMENT='设备档案表';

-- 2. 设备状态表
CREATE TABLE sys_device_status (
    status_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '状态编号',
    device_id INT NOT NULL COMMENT '设备编号',
    collect_time DATETIME NOT NULL COMMENT '采集时间',
    run_status ENUM('正常', '故障', '离线') NOT NULL COMMENT '运行状态',
    battery_level INT COMMENT '电池电量',
    signal_strength INT COMMENT '信号强度',
    FOREIGN KEY (device_id) REFERENCES sys_device(device_id)
) COMMENT='设备实时状态记录表';

CREATE TABLE sys_maintenance_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '维护编号',
    device_id INT NOT NULL COMMENT '设备编号',
    maint_type ENUM('巡检', '维修', '更换') NOT NULL COMMENT '维护类型',
    maint_time DATETIME NOT NULL COMMENT '维护时间',
    maint_person_id INT COMMENT '维护人ID',
    maint_content TEXT COMMENT '维护内容',
    maint_result TEXT COMMENT '维护结果',
    pre_status ENUM('正常', '故障', '离线') COMMENT '维护前状态',
    post_status ENUM('正常', '故障', '离线') COMMENT '维护后状态',
    FOREIGN KEY (device_id) REFERENCES sys_device(device_id),
    FOREIGN KEY (maint_person_id) REFERENCES sys_user(user_id)
) COMMENT='设备维护记录表';
