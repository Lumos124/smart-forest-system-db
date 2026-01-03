SELECT 
    r.`资源编号`,
    r.`品种名称` AS 品种,
    a.`区域名称` AS 所属区域,
    COUNT(c.`变动编号`) AS 变动次数,
    MAX(c.`变动时间`) AS 最后变动时间,
    GROUP_CONCAT(DISTINCT c.`变动类型` ORDER BY c.`变动时间` DESC) AS 变动类型历史
FROM `林草资源` r
JOIN `资源变动记录` c ON r.`资源编号` = c.`资源编号`
JOIN `区域` a ON r.`区域编号` = a.`区域编号`
WHERE c.`变动时间` >= DATE_SUB(NOW(), INTERVAL 6 MONTH)
GROUP BY r.`资源编号`, r.`品种名称`, a.`区域名称`
HAVING COUNT(c.`变动编号`) >= 3
ORDER BY 变动次数 DESC;