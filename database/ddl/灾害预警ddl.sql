-- 创建预警规则表
create table 预警规则 (
    规则编号 int identity(1,1) primary key,
    预警类型 varchar(20) not null check (预警类型 in ('火灾','旱情','病虫害','其他')),
    触发条件 varchar(200) not null,
    预警级别 varchar(10) not null check (预警级别 in ('一般', '较重', '严重', '特别严重')),
    生效状态 bit default 1,
    创建人ID int not null,
    创建时间 datetime default getdate(),
    constraint fk_预警规则_创建人 foreign key (创建人ID) references 用户(用户编号)
);

-- 创建预警记录表
create table 预警记录 (
    预警编号 int identity(1,1) primary key,
    触发规则编号 int not null,
    涉及区域编号 int not null,
    触发时间 datetime not null,
    预警内容 varchar(500) not null,
    处理状态 varchar(10) default '未处理' check (处理状态 in ('未处理', '处理中', '已结案')),
    处理人ID int,
    处理结果 varchar(500),
    解决时间 datetime null,
    constraint fk_预警记录_触发规则 foreign key (触发规则编号) references 预警规则(规则编号),
    constraint fk_预警记录_处理人 foreign key (处理人ID) references 用户(用户编号),
    constraint fk_预警记录_区域 foreign key (涉及区域编号) references 区域(区域编号)
);

-- 创建通知记录表
create table 通知记录 (
    通知编号 int identity(1,1) primary key,
    预警编号 int not null,
    接收人ID int not null,
    通知方式 varchar(10) not null check (通知方式 in ('短信', '系统消息','邮件')),
    发送时间 datetime default getdate(),
    接收状态 varchar(10) check (接收状态 in ('已发送', '已接收', '失败')),
    constraint fk_通知记录_预警编号 foreign key (预警编号) references 预警记录(预警编号),
    constraint fk_通知记录_接收人 foreign key (接收人ID) references 用户(用户编号)
);