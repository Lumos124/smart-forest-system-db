SELECT 
    r.`品种名称` AS 资源名称,
    r.`种植时间`,
    a.`区域名称` AS 所属区域,
    u.`用户名` AS 区域负责人,
    u.`联系电话` AS 负责人电话
FROM `林草资源` r
JOIN `区域` a ON r.`区域编号` = a.`区域编号`
JOIN `用户` u ON a.`负责人ID` = u.`用户ID`
WHERE YEAR(r.`种植时间`) = 2025; 
-- 筛选条件：只看2025年种植的