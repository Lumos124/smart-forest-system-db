DROP TRIGGER IF EXISTS `trg_资源逻辑强校验`;

DELIMITER $$

CREATE TRIGGER `trg_资源逻辑强校验`
BEFORE UPDATE ON Resource
FOR EACH ROW
BEGIN
    -- 1. 保护主键不被修改 (防止数据孤岛)
    IF OLD.resource_id != NEW.resource_id THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '安全拦截：禁止修改资源编号(PK)';
    END IF;

    -- 2. 防止生长阶段倒退 (时间不可逆)
    -- 定义阶段权重: 幼苗=1, 成长期=2, 成熟期=3
    -- 注意：MySQL 触发器中比较字符串比较繁琐，这里用简化逻辑
    IF OLD.growth_stage = '成熟期' AND NEW.growth_stage = '幼苗' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '逻辑错误：成熟期资源不可逆转为幼苗';
    END IF;
    
    IF OLD.growth_stage = '成长期' AND NEW.growth_stage = '幼苗' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '逻辑错误：成长期资源不可逆转为幼苗';
    END IF;

    -- 3. 数量底线校验
    IF NEW.amount < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '数据错误：资源数量不能为负数';
    END IF;

    -- 4. 自动化字段更新
    -- 只要有任何数据变动，自动刷新 update_time 为当前时间（无需业务层手动传）
    SET NEW.update_time = NOW();
END $$

DELIMITER ;