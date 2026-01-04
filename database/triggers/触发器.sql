DELIMITER //
DROP TRIGGER IF EXISTS `trg_状态自动同步` //
CREATE TRIGGER `trg_状态自动同步`
AFTER INSERT ON `设备状态`
FOR EACH ROW
BEGIN
    -- 当监测到故障时，自动更新主档案状态
    IF NEW.`运行状态` = '故障' THEN
        UPDATE `设备档案` SET `状态` = '故障' WHERE `设备编号` = NEW.`设备编号`;
    END IF;
END;
//
DELIMITER ;
