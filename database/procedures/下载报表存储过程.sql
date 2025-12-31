DELIMITER $$

CREATE PROCEDURE sp_download_report(
    IN p_report_id INT UNSIGNED,
    IN p_user_id INT UNSIGNED,
    IN p_ip_address VARCHAR(45),
    IN p_user_agent VARCHAR(500),
    IN p_file_size BIGINT,
    OUT p_result_message VARCHAR(200)
)
proc_label: BEGIN
    DECLARE v_report_exists BOOLEAN DEFAULT FALSE;
    DECLARE v_user_exists BOOLEAN DEFAULT FALSE;
    DECLARE v_access_level ENUM('公开','内部','机密');
    DECLARE v_user_role INT UNSIGNED;
    DECLARE v_report_name VARCHAR(100);
    DECLARE v_user_area INT UNSIGNED;
    DECLARE v_report_area INT UNSIGNED;
    DECLARE v_can_access BOOLEAN DEFAULT FALSE;
    DECLARE v_has_permission BOOLEAN DEFAULT FALSE;
    
    START TRANSACTION;
    
    -- 方法1：使用子查询避免 GROUP BY 问题
    -- 先检查报表是否存在
    SELECT EXISTS (
        SELECT 1 
        FROM 生成报表 gr
        WHERE gr.报表编号 = p_report_id 
          AND gr.报表状态 IN ('已生成', '已发布')
    ) INTO v_report_exists;
    
    IF NOT v_report_exists THEN
        SET p_result_message = CONCAT('报表不存在或不可用，报表编号：', p_report_id);
        ROLLBACK;
        LEAVE proc_label;
    END IF;
    
    -- 然后获取报表详细信息
    SELECT 
        gr.访问级别,
        rt.报表名称,
        u2.管辖区域编号
    INTO 
        v_access_level,
        v_report_name,
        v_report_area
    FROM 生成报表 gr
    JOIN 报表模板 rt ON gr.模板编号 = rt.模板编号
    JOIN 用户 u2 ON gr.生成人ID = u2.用户编号
    WHERE gr.报表编号 = p_report_id;
    
    -- 检查用户
    SELECT EXISTS (
        SELECT 1 
        FROM 用户 
        WHERE 用户编号 = p_user_id AND 状态 = '正常'
    ) INTO v_user_exists;
    
    IF NOT v_user_exists THEN
        SET p_result_message = '用户不存在或账户异常';
        ROLLBACK;
        LEAVE proc_label;
    END IF;
    
    -- 获取用户详细信息
    SELECT 
        角色编号,
        管辖区域编号
    INTO 
        v_user_role,
        v_user_area
    FROM 用户 
    WHERE 用户编号 = p_user_id AND 状态 = '正常';
    
    -- 权限检查逻辑（保持不变）
    IF v_access_level = '公开' THEN
        SET v_can_access = TRUE;
    -- 内部报表：系统管理员、数据管理员、区域护林员、监管人员
    ELSEIF v_access_level = '内部' AND v_user_role IN (1,2,3,5) THEN
        SET v_can_access = TRUE;
        -- 如果是区域护林员，只能访问自己区域的报表
        IF v_user_role = 3 AND v_user_area IS NOT NULL AND v_report_area IS NOT NULL 
           AND v_user_area != v_report_area THEN
            SET v_can_access = FALSE;
        END IF;
    -- 机密报表：仅系统管理员和监管人员
    ELSEIF v_access_level = '机密' AND v_user_role IN (1,5) THEN
        SET v_can_access = TRUE;
    END IF;
    
    IF NOT v_can_access THEN
        SET p_result_message = '没有权限下载该报表';
        ROLLBACK;
        LEAVE proc_label;
    END IF;
    
    -- 检查下载权限
    SELECT EXISTS (
        SELECT 1
        FROM 角色权限关联表 rp
        JOIN 权限 p ON rp.权限编号 = p.权限编号
        WHERE rp.角色编号 = v_user_role
          AND p.权限代码 IN ('REPORT_DOWNLOAD', 'REPORT_DOWNLOAD_ALL')
    ) INTO v_has_permission;
    
    IF NOT v_has_permission THEN
        SET p_result_message = '用户没有下载报表的权限';
        ROLLBACK;
        LEAVE proc_label;
    END IF;
    
    INSERT INTO 下载日志 (用户ID, 报表编号, 下载文件大小)
    VALUES (p_user_id, p_report_id, p_file_size);
    
    INSERT INTO 操作日志 (用户ID, 操作类型, 目标表, 目标ID, 操作结果, 操作详情)
    VALUES (p_user_id, 'DOWNLOAD_REPORT', '生成报表', p_report_id, '成功',
            JSON_OBJECT('report_id', p_report_id, 'report_name', v_report_name, 
                       'access_level', v_access_level));
    
    SET p_result_message = CONCAT('报表下载记录成功，报表：', v_report_name);
    
    COMMIT;
    
END$$

DELIMITER ;
