USE smart_forest_analysis;

-- ==================== 用户表索引 ====================
-- 1. 用户复合查询索引（按角色、状态、最后登录时间）
CREATE INDEX idx_user_composite ON 用户(角色编号, 状态, 最后登录时间 DESC);

-- 2. 用户活跃度查询索引
CREATE INDEX idx_user_active ON 用户(最后登录时间 DESC, 状态);

-- 3. 区域用户查询索引（用于护林员管理）
CREATE INDEX idx_user_area ON 用户(管辖区域编号, 角色编号, 状态);

-- ==================== 报表模板表索引 ====================
-- 4. 模板复合查询索引（按生效状态、审核状态、创建时间）
CREATE INDEX idx_template_composite ON 报表模板(是否生效, 审核状态, 创建时间 DESC);

-- 5. 模板数据来源索引（按数据来源类型查询）
CREATE INDEX idx_template_data_source ON 报表模板(数据来源, 是否生效);

-- 6. 模板创建者索引（查询用户创建的模板）
CREATE INDEX idx_template_creator_search ON 报表模板(创建人ID, 创建时间 DESC);

-- ==================== 生成报表表索引 ====================
-- 7. 报表状态复合索引（按状态、访问级别、生成时间）
CREATE INDEX idx_report_composite ON 生成报表(报表状态, 访问级别, 生成时间 DESC);

-- 8. 报表模板-周期查询索引
CREATE INDEX idx_report_search ON 生成报表(模板编号, 统计周期, 报表状态);

-- 9. 报表生成者索引（查询用户生成的报表）
CREATE INDEX idx_report_generator ON 生成报表(生成人ID, 生成时间 DESC);

-- 10. 报表归档索引（按归档时间查询）
CREATE INDEX idx_report_archive ON 生成报表(归档时间 DESC, 报表状态);

-- 11. 报表下载热度索引（按下载次数排序）
CREATE INDEX idx_report_download_hot ON 生成报表(下载次数 DESC, 生成时间 DESC);

-- 12. 报表区域查询索引（结合用户表查询区域报表）
CREATE INDEX idx_report_area ON 生成报表(生成人ID, 报表状态, 访问级别);

-- ==================== 下载日志表索引 ====================
-- 13. 下载分析索引（按用户、下载时间、报表）
CREATE INDEX idx_dl_analysis ON 下载日志(用户ID, 下载时间 DESC, 报表编号);

-- 14. 报表下载统计索引（按报表、下载时间）
CREATE INDEX idx_dl_report_stats ON 下载日志(报表编号, 下载时间 DESC);

-- 15. 日期范围下载查询索引
CREATE INDEX idx_dl_date_range ON 下载日志(下载时间 DESC, 用户ID);

-- 16. 用户下载行为分析索引
CREATE INDEX idx_dl_user_behavior ON 下载日志(用户ID, 报表编号, 下载时间 DESC);

-- ==================== 操作日志表索引 ====================
-- 17. 操作审计索引（按操作类型、结果、时间）
CREATE INDEX idx_ol_audit ON 操作日志(操作类型, 操作结果, 操作时间 DESC);

-- 18. 用户操作追踪索引
CREATE INDEX idx_ol_user_tracking ON 操作日志(用户ID, 操作类型, 操作时间 DESC);

-- 19. 目标对象操作历史索引
CREATE INDEX idx_ol_target_history ON 操作日志(目标表, 目标ID, 操作时间 DESC);

-- 20. 错误操作分析索引
CREATE INDEX idx_ol_error_analysis ON 操作日志(操作结果, 操作时间 DESC, 操作类型);

-- ==================== 角色权限表索引 ====================
-- 21. 角色权限查询索引
CREATE INDEX idx_role_permission_query ON 角色权限关联表(角色编号, 创建时间 DESC);

-- 22. 权限角色查询索引
CREATE INDEX idx_permission_role_query ON 角色权限关联表(权限编号, 角色编号);

-- ==================== 全文索引（支持中文搜索） ====================
-- 23. 报表模板名称全文索引（支持模糊搜索）
CREATE FULLTEXT INDEX ft_report_name ON 报表模板(报表名称);

-- 24. 报表模板统计指标全文索引
CREATE FULLTEXT INDEX ft_stat_indicator ON 报表模板(统计指标);

-- 25. 操作日志详情全文索引（便于审计查询）
CREATE FULLTEXT INDEX ft_operation_detail ON 操作日志(操作详情);

-- ==================== 复合覆盖索引（Covering Indexes） ====================
-- 26. 报表列表查询覆盖索引（减少回表）
CREATE INDEX idx_report_list_covering ON 生成报表(报表状态, 生成时间 DESC, 报表编号, 统计周期, 下载次数, 访问级别);

-- 27. 用户模板列表覆盖索引
CREATE INDEX idx_user_template_covering ON 报表模板(创建人ID, 是否生效, 模板编号, 报表名称, 审核状态, 最后使用时间);

-- 28. 下载统计覆盖索引
CREATE INDEX idx_download_stats_covering ON 下载日志(下载时间 DESC, 用户ID, 报表编号, 下载文件大小);

-- ==================== 函数索引 ====================
-- 29. 日期函数索引（按月统计查询优化）
ALTER TABLE 下载日志 ADD INDEX idx_dl_month ((DATE_FORMAT(下载时间, '%Y-%m')));
ALTER TABLE 操作日志 ADD INDEX idx_ol_month ((DATE_FORMAT(操作时间, '%Y-%m')));
