CREATE OR REPLACE VIEW 下载统计视图 AS
SELECT 
    -- 按日期统计
    DATE(dl.下载时间) as 下载日期,
    -- 按用户统计
    u.用户编号,
    u.真实姓名,
    u.角色编号,
    r.角色名称,
    -- 按报表统计
    gr.报表编号,
    gr.统计周期,
    rt.报表名称,
    -- 统计指标
    COUNT(DISTINCT dl.日志编号) as 下载次数,
    SUM(dl.下载文件大小) as 总下载大小,
    AVG(dl.下载文件大小) as 平均文件大小,
    COUNT(DISTINCT gr.报表编号) as 下载报表种类数,
    -- 时间范围
    MIN(dl.下载时间) as 最早下载时间,
    MAX(dl.下载时间) as 最晚下载时间
FROM 下载日志 dl
JOIN 用户 u ON dl.用户ID = u.用户编号
JOIN 生成报表 gr ON dl.报表编号 = gr.报表编号
JOIN 报表模板 rt ON gr.模板编号 = rt.模板编号
JOIN 角色 r ON u.角色编号 = r.角色编号
GROUP BY DATE(dl.下载时间), u.用户编号, u.真实姓名, u.角色编号, 
         r.角色名称, gr.报表编号, gr.统计周期, rt.报表名称
ORDER BY 下载日期 DESC, 下载次数 DESC;
