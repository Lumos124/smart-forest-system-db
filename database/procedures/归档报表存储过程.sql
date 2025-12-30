DELIMITER $$

CREATE PROCEDURE sp_archive_report(
    IN p_report_id INT UNSIGNED,
    IN p_user_id INT UNSIGNED,
    OUT p_result_message VARCHAR(200)
)
BEGIN
    DECLARE v_report_exists BOOLEAN DEFAULT FALSE;
    DECLARE v_current_status ENUM('已生成','已发布','已归档');
    DECLARE v_user_role INT UNSIGNED;
    DECLARE v_report_name VARCHAR(100);
    DECLARE v_has_permission BOOLEAN DEFAULT FALSE;
    DECLARE v_is_owner BOOLEAN DEFAULT FALSE;
    DECLARE v_template_id INT UNSIGNED;
    DECLARE v_generator_id INT UNSIGNED;
    DECLARE v_report_count INT UNSIGNED DEFAULT 0;
    
    -- 开始事务
    START TRANSACTION;
    
    -- 1. 检查报表是否存在
    SELECT 
        COUNT(*) > 0,
        gr.报表状态,
        rt.报表名称,
        gr.模板编号,
        gr.生成人ID
    INTO 
        v_report_exists,
        v_current_status,
        v_report_name,
        v_template_id,
        v_generator_id
    FROM 生成报表 gr
    JOIN 报表模板 rt ON gr.模板编号 = rt.模板编号
    WHERE gr.报表编号 = p_report_id;
    
    IF NOT v_report_exists THEN
        SET p_result_message = CONCAT('报表不存在，报表编号：', p_report_id);
        ROLLBACK;
        LEAVE PROCEDURE;
    END IF;
    
    IF v_current_status = '已归档' THEN
        SET p_result_message = CONCAT('报表"', v_report_name, '"已经归档');
        ROLLBACK;
        LEAVE PROCEDURE;
    END IF;
    
    -- 2. 检查用户权限
    SELECT 角色编号 INTO v_user_role 
    FROM 用户 
    WHERE 用户编号 = p_user_id AND 状态 = '正常';
    
    IF v_user_role IS NULL THEN
        SET p_result_message = '用户不存在或账户被禁用';
        ROLLBACK;
        LEAVE PROCEDURE;
    END IF;
    
    -- 检查是否是报表所有者
    SELECT COUNT(*) > 0 INTO v_is_owner
    FROM 生成报表 
    WHERE 报表编号 = p_report_id AND 生成人ID = p_user_id;
    
    -- 检查是否有归档权限（报表所有者或系统管理员、监管人员）
    IF v_is_owner THEN
        SET v_has_permission = TRUE;
    ELSE
        -- 系统管理员和监管人员可以归档所有报表
        IF v_user_role IN (1, 5) THEN
            SET v_has_permission = TRUE;
        END IF;
    END IF;
    
    IF NOT v_has_permission THEN
        SET p_result_message = '没有权限归档该报表';
        ROLLBACK;
        LEAVE PROCEDURE;
    END IF;
    
    -- 3. 检查该模板下是否还有未归档的报表
    SELECT COUNT(*) INTO v_report_count
    FROM 生成报表
    WHERE 模板编号 = v_template_id 
        AND 报表编号 != p_report_id 
        AND 报表状态 != '已归档';
    
    -- 4. 执行归档操作
    UPDATE 生成报表 
    SET 
        报表状态 = '已归档',
        归档时间 = NOW()
    WHERE 报表编号 = p_report_id;
    
    -- 5. 如果该模板下所有报表都已归档，且模板长期未使用，可以提醒用户考虑停用模板
    IF v_report_count = 0 THEN
        -- 检查模板最后使用时间是否超过30天
        SELECT TIMESTAMPDIFF(DAY, 最后使用时间, NOW()) > 30 INTO v_report_exists
        FROM 报表模板 
        WHERE 模板编号 = v_template_id;
        
        IF v_report_exists THEN
            -- 这里可以添加通知逻辑，例如插入系统消息
            INSERT INTO 操作日志 (用户ID, 操作类型, 目标表, 目标ID, 操作详情, 操作结果)
            VALUES (p_user_id, 'ARCHIVE_NOTICE', '报表模板', v_template_id, 
                   CONCAT('模板"', v_report_name, '"下的所有报表都已归档，且超过30天未使用，建议检查是否需要停用'), 
                   '成功');
        END IF;
    END IF;
    
    -- 6. 记录归档操作日志
    INSERT INTO 操作日志 (用户ID, 操作类型, 目标表, 目标ID, 操作详情, 操作结果)
    VALUES (p_user_id, 'ARCHIVE_REPORT', '生成报表', p_report_id, 
           CONCAT('归档报表"', v_report_name, '"(ID:', p_report_id, ')'), 
           '成功');
    
    -- 7. 记录归档历史（如果需要详细跟踪）
    INSERT INTO 报表归档历史 (
        报表编号, 
        归档人ID, 
        归档时间, 
        归档前状态, 
        归档原因
    ) VALUES (
        p_report_id, 
        p_user_id, 
        NOW(), 
        v_current_status, 
        '手动归档'
    );
    
    -- 提交事务
    COMMIT;
    
    SET p_result_message = CONCAT('报表"', v_report_name, '"归档成功');
    
END$$

DELIMITER ;
