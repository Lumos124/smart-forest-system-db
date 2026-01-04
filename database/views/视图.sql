-- 视图1：设备完整档案视图 (中文版)
CREATE OR REPLACE VIEW `v_设备完整信息` AS
SELECT 
    d.`设备编号`, d.`设备名称`, d.`设备类型`, d.`状态` AS `当前状态`,
    a.`区域名称`, a.`区域类型`,
    u.`真实姓名` AS `安装人姓名`, d.`采购时间`
FROM `设备档案` d
LEFT JOIN `区域` a ON d.`区域编号` = a.`区域编号`
LEFT JOIN `用户` u ON d.`安装人ID` = u.`用户ID`;

-- 视图2：设备故障预警视图
CREATE OR REPLACE VIEW `v_设备故障预警` AS
SELECT d.`设备编号`, d.`设备名称`, a.`区域名称`, d.`状态`, d.`型号规格`
FROM `设备档案` d
JOIN `区域` a ON d.`区域编号` = a.`区域编号`
WHERE d.`状态` IN ('故障', '离线', '报废');

-- 视图3：区域设备维护统计视图
CREATE OR REPLACE VIEW `v_区域维护统计` AS
SELECT a.`区域名称`, COUNT(DISTINCT d.`设备编号`) AS `设备总数`,
       COUNT(l.`维护编号`) AS `累计维护次数`
FROM `区域` a
JOIN `设备档案` d ON a.`区域编号` = d.`区域编号`
LEFT JOIN `维护记录` l ON d.`设备编号` = l.`设备编号`
GROUP BY a.`区域名称`;
