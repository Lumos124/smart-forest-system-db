-- 查询1：统计“森林”区域中，各类型设备的故障数量及最后一次维护时间
SELECT d.device_type, COUNT(d.device_id) AS total,
       SUM(CASE WHEN d.status='故障' THEN 1 ELSE 0 END) AS fault_count,
       MAX(l.maint_time) AS last_maint
FROM sys_device d
JOIN sys_area a ON d.area_id = a.area_id
LEFT JOIN sys_maintenance_log l ON d.device_id = l.device_id
WHERE a.area_type = '森林'
GROUP BY d.device_type;

-- 查询2：查找过去一个月内进行过“更换”操作的员工及其负责区域
SELECT u.real_name, a.area_name, d.device_name, l.maint_result
FROM sys_maintenance_log l
JOIN sys_user u ON l.maint_person_id = u.user_id
JOIN sys_device d ON l.device_id = d.device_id
JOIN sys_area a ON d.area_id = a.area_id
WHERE l.maint_type = '更换' AND l.maint_time >= DATE_SUB(NOW(), INTERVAL 1 MONTH);

-- 查询3：分析各区域的“设备健康度”（设备表+状态表+区域表）
SELECT a.area_name, COUNT(d.device_id) as dev_count, AVG(s.battery_level) as avg_battery
FROM sys_area a
JOIN sys_device d ON a.area_id = d.area_id
JOIN sys_device_status s ON d.device_id = s.device_id
GROUP BY a.area_name;

-- 查询4：统计每位安装工人的设备故障率（用户表+设备表+状态表）
SELECT u.real_name, COUNT(d.device_id) as install_total,
       SUM(CASE WHEN s.run_status = '故障' THEN 1 ELSE 0 END) as fault_count
FROM sys_user u
JOIN sys_device d ON u.user_id = d.installer_id
JOIN sys_device_status s ON d.device_id = s.device_id
GROUP BY u.real_name;

-- 查询5：查询“森林”区域内所有质保期即将过期（<12个月）的设备
SELECT d.device_name, a.area_name, d.install_time, d.warranty_period
FROM sys_device d
JOIN sys_area a ON d.area_id = a.area_id
WHERE a.area_type = '森林' AND d.warranty_period < 12;
