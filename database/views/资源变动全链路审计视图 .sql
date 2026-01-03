CREATE OR REPLACE VIEW `v_资源变动审计` AS
SELECT 
    c.`变动编号`,
    r.`品种名称` AS 资源名称,
    a.`区域名称` AS 所属区域,
    c.`变动类型` AS 动作,
    c.`变动原因` AS 详情,
    c.`变动时间`,
    -- 核心：对比操作人和负责人
    op_user.`用户名` AS 实际操作人,
    mgr_user.`用户名` AS 归属负责人,
    CASE 
        WHEN c.`操作人ID` = a.`负责人ID` THEN '正常履职'
        WHEN op_user.`角色` = '系统管理员' THEN '行政干预'
        ELSE '⚠️ 越权/代操作' 
    END AS 审计结论
FROM `资源变动记录` c
JOIN `林草资源` r ON c.`资源编号` = r.`资源编号`
JOIN `区域` a ON r.`区域编号` = a.`区域编号`
JOIN `用户` op_user ON c.`操作人ID` = op_user.`用户ID`
JOIN `用户` mgr_user ON a.`负责人ID` = mgr_user.`用户ID`;