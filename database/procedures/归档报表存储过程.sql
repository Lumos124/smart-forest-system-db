DELIMITER $$

CREATE PROCEDURE sp_archive_report(
    IN p_report_id INT UNSIGNED,
    IN p_user_id INT UNSIGNED,
    OUT p_result_message VARCHAR(200)
)
proc_main: BEGIN
    DECLARE v_report_exists BOOLEAN DEFAULT FALSE;
    DECLARE v_current_status ENUM('已生成','已发布','已归档');
    DECLARE v_user_role INT UNSIGNED;
    DECLARE v_report_name VARCHAR(100);
    DECLARE v_has_permission BOOLEAN DEFAULT FALSE;
    DECLARE v_is_owner BOOLEAN DEFAULT FALSE;
    DECLARE v_template_id INT UNSIGNED;
    DECLARE v_generator_id INT UNSIGNED;
    DECLARE v_report_count INT UNSIGNED DEFAULT 0;
    DECLARE v_days_since_last_use INT DEFAULT 0;
    
    -- Start transaction
    START TRANSACTION;
    
    -- 1. Check if report exists
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
        SET p_result_message = CONCAT('Report does not exist, ID: ', p_report_id);
        ROLLBACK;
        LEAVE proc_main;
    END IF;
    
    IF v_current_status = '已归档' THEN
        SET p_result_message = CONCAT('Report "', v_report_name, '" is already archived');
        ROLLBACK;
        LEAVE proc_main;
    END IF;
    
    -- 2. Check user permissions
    SELECT 角色编号 INTO v_user_role 
    FROM 用户 
    WHERE 用户编号 = p_user_id AND 状态 = '正常';
    
    IF v_user_role IS NULL THEN
        SET p_result_message = 'User does not exist or account is disabled';
        ROLLBACK;
        LEAVE proc_main;
    END IF;
    
    -- Check if user is the report owner
    SELECT COUNT(*) > 0 INTO v_is_owner
    FROM 生成报表 
    WHERE 报表编号 = p_report_id AND 生成人ID = p_user_id;
    
    -- Check archive permission (owner, system admin, or supervisor)
    IF v_is_owner THEN
        SET v_has_permission = TRUE;
    ELSE
        IF v_user_role IN (1, 5) THEN
            SET v_has_permission = TRUE;
        END IF;
    END IF;
    
    IF NOT v_has_permission THEN
        SET p_result_message = 'No permission to archive this report';
        ROLLBACK;
        LEAVE proc_main;
    END IF;
    
    -- 3. Check if there are other unarchived reports for this template
    SELECT COUNT(*) INTO v_report_count
    FROM 生成报表
    WHERE 模板编号 = v_template_id 
        AND 报表编号 != p_report_id 
        AND 报表状态 != '已归档';
    
    -- 4. Execute archive operation
    UPDATE 生成报表 
    SET 
        报表状态 = '已归档',
        归档时间 = NOW()
    WHERE 报表编号 = p_report_id;
    
    -- 5. If all reports of this template are archived, check if template is unused
    IF v_report_count = 0 THEN
        SELECT TIMESTAMPDIFF(DAY, 最后使用时间, NOW()) INTO v_days_since_last_use
        FROM 报表模板 
        WHERE 模板编号 = v_template_id;
        
        IF v_days_since_last_use > 30 THEN
            INSERT INTO 操作日志 (用户ID, 操作类型, 目标表, 目标ID, 操作详情, 操作结果)
            VALUES (p_user_id, 'ARCHIVE_NOTICE', '报表模板', v_template_id, 
                   CONCAT('All reports for template "', v_report_name, '" are archived and unused for 30+ days'), 
                   '成功');
        END IF;
    END IF;
    
    -- 6. Log the archive operation
    INSERT INTO 操作日志 (用户ID, 操作类型, 目标表, 目标ID, 操作详情, 操作结果)
    VALUES (p_user_id, 'ARCHIVE_REPORT', '生成报表', p_report_id, 
           CONCAT('Archived report "', v_report_name, '"(ID:', p_report_id, ')'), 
           '成功');
    
    -- 7. Record archive history
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
        'Manual archive'
    );
    
    COMMIT;
    
    SET p_result_message = CONCAT('Report "', v_report_name, '" archived successfully');
    
END$$

DELIMITER ;
