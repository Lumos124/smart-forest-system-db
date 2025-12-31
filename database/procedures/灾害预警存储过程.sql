-- 存储过程：预警触发
-- 功能：当监测数据达到预警条件时，调用此过程创建预警记录
create procedure 存储过程_触发预警
    @规则编号 int,
    @区域编号 int,
    @监测数值 varchar(100)
as
begin
    -- 检查规则是否存在且生效
    if not exists (select 1 from 预警规则 where 规则编号 = @规则编号 and 生效状态 = 1)
    begin
        print '错误：预警规则不存在或未启用';
        return;
    end
    
    -- 插入预警记录
    insert into 预警记录 (
        触发规则编号, 
        涉及区域编号, 
        触发时间, 
        预警内容, 
        处理状态
    ) 
    select 
        @规则编号,
        @区域编号,
        getdate(),
        '自动触发：区域[' + cast(@区域编号 as varchar) + 
        ']监测值[' + @监测数值 + ']达到预警条件',
        '未处理'
    from 预警规则 
    where 规则编号 = @规则编号;
    
    print '预警触发成功，预警编号：' + cast(scope_identity() as varchar);
end;