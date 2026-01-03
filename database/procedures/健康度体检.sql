DELIMITER //

DROP PROCEDURE IF EXISTS pro_area_health_check //

CREATE PROCEDURE pro_area_health_check(
    IN target_area_id INT,           -- 输入：区域ID
    OUT health_score DECIMAL(5,2),   -- 输出：健康分
    OUT health_level VARCHAR(20)     -- 输出：评级
)
BEGIN
    DECLARE total_count INT DEFAULT 0;
    DECLARE good_count INT DEFAULT 0;
    
    -- 1. 计算该区域设备总数
    SELECT COUNT(*) INTO total_count 
    FROM sys_device WHERE area_id = target_area_id;
    
    -- 2. 计算完好设备数 (状态为'正常')
    SELECT COUNT(*) INTO good_count 
    FROM sys_device 
    WHERE area_id = target_area_id AND status = '正常';
    
    -- 3. 核心业务逻辑：计算得分与评级
    IF total_count = 0 THEN
        SET health_score = 0;
        SET health_level = '无设备';
    ELSE
        SET health_score = (good_count / total_count) * 100;
        
        IF health_score >= 90 THEN
            SET health_level = '优秀 (A级)';
        ELSEIF health_score >= 60 THEN
            SET health_level = '良好 (B级)';
        ELSE
            SET health_level = '警告 (需维护)';
        END IF;
    END IF;
END //

DELIMITER ;