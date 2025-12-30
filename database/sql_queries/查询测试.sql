-- 查询1：查询某区域近7天火灾预警及处理情况（关联3个表）
SELECT 
    wr.预警编号,
    wr.触发时间,
    wr.预警内容,
    wr.处理状态,
    wr.处理结果,
    a.区域名称,
    gr.统计周期,
    gr.报表文件存储路径
FROM 预警记录 wr
JOIN 区域 a ON wr.涉及区域编号 = a.区域编号
LEFT JOIN 生成报表 gr ON gr.统计周期 = DATE_FORMAT(wr.触发时间, '%Y-%m')
    AND gr.模板编号 IN (
        SELECT 模板编号 FROM 报表模板 
        WHERE 报表名称 LIKE '%火灾预警%' AND 是否生效 = TRUE
    )
WHERE a.区域编号 = 1  -- 指定区域ID
  AND wr.触发时间 >= DATE_SUB(NOW(), INTERVAL 7 DAY)
  AND wr.预警类型 = '火灾'
ORDER BY wr.触发时间 DESC;

-- 查询2：统计各区域设备故障次数及维护成本（关联4个表）
SELECT 
    a.区域编号,
    a.区域名称,
    COUNT(DISTINCT d.设备编号) as 设备总数,
    SUM(CASE WHEN ds.运行状态 = '故障' THEN 1 ELSE 0 END) as 故障次数,
    SUM(CASE WHEN mr.维护类型 = '维修' THEN 1 ELSE 0 END) as 维修次数,
    SUM(CASE WHEN mr.维护类型 = '更换' THEN 1 ELSE 0 END) as 更换次数,
    gr.统计周期 as 统计报表周期
FROM 区域 a
LEFT JOIN 设备 d ON a.区域编号 = d.安装区域编号
LEFT JOIN 设备状态数据 ds ON d.设备编号 = ds.设备编号 
    AND ds.采集时间 >= DATE_SUB(NOW(), INTERVAL 30 DAY)
LEFT JOIN 维护记录 mr ON d.设备编号 = mr.设备编号
    AND mr.维护时间 >= DATE_SUB(NOW(), INTERVAL 30 DAY)
LEFT JOIN 生成报表 gr ON gr.统计周期 = DATE_FORMAT(NOW(), '%Y-%m')
    AND gr.模板编号 IN (
        SELECT 模板编号 FROM 报表模板 
        WHERE 报表名称 LIKE '%设备故障%' AND 是否生效 = TRUE
    )
GROUP BY a.区域编号, a.区域名称, gr.统计周期
ORDER BY 故障次数 DESC;

-- 查询3：查看数据管理员生成的报表及其模板信息（关联3个表）
SELECT 
    u.真实姓名 as 生成人,
    u.角色编号,
    rt.报表名称 as 模板名称,
    rt.统计维度,
    rt.生成周期 as 模板周期,
    COUNT(gr.报表编号) as 生成报表数量,
    SUM(gr.下载次数) as 总下载次数,
    MAX(gr.生成时间) as 最近生成时间
FROM 用户 u
JOIN 生成报表 gr ON u.用户编号 = gr.生成人ID
JOIN 报表模板 rt ON gr.模板编号 = rt.模板编号
WHERE u.角色编号 = (SELECT 角色编号 FROM 角色 WHERE 角色名称 = '数据管理员')
  AND gr.生成时间 >= DATE_SUB(NOW(), INTERVAL 90 DAY)
GROUP BY u.用户编号, u.真实姓名, u.角色编号, rt.模板编号, rt.报表名称, rt.统计维度, rt.生成周期
ORDER BY 生成报表数量 DESC;

-- 查询4：分析报表下载热度与用户活跃度（关联4个表）
SELECT 
    u.用户编号,
    u.真实姓名,
    r.角色名称,
    COUNT(DISTINCT dl.日志编号) as 下载次数,
    COUNT(DISTINCT dl.报表编号) as 下载报表种类,
    SUM(dl.下载文件大小) / 1024 / 1024 as 总下载大小_MB,
    AVG(gr.文件大小) / 1024 / 1024 as 平均报表大小_MB,
    MAX(dl.下载时间) as 最近下载时间,
    DATEDIFF(NOW(), MAX(dl.下载时间)) as 距今天数
FROM 用户 u
JOIN 角色 r ON u.角色编号 = r.角色编号
LEFT JOIN 下载日志 dl ON u.用户编号 = dl.用户ID
LEFT JOIN 生成报表 gr ON dl.报表编号 = gr.报表编号
WHERE dl.下载时间 >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY u.用户编号, u.真实姓名, r.角色名称
HAVING 下载次数 > 0
ORDER BY 下载次数 DESC, 总下载大小_MB DESC;

-- 查询5：模板审核流程跟踪与效率分析（关联3个表）
SELECT 
    rt.模板编号,
    rt.报表名称,
    rt.创建时间 as 模板创建时间,
    u1.真实姓名 as 创建人,
    rt.审核状态,
    MAX(ol.操作时间) as 最后审核操作时间,
    u2.真实姓名 as 最后审核人,
    TIMESTAMPDIFF(HOUR, rt.创建时间, MAX(ol.操作时间)) as 审核耗时_小时,
    COUNT(DISTINCT gr.报表编号) as 已生成报表数,
    SUM(gr.下载次数) as 总下载次数
FROM 报表模板 rt
JOIN 用户 u1 ON rt.创建人ID = u1.用户编号
LEFT JOIN 操作日志 ol ON rt.模板编号 = ol.目标ID 
    AND ol.目标表 = '报表模板' 
    AND ol.操作类型 LIKE '%APPROVE%'
LEFT JOIN 用户 u2 ON ol.用户ID = u2.用户编号
LEFT JOIN 生成报表 gr ON rt.模板编号 = gr.模板编号
WHERE rt.是否需要审核 = TRUE
  AND rt.创建时间 >= DATE_SUB(NOW(), INTERVAL 60 DAY)
GROUP BY rt.模板编号, rt.报表名称, rt.创建时间, u1.真实姓名, rt.审核状态
ORDER BY 审核耗时_小时 DESC;
