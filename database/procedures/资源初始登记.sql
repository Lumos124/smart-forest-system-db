DROP PROCEDURE IF EXISTS `sp_资源初始登记`;

DELIMITER $$

CREATE PROCEDURE `sp_资源初始登记`(
    IN p_resource_id BIGINT,
    IN p_area_id INT,
    IN p_res_type VARCHAR(20), 
    IN p_variety VARCHAR(50),
    IN p_amount DECIMAL(10,2),
    IN p_growth_stage VARCHAR(20),
    IN p_operator_id INT
)
BEGIN
    DECLARE v_area_type VARCHAR(20);
    DECLARE v_user_role VARCHAR(20);
    DECLARE v_exists INT;

    -- 1) 基础校验：操作人是否存在？
    SELECT role INTO v_user_role FROM User WHERE user_id = p_operator_id;
    IF v_user_role IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '错误：操作员不存在，无法登记';
    END IF;

    -- 2) 基础校验：区域是否存在？
    SELECT area_type INTO v_area_type FROM Area WHERE area_id = p_area_id;
    IF v_area_type IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '错误：指定区域不存在';
    END IF;

    -- 3) 唯一性校验：ID是否冲突
    SELECT COUNT(*) INTO v_exists FROM Resource WHERE resource_id = p_resource_id;
    IF v_exists > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '错误：资源ID已存在，请核对';
    END IF;

    -- 4) 业务规则校验：生态匹配性
    -- 规则：如果区域是“森林”，不建议大面积种植“草地”资源，反之亦然。
    -- 这里做成强校验，提升逻辑复杂度
    IF v_area_type = '森林' AND p_res_type = '草地' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '业务冲突：森林区域禁止登记草地资源';
    END IF;
    
    IF v_area_type = '草地' AND p_res_type = '树木' THEN
         -- 允许草地种树（防风固沙），但数量不能过大（假设单次上限1000）
         IF p_amount > 1000 THEN
             SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '业务预警：草地种树单次数量不能超过1000株';
         END IF;
    END IF;

    -- 5) 数据有效性校验
    IF p_amount <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '错误：资源数量必须大于0';
    END IF;

    -- 6) 事务执行：同时写入资源表和日志表
    START TRANSACTION;
        -- 插入资源
        INSERT INTO Resource (resource_id, area_id, res_type, variety, amount, growth_stage, plant_time, update_time)
        VALUES (p_resource_id, p_area_id, p_res_type, p_variety, p_amount, p_growth_stage, NOW(), NOW());

        -- 自动插入日志
        INSERT INTO ChangeLog (resource_id, change_type, reason, operator_id, change_time)
        VALUES (p_resource_id, '新增', '系统存储过程标准化录入', p_operator_id, NOW());
        
    COMMIT;
END $$

DELIMITER ;

/*
-- 测试用例：
-- 1. 正常录入
CALL sp_资源初始登记(8001, 201, '树木', '红松', 50, '幼苗', 101);
-- 2. 报错：ID重复
CALL sp_资源初始登记(8001, 201, '树木', '红松', 50, '幼苗', 101);
-- 3. 报错：森林里种草
CALL sp_资源初始登记(8002, 201, '草地', '野草', 50, '幼苗', 101);
*/