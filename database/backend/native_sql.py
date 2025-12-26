import pymysql
from datetime import datetime

DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "1211",
    "database": "env-monitoring",
    "port": 3306,
    "charset": "utf8mb4",
    "cursorclass": pymysql.cursors.DictCursor
}

# 获取数据库连接
def get_connection():
    return pymysql.connect(**DB_CONFIG)

# 传感器相关CRUD
def add_sensor(sensor_id, region_id, model, sensor_type, install_time, protocol):
    sql = """
    INSERT INTO 传感器
    (传感器编号, 区域编号, 设备型号, 监测类型, 安装时间, 通信协议)
    VALUES (%s, %s, %s, %s, %s, %s)
    """
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute(sql, (
                sensor_id, region_id, model, sensor_type, install_time, protocol
            ))
        conn.commit()
    finally:
        conn.close()

def get_sensor(sensor_id):
    sql = "SELECT * FROM 传感器 WHERE 传感器编号 = %s"
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute(sql, (sensor_id,))
            return cursor.fetchone()
    finally:
        conn.close()

def update_sensor_model(sensor_id, new_model):
    sql = "UPDATE 传感器 SET 设备型号 = %s WHERE 传感器编号 = %s"
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute(sql, (new_model, sensor_id))
        conn.commit()
    finally:
        conn.close()

def delete_sensor(sensor_id):
    sql = "DELETE FROM 传感器 WHERE 传感器编号 = %s"
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute(sql, (sensor_id,))
        conn.commit()
    finally:
        conn.close()


# 监测数据相关CRUD/查询
def insert_monitor_data(sensor_id, value, status):
    sql = """
    INSERT INTO 监测数据
    (数据采集时间, 传感器编号, 监测数值, 数据状态)
    VALUES (%s, %s, %s, %s)
    """
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute(sql, (
                datetime.now(), sensor_id, value, status
            ))
        conn.commit()
    finally:
        conn.close()

def get_recent_monitor_data(sensor_id, limit=5):
    sql = """
    SELECT * FROM 监测数据
    WHERE 传感器编号 = %s
    ORDER BY 数据采集时间 DESC
    LIMIT %s
    """
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute(sql, (sensor_id, limit))
            return cursor.fetchall()
    finally:
        conn.close()

def get_avg_monitor_value(sensor_id):
    sql = """
    SELECT AVG(监测数值) AS avg_value
    FROM 监测数据
    WHERE 传感器编号 = %s
    """
    conn = get_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute(sql, (sensor_id,))
            result = cursor.fetchone()
            return result["avg_value"]
    finally:
        conn.close()

if __name__ == "__main__":

    print("===== 1. 新增传感器 =====")
    add_sensor(
        sensor_id=1001,
        region_id=1,
        model="TH-100",
        sensor_type="温度",
        install_time="2025-01-01 10:00:00",
        protocol="MQTT"
    )

    print("===== 2. 查询传感器 =====")
    sensor = get_sensor(1001)
    print(sensor)

    print("===== 3. 修改传感器型号 =====")
    update_sensor_model(1001, "TH-200")
    print(get_sensor(1001))

    print("===== 4. 插入监测数据 =====")
    insert_monitor_data(1001, 26.5, "有效")
    insert_monitor_data(1001, 27.2, "有效")

    print("===== 5. 查询最近监测数据 =====")
    data_list = get_recent_monitor_data(1001)
    for d in data_list:
        print(d)

    print("===== 6. 统计平均监测值 =====")
    avg = get_avg_monitor_value(1001)
    print("平均值：", avg)

    print("===== 7. 删除传感器 =====")
    delete_sensor(1001)
    print("删除后查询结果：", get_sensor(1001))
