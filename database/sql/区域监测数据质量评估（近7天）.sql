-- 质量控制：找出“无效数据占比高”的区域-监测类型（过去7天）
SELECT
  r.`区域编号`, r.`区域名称`,
  s.`监测类型`,
  COUNT(*) AS `总数据量`,
  SUM(d.`数据状态`='无效') AS `无效数据量`,
  ROUND(SUM(d.`数据状态`='无效') / COUNT(*) * 100, 2) AS `无效率(%)`
FROM `区域` r
JOIN `传感器` s ON s.`区域编号` = r.`区域编号`
JOIN `监测数据` d ON d.`传感器编号` = s.`传感器编号`
WHERE d.`数据采集时间` >= NOW() - INTERVAL 7 DAY
GROUP BY r.`区域编号`, r.`区域名称`, s.`监测类型`
HAVING `无效率(%)` >= 5      -- 阈值可配置
ORDER BY `无效率(%)` DESC, `无效数据量` DESC;
