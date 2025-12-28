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
    'autocommit': False  # 关闭自动提交，手动控制事务
}


class ForestryDAO:
    def __init__(self):
        """初始化数据库连接"""
        try:
            self.conn = pymysql.connect(**DB_CONFIG)
            self.cursor = self.conn.cursor(DictCursor)
            print("数据库连接成功")
        except pymysql.Error as e:
            print(f"数据库连接失败: {e}")

    def __del__(self):
        """析构函数，关闭连接"""
        if hasattr(self, 'cursor') and self.cursor:
            self.cursor.close()
        if hasattr(self, 'conn') and self.conn:
            self.conn.close()

    # Resource 表 CRUD 操作
    def insert_resource(self, res_id, area_id, res_type, variety, amount, stage, plant_time):
        """[C] 新增资源 """
        sql = """
        INSERT INTO Resource (resource_id, area_id, res_type, variety, amount, growth_stage, plant_time) 
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        """
        try:
            self.cursor.execute(sql, (res_id, area_id, res_type, variety, amount, stage, plant_time))
            self.conn.commit()
            print(f"[Resource] 插入成功 ID: {res_id}")
            return True
        except pymysql.Error as e:
            self.conn.rollback()
            print(f"[Resource] 插入失败: {e}")
            return False

    def get_resource_by_id(self, res_id):
        """[R] 查询单个资源详情"""
        sql = "SELECT * FROM Resource WHERE resource_id = %s"
        self.cursor.execute(sql, (res_id,))
        return self.cursor.fetchone()

    def update_resource_stage(self, res_id, new_stage, amount_change=0):
        """[U] 更新资源状态和数量"""
        sql = """
        UPDATE Resource 
        SET growth_stage = %s, amount = amount + %s, update_time = NOW()
        WHERE resource_id = %s
        """
        try:
            self.cursor.execute(sql, (new_stage, amount_change, res_id))
            self.conn.commit()
            print(f"[Resource] 更新成功 ID: {res_id}")
            return True
        except pymysql.Error as e:
            self.conn.rollback()
            print(f"[Resource] 更新失败: {e}")
            return False

    def delete_resource(self, res_id):
        """[D] 删除资源 (需注意外键约束，若有日志则可能失败，除非级联删除)"""
        sql = "DELETE FROM Resource WHERE resource_id = %s"
        try:
            self.cursor.execute(sql, (res_id,))
            self.conn.commit()
            print(f"[Resource] 删除成功 ID: {res_id}")
            return True
        except pymysql.Error as e:
            self.conn.rollback()
            print(f"[Resource] 删除失败 (可能存在关联日志): {e}")
            return False

    # ChangeLog 表 CRUD 操作
    def insert_changelog(self, res_id, change_type, reason, op_id):
        """[C] 插入变动日志"""
        sql = """
        INSERT INTO ChangeLog (resource_id, change_type, reason, operator_id, change_time)
        VALUES (%s, %s, %s, %s, NOW())
        """
        try:
            self.cursor.execute(sql, (res_id, change_type, reason, op_id))
            self.conn.commit()
            new_log_id = self.cursor.lastrowid
            print(f"[ChangeLog] 日志记录成功 ID: {new_log_id}")
            return True
        except pymysql.Error as e:
            self.conn.rollback()
            print(f"[ChangeLog] 记录失败: {e}")
            return False

    def get_logs_by_resource(self, res_id):
        """[R] 查询某资源的所有历史变动"""
        sql = """
        SELECT c.log_id, c.change_type, c.reason, c.change_time, u.username
        FROM ChangeLog c
        JOIN User u ON c.operator_id = u.user_id
        WHERE c.resource_id = %s
        ORDER BY c.change_time DESC
        """
        self.cursor.execute(sql, (res_id,))
        return self.cursor.fetchall()

    # 统计与分析操作
    def stat_area_resource_summary(self):
        """[统计] 各区域资源总量统计 (连接3个表: Area, Resource, User)"""
        sql = """
        SELECT 
            a.area_name,
            u.username AS manager,
            COUNT(r.resource_id) AS resource_count,
            IFNULL(SUM(r.amount), 0) AS total_amount
        FROM Area a
        LEFT JOIN Resource r ON a.area_id = r.area_id
        LEFT JOIN User u ON a.manager_id = u.user_id
        GROUP BY a.area_id, a.area_name, u.username
        """
        self.cursor.execute(sql)
        return self.cursor.fetchall()

    def stat_avg_seedling_days(self):
        """[统计] 计算系统中所有 '幼苗' 的平均种植天数"""
        sql = """
        SELECT AVG(DATEDIFF(NOW(), plant_time)) as avg_days
        FROM Resource 
        WHERE growth_stage = '幼苗'
        """
        self.cursor.execute(sql)
        result = self.cursor.fetchone()
        return result['avg_days'] if result else 0


# 测试代码
if __name__ == "__main__":
    dao = ForestryDAO()

    print("\n--- 1. 测试插入新资源 ---")
    # 假设区域 201 存在 (前面SQL已创建)
    dao.insert_resource(
        res_id=9001, area_id=201, res_type='树木',
        variety='测试松', amount=100.0, stage='幼苗',
        plant_time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    )

    print("\n--- 2. 测试插入日志 ---")
    # 假设操作人 101 存在
    dao.insert_changelog(
        res_id=3001,
        change_type='新增', reason='Python脚本测试录入', op_id=101
    )

    print("\n--- 3. 测试查询资源 ---")
    res = dao.get_resource_by_id(9001)
    print(f"查询结果: {res}")

    print("\n--- 4. 测试更新资源 ---")
    dao.update_resource_stage(3001, '幼苗', amount_change=0)
    # 补一条日志
    dao.insert_changelog(3001, '状态更新', '测试自动升级', 101)

    print("\n--- 5. 测试统计操作 (连接3表) ---")
    stats = dao.stat_area_resource_summary()
    for row in stats:
        print(f"区域: {row['area_name']} | 负责人: {row['manager']} | 资源数: {row['resource_count']}")

    print("\n--- 6. 测试平均值统计 ---")
    avg_days = dao.stat_avg_seedling_days()
    print(f"幼苗平均种植天数: {float(avg_days):.2f} 天")

    # 清理测试数据 (可选，为了防止下次运行主键冲突)
    # print("\n--- 7. 清理测试数据 ---")
    # dao.delete_resource(9001) # 注意：如果有日志关联，需先删日志