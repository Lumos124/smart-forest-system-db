-- =============================================
-- 模块：设备管理
-- 功能：性能优化索引 (针对高频查询字段)
-- =============================================

-- 1. 优化设备检索：加快按“设备类型”过滤的速度
-- 场景：护林员经常筛选“只看摄像头”
CREATE INDEX idx_device_type ON sys_device(device_type);

-- 2. 优化状态监测：加快按“采集时间”的时间轴查询
-- 场景：大屏展示“最近24小时数据”
CREATE INDEX idx_status_time ON sys_device_status(collect_time);

-- 3. 优化维护考核：加快按“维护人员”统计绩效
-- 场景：月底统计某员工修了多少设备
CREATE INDEX idx_maint_person ON sys_maintenance_log(maint_person_id);