-- 区域 表索引
CREATE INDEX `idx_area_manager` ON `区域`(`负责人ID`); -- 区域-负责人关联

-- 林草资源 表索引
CREATE INDEX `idx_res_area` ON `林草资源`(`区域编号`);    -- 区域-资源关联
-- 组合索引：最常查询的是 "某种类型的某种状态" (如: 树木-幼苗)
CREATE INDEX `idx_res_type_stage` ON `林草资源`(`资源类型`, `生长状态`); 
CREATE INDEX `idx_res_update_time` ON `林草资源`(`最后更新时间`); -- 长期未维护检测
CREATE INDEX `idx_res_type_variety` ON `林草资源`(`资源类型`, `品种名称`);

-- 资源变动记录 表索引
CREATE INDEX `idx_log_time` ON `资源变动记录`(`变动时间`);       -- 按时间段审计
CREATE INDEX `idx_log_resource` ON `资源变动记录`(`资源编号`);   -- 资源-日志关联
CREATE INDEX `idx_log_operator` ON `资源变动记录`(`操作人ID`);   -- 人员-操作关联