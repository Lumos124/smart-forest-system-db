SELECT 
    r.`资源编号`,
    r.`品种名称`,
    a.`区域名称`,
    r.`生长状态`,
    c.`变动类型` AS 最后动态,
    c.`变动时间` AS 动态时间
FROM `林草资源` r
JOIN `区域` a ON r.`区域编号` = a.`区域编号`
JOIN `资源变动记录` c ON r.`资源编号` = c.`资源编号`
WHERE r.`生长状态` = '幼苗'
  AND c.`变动时间` = (
      SELECT MAX(`变动时间`) 
      FROM `资源变动记录` sub 
      WHERE sub.`资源编号` = r.`资源编号`
  );