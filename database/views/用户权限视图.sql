CREATE OR REPLACE VIEW 用户权限视图 AS
SELECT 
    u.用户编号,
    u.用户名,
    u.真实姓名,
    r.角色名称,
    r.角色描述,
    p.权限代码,
    p.权限名称,
    p.资源类型,
    p.操作类型,
    p.资源范围,
    p.权限描述
FROM 用户 u
JOIN 角色 r ON u.角色编号 = r.角色编号
JOIN 角色权限关联表 rp ON r.角色编号 = rp.角色编号
JOIN 权限 p ON rp.权限编号 = p.权限编号
WHERE u.状态 = '正常'
ORDER BY u.用户编号, p.资源类型, p.操作类型;
