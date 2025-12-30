USE smart_forest_analysis;

CREATE TABLE IF NOT EXISTS 角色 (
    角色编号 INT UNSIGNED AUTO_INCREMENT COMMENT '角色唯一标识',
    角色名称 VARCHAR(50) NOT NULL COMMENT '系统管理员/数据管理员/区域护林员/公众用户/监管人员',
    角色描述 TEXT COMMENT '角色职责详细说明',
    创建时间 DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '角色创建时间',
    PRIMARY KEY (角色编号),
    UNIQUE KEY uk_role_name (角色名称),
    INDEX idx_created_time (创建时间)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统角色定义表';

CREATE TABLE IF NOT EXISTS 权限 (
    权限编号 INT UNSIGNED AUTO_INCREMENT COMMENT '权限唯一标识',
    权限名称 VARCHAR(100) NOT NULL COMMENT '权限描述性名称',
    权限代码 VARCHAR(50) NOT NULL COMMENT '唯一权限代码，用于程序验证',
    资源类型 ENUM('模版', '报表') NOT NULL COMMENT '权限作用的资源类型',
    操作类型 ENUM('CREATE', 'READ', 'UPDATE', 'DELETE', 'DOWNLOAD') NOT NULL COMMENT '允许的操作类型',
    资源范围 ENUM('ALL', 'OWN', 'AREA', 'PUBLIC') NOT NULL COMMENT '资源访问范围',
    权限描述 TEXT COMMENT '权限详细说明',
    PRIMARY KEY (权限编号),
    UNIQUE KEY uk_permission_code (权限代码),
    INDEX idx_resource_type (资源类型),
    INDEX idx_operation_type (操作类型),
    INDEX idx_resource_scope (资源范围)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统权限定义表';

CREATE TABLE IF NOT EXISTS 角色权限关联表 (
    角色编号 INT UNSIGNED NOT NULL COMMENT '外键，关联角色',
    权限编号 INT UNSIGNED NOT NULL COMMENT '外键，关联权限',
    创建时间 DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '关联创建时间',
    PRIMARY KEY (角色编号, 权限编号),
    FOREIGN KEY fk_rp_role (角色编号) REFERENCES 角色(角色编号) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY fk_rp_permission (权限编号) REFERENCES 权限(权限编号) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_created_time (创建时间)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色与权限多对多关联表';

CREATE TABLE IF NOT EXISTS 用户 (
    用户编号 INT UNSIGNED AUTO_INCREMENT COMMENT '用户唯一标识',
    用户名 VARCHAR(50) NOT NULL COMMENT '登录账号，唯一',
    密码哈希 CHAR(60) NOT NULL COMMENT 'bcrypt加密后的密码，固定60字符',
    真实姓名 VARCHAR(50) NOT NULL COMMENT '用户真实姓名',
    手机号 VARCHAR(20) NOT NULL COMMENT '联系电话，用于紧急通知',
    邮箱 VARCHAR(100) NOT NULL COMMENT '电子邮箱，用于系统通知',
    角色编号 INT UNSIGNED NOT NULL COMMENT '外键，用户所属角色',
    管辖区域编号 INT UNSIGNED COMMENT '外键，仅区域护林员需要此字段',
    状态 ENUM('正常', '禁用', '锁定') DEFAULT '正常' COMMENT '账户状态',
    创建时间 DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '账户创建时间',
    最后登录时间 DATETIME COMMENT '最近成功登录时间',
    PRIMARY KEY (用户编号),
    UNIQUE KEY uk_username (用户名),
    UNIQUE KEY uk_email (邮箱),
    UNIQUE KEY uk_phone (手机号),
    FOREIGN KEY fk_user_role (角色编号) REFERENCES 角色(角色编号) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_role_id (角色编号),
    INDEX idx_status (状态),
    INDEX idx_area_id (管辖区域编号),
    INDEX idx_created_time (创建时间),
    INDEX idx_last_login (最后登录时间 DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统用户表';

CREATE TABLE IF NOT EXISTS 报表模板 (
    模板编号 INT UNSIGNED AUTO_INCREMENT COMMENT '模板唯一标识',
    报表名称 VARCHAR(100) NOT NULL COMMENT '报表模板名称，唯一',
    统计维度 VARCHAR(50) NOT NULL COMMENT '区域/时间/类型/组合等统计维度',
    统计指标 VARCHAR(100) NOT NULL COMMENT '均值/总量/次数/最大值/最小值等统计指标',
    生成周期 ENUM('日', '周', '月', '季', '年') NOT NULL COMMENT '报表自动生成周期',
    数据来源 VARCHAR(50) NOT NULL COMMENT '监测/预警/资源/设备/综合',
    是否生效 BOOLEAN DEFAULT TRUE COMMENT '模板是否启用',
    是否需要审核 BOOLEAN DEFAULT FALSE COMMENT '重要模板需要审核后才能使用',
    审核状态 ENUM('待审核', '通过', '驳回') DEFAULT '待审核' COMMENT '模板审核状态',
    创建时间 DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '模板创建时间',
    创建人ID INT UNSIGNED NOT NULL COMMENT '外键，创建者用户ID',
    最后使用时间 DATETIME COMMENT '模板最后被使用的时间',
    PRIMARY KEY (模板编号),
    UNIQUE KEY uk_report_name (报表名称),
    FOREIGN KEY fk_template_creator (创建人ID) REFERENCES 用户(用户编号) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_creator (创建人ID),
    INDEX idx_is_active (是否生效),
    INDEX idx_approval_status (审核状态),
    INDEX idx_data_source (数据来源),
    INDEX idx_created_time (创建时间),
    INDEX idx_last_used (最后使用时间 DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='报表模板定义表';

CREATE TABLE IF NOT EXISTS 生成报表 (
    报表编号 INT UNSIGNED AUTO_INCREMENT COMMENT '报表唯一标识',
    模板编号 INT UNSIGNED NOT NULL COMMENT '外键，基于的模板',
    统计周期 VARCHAR(20) NOT NULL COMMENT '统计时间范围，格式：YYYY-MM/YYYY-Www/YYYY-Qq',
    报表文件存储路径 VARCHAR(500) NOT NULL COMMENT 'PDF/Excel文件服务器存储路径',
    报表状态 ENUM('已生成', '已发布', '已归档') DEFAULT '已生成' COMMENT '报表生命周期状态',
    数据来源说明 TEXT COMMENT '详细的数据来源和统计方法说明',
    下载次数 INT UNSIGNED DEFAULT 0 COMMENT '累计被下载次数',
    生成时间 DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '报表生成时间',
    生成人ID INT UNSIGNED NOT NULL COMMENT '外键，生成者用户ID',
    文件大小 BIGINT UNSIGNED COMMENT '文件大小，单位：字节',
    访问级别 ENUM('公开', '内部', '机密') DEFAULT '内部' COMMENT '报表访问权限级别',
    归档时间 DATETIME COMMENT '报表归档时间',
    PRIMARY KEY (报表编号),
    UNIQUE KEY uk_template_period (模板编号, 统计周期) COMMENT '同一模板同一周期只能生成一次',
    FOREIGN KEY fk_report_template (模板编号) REFERENCES 报表模板(模板编号) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY fk_report_generator (生成人ID) REFERENCES 用户(用户编号) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_template_id (模板编号),
    INDEX idx_report_status (报表状态),
    INDEX idx_generate_time (生成时间 DESC),
    INDEX idx_stat_period (统计周期),
    INDEX idx_access_level (访问级别),
    INDEX idx_archive_time (归档时间),
    INDEX idx_download_count (下载次数 DESC),
    INDEX idx_creator_status (生成人ID, 报表状态)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='已生成报表记录表';

CREATE TABLE IF NOT EXISTS 下载日志 (
    日志编号 INT UNSIGNED AUTO_INCREMENT COMMENT '日志记录唯一标识',
    用户ID INT UNSIGNED NOT NULL COMMENT '外键，下载者用户ID',
    报表编号 INT UNSIGNED NOT NULL COMMENT '外键，被下载的报表ID',
    下载时间 DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '下载操作时间',
    下载文件大小 BIGINT UNSIGNED COMMENT '实际下载的文件大小，单位：字节',
    PRIMARY KEY (日志编号),
    FOREIGN KEY fk_dl_user (用户ID) REFERENCES 用户(用户编号) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY fk_dl_report (报表编号) REFERENCES 生成报表(报表编号) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_user_id (用户ID),
    INDEX idx_report_id (报表编号),
    INDEX idx_download_time (下载时间 DESC),
    INDEX idx_user_report_time (用户ID, 报表编号, 下载时间 DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='报表下载日志表';

CREATE TABLE IF NOT EXISTS 操作日志 (
    日志编号 INT UNSIGNED AUTO_INCREMENT COMMENT '日志记录唯一标识',
    用户ID INT UNSIGNED NOT NULL COMMENT '外键，操作者用户ID',
    操作类型 VARCHAR(50) NOT NULL COMMENT '操作类型，如：CREATE_TEMPLATE, APPROVE_TEMPLATE等',
    目标表 VARCHAR(50) NOT NULL COMMENT '操作的目标表名',
    目标ID INT UNSIGNED COMMENT '操作的目标记录ID',
    操作时间 DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '操作发生时间',
    操作详情 TEXT COMMENT '操作详细信息，JSON格式存储',
    操作结果 ENUM('成功', '失败') NOT NULL COMMENT '操作执行结果',
    错误信息 VARCHAR(500) COMMENT '操作失败时的错误信息',
    PRIMARY KEY (日志编号),
    FOREIGN KEY fk_ol_user (用户ID) REFERENCES 用户(用户编号) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_user_id (用户ID),
    INDEX idx_operation_time (操作时间 DESC),
    INDEX idx_target (目标表, 目标ID),
    INDEX idx_operation_result (操作结果),
    INDEX idx_operation_type (操作类型),
    INDEX idx_user_operation (用户ID, 操作类型, 操作时间 DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统操作日志表';
