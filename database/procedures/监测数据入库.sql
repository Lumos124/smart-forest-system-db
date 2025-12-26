DROP PROCEDURE IF EXISTS `sp_监测数据入库`;
DELIMITER $$

CREATE PROCEDURE `sp_监测数据入库`(
  IN p_传感器编号 BIGINT,
  IN p_数据采集时间 DATETIME(3),
  IN p_监测数值 DECIMAL(10,3),
  IN p_图像存储路径 VARCHAR(255)
)
BEGIN
  DECLARE v_监测类型 ENUM('温度','湿度','图像','其他');
  DECLARE v_状态 ENUM('有效','无效');

  -- 1) 传感器存在性校验
  SELECT `监测类型` INTO v_监测类型
  FROM `传感器`
  WHERE `传感器编号` = p_传感器编号;

  IF v_监测类型 IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '传感器不存在：无法入库监测数据';
  END IF;

  -- 2) CHECK约束等价校验
  IF p_监测数值 IS NULL AND (p_图像存储路径 IS NULL OR p_图像存储路径 = '') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '监测数值与图像存储路径至少提供一个';
  END IF;

  -- 3) 业务规则：按监测类型判定有效性
  SET v_状态 = '有效';

  IF v_监测类型 = '温度' AND p_监测数值 IS NOT NULL THEN
    IF p_监测数值 < -50 OR p_监测数值 > 60 THEN
      SET v_状态 = '无效';
    END IF;
  END IF;

  IF v_监测类型 = '湿度' AND p_监测数值 IS NOT NULL THEN
    IF p_监测数值 < 0 OR p_监测数值 > 100 THEN
      SET v_状态 = '无效';
    END IF;
  END IF;

  -- 图像类：只要有路径即可视为有效
  IF v_监测类型 = '图像' THEN
    IF p_图像存储路径 IS NULL OR p_图像存储路径 = '' THEN
      SET v_状态 = '无效';
    END IF;
  END IF;

  -- 4) 入库
  INSERT INTO `监测数据`(
    `数据采集时间`, `传感器编号`, `监测数值`, `图像存储路径`, `数据状态`
  ) VALUES (
    p_数据采集时间, p_传感器编号, p_监测数值, p_图像存储路径, v_状态
  );
END $$

DELIMITER ;

/*
-- 温度：给数值即可
CALL sp_监测数据入库(1, NOW(3), 23.500, NULL);

-- 图像：给路径即可
CALL sp_监测数据入库(2, NOW(3), NULL, '/img/area1/20251219_120001.jpg');

-- 既不给值也不给路径：会被过程拦截并报错（更易读）
CALL sp_监测数据入库(3, NOW(3), NULL, NULL);
*/
