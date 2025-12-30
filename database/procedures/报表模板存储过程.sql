DELIMITER $$

CREATE PROCEDURE sp_create_template(
    IN p_report_name VARCHAR(100),
    IN p_dimension VARCHAR(50),
    IN p_indicator VARCHAR(100),
    IN p_cycle_type ENUM('日','周','月','季','年'),
    IN p_data_source VARCHAR(50),
    IN p_need_approve BOOLEAN,
    IN p_creator_id INT UNSIGNED,
    IN p_description TEXT,
    OUT p_template_id INT UNSIGNED,
    OUT p_result_message VARCHAR(200)
)
BEGIN
    DECLARE v_role_id INT UNSIGNED;
    DECLARE v_has_permission BOOLEAN DEFAULT FALSE;
    
    -- 开始事务
    START TRANSACTION;
    
    -- 1. 检查用户权限
    SELECT 角色编号 INTO v_role_id FROM 用户 WHERE 用户编号 = p_creator_id AND 状态 = '正常';
    
    -- 检查是否有创建模板的权限
    SELECT COUNT(*) > 0 INTO v_has_permission
    FROM 角色权限关联表 rp
    JOIN 权限 p ON rp.权限编号 = p.权限编号
    WHERE rp.角色编号 = v_role_id
      AND p.权限代码 = 'TEMPLATE_CREATE';
    
    IF NOT v_has_permission THEN
        SET p_result_message = '用户没有创建报表模板的权限';
        ROLLBACK;
        LEAVE PROCEDURE;
    END IF;
    
    -- 2. 检查报表名称是否重复
    IF EXISTS(SELECT 1 FROM 报表模板 WHERE 报表名称 = p_report_name) THEN
        SET p_result_message = CONCAT('报表名称"', p_report_name, '"已存在');
        ROLLBACK;
        LEAVE PROCEDURE;
    END IF;
    
    -- 3. 插入模板记录
    INSERT INTO 报表模板 (
        报表名称, 统计维度, 统计指标, 生成周期, 
        数据来源, 是否需要审核, 创建人ID
    ) VALUES (
        p_report_name, p_dimension, p_indicator, p_cycle_type,
        p_data_source, p_need_approve, p_creator_id
    );
    
    -- 获取生成的模板ID
    SET p_template_id = LAST_INSERT_ID();
    
    -- 4. 记录操作日志
    INSERT INTO 操作日志 (用户ID, 操作类型, 目标表, 目标ID, 操作结果, 操作详情)
    VALUES (p_creator_id, 'CREATE_TEMPLATE', '报表模板', p_template_id, '成功',
            JSON_OBJECT('report_name', p_report_name, 'dimension', p_dimension));
    
    -- 5. 根据是否需要审核设置状态
    IF p_need_approve THEN
        UPDATE 报表模板 SET 审核状态 = '待审核' WHERE 模板编号 = p_template_id;
        SET p_result_message = CONCAT('模板创建成功，模板编号：', p_template_id, '，等待审核');
    ELSE
        UPDATE 报表模板 SET 审核状态 = '通过' WHERE 模板编号 = p_template_id;
        SET p_result_message = CONCAT('模板创建成功，模板编号：', p_template_id);
    END IF;
    
    -- 提交事务
    COMMIT;
    
END$$

DELIMITER ;
