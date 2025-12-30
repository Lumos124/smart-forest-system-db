CREATE OR REPLACE VIEW 模板使用统计视图 AS
SELECT 
    rt.模板编号,
    rt.报表名称,
    rt.统计维度,
    rt.统计指标,
    rt.生成周期,
    rt.数据来源,
    rt.是否生效,
    rt.审核状态,
    -- 使用统计
    COUNT(DISTINCT gr.报表编号) as 总生成次数,
    SUM(gr.下载次数) as 总下载次数,
    AVG(gr.下载次数) as 平均下载次数,
    -- 时间统计
    MIN(gr.生成时间) as 首次生成时间,
    MAX(gr.生成时间) as 最近生成时间,
    DATEDIFF(NOW(), MAX(gr.生成时间)) as 闲置天数,
    -- 创建者信息
    u.真实姓名 as 创建人,
    rt.创建时间
FROM 报表模板 rt
LEFT JOIN 生成报表 gr ON rt.模板编号 = gr.模板编号
JOIN 用户 u ON rt.创建人ID = u.用户编号
GROUP BY rt.模板编号, rt.报表名称, rt.统计维度, rt.统计指标,
         rt.生成周期, rt.数据来源, rt.是否生效, rt.审核状态,
         u.真实姓名, rt.创建时间
ORDER BY 总下载次数 DESC, 总生成次数 DESC;
