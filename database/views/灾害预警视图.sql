--视图1 护林员工作台视图（显示所有未处理的预警）
create view 视图_护林员工作台 as
select 
    wr.预警编号,
    r.区域名称,
    w.预警类型,
    w.预警级别,
    wr.触发时间,
    wr.预警内容
from 预警记录 wr
join 预警规则 w on wr.触发规则编号 = w.规则编号
join 区域 r on wr.涉及区域编号 = r.区域编号
where wr.处理状态 = '未处理';

--视图2 预警统计视图（统计各区域的预警数量）
create view 视图_区域预警统计 as
select 
    r.区域名称,
    count(*) as 预警总数,
    sum(case when wr.处理状态 = '未处理' then 1 else 0 end) as 未处理数,
    sum(case when wr.处理状态 = '已结案' then 1 else 0 end) as 已结案数
from 预警记录 wr
join 区域 r on wr.涉及区域编号 = r.区域编号
group by r.区域名称;

--视图3：通知情况视图（查看预警通知的发送情况）
create view 视图_通知情况 as
select 
    wr.预警编号,
    w.预警类型,
    r.区域名称,
    n.通知方式,
    n.发送时间,
    n.接收状态,
    u.用户名 as 接收人
from 预警记录 wr
join 预警规则 w on wr.触发规则编号 = w.规则编号
join 区域 r on wr.涉及区域编号 = r.区域编号
join 通知记录 n on wr.预警编号 = n.预警编号
join 用户 u on n.接收人ID = u.用户编号;