import pymysql
from pymysql.cursors import DictCursor
from datetime import datetime

DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': '123456',
    'database': 'forestry_system',
    'charset': 'utf8mb4',
    'port': 3306,
    'autocommit': False
}

class ForestryDAO:
    def __init__(self):
        try:
            self.conn = pymysql.connect(**DB_CONFIG)
            self.cursor = self.conn.cursor(DictCursor)
            print("数据库连接成功")
        except pymysql.Error as e:
            print(f"数据库连接失败: {e}")

    def __del__(self):
        if hasattr(self, 'cursor') and self.cursor:
            self.cursor.close()
        if hasattr(self, 'conn') and self.conn:
            self.conn.close()

    # 林草资源 表 CRUD 操作
    def insert_resource(self, res_id, area_id, res_type, variety, amount, stage, plant_time):
        """[C] 新增资源 """
        sql = """
        INSERT INTO `林草资源` (`资源编号`, `区域编号`, `资源类型`, `品种名称`, `数量或面积`, `生长状态`, `种植时间`) 
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        """
        try:
            self.cursor.execute(sql, (res_id, area_id, res_type, variety, amount, stage, plant_time))
            self.conn.commit()
            print(f"[林草资源] 插入成功 ID: {res_id}")
            return True
        except pymysql.Error as e:
            self.conn.rollback()
            print(f"[林草资源] 插入失败: {e}")
            return False

    def get_resource_by_id(self, res_id):
        """[R] 查询单个资源详情"""
        sql = "SELECT * FROM `林草资源` WHERE `资源编号` = %s"
        self.cursor.execute(sql, (res_id,))
        return self.cursor.fetchone()

    def update_resource_stage(self, res_id, new_stage, amount_change=0):
        """[U] 更新资源状态和数量"""
        sql = """
        UPDATE `林草资源` 
        SET `生长状态` = %s, `数量或面积` = `数量或面积` + %s, `最后更新时间` = NOW()
        WHERE `资源编号` = %s
        """
        try:
            self.cursor.execute(sql, (new_stage, amount_change, res_id))
            self.conn.commit()
            print(f"[林草资源] 更新成功 ID: {res_id}")
            return True
        except pymysql.Error as e:
            self.conn.rollback()
            print(f"[林草资源] 更新失败: {e}")
            return False

    def delete_resource(self, res_id):
        """[D] 删除资源"""
        sql = "DELETE FROM `林草资源` WHERE `资源编号` = %s"
        try:
            self.cursor.execute(sql, (res_id,))
            self.conn.commit()
            print(f"[林草资源] 删除成功 ID: {res_id}")
            return True
        except pymysql.Error as e:
            self.conn.rollback()
            print(f"[林草资源] 删除失败 (可能存在关联日志): {e}")
            return False

    # 资源变动记录 表 CRUD 操作
    def insert_changelog(self, res_id, change_type, reason, op_id):
        """[C] 插入变动日志"""
        sql = """
        INSERT INTO `资源变动记录` (`资源编号`, `变动类型`, `变动原因`, `操作人ID`, `变动时间`)
        VALUES (%s, %s, %s, %s, NOW())
        """
        try:
            self.cursor.execute(sql, (res_id, change_type, reason, op_id))
            self.conn.commit()
            new_log_id = self.cursor.lastrowid
            print(f"[资源变动记录] 日志记录成功 ID: {new_log_id}")
            return True
        except pymysql.Error as e:
            self.conn.rollback()
            print(f"[资源变动记录] 记录失败: {e}")
            return False

    def get_logs_by_resource(self, res_id):
        """[R] 查询某资源的所有历史变动"""
        sql = """
        SELECT c.`变动编号`, c.`变动类型`, c.`变动原因`, c.`变动时间`, u.`用户名`
        FROM `资源变动记录` c
        JOIN `用户` u ON c.`操作人ID` = u.`用户ID`
        WHERE c.`资源编号` = %s
        ORDER BY c.`变动时间` DESC
        """
        self.cursor.execute(sql, (res_id,))
        return self.cursor.fetchall()

    # 统计与分析操作
    def stat_area_resource_summary(self):
        """[统计] 各区域资源总量统计"""
        sql = """
        SELECT 
            a.`区域名称`,
            u.`用户名` AS manager,
            COUNT(r.`资源编号`) AS resource_count,
            IFNULL(SUM(r.`数量或面积`), 0) AS total_amount
        FROM `区域` a
        LEFT JOIN `林草资源` r ON a.`区域编号` = r.`区域编号`
        LEFT JOIN `用户` u ON a.`负责人ID` = u.`用户ID`
        GROUP BY a.`区域编号`, a.`区域名称`, u.`用户名`
        """
        self.cursor.execute(sql)
        return self.cursor.fetchall()

    def stat_avg_seedling_days(self):
        """[统计] 计算系统中所有 '幼苗' 的平均种植天数"""
        sql = """
        SELECT AVG(DATEDIFF(NOW(), `种植时间`)) as avg_days
        FROM `林草资源` 
        WHERE `生长状态` = '幼苗'
        """
        self.cursor.execute(sql)
        result = self.cursor.fetchone()
        return result['avg_days'] if result else 0

# 测试代码
if __name__ == "__main__":
    dao = ForestryDAO()

    print("\n--- 1. 测试插入新资源 ---")
    dao.insert_resource(
        res_id=9001, area_id=201, res_type='树木',
        variety='测试松', amount=100.0, stage='幼苗',
        plant_time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    )

    print("\n--- 2. 测试插入日志 ---")
    dao.insert_changelog(
        res_id=3001,
        change_type='新增', reason='Python脚本测试录入', op_id=101
    )

    print("\n--- 3. 测试查询资源 ---")
    res = dao.get_resource_by_id(9001)
    # 注意：如果表字段是中文，字典的Key也是中文
    print(f"查询结果: {res}") 

    print("\n--- 4. 测试更新资源 ---")
    dao.update_resource_stage(3001, '幼苗', amount_change=0)
    dao.insert_changelog(3001, '状态更新', '测试自动升级', 101)

    print("\n--- 5. 测试统计操作 ---")
    stats = dao.stat_area_resource_summary()
    for row in stats:
        print(f"区域: {row['区域名称']} | 负责人: {row['manager']} | 资源数: {row['resource_count']}")