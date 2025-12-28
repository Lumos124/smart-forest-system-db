SELECT 
    c.log_id,
    op_user.username AS 操作人,
    mgr_user.username AS 区域负责人,
    a.area_name AS 发生区域,
    r.variety AS 涉及资源,
    c.change_type,
    c.change_time
FROM ChangeLog c
JOIN Resource r ON c.resource_id = r.resource_id
JOIN Area a ON r.area_id = a.area_id
JOIN User op_user ON c.operator_id = op_user.user_id      -- 关联找出操作人
JOIN User mgr_user ON a.manager_id = mgr_user.user_id     -- 关联找出区域负责人
WHERE c.operator_id != a.manager_id                       -- 核心逻辑：操作人不是负责人
  AND op_user.role != '系统管理员'                         -- 排除拥有最高权限的管理员
ORDER BY c.change_time DESC;