-- 查询1：统计“森林”区域中，各类型设备的故障数量
SELECT d.`设备类型`, COUNT(d.`设备编号`) AS `总数`,
       SUM(CASE WHEN d.`状态`='故障' THEN 1 ELSE 0 END) AS `故障数`
FROM `设备档案` d
JOIN `区域` a ON d.`区域编号` = a.`区域编号`
WHERE a.`区域类型` = '森林'
GROUP BY d.`设备类型`;

-- 查询2：查找过去一个月内进行过“更换”操作的维护记录
SELECT u.`真实姓名`, a.`区域名称`, d.`设备名称`, l.`维护结果`
FROM `维护记录` l
JOIN `用户` u ON l.`维护人ID` = u.`用户ID`
JOIN `设备档案` d ON l.`设备编号` = d.`设备编号`
JOIN `区域` a ON d.`区域编号` = a.`区域编号`
WHERE l.`维护类型` = '更换' AND l.`维护时间` >= DATE_SUB(NOW(), INTERVAL 1 MONTH);

-- 查询3：分析各区域的“设备健康度”
SELECT a.`区域名称`, COUNT(d.`设备编号`) as `设备数`, AVG(s.`电池电量`) as `平均电量`
FROM `区域` a
JOIN `设备档案` d ON a.`区域编号` = d.`区域编号`
JOIN `设备状态` s ON d.`设备编号` = s.`设备编号`
GROUP BY a.`区域名称`;
