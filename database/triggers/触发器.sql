-- 触发器：设备状态自动同步 (trg_sync_device_status)
DELIMITER //
CREATE TRIGGER trg_sync_device_status
AFTER INSERT ON sys_device_status
FOR EACH ROW
BEGIN
    -- 故障同步逻辑
    IF NEW.run_status = '故障' THEN
        UPDATE sys_device SET status = '故障' WHERE device_id = NEW.device_id;
    END IF;
END;
//
DELIMITER ;
