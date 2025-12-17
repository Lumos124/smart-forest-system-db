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
