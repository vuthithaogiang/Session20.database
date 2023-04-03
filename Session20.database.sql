use master

if exists (select * from sys.databases where name='Session20')
drop database Session20

create database Session20

use Session20

-- 2: create tables

create table Customer (
  id varchar(9) primary key,
  fullName varchar(50),
  address varchar(40)
)

create table Phone(
 phoneNumber varchar(10) primary key,
 type varchar (20)
)

create table RegisterAccount (
 customer_id varchar(9) foreign key references Customer(id),
 register_date date,
 phoneNumber varchar(10) foreign key references Phone(phoneNumber),
 primary key (customer_id, phoneNumber)
)

-- insert data

insert into Customer values ('123456789', 'Nguyen Nguyet Nga', 'Ha Noi' )

insert into Phone values ('123456789', 'Tra truoc')
insert into Phone values ('234567890', 'Tra sau')

insert into RegisterAccount values ('123456789', '2009-12-12', '123456789')
insert into RegisterAccount values ('123456789', '2010-12-12', '234567890')

-- select 

select * from Customer
select * from Phone

-- 5: hiển thị toàn bộ thông tin của thê bao số 123456789
select RegisterAccount.*,
        Phone.type

from RegisterAccount
inner join Phone on Phone.phoneNumber = RegisterAccount.phoneNumber
where Phone.phoneNumber like '123456789'

-- hiển thị thông tin về khách hàng có số CMT: 123456789
select * from Customer
where id like '123456789'

-- Hiển thị các số thuê bao của khách hàng có số CTM: 123456789
select RegisterAccount.*
from RegisterAccount
where customer_id like '123456789'

-- liệt kê các thuê bao đăng kí vào ngày 12/12/09
select RegisterAccount.*
from RegisterAccount
where register_date = '2009-12-12'
-- liệt kê các thuê bao có địa chỉa tại Ha Noi
select RegisterAccount.*
from RegisterAccount
inner join Customer as c on c.id = RegisterAccount.customer_id
where c.address like 'Ha Noi'

--6: tổng số khách hàng của công ty

select count (id) as NumberOfCustomer
from Customer

-- tổng số thuê bao của công ty
select count (phoneNumber) as NumberOfPhoneNumber
from Phone


-- tổng số thuê bao đăg kí ngày 12/12/2009
select count (*) as NumberOfRegister
from RegisterAccount
where register_date = '2009-12-12'

-- hiển thị tất cả thông tin về khách hàng và thuê bao của tất cả các số thuê bao
select c.* ,
       r.register_date,
	   p.phoneNumber,
	   p.type
from Customer as c
inner join RegisterAccount as r on r.customer_id = c.id
inner join Phone as p on p.phoneNumber = r.phoneNumber


--7: viết câu kệnh để thay đổi trừong ngày đăng kí là not null
alter table RegisterAccount

alter column register_date date not null

-- viết câu lệnh để trường ngày đăng kí là ngày hiện tại
update RegisterAccount
set register_date =  convert(Date, GETDATE())

select * from RegisterAccount

-- thay đổi phoneNumber phải bắt đầu là 09
alter table RegisterAccount
drop constraint FK__RegisterA__custo__4D94879B

alter table RegisterAccount
drop constraint [FK__RegisterA__phone__4E88ABD4]

alter table RegisterAccount
add constraint Fk_Customer
foreign key (customer_id) references Customer(id)
on delete cascade on update cascade

alter table RegisterAccount
add constraint Fk_PhoneNumber
foreign key (phoneNumber) references Phone(phoneNumber)
on delete cascade on update cascade

update Phone
set phoneNumber = '09' + phoneNumber
where 
 CHARINDEX ('09', phoneNumber , 1) not in (1)

 select * from Phone
 select * from RegisterAccount
	 
-- viết câu lệnh thêm trừong điểm thửong cho mỗi thuê bao
alter table RegisterAccount
add coins int check(coins > 0)

--8: đặt chỉ mục index cho cột tên khách hàng của bảng chứa thông tin khách hàng
create nonclustered index IX_Name_Customer
on Customer(fullName)

-- View_Customer: hiển thị thông tin mã khách hàng, tên , địa chỉ
create or alter view View_Customer
as 
select
* 
from Customer

select * from View_Customer

-- View_Customer_Phone: hiển thị thông tin mã khách hàng,  tên khách hàng
-- số thuê bao
create view View_Customer_Phone
as
select c.*,
 r.phoneNumber
from Customer as c
inner join RegisterAccount as r on r.customer_id = c.id

select * from View_Customer_Phone
-- SP_SeacchCustomer_Phone: hiển thị thông tin khách hàng với số thuê bao nhập vào
create or alter procedure SP_SearchCustomer_Phone( @phone varchar(10))
as 
begin
   select c.* from
   Customer as c
   inner join RegisterAccount as r on r.customer_id = c.id
   where r.phoneNumber like @phone
end

exec SP_SearchCustomer_Phone '1234567890'
exec SP_SearchCustomer_Phone '0912345678'

select * from RegisterAccount

-- SP_SearchPhone_Customer: liệt kê các số điện thoại của khách hàng theo tên truyền vào
create or alter procedure SP_SearchPhone_Customer ( @name varchar(40))
as 
begin
   select p.*
   from Phone as p
   inner join	RegisterAccount as r on r.phoneNumber = p.phoneNumber
   inner join Customer as c on c.id = r.customer_id
   where PATINDEX ('%'+ @name + '%', c.fullName) not in (0)
end


exec SP_SearchPhone_Customer 'nguyen'

 select p.*
   from Phone as p
   inner join	RegisterAccount as r on r.phoneNumber = p.phoneNumber
   inner join Customer as c on c.id = r.customer_id
   where PATINDEX ('%nguyen%', c.fullName) not in (0)


   select * from
   Customer
   where fullName like '%nguyen%'

-- SP_RemovePhone_CustomerId: xóa bỏ thue bao của khách hàng theo mã khách hàng

create procedure SP_RemovePhone_CustomerId ( @customerID varchar(9) )
as
begin
   if(@customerID in (select customer_id from RegisterAccount))
   begin
       declare @phone varchar(10) ;

	   set @phone = (select p.phoneNumber from Phone as  p
	   inner join RegisterAccount as r on r.phoneNumber = p.phoneNumber
	   inner join Customer as c on c.id = r.customer_id
	   where c.id = @customerID
	   )

	   delete from Phone where phoneNumber = @phone
   end
   else
   begin
    print 'Do not find customer id in Register Account';
	rollback transaction;
   end
end

exec SP_RemovePhone_CustomerId '123456789'