DELIMITER //

DROP PROCEDURE IF EXISTS pro_area_health_check //

CREATE PROCEDURE pro_area_health_check(
    IN target_area_id INT,           -- 输入参数：要检查的区域ID
    OUT health_score DECIMAL(5,2),   -- 输出参数：健康得分(0-100)
    OUT health_level VARCHAR(20)     -- 输出参数：健康评级
)
BEGIN
    DECLARE total_count INT DEFAULT 0;
    DECLARE good_count INT DEFAULT 0;
    
    -- 1. 统计该区域下的设备总数
    SELECT COUNT(*) INTO total_count 
    FROM sys_device WHERE area_id = target_area_id;
    
    -- 2. 统计状态为“正常”的完好设备数
    SELECT COUNT(*) INTO good_count 
    FROM sys_device 
    WHERE area_id = target_area_id AND status = '正常';
    
    -- 3. 核心算法：计算得分与评级
    IF total_count = 0 THEN
        SET health_score = 0;
        SET health_level = '无设备数据';
    ELSE
        -- 得分 = (完好数 / 总数) * 100
        SET health_score = (good_count / total_count) * 100;
        
        -- 根据得分判定等级
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
