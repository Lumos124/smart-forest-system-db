DROP PROCEDURE IF EXISTS `sp_资源初始登记`;

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
    SELECT `角色` INTO v_user_role FROM `用户` WHERE `用户ID` = p_operator_id;
    IF v_user_role IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '错误：操作员不存在，无法登记';
    END IF;

    -- 2) 基础校验：区域是否存在？
    SELECT `区域类型` INTO v_area_type FROM `区域` WHERE `区域编号` = p_area_id;
    IF v_area_type IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '错误：指定区域不存在';
    END IF;

    -- 3) 唯一性校验：ID是否冲突
    SELECT COUNT(*) INTO v_exists FROM `林草资源` WHERE `资源编号` = p_resource_id;
    IF v_exists > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '错误：资源ID已存在，请核对';
    END IF;

    -- 4) 业务规则校验：生态匹配性
    IF v_area_type = '森林' AND p_res_type = '草地' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '业务冲突：森林区域禁止登记草地资源';
    END IF;
    
    IF v_area_type = '草地' AND p_res_type = '树木' THEN
         IF p_amount > 1000 THEN
             SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '业务预警：草地种树单次数量不能超过1000株';
         END IF;
    END IF;

    -- 5) 数据有效性校验
    IF p_amount <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '错误：资源数量必须大于0';
    END IF;

    -- 6) 事务执行
    START TRANSACTION;
        -- 插入资源
        INSERT INTO `林草资源` (`资源编号`, `区域编号`, `资源类型`, `品种名称`, `数量或面积`, `生长状态`, `种植时间`, `最后更新时间`)
        VALUES (p_resource_id, p_area_id, p_res_type, p_variety, p_amount, p_growth_stage, NOW(), NOW());

        -- 自动插入日志
        INSERT INTO `资源变动记录` (`资源编号`, `变动类型`, `变动原因`, `操作人ID`, `变动时间`)
        VALUES (p_resource_id, '新增', '系统存储过程标准化录入', p_operator_id, NOW());
        
    COMMIT;
END;