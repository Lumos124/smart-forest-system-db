SET @current_user_id := 2001;

SELECT
    r.区域名称,
    s.传感器编号,
    m.监测数值,
    m.数据采集时间
FROM 区域 r
JOIN 传感器 s
    ON r.区域编号 = s.区域编号
JOIN 监测数据 m
    ON s.传感器编号 = m.传感器编号
JOIN 用户 u
    ON u.用户ID = r.负责人ID
WHERE
    u.用户ID = @current_user_id
    AND u.角色 = '护林员'
    AND u.状态 = '正常'
  AND m.数据采集时间 >= '2025-12-30 08:00:00'
  AND m.数据采集时间 <  '2025-12-30 12:00:00'
ORDER BY m.数据采集时间;


