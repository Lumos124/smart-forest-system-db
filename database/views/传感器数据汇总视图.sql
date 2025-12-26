DROP VIEW IF EXISTS `v_传感器数据汇总`;
CREATE VIEW `v_传感器数据汇总` AS
SELECT
  a.`区域编号`,
  a.`区域名称`,
  s.`传感器编号`,
  s.`设备型号`,
  s.`监测类型`,
  s.`通信协议`,
  MAX(d.`数据采集时间`) AS `最近采集时间`,
  SUM(d.`数据采集时间` >= NOW(3) - INTERVAL 24 HOUR) AS `近24h总数`,
  SUM(d.`数据采集时间` >= NOW(3) - INTERVAL 24 HOUR AND d.`数据状态`='有效') AS `近24h有效数`,
  SUM(d.`数据采集时间` >= NOW(3) - INTERVAL 24 HOUR AND d.`数据状态`='无效') AS `近24h无效数`,
  ROUND(
    100 * SUM(d.`数据采集时间` >= NOW(3) - INTERVAL 24 HOUR AND d.`数据状态`='有效')
    / NULLIF(SUM(d.`数据采集时间` >= NOW(3) - INTERVAL 24 HOUR), 0),
    2
  ) AS `近24h有效率(%)`
FROM `传感器` s
JOIN `区域` a ON a.`区域编号` = s.`区域编号`
LEFT JOIN `监测数据` d ON d.`传感器编号` = s.`传感器编号`
GROUP BY
  a.`区域编号`, a.`区域名称`,
  s.`传感器编号`, s.`设备型号`, s.`监测类型`, s.`通信协议`;
