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

proc_main: BEGIN
    DECLARE v_template_exists INT DEFAULT 0;
    DECLARE v_template_active BOOLEAN DEFAULT FALSE;
    DECLARE v_template_approved BOOLEAN DEFAULT FALSE;
    DECLARE v_role_id INT UNSIGNED;
    DECLARE v_has_permission INT DEFAULT 0;
    DECLARE v_report_exists INT DEFAULT 0;
    DECLARE v_report_name VARCHAR(100);
    
    START TRANSACTION;

    -- 直接查询，不使用COUNT(*)>0
    SELECT 
        是否生效,
        审核状态 = '通过',
        报表名称
    INTO 
        v_template_active,
        v_template_approved,
        v_report_name
    FROM 报表模板
    WHERE 模板编号 = p_template_id;

    -- 检查模板是否存在
    SELECT COUNT(*) INTO v_template_exists
    FROM 报表模板
    WHERE 模板编号 = p_template_id;

    IF v_template_exists = 0 THEN
        SET p_result_message = CONCAT('模板不存在，ID：', p_template_id);
        SET p_report_id = 0;
        ROLLBACK;
        LEAVE proc_main;
    END IF;

    IF NOT v_template_active THEN
        SET p_result_message = CONCAT('模板未启用，ID：', p_template_id);
        SET p_report_id = 0;
        ROLLBACK;
        LEAVE proc_main;
    END IF;

    IF NOT v_template_approved THEN
        SET p_result_message = CONCAT('模板未审核通过，ID：', p_template_id);
        SET p_report_id = 0;
        ROLLBACK;
        LEAVE proc_main;
    END IF;

    SELECT 角色编号 INTO v_role_id FROM 用户 WHERE 用户编号 = p_generator_id AND 状态 = '正常';

    IF v_role_id IS NULL THEN
        SET p_result_message = '用户不存在或已禁用';
        SET p_report_id = 0;
        ROLLBACK;
        LEAVE proc_main;
    END IF;

    -- 使用子查询避免GROUP BY问题
    SELECT EXISTS (
        SELECT 1
        FROM 角色权限关联表 rp
        JOIN 权限 p ON rp.权限编号 = p.权限编号
        WHERE rp.角色编号 = v_role_id
        AND p.权限代码 = 'REPORT_GENERATE'
    ) INTO v_has_permission;

    IF NOT v_has_permission THEN
        SET p_result_message = '没有生成报表的权限';
        SET p_report_id = 0;
        ROLLBACK;
        LEAVE proc_main;
    END IF;

    SELECT COUNT(*) INTO v_report_exists
    FROM 生成报表
    WHERE 模板编号 = p_template_id AND 统计周期 = p_stat_period;

    IF v_report_exists > 0 THEN
        SET p_result_message = CONCAT('该周期报表已存在，周期：', p_stat_period);
        SET p_report_id = 0;
        ROLLBACK;
        LEAVE proc_main;
    END IF;

    INSERT INTO 生成报表 (
        模板编号, 统计周期, 报表文件存储路径, 数据来源说明,
        生成人ID, 文件大小, 访问级别
    ) VALUES (
        p_template_id, p_stat_period, p_file_path, p_data_source_desc,
        p_generator_id, p_file_size, p_access_level
    );

    SET p_report_id = LAST_INSERT_ID();

    UPDATE 报表模板
    SET 最后使用时间 = NOW()
    WHERE 模板编号 = p_template_id;

    INSERT INTO 操作日志 (用户ID, 操作类型, 目标表, 目标ID, 操作结果, 操作详情)
    VALUES (p_generator_id, 'GENERATE_REPORT', '生成报表', p_report_id, '成功',
        JSON_OBJECT('template_id', p_template_id, 'stat_period', p_stat_period,
                    'template_name', v_report_name));

    SET p_result_message = CONCAT('报表生成成功，编号：', p_report_id);

    COMMIT;
END$$

DELIMITER ;
