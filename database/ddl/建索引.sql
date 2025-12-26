-- 按区域查询传感器
CREATE INDEX idx_传感器_区域
ON `传感器` (`区域编号`);

-- 按监测类型筛选（温度/湿度/图像）
CREATE INDEX idx_传感器_监测类型
ON `传感器` (`监测类型`);

CREATE INDEX idx_监测数据_传感器_时间
ON `监测数据` (`传感器编号`, `数据采集时间`);

CREATE INDEX idx_监测数据_采集时间
ON `监测数据` (`数据采集时间`);

CREATE INDEX idx_监测数据_状态
ON `监测数据` (`数据状态`);
