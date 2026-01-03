SELECT 
    c.`变动编号`,
    op_user.`用户名` AS `操作人`,
    mgr_user.`用户名` AS `区域负责人`,
    a.`区域名称` AS `发生区域`,
    r.`品种名称` AS `涉及资源`,
    c.`变动类型`,
    c.`变动时间`
FROM `资源变动记录` c
JOIN `林草资源` r ON c.`资源编号` = r.`资源编号`
JOIN `区域` a ON r.`区域编号` = a.`区域编号`
JOIN `用户` op_user ON c.`操作人ID` = op_user.`用户ID`
JOIN `用户` mgr_user ON a.`负责人ID` = mgr_user.`用户ID`
WHERE c.`操作人ID` != a.`负责人ID`
  AND op_user.`角色` != '系统管理员'
ORDER BY c.`变动时间` DESC;