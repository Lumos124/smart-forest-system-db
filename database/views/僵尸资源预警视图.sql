CREATE OR REPLACE VIEW v_长期未维护清单 AS
SELECT 
    r.resource_id,
    r.variety,
    r.growth_stage,
    a.area_name,
    u.username AS 负责人,
    r.update_time AS 最后更新时间,
    DATEDIFF(NOW(), r.update_time) AS 未维护天数,
    -- 业务逻辑：根据生长阶段给出建议
    CASE 
        WHEN r.growth_stage = '幼苗' AND DATEDIFF(NOW(), r.update_time) > 30 THEN '🔴 紧急：幼苗需月检'
        WHEN r.growth_stage = '成长期' AND DATEDIFF(NOW(), r.update_time) > 90 THEN '🟡 警告：需季度巡查'
        WHEN DATEDIFF(NOW(), r.update_time) > 365 THEN '🔵 提示：年度普查遗漏'
        ELSE '正常'
    END AS 维护建议
FROM Resource r
JOIN Area a ON r.area_id = a.area_id
JOIN User u ON a.manager_id = u.user_id
WHERE DATEDIFF(NOW(), r.update_time) > 30; -- 基础过滤