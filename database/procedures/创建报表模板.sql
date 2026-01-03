DELIMITER $$

DROP PROCEDURE IF EXISTS sp_create_template$$

CREATE PROCEDURE sp_create_template(
    IN p_report_name VARCHAR(100),
    IN p_dimension VARCHAR(50),
    IN p_indicator VARCHAR(100),
    IN p_cycle_type ENUM('日','周','月','季','年'),
    IN p_data_source VARCHAR(50),
    IN p_creator_id INT UNSIGNED,
    IN p_description TEXT,
    OUT p_template_id INT UNSIGNED,
    OUT p_result_message VARCHAR(200)
)
proc_main: BEGIN
    DECLARE v_role_id INT UNSIGNED;
    DECLARE v_has_permission BOOLEAN DEFAULT FALSE;
    
    START TRANSACTION;
    
    -- 检查用户权限
    SELECT 角色编号 INTO v_role_id 
    FROM 用户 
    WHERE 用户编号 = p_creator_id AND 状态 = '正常';
    
    IF v_role_id IS NULL THEN
        SET p_result_message = '用户不存在或账户异常';
        SET p_template_id = 0;
        ROLLBACK;
        LEAVE proc_main;
    END IF;
    
    -- 检查创建模板权限
    SELECT COUNT(*) > 0 INTO v_has_permission
    FROM 角色权限关联表 rp
    JOIN 权限 p ON rp.权限编号 = p.权限编号
    WHERE rp.角色编号 = v_role_id
    AND p.权限代码 = 'TEMPLATE_CREATE';
    
    IF NOT v_has_permission THEN
        SET p_result_message = '用户没有创建报表模板的权限';
        SET p_template_id = 0;
        ROLLBACK;
        LEAVE proc_main;
    END IF;
    
    -- 检查模板名称是否重复
    IF EXISTS(SELECT 1 FROM 报表模板 WHERE 报表名称 = p_report_name) THEN
        SET p_result_message = CONCAT('模板名称 "', p_report_name, '" 已存在');
        SET p_template_id = 0;
        ROLLBACK;
        LEAVE proc_main;
    END IF;
    
    -- 插入模板记录，所有模板都需要审核
    INSERT INTO 报表模板 (
        报表名称,
        统计维度,
        统计指标,
        生成周期,
        数据来源,
        是否生效,
        审核状态,  -- 默认设置为'待审核'
        创建人ID
    ) VALUES (
        p_report_name,
        p_dimension,
        p_indicator,
        p_cycle_type,
        p_data_source,
        TRUE,      -- 默认生效
        '待审核',  -- 所有模板都需要审核
        p_creator_id
    );
    
    SET p_template_id = LAST_INSERT_ID();
    
    -- 记录操作日志
    INSERT INTO 操作日志 (用户ID, 操作类型, 目标表, 目标ID, 操作结果, 操作详情)
    VALUES (
        p_creator_id,
        'CREATE_TEMPLATE',
        '报表模板',
        p_template_id,
        '成功',
        CONCAT('创建报表模板: ', p_report_name, ' 维度: ', p_dimension)
    );
    
    SET p_result_message = CONCAT('模板创建成功，编号: ', p_template_id, '，等待管理员审核');
    
    COMMIT;
END$$

DELIMITER ;
