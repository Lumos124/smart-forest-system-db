DROP VIEW IF EXISTS `v_区域日均值`;
CREATE VIEW `v_区域日均值` AS
SELECT
  a.`区域编号`,
  a.`区域名称`,
  a.`区域类型`,
  DATE(d.`数据采集时间`) AS `统计日期`,
  s.`监测类型`,
  COUNT(*) AS `记录总数`,
  SUM(d.`数据状态`='有效') AS `有效记录数`,
  AVG(CASE WHEN d.`数据状态`='有效' THEN d.`监测数值` END) AS `有效均值`,
  MAX(CASE WHEN d.`数据状态`='有效' THEN d.`监测数值` END) AS `有效最大值`,
  MIN(CASE WHEN d.`数据状态`='有效' THEN d.`监测数值` END) AS `有效最小值`
FROM `区域` a
JOIN `传感器` s ON s.`区域编号` = a.`区域编号`
JOIN `监测数据` d ON d.`传感器编号` = s.`传感器编号`
GROUP BY
  a.`区域编号`, a.`区域名称`, a.`区域类型`,
  DATE(d.`数据采集时间`),
  s.`监测类型`;
