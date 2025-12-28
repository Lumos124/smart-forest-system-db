-- Area 表索引
CREATE INDEX idx_area_manager ON Area(manager_id); -- 区域-负责人关联

-- Resource 表索引
CREATE INDEX idx_res_area ON Resource(area_id);    -- 区域-资源关联
-- 组合索引：最常查询的是 "某种类型的某种状态" (如: 树木-幼苗)
CREATE INDEX idx_res_type_stage ON Resource(res_type, growth_stage); 
CREATE INDEX idx_res_update_time ON Resource(update_time); -- 长期未维护检测
CREATE INDEX idx_res_type_variety ON Resource(res_type, variety);


-- ChangeLog 表索引
CREATE INDEX idx_log_time ON ChangeLog(change_time);       -- 按时间段审计
CREATE INDEX idx_log_resource ON ChangeLog(resource_id);   -- 资源-日志关联
CREATE INDEX idx_log_operator ON ChangeLog(operator_id);   -- 人员-操作关联