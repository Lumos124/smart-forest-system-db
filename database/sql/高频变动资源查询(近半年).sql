SELECT 
    r.resource_id,
    r.variety AS 品种,
    a.area_name AS 所属区域,
    COUNT(c.log_id) AS 变动次数,
    MAX(c.change_time) AS 最后变动时间,
    -- 使用 GROUP_CONCAT 将多次变动原因合并显示
    GROUP_CONCAT(DISTINCT c.change_type ORDER BY c.change_time DESC) AS 变动类型历史
FROM Resource r
JOIN ChangeLog c ON r.resource_id = c.resource_id
JOIN Area a ON r.area_id = a.area_id
WHERE c.change_time >= DATE_SUB(NOW(), INTERVAL 6 MONTH) -- 仅限近半年
GROUP BY r.resource_id, r.variety, a.area_name
HAVING COUNT(c.log_id) >= 3 -- 核心逻辑：变动次数过滤
ORDER BY 变动次数 DESC;