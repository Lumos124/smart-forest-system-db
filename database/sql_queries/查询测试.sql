-- 查询北部森林保护区近7天的火灾预警记录及其处理情况
SELECT 
    w.预警编号,
    w.触发时间,
    w.预警内容,
    w.处理状态,
    u.真实姓名 AS 处理人姓名,
    w.处理结果,
    w.解决时间,
    r.区域名称,
    wr.预警类型
FROM 
    预警记录 w
    JOIN 区域 r ON w.涉及区域编号 = r.区域编号
    JOIN 预警规则 wr ON w.触发规则编号 = wr.规则编号
    LEFT JOIN 用户 u ON w.处理人编号 = u.用户编号
WHERE 
    r.区域名称 = '北部森林保护区'
    AND wr.预警类型 = '火灾'
    AND w.触发时间 >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
ORDER BY 
    w.触发时间 DESC;

-- 统计各区域设备故障次数及维护次数
SELECT 
    r.区域名称,
    COUNT(DISTINCT d.设备编号) AS 设备总数,
    SUM(CASE WHEN ds.运行状态 = '故障' THEN 1 ELSE 0 END) AS 故障次数,
    COUNT(DISTINCT m.维护编号) AS 维护记录数,
    SUM(CASE WHEN m.维护类型 = '维修' THEN 1 ELSE 0 END) AS 维修次数,
    SUM(CASE WHEN m.维护类型 = '更换' THEN 1 ELSE 0 END) AS 更换次数
FROM 
    区域 r
    LEFT JOIN 设备档案 d ON r.区域编号 = d.区域编号
    LEFT JOIN 设备状态 ds ON d.设备编号 = ds.设备编号
    LEFT JOIN 维护记录 m ON d.设备编号 = m.设备编号
WHERE 
    ds.采集时间 >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)  -- 最近30天
    OR m.维护时间 >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY 
    r.区域编号, r.区域名称
ORDER BY 
    故障次数 DESC;

-- 统计各报表模板的生成报表数量、总下载次数及使用率
SELECT 
    t.模板编号,
    t.报表名称,
    t.生成周期,
    t.数据来源,
    COUNT(DISTINCT r.报表编号) AS 已生成报表数,
    SUM(r.下载次数) AS 总下载次数,
    AVG(r.下载次数) AS 平均下载次数,
    COUNT(DISTINCT dl.用户编号) AS 下载用户数,
    ROUND(SUM(r.下载次数) * 100.0 / NULLIF(COUNT(DISTINCT r.报表编号), 0), 2) AS 报表平均使用率
FROM 
    报表模板 t
    LEFT JOIN 生成报表 r ON t.模板编号 = r.模板编号
    LEFT JOIN 下载日志 dl ON r.报表编号 = dl.报表编号
WHERE 
    t.审核状态 = '通过'
    AND t.是否生效 = TRUE
GROUP BY 
    t.模板编号, t.报表名称, t.生成周期, t.数据来源
ORDER BY 
    总下载次数 DESC;

-- 统计各类公众反馈的处理效率
SELECT 
    f.反馈类型,
    COUNT(*) AS 总反馈数,
    SUM(CASE WHEN f.处理状态 = '已处理' THEN 1 ELSE 0 END) AS 已处理数,
    SUM(CASE WHEN f.处理状态 = '处理中' THEN 1 ELSE 0 END) AS 处理中数,
    SUM(CASE WHEN f.处理状态 = '待处理' THEN 1 ELSE 0 END) AS 待处理数,
    ROUND(100.0 * SUM(CASE WHEN f.处理状态 = '已处理' THEN 1 ELSE 0 END) / COUNT(*), 2) AS 处理完成率,
    ROUND(AVG(TIMESTAMPDIFF(HOUR, f.提交时间, f.处理时间)), 2) AS 平均处理时长_小时,
    u.真实姓名 AS 主要处理人,
    COUNT(DISTINCT f.提交人编号) AS 反馈用户数
FROM 
    公众反馈 f
    LEFT JOIN 用户 u ON f.处理人编号 = u.用户编号
WHERE 
    f.提交时间 >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)  -- 最近90天
GROUP BY 
    f.反馈类型, u.真实姓名
ORDER BY 
    总反馈数 DESC;

-- 综合统计：各区域的监测数据、林草资源、设备情况
SELECT 
    r.区域名称,
    r.区域类型,
    u.真实姓名 AS 负责人,
    COUNT(DISTINCT d.设备编号) AS 设备总数,
    COUNT(DISTINCT s.传感器编号) AS 传感器数,
    COUNT(DISTINCT md.数据编号) AS 监测数据条数,
    COUNT(DISTINCT lc.资源编号) AS 林草资源数,
    SUM(CASE WHEN lc.资源类型 = '树木' THEN lc.数量 ELSE 0 END) AS 树木总数,
    SUM(CASE WHEN lc.资源类型 = '草地' THEN lc.面积 ELSE 0 END) AS 草地总面积
FROM 
    区域 r
    LEFT JOIN 用户 u ON r.负责人编号 = u.用户编号
    LEFT JOIN 设备档案 d ON r.区域编号 = d.区域编号
    LEFT JOIN 传感器 s ON d.设备编号 = s.设备编号
    LEFT JOIN 监测数据 md ON s.传感器编号 = md.传感器编号
    LEFT JOIN 林草资源 lc ON r.区域编号 = lc.区域编号
WHERE 
    md.数据采集时间 >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)  -- 最近7天
GROUP BY 
    r.区域编号, r.区域名称, r.区域类型, u.真实姓名
ORDER BY 
    监测数据条数 DESC;
