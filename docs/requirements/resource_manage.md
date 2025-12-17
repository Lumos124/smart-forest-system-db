# 资源管理业务线需求与设计文档

## 1. 业务概述
本模块负责智慧林草系统中森林与草地资源的数字化管理。核心功能包括林草基础信息的录入与更新、资源变动的全生命周期追踪（审计日志），以及基于区域和类型的统计分析。

依据任务书 **2.1.3** 章节，本模块涉及两个核心实体：
1. **林草资源信息**：记录树木或草地的静态属性与生长状态。
2. **资源变动记录**：记录资源的新增、减少或状态变更历史。

---

## 2. 外部依赖 (External Dependencies)
根据项目约定，本模块依赖以下基础表结构（外键指向）：

| 依赖模块 | 表名 | 主键 | 说明 |
| :--- | :--- | :--- | :--- |
| **区域管理** | `Areas` | `area_id` | 用于关联资源所属的部署区域 |
| **用户管理** | `Users` | `user_id` | 用于关联操作人（数据管理员） |

---

## 3. 数据字典设计 (Data Dictionary)

### 3.1 实体：林草资源表 (resources)
**描述**：存储具体的林草分布数据，与部署区域为多对一关系。

| 字段名称 (Eng) | 字段名称 (Chn) | 数据类型 | 必填 | 约束/说明 |
| :--- | :--- | :--- | :--- | :--- |
| **resource_id** | **资源编号** | `BIGINT` | **Yes** | **PK**, 自增 |
| **area_id** | 区域编号 | `INT` | **Yes** | **FK**, 关联 `Areas.area_id` |
| **resource_type** | 资源类型 | `TINYINT` | **Yes** | 1=树木, 2=草地 |
| **variety_name** | 品种名称 | `VARCHAR(50)` | **Yes** | 如：松树、羊草等 |
| **quantity** | 数量 | `INT` | No | 当类型为**树木**时必填，单位：株 |
| **coverage_area** | 面积 | `DECIMAL(10,2)`| No | 当类型为**草地**时必填，单位：平方米 |
| **growth_stage** | 生长状态 | `VARCHAR(20)` | **Yes** | 枚举值：幼苗、成长期、成熟期 |
| **plant_time** | 种植时间 | `DATE` | No | 资源的起始时间 |
| **updated_time** | 更新时间 | `DATETIME` | **Yes** | 最后一次变更时间 |

### 3.2 实体：资源变动记录表 (resource_logs)
**描述**：作为审计日志，记录对资源表的所有关键性修改。此表数据**不可删除**。

| 字段名称 (Eng) | 字段名称 (Chn) | 数据类型 | 必填 | 约束/说明 |
| :--- | :--- | :--- | :--- | :--- |
| **log_id** | **变动编号** | `BIGINT` | **Yes** | **PK**, 自增 |
| **resource_id** | 资源编号 | `BIGINT` | **Yes** | **FK**, 关联 `resources.resource_id` |
| **change_type** | 变动类型 | `VARCHAR(20)` | **Yes** | 枚举值：新增、减少、状态更新 |
| **change_reason** | 变动原因 | `VARCHAR(255)`| No | 如：病虫害伐除、自然生长更新 |
| **operator_id** | 操作人ID | `INT` | **Yes** | **FK**, 关联 `Users.user_id` |
| **change_time** | 变动时间 | `DATETIME` | **Yes** | 默认为当前系统时间 |

---

## 4. 业务规则与完整性约束 (Business Rules)

1.  **类型互斥约束**：
    *   当 `resource_type` 为 **1 (树木)** 时：字段 `quantity` (数量) 为必填项，而 `coverage_area` (面积) 可为空。
    *   当 `resource_type` 为 **2 (草地)** 时：字段 `coverage_area` (面积) 为必填项，而 `quantity` (数量) 可为空。

2.  **区域关联性**：
    *   任何一条资源记录必须关联一个有效的 `area_id`（必须存在于 Areas 表中）。
    *   若要删除某个区域，系统应检查该区域下是否存在资源记录。如果存在，则禁止删除（即外键约束策略为 `ON DELETE RESTRICT`）。

3.  **日志不可篡改**：
    *   `resource_logs` 表仅允许执行 `INSERT` (插入) 和 `SELECT` (查询) 操作，严禁执行 `UPDATE` 或 `DELETE`，以确保审计数据的真实性。

4.  **统计口径**：
    *   **树木资源**：系统将对 `quantity` 字段进行累加统计。
    *   **草地资源**：系统将对 `coverage_area` 字段进行累加统计

---

## 5. 实体关系简图 (ER Context)

```mermaid
erDiagram
    Areas ||--|{ resources : "contains"
    Users ||--|{ resource_logs : "operates"
    resources ||--|{ resource_logs : "has history"

    resources {
        bigint resource_id PK
        int area_id FK
        tinyint resource_type
        string variety_name
        int quantity
        decimal coverage_area
        string growth_stage
    }

    resource_logs {
        bigint log_id PK
        bigint resource_id FK
        string change_type
        string change_reason
        int operator_id FK
        datetime change_time
    }
