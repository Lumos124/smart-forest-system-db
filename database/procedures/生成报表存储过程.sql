DELIMITER $$

CREATE PROCEDURE sp_generate_report(
    IN p_template_id INT UNSIGNED,
    IN p_stat_period VARCHAR(20),
    IN p_generator_id INT UNSIGNED,
    IN p_file_path VARCHAR(500),
    IN p_data_source_desc TEXT,
    IN p_file_size BIGINT,
    IN p_access_level ENUM('公开','内部','机密'),
    OUT p_report_id INT UNSIGNED,
    OUT p_result_message VARCHAR(200)
)
BEGIN
    DECLARE v_template_exists BOOLEAN DEFAULT FALSE;
    DECLARE v_template_active BOOLEAN DEFAULT FALSE;
    DECLARE v_template_approved BOOLEAN DEFAULT FALSE;
    DECLARE v_role_id INT UNSIGNED;
    DECLARE v_has_permission BOOLEAN DEFAULT FALSE;
    DECLARE v_report_exists BOOLEAN DEFAULT FALSE;
    DECLARE v_report_name VARCHAR(100);
    
    -- 开始事务
    START TRANSACTION;
    
    -- 1. 检查模板是否存在且可用
    SELECT 
        COUNT(*) > 0,
        是否生效,
        审核状态 = '通过',
        报表名称
    INTO 
        v_template_exists,
        v_template_active,
        v_template_approved,
        v_report_name
    FROM 报表模板 
    WHERE 模板编号 = p_template_id;
    
    IF NOT v_template_exists THEN
        SET p_result_message = CONCAT('模板不存在，模板编号：', p_template_id);
        ROLLBACK;
        LEAVE PROCEDURE;
    END IF;
    
    IF NOT v_template_active THEN
        SET p_result_message = CONCAT('模板未生效，模板编号：', p_template_id);
        ROLLBACK;
        LEAVE PROCEDURE;
    END IF;
    
    -- 检查是否需要审核且已通过
    IF (SELECT 是否需要审核 FROM 报表模板 WHERE 模板编号 = p_template_id) 
       AND NOT v_template_approved THEN
        SET p_result_message = CONCAT('模板需要审核通过后才能使用，模板编号：', p_template_id);
        ROLLBACK;
        LEAVE PROCEDURE;
    END IF;
    
    -- 2. 检查用户权限
    SELECT 角色编号 INTO v_role_id FROM 用户 WHERE 用户编号 = p_generator_id AND 状态 = '正常';
    
    SELECT COUNT(*) > 0 INTO v_has_permission
    FROM 角色权限关联表 rp
    JOIN 权限 p ON rp.权限编号 = p.权限编号
    WHERE rp.角色编号 = v_role_id
      AND p.权限代码 = 'REPORT_GENERATE';
    
    IF NOT v_has_permission THEN
        SET p_result_message = '用户没有生成报表的权限';
        ROLLBACK;
        LEAVE PROCEDURE;
    END IF;
    
    -- 3. 检查是否已生成过该周期的报表
    SELECT COUNT(*) > 0 INTO v_report_exists
    FROM 生成报表 
    WHERE 模板编号 = p_template_id AND 统计周期 = p_stat_period;
    
    IF v_report_exists THEN
        SET p_result_message = CONCAT('该模板在周期"', p_stat_period, '"已生成过报表');
        ROLLBACK;
        LEAVE PROCEDURE;
    END IF;
    
    -- 4. 生成报表
    INSERT INTO 生成报表 (
        模板编号, 统计周期, 报表文件存储路径, 数据来源说明,
        生成人ID, 文件大小, 访问级别
    ) VALUES (
        p_template_id, p_stat_period, p_file_path, p_data_source_desc,
        p_generator_id, p_file_size, p_access_level
    );
    
    -- 获取生成的报表ID
    SET p_report_id = LAST_INSERT_ID();
    
    -- 5. 更新模板最后使用时间
    UPDATE 报表模板 
    SET 最后使用时间 = NOW() 
    WHERE 模板编号 = p_template_id;
    
    -- 6. 记录操作日志
    INSERT INTO 操作日志 (用户ID, 操作类型, 目标表, 目标ID, 操作结果, 操作详情)
    VALUES (p_generator_id, 'GENERATE_REPORT', '生成报表', p_report_id, '成功',
            JSON_OBJECT('template_id', p_template_id, 'stat_period', p_stat_period, 
                       'template_name', v_report_name));
    
    SET p_result_message = CONCAT('报表生成成功，报表编号：', p_report_id);
    
    -- 提交事务
    COMMIT;
    
END$$

DELIMITER ;
