DELIMITER //

CREATE TRIGGER trg_check_monitor_data
BEFORE INSERT ON 监测数据
FOR EACH ROW
BEGIN
    IF NEW.监测数值 < -40 OR NEW.监测数值 > 80 THEN
        SET NEW.数据状态 = '无效';
    ELSE
        SET NEW.数据状态 = '有效';
    END IF;
END//

DELIMITER ;