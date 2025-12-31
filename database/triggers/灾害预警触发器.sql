-- 触发器：通知自动发送
-- 功能：当有新的预警记录时，自动向区域负责人发送通知
create trigger 触发器_自动发送通知
on 预警记录
after insert
as
begin
    -- 向区域负责人发送系统消息通知
    insert into 通知记录 (预警编号, 接收人ID, 通知方式, 发送时间, 接收状态)
    select 
        i.预警编号,
        r.负责人ID,
        '系统消息',
        getdate(),
        '已发送'
    from inserted i
    join 区域 r on i.涉及区域编号 = r.区域编号
    where r.负责人ID is not null;
    
    print '已自动发送' + cast(@@rowcount as varchar) + '条通知';
end;