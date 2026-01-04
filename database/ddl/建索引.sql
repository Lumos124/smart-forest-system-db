
-- 1. 优化设备检索：加快按“设备类型”过滤的速度
-- 场景：护林员经常在列表页筛选“只看摄像头”或“只看传感器”
CREATE INDEX idx_device_type ON sys_device(device_type);

-- 2. 优化状态监测：加快按“采集时间”的时间轴查询
-- 场景：大屏展示“最近24小时数据”趋势图时，此索引至关重要
CREATE INDEX idx_status_time ON sys_device_status(collect_time);

-- 3. 优化维护考核：加快按“维护人员”统计绩效
-- 场景：月底统计某员工（如张三）修了多少设备
CREATE INDEX idx_maint_person ON sys_maintenance_log(maint_person_id);
