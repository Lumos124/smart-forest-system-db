# 资源管理业务线 - 概念结构设计 (E-R图)

## 1. 局部 E-R 图预览
下图展示了林草资源、变动记录与外部实体（区域、用户）之间的关联关系。

```mermaid
erDiagram
    %% 实体定义
    Area {
        int area_id PK "区域编号"
        string area_name "区域名称"
    }
    User {
        int user_id PK "用户编号"
        string name "姓名"
    }
    Resource {
        bigint resource_id PK "资源编号"
        tinyint resource_type "类型(树/草)"
        string variety_name "品种"
        int quantity "数量"
        decimal coverage_area "面积"
        string growth_stage "生长状态"
    }
    ResourceLog {
        bigint log_id PK "变动编号"
        string change_type "变动类型"
        string change_reason "原因"
        datetime change_time "时间"
    }

    %% 关系定义
    Area ||--|{ Resource : "归属 (1:N)"
    Resource ||--|{ ResourceLog : "拥有历史 (1:N)"
    User ||--|{ ResourceLog : "执行操作 (1:N)"
```

## 2. 关系说明
1.  **归属关系**：一个区域 (Area) 可以包含多个资源 (Resource)，但一个资源只能属于一个区域。
2.  **历史关系**：一个资源 (Resource) 在生命周期中会产生多条变动记录 (ResourceLog)。
3.  **操作关系**：一个用户 (User) 可以执行多次操作，产生多条变动记录。
