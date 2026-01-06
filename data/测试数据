USE smart_forest_analysis;

-- 1. 插入基础角色（5种固定角色）
INSERT INTO 角色 (角色名称, 角色描述) VALUES
('系统管理员', '最高权限，负责用户管理、权限分配、模板审核和系统维护'),
('数据管理员', '负责报表模板管理、报表生成与发布、数据处理'),
('区域护林员', '负责特定区域的巡查工作，查看管辖区域的统计报表'),
('公众用户', '只能查看公开的统计数据和环境监测信息'),
('监管人员', '监督全系统运行，查看所有业务数据和操作记录，审核报表质量')
ON DUPLICATE KEY UPDATE 角色描述 = VALUES(角色描述);

-- 2. 插入统计分析模块权限
INSERT INTO 权限 (权限名称, 权限代码, 资源类型, 操作类型, 资源范围, 权限描述) VALUES
-- 模板相关权限
('创建报表模板', 'TEMPLATE_CREATE', '模版', 'CREATE', 'OWN', '创建新的报表模板'),
('查看报表模板', 'TEMPLATE_READ', '模版', 'READ', 'OWN', '查看自己创建的模板'),
('编辑报表模板', 'TEMPLATE_UPDATE', '模版', 'UPDATE', 'OWN', '编辑自己创建的模板'),
('删除报表模板', 'TEMPLATE_DELETE', '模版', 'DELETE', 'OWN', '删除自己创建的模板'),
('审核报表模板', 'TEMPLATE_APPROVE', '模版', 'UPDATE', 'ALL', '审核所有用户的模板'),

-- 报表相关权限
('手动生成报表', 'REPORT_GENERATE', '报表', 'CREATE', 'OWN', '手动触发报表生成'),
('查看报表列表', 'REPORT_READ_LIST', '报表', 'READ', 'AREA', '查看管辖区域的报表列表'),
('查看报表详情', 'REPORT_READ_DETAIL', '报表', 'READ', 'AREA', '查看报表详细内容'),
('下载报表文件', 'REPORT_DOWNLOAD', '报表', 'DOWNLOAD', 'AREA', '下载报表文件'),
('发布报表', 'REPORT_PUBLISH', '报表', 'UPDATE', 'OWN', '将生成的报表发布为可用状态'),
('归档报表', 'REPORT_ARCHIVE', '报表', 'UPDATE', 'OWN', '将旧报表归档处理'),
('查看所有报表', 'REPORT_READ_ALL', '报表', 'READ', 'ALL', '查看系统中的所有报表'),
('下载所有报表', 'REPORT_DOWNLOAD_ALL', '报表', 'DOWNLOAD', 'ALL', '下载系统中的所有报表'),
('查看公开报表', 'REPORT_READ_PUBLIC', '报表', 'READ', 'PUBLIC', '查看公开的统计报表')
ON DUPLICATE KEY UPDATE 
    权限描述 = VALUES(权限描述),
    资源类型 = VALUES(资源类型),
    操作类型 = VALUES(操作类型),
    资源范围 = VALUES(资源范围);

-- 3. 分配角色权限（系统管理员）
INSERT INTO 角色权限关联表 (角色编号, 权限编号)
SELECT r.角色编号, p.权限编号
FROM 角色 r, 权限 p
WHERE r.角色名称 = '系统管理员'
  AND p.权限代码 IN ('TEMPLATE_APPROVE', 'REPORT_READ_ALL', 'REPORT_DOWNLOAD_ALL')
ON DUPLICATE KEY UPDATE 角色编号 = VALUES(角色编号);

-- 4. 分配角色权限（数据管理员）
INSERT INTO 角色权限关联表 (角色编号, 权限编号)
SELECT r.角色编号, p.权限编号
FROM 角色 r, 权限 p
WHERE r.角色名称 = '数据管理员'
  AND p.权限代码 IN ('TEMPLATE_CREATE', 'TEMPLATE_READ', 'TEMPLATE_UPDATE', 'TEMPLATE_DELETE',
                    'REPORT_GENERATE', 'REPORT_READ_DETAIL', 'REPORT_DOWNLOAD', 'REPORT_PUBLISH', 'REPORT_ARCHIVE')
ON DUPLICATE KEY UPDATE 角色编号 = VALUES(角色编号);

-- 5. 创建测试用户（密码都是：123456）
-- 注意：实际项目中密码应该用bcrypt加密，这里为演示使用明文
INSERT INTO 用户 (用户名, 密码哈希, 真实姓名, 手机号, 邮箱, 角色编号, 状态) VALUES
('admin', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '系统管理员', '13800138001', 'admin@forest.com', 
 (SELECT 角色编号 FROM 角色 WHERE 角色名称 = '系统管理员'), '正常'),
('data_mgr', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '张三', '13800138002', 'zhangsan@forest.com',
 (SELECT 角色编号 FROM 角色 WHERE 角色名称 = '数据管理员'), '正常'),
('guardian_a1', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '李四', '13800138003', 'lisi@forest.com',
 (SELECT 角色编号 FROM 角色 WHERE 角色名称 = '区域护林员'), '正常'),
('public_user', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '王五', '13800138004', 'wangwu@example.com',
 (SELECT 角色编号 FROM 角色 WHERE 角色名称 = '公众用户'), '正常'),
('supervisor', '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '赵六', '13800138005', 'zhaoliu@forest.com',
 (SELECT 角色编号 FROM 角色 WHERE 角色名称 = '监管人员'), '正常')
ON DUPLICATE KEY UPDATE 
    真实姓名 = VALUES(真实姓名),
    手机号 = VALUES(手机号),
    邮箱 = VALUES(邮箱),
    角色编号 = VALUES(角色编号);

-- 6. 创建测试报表模板
INSERT INTO 报表模板 (报表名称, 统计维度, 统计指标, 生成周期, 数据来源, 是否生效, 是否需要审核, 审核状态, 创建人ID) VALUES
('环境监测日报', '区域', '温度均值,湿度均值', '日', '监测', TRUE, FALSE, '通过', 
 (SELECT 用户编号 FROM 用户 WHERE 用户名 = 'data_mgr')),
('设备故障周报', '区域,设备类型', '故障次数,离线时长', '周', '设备', TRUE, TRUE, '通过', 
 (SELECT 用户编号 FROM 用户 WHERE 用户名 = 'data_mgr')),
('火灾预警月报', '区域,预警级别', '预警次数,处理率', '月', '预警', TRUE, TRUE, '待审核', 
 (SELECT 用户编号 FROM 用户 WHERE 用户名 = 'data_mgr')),
('林草资源季报', '区域,资源类型', '资源总量,生长状态分布', '季', '资源', TRUE, FALSE, '通过', 
 (SELECT 用户编号 FROM 用户 WHERE 用户名 = 'data_mgr')),
('综合统计年报', '时间,区域,类型', '多指标综合分析', '年', '综合', TRUE, TRUE, '通过', 
 (SELECT 用户编号 FROM 用户 WHERE 用户名 = 'data_mgr'))
ON DUPLICATE KEY UPDATE 
    统计维度 = VALUES(统计维度),
    统计指标 = VALUES(统计指标),
    生成周期 = VALUES(生成周期),
    数据来源 = VALUES(数据来源);
