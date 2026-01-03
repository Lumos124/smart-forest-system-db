DROP TRIGGER IF EXISTS `trg_资源逻辑强校验`;

DELIMITER $$

CREATE TRIGGER `trg_资源逻辑强校验`
BEFORE UPDATE ON `林草资源`
FOR EACH ROW
BEGIN
    -- 1. 保护主键不被修改
    IF OLD.`资源编号` != NEW.`资源编号` THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '安全拦截：禁止修改资源编号(PK)';
    END IF;

    -- 2. 防止生长阶段倒退
    IF OLD.`生长状态` = '成熟期' AND NEW.`生长状态` = '幼苗' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '逻辑错误：成熟期资源不可逆转为幼苗';
    END IF;
    
    IF OLD.`生长状态` = '成长期' AND NEW.`生长状态` = '幼苗' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '逻辑错误：成长期资源不可逆转为幼苗';
    END IF;

    -- 3. 数量底线校验
    IF NEW.`数量或面积` < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '数据错误：资源数量不能为负数';
    END IF;

    -- 4. 自动化字段更新
    SET NEW.`最后更新时间` = NOW();
END $$

DELIMITER ;