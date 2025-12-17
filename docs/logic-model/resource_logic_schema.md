# 资源管理业务线 - 逻辑结构设计

## 1. 关系模式定义
将 E-R 图转换为关系模型，主键加下划线，外键加斜体。

1.  **林草资源 (Resources)**
    *   模式：( 资源编号(PK), 区域编号(FK), 资源类型, 品种名称, 数量, 面积, 生长状态, 种植时间, 更新时间 )
    *   简记：Resources ( resource_id(PK), area_id(FK), resource_type, variety_name, quantity, coverage_area, growth_stage, plant_time, updated_time )

2.  **资源变动记录 (ResourceLogs)**
    *   模式：( 变动编号(PK), 资源编号(FK), 变动类型, 变动原因, 操作人ID(FK), 变动时间 )
    *   简记：ResourceLogs ( log_id(PK), resource_id(FK), change_type, change_reason, operator_id(FK), change_time )

## 2. 规范化分析 (第三范式验证)

### 2.1 第一范式 (1NF)
*   **定义**：所有属性都是不可分割的原子值。
*   **分析**：当前设计中，“数量”、“品种”、“时间”等字段均为单一值，不存在重复组或多值属性。
*   **结论**：满足 1NF。

### 2.2 第二范式 (2NF)
*   **定义**：满足 1NF，且非主属性完全依赖于主键（消除部分依赖）。
*   **分析**：
    *   Resources 表主键是单一属性 `resource_id`，不存在复合主键，因此不存在部分依赖。
    *   ResourceLogs 表同理。
*   **结论**：满足 2NF。

### 2.3 第三范式 (3NF)
*   **定义**：满足 2NF，且消除传递依赖（非主属性不依赖于其他非主属性）。
*   **分析**：
    *   在 Resources 表中：所有属性（如品种、数量）直接描述“资源本身”，不由“区域编号”决定（区域编号只决定区域的信息，那是 Area 表的事）。
    *   在 ResourceLogs 表中：操作人 ID 指向 User 表，变动记录表中只存 ID，不存“操作人姓名”，避免了（Log -> OperatorID -> OperatorName）的传递依赖。
*   **结论**：满足 3NF。
