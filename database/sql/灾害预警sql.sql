-- 查询1：查询某区域近7天火灾预警及处理情况

-- 方式1：使用显式JOIN
select 
    wr.预警编号,
    wr.触发时间,
    w.预警类型,
    w.预警级别,
    wr.预警内容,
    wr.处理状态,
    u.用户名 as 处理人,
    wr.处理结果,
    wr.解决时间
from 预警记录 wr
join 预警规则 w on wr.触发规则编号 = w.规则编号
left join 用户 u on wr.处理人ID = u.用户编号
where wr.涉及区域编号 = 1  -- 1号林区
    and w.预警类型 = '火灾'
    and wr.触发时间 >= dateadd(day, -7, getdate())
order by wr.触发时间 desc;

-- 方式2：使用隐式JOIN
select 
    wr.预警编号,
    wr.触发时间,
    w.预警类型,
    w.预警级别,
    wr.预警内容,
    wr.处理状态,
    u.用户名 as 处理人,
    wr.处理结果,
    wr.解决时间
from 预警记录 wr, 预警规则 w, 用户 u
where wr.触发规则编号 = w.规则编号
    and wr.处理人ID = u.用户编号
    and wr.涉及区域编号 = 1
    and w.预警类型 = '火灾'
    and wr.触发时间 >= dateadd(day, -7, getdate())
order by wr.触发时间 desc;

-- 查询2：统计各区域预警次数及处理状态

-- 方式1：使用JOIN + GROUP BY
select 
    r.区域名称,
    count(wr.预警编号) as 预警总次数,
    sum(case when wr.处理状态 = '未处理' then 1 else 0 end) as 未处理数,
    sum(case when wr.处理状态 = '处理中' then 1 else 0 end) as 处理中数,
    sum(case when wr.处理状态 = '已结案' then 1 else 0 end) as 已结案数
from 预警记录 wr
join 区域 r on wr.涉及区域编号 = r.区域编号
group by r.区域名称
order by 预警总次数 desc;

-- 方式2：使用相关子查询
select 
    r.区域名称,
    (select count(*) from 预警记录 wr where wr.涉及区域编号 = r.区域编号) as 预警总次数,
    (select count(*) from 预警记录 wr where wr.涉及区域编号 = r.区域编号 and wr.处理状态 = '未处理') as 未处理数,
    (select count(*) from 预警记录 wr where wr.涉及区域编号 = r.区域编号 and wr.处理状态 = '处理中') as 处理中数,
    (select count(*) from 预警记录 wr where wr.涉及区域编号 = r.区域编号 and wr.处理状态 = '已结案') as 已结案数
from 区域 r
where exists (select 1 from 预警记录 wr where wr.涉及区域编号 = r.区域编号)
order by 预警总次数 desc;

-- 查询3：查询预警处理人工作效率

-- 方式1：使用JOIN + 聚合函数
select 
    u.用户名 as 处理人,
    count(wr.预警编号) as 处理预警数,
    avg(datediff(hour, wr.触发时间, wr.解决时间)) as 平均响应小时,
    min(datediff(hour, wr.触发时间, wr.解决时间)) as 最快响应,
    max(datediff(hour, wr.触发时间, wr.解决时间)) as 最慢响应
from 预警记录 wr
join 用户 u on wr.处理人ID = u.用户编号
where wr.处理状态 = '已结案'
    and wr.解决时间 is not null
group by u.用户名
order by 平均响应小时 asc;

-- 方式2：使用普通子查询先过滤
select 
    u.用户名 as 处理人,
    统计信息.处理预警数,
    统计信息.平均响应小时,
    统计信息.最快响应,
    统计信息.最慢响应
from 用户 u
join (
    select 
        处理人ID,
        count(*) as 处理预警数,
        avg(datediff(hour, 触发时间, 解决时间)) as 平均响应小时,
        min(datediff(hour, 触发时间, 解决时间)) as 最快响应,
        max(datediff(hour, 触发时间, 解决时间)) as 最慢响应
    from 预警记录
    where 处理状态 = '已结案'
        and 解决时间 is not null
    group by 处理人ID
) 统计信息 on u.用户编号 = 统计信息.处理人ID
order by 平均响应小时 asc;

-- 查询4：查询未处理预警及其通知情况
select 
    wr.预警编号,
    wr.触发时间,
    w.预警类型,
    w.预警级别,
    r.区域名称,
    wr.预警内容,
    count(n.通知编号) as 已发通知数
from 预警记录 wr
join 预警规则 w on wr.触发规则编号 = w.规则编号
join 区域 r on wr.涉及区域编号 = r.区域编号
left join 通知记录 n on wr.预警编号 = n.预警编号
where wr.处理状态 = '未处理'
group by wr.预警编号, wr.触发时间, w.预警类型, w.预警级别, r.区域名称, wr.预警内容
order by wr.触发时间 desc;

-- 查询5：查询预警规则触发频率 
select 
    w.规则编号,
    w.预警类型,
    w.预警级别,
    w.触发条件,
    count(wr.预警编号) as 触发次数,
    min(wr.触发时间) as 首次触发时间,
    max(wr.触发时间) as 最近触发时间
from 预警规则 w
left join 预警记录 wr on w.规则编号 = wr.触发规则编号
group by w.规则编号, w.预警类型, w.预警级别, w.触发条件
order by 触发次数 desc;