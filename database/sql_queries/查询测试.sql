-- 查看数据管理员生成的报表及其模板信息（关联3个表）
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

-- 分析报表下载热度与用户活跃度（关联4个表）
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

-- 模板审核流程跟踪与效率分析（关联3个表）
SELECT
    rt.模板编号,
    rt.报表名称,
    rt.创建时间 as 模板创建时间,
    u1.真实姓名 as 创建人,
    rt.审核状态,
    MAX(ol.操作时间) as 最后审核操作时间,
    MAX(CASE WHEN ol.操作时间 = max_time.最后操作时间 THEN u2.真实姓名 END) as 最后审核人,
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
LEFT JOIN (
    SELECT 目标ID, MAX(操作时间) as 最后操作时间
    FROM 操作日志
    WHERE 目标表 = '报表模板' AND 操作类型 LIKE '%APPROVE%'
    GROUP BY 目标ID
) max_time ON rt.模板编号 = max_time.目标ID
WHERE rt.是否需要审核 = TRUE
  AND rt.创建时间 >= DATE_SUB(NOW(), INTERVAL 60 DAY)
GROUP BY rt.模板编号, rt.报表名称, rt.创建时间, u1.真实姓名, rt.审核状态
ORDER BY 审核耗时_小时 DESC;
