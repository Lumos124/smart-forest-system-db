DELIMITER $$

CREATE PROCEDURE sp_approve_template(
    IN p_template_id INT UNSIGNED,
    IN p_admin_id INT UNSIGNED,
    IN p_approve_action ENUM('通过','驳回'),
    IN p_reason TEXT,
    OUT p_result_message VARCHAR(200)
)
proc_main: BEGIN
    DECLARE v_template_exists BOOLEAN DEFAULT FALSE;
    DECLARE v_admin_role INT UNSIGNED;
    DECLARE v_current_status ENUM('待审核','通过','驳回');
    DECLARE v_template_name VARCHAR(100);
    DECLARE v_need_approve BOOLEAN;
    
    START TRANSACTION;
    
    -- 获取管理员角色
    SELECT 角色编号 INTO v_admin_role
    FROM 用户
    WHERE 用户编号 = p_admin_id AND 状态 = '正常';
    
    IF v_admin_role IS NULL THEN
        SET p_result_message = '管理员用户不存在';
        ROLLBACK;
        LEAVE proc_main;
    END IF;
    
    IF v_admin_role != 1 THEN
        SET p_result_message = '只有系统管理员可以审核模板';
        ROLLBACK;
        LEAVE proc_main;
    END IF;
    
    -- 修复：使用 EXISTS 检查模板是否存在
    SELECT EXISTS (
        SELECT 1
        FROM 报表模板
        WHERE 模板编号 = p_template_id
          AND 是否需要审核 = TRUE
    ) INTO v_template_exists;
    
    IF NOT v_template_exists THEN
        SET p_result_message = CONCAT('模板不存在或不需要审核，模板编号：', p_template_id);
        ROLLBACK;
        LEAVE proc_main;
    END IF;
    
    -- 获取模板详细信息
    SELECT 
        审核状态,
        报表名称,
        是否需要审核
    INTO 
        v_current_status,
        v_template_name,
        v_need_approve
    FROM 报表模板
    WHERE 模板编号 = p_template_id;
    
    IF v_current_status != '待审核' THEN
        SET p_result_message = CONCAT('模板当前状态为"', v_current_status, '"，无需重复审核');
        ROLLBACK;
        LEAVE proc_main;
    END IF;
    
    -- 更新模板状态
    UPDATE 报表模板
    SET 审核状态 = p_approve_action
    WHERE 模板编号 = p_template_id;
    
    -- 记录操作日志
    INSERT INTO 操作日志 (用户ID, 操作类型, 目标表, 目标ID, 操作结果, 操作详情)
    VALUES (p_admin_id, 'APPROVE_TEMPLATE', '报表模板', p_template_id, '成功',
            JSON_OBJECT('template_id', p_template_id, 'template_name', v_template_name,
                       'action', p_approve_action, 'reason', COALESCE(p_reason, '')));
    
    IF p_approve_action = '驳回' THEN
        SET p_result_message = CONCAT('模板"', v_template_name, '"已驳回，原因：', COALESCE(p_reason, ''));
    ELSE
        SET p_result_message = CONCAT('模板"', v_template_name, '"审核通过');
    END IF;
    
    COMMIT;
END$$

DELIMITER ;
