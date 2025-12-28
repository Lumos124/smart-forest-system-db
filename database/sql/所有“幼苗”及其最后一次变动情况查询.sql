SELECT 
    r.resource_id,
    r.variety,
    a.area_name,
    r.growth_stage,
    c.change_type AS 最后动态,
    c.change_time AS 动态时间
FROM Resource r
JOIN Area a ON r.area_id = a.area_id
JOIN ChangeLog c ON r.resource_id = c.resource_id
WHERE r.growth_stage = '幼苗'
  AND c.change_time = (
      -- 子查询：找到该资源最新的一条日志时间
      SELECT MAX(change_time) 
      FROM ChangeLog sub 
      WHERE sub.resource_id = r.resource_id
  );