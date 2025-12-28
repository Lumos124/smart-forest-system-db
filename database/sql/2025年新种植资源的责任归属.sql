SELECT 
    r.variety AS 资源名称,
    r.plant_time AS 种植时间,
    a.area_name AS 所属区域,
    u.username AS 区域负责人,
    u.phone AS 负责人电话
FROM Resource r
JOIN Area a ON r.area_id = a.area_id
JOIN User u ON a.manager_id = u.user_id
WHERE YEAR(r.plant_time) = 2025; 
-- 筛选条件：只看2025年种植的