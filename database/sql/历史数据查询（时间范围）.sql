SELECT r.区域名称, s.传感器编号,
       m.监测数值, m.数据采集时间
FROM 区域 r
JOIN 传感器 s ON r.区域编号 = s.部署区域编号
JOIN 监测数据 m ON s.传感器编号 = m.传感器编号
WHERE r.负责人ID = 101
  AND m.数据采集时间 BETWEEN '2025-01-01' AND '2025-01-31'
ORDER BY m.数据采集时间;
