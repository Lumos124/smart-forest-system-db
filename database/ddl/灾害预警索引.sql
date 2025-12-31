-- 预警规则表：
create index idx_规则_类型状态 on 预警规则(预警类型, 生效状态);

-- 预警记录表：
create index idx_记录_区域状态 on 预警记录(涉及区域编号, 处理状态);
create index idx_记录_触发时间 on 预警记录(触发时间);
create index idx_记录_规则编号 on 预警记录(触发规则编号);

-- 通知记录表：
create index idx_通知_接收人状态 on 通知记录(接收人ID, 接收状态);
create index idx_通知_发送时间 on 通知记录(发送时间);