DELIMITER $$

DROP TRIGGER IF EXISTS tr_after_download_insert;

CREATE TRIGGER tr_after_download_insert
AFTER INSERT ON 下载日志
FOR EACH ROW
BEGIN
    -- 更新生成报表表的下载次数
    UPDATE 生成报表 
    SET 下载次数 = 下载次数 + 1
    WHERE 报表编号 = NEW.报表编号;
    
    -- 记录到操作日志
    INSERT INTO 操作日志 (用户ID, 操作类型, 目标表, 目标ID, 操作详情, 操作结果)
    VALUES (NEW.用户ID, 'DOWNLOAD_REPORT', '生成报表', NEW.报表编号, 
            CONCAT('用户下载报表，日志ID:', NEW.日志编号), '成功');
END$$

DELIMITER ;
