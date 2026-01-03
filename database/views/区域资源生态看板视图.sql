CREATE OR REPLACE VIEW `v_区域生态概览` AS
SELECT 
    a.`区域名称`,
    a.`区域类型` AS 规划类型,
    u.`用户名` AS 负责人,
    COUNT(r.`资源编号`) AS 资源种类数,
    -- 统计树木和草地的分布
    SUM(CASE WHEN r.`资源类型` = '树木' THEN r.`数量或面积` ELSE 0 END) AS 树木保有量,
    SUM(CASE WHEN r.`资源类型` = '草地' THEN r.`数量或面积` ELSE 0 END) AS 草地面积,
    -- 统计生态结构
    CONCAT(ROUND(
        SUM(CASE WHEN r.`生长状态` = '幼苗' THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(r.`资源编号`), 0), 
    2), '%') AS 幼苗占比
FROM `区域` a
LEFT JOIN `用户` u ON a.`负责人ID` = u.`用户ID`
LEFT JOIN `林草资源` r ON a.`区域编号` = r.`区域编号`
GROUP BY a.`区域编号`, a.`区域名称`, u.`用户名`;