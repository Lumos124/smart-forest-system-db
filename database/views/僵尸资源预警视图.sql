CREATE OR REPLACE VIEW `v_长期未维护清单` AS
SELECT 
    r.`资源编号`,
    r.`品种名称`,
    r.`生长状态`,
    a.`区域名称`,
    u.`用户名` AS 负责人,
    r.`最后更新时间`,
    DATEDIFF(NOW(), r.`最后更新时间`) AS 未维护天数,
    CASE 
        WHEN r.`生长状态` = '幼苗' AND DATEDIFF(NOW(), r.`最后更新时间`) > 30 THEN '🔴 紧急：幼苗需月检'
        WHEN r.`生长状态` = '成长期' AND DATEDIFF(NOW(), r.`最后更新时间`) > 90 THEN '🟡 警告：需季度巡查'
        WHEN DATEDIFF(NOW(), r.`最后更新时间`) > 365 THEN '🔵 提示：年度普查遗漏'
        ELSE '正常'
    END AS 维护建议
FROM `林草资源` r
JOIN `区域` a ON r.`区域编号` = a.`区域编号`
JOIN `用户` u ON a.`负责人ID` = u.`用户ID`
WHERE DATEDIFF(NOW(), r.`最后更新时间`) > 30;