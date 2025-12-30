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
    
    -- 开始事务
    START TRANSACTION;
    
    -- 1. 检查报表是否存在
    SELECT 
        COUNT(*) > 0,
        报表状态,
        rt.报表名称
    INTO 
        v_report_exists,
        v_current_status,
        v_report_name
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
    
    --
