-- 视图1：设备完整档案视图 (v_device_full_info)
CREATE OR REPLACE VIEW v_device_full_info AS
SELECT 
    d.device_id, d.device_name, d.device_type, d.status AS current_status,
    a.area_name, a.area_type,
    u.real_name AS installer_name, d.purchase_time
FROM sys_device d
LEFT JOIN sys_area a ON d.area_id = a.area_id
LEFT JOIN sys_user u ON d.installer_id = u.user_id;

-- 视图2：设备故障预警视图 (v_device_alert)
CREATE OR REPLACE VIEW v_device_alert AS
SELECT d.device_id, d.device_name, a.area_name, d.status, d.model_spec
FROM sys_device d
JOIN sys_area a ON d.area_id = a.area_id
WHERE d.status IN ('故障', '离线', '报废');

-- 视图3：区域设备维护统计视图 (v_area_maintenance_stats)
CREATE OR REPLACE VIEW v_area_maintenance_stats AS
SELECT a.area_name, COUNT(DISTINCT d.device_id) AS total_devices,
       COUNT(l.log_id) AS total_maintenance_times
FROM sys_area a
JOIN sys_device d ON a.area_id = d.area_id
LEFT JOIN sys_maintenance_log l ON d.device_id = l.device_id
GROUP BY a.area_name;
