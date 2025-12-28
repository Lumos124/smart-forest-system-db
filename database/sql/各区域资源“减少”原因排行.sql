SELECT 
    a.area_name,
    r.res_type AS 资源类型,
    c.reason AS 减少原因,
    COUNT(c.log_id) AS 发生次数,
    u.username AS 登记人
FROM ChangeLog c
JOIN Resource r ON c.resource_id = r.resource_id
JOIN Area a ON r.area_id = a.area_id
JOIN User u ON c.operator_id = u.user_id
WHERE c.change_type = '减少'  -- 只看减少的操作
GROUP BY a.area_name, r.res_type, c.reason, u.username
HAVING 发生次数 > 0
ORDER BY 发生次数 DESC, a.area_name;