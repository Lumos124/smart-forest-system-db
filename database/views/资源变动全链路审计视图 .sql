CREATE OR REPLACE VIEW v_资源变动审计 AS
SELECT 
    c.log_id,
    r.variety AS 资源名称,
    a.area_name AS 所属区域,
    c.change_type AS 动作,
    c.reason AS 详情,
    c.change_time,
    -- 核心：对比操作人和负责人
    op_user.username AS 实际操作人,
    mgr_user.username AS 归属负责人,
    CASE 
        WHEN c.operator_id = a.manager_id THEN '正常履职'
        WHEN op_user.role = '系统管理员' THEN '行政干预'
        ELSE '⚠️ 越权/代操作' 
    END AS 审计结论
FROM ChangeLog c
JOIN Resource r ON c.resource_id = r.resource_id
JOIN Area a ON r.area_id = a.area_id
JOIN User op_user ON c.operator_id = op_user.user_id
JOIN User mgr_user ON a.manager_id = mgr_user.user_id;