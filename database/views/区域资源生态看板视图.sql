CREATE OR REPLACE VIEW v_区域生态概览 AS
SELECT 
    a.area_name AS 区域名称,
    a.area_type AS 规划类型,
    u.username AS 负责人,
    COUNT(r.resource_id) AS 资源种类数,
    -- 统计树木和草地的分布
    SUM(CASE WHEN r.res_type = '树木' THEN r.amount ELSE 0 END) AS 树木保有量,
    SUM(CASE WHEN r.res_type = '草地' THEN r.amount ELSE 0 END) AS 草地面积,
    -- 统计生态结构（计算幼苗占比，评估未来潜力）
    CONCAT(ROUND(
        SUM(CASE WHEN r.growth_stage = '幼苗' THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(r.resource_id), 0), 
    2), '%') AS 幼苗占比
FROM Area a
LEFT JOIN User u ON a.manager_id = u.user_id
LEFT JOIN Resource r ON a.area_id = r.area_id
GROUP BY a.area_id, a.area_name, u.username;