SELECT 
    a.`区域名称`,
    r.`资源类型`,
    c.`变动原因` AS 减少原因,
    COUNT(c.`变动编号`) AS 发生次数,
    u.`用户名` AS 登记人
FROM `资源变动记录` c
JOIN `林草资源` r ON c.`资源编号` = r.`资源编号`
JOIN `区域` a ON r.`区域编号` = a.`区域编号`
JOIN `用户` u ON c.`操作人ID` = u.`用户ID`
WHERE c.`变动类型` = '减少'  -- 只看减少的操作
GROUP BY a.`区域名称`, r.`资源类型`, c.`变动原因`, u.`用户名`
HAVING 发生次数 > 0
ORDER BY 发生次数 DESC, a.`区域名称`;