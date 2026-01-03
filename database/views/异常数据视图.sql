DROP VIEW IF EXISTS `v_异常数据`;
CREATE VIEW `v_异常数据` AS
SELECT
  d.`数据编号`,
  d.`数据采集时间`,
  a.`区域编号`,
  a.`区域名称`,
  s.`传感器编号`,
  s.`设备型号`,
  s.`监测类型`,
  d.`监测数值`,
  d.`图像存储路径`,
  d.`数据状态`
FROM `监测数据` d
JOIN `传感器` s ON s.`传感器编号` = d.`传感器编号`
JOIN `区域` a ON a.`区域编号` = s.`区域编号`
WHERE d.`数据状态` <> '有效';
