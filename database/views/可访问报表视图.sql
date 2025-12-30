CREATE OR REPLACE VIEW 可访问报表视图 AS
SELECT 
    gr.报表编号,
    gr.统计周期,
    gr.生成时间,
    gr.报表状态,
    gr.访问级别,
    gr.下载次数,
    gr.文件大小,
    rt.报表名称,
    rt.统计维度,
    rt.统计指标,
    rt.生成周期 as 模板周期,
    rt.数据来源,
    u.真实姓名 as 生成人姓名,
    u.用户编号 as 生成人ID,
    u.角色编号 as 生成人角色,
    u.管辖区域编号 as 生成人区域,
    -- 权限计算字段
    CASE 
        WHEN gr.访问级别 = '公开' THEN TRUE
        WHEN gr.访问级别 = '内部' AND u.角色编号 IN (1,2,3,5) THEN TRUE
        WHEN gr.访问级别 = '机密' AND u.角色编号 IN (1,5) THEN TRUE
        ELSE FALSE
    END as 可访问标志
FROM 生成报表 gr
JOIN 报表模板 rt ON gr.模板编号 = rt.模板编号
JOIN 用户 u ON gr.生成人ID = u.用户编号
WHERE gr.报表状态 IN ('已发布', '已生成');
