DELIMITER $$

DROP TRIGGER IF EXISTS tr_after_report_generate;

CREATE TRIGGER tr_after_report_generate
AFTER INSERT ON 生成报表
FOR EACH ROW
BEGIN
    -- 更新报表模板的最后使用时间
    UPDATE 报表模板 
    SET 最后使用时间 = NEW.生成时间
    WHERE 模板编号 = NEW.模板编号;
END$$

DELIMITER ;
