-- # 1 ) 2009�� ������ �����̸鼭, 2010�� ���� ������ ���϶�.
select course_id
from section
where semester = 'Fall' and year = 2009 and 
	course_id in ( select course_id
				   from section
				   where semester = 'Spring' and year = 2010)


-- # 2 ) 2009�� ������ ����������, 2010�� ������ ���� ������ ���϶�.
select  course_id
from section
where semester = 'Fall' and year = 2009 and
	course_id not in (select course_id
				  from section	
				  where semester = 'Spring' and year = 2010)


-- # 3 ) ID 110011�� ������ ����ġ�� ���� �й��� �����ϴ� �л� ���� ���϶�.
--> sql-server�� ���� �� �� �Ұ���
select count(distinct ID)
from takes					-- �л� : �̼�����
where (course_id, sec_id, semester, year) in (select course_id, sec_id, semester, year
											   from teaches
											   where teaches.ID = 110011 ) 


-- # 4 ) �����а��� ��� �� �������ٵ� �޿��� ���� ��� �������� �̸��� ���϶�.
select distinct i1.name										-- distinct ��� x
from instructor i1, instructor i2
where i1.salary > i2.salary and i2.dept_name = 'Biology'

select distinct i1.name										-- distinct ��� x
from instructor i1											-- �׳� instructor�� �ص� ����
where i1.salary > some( select i2.salary
						from instructor i2					-- �׳� instructor�� �ص� ����
						where i2.dept_name = 'Biology' )


-- # 5 ) �����а��� �� �����麸�� �޿��� ���� ��� �������� �̸��� ���϶�.
select distinct i1.name										-- distinct ��� x
from instructor i1											-- �׳� instructor�� �ص� ����
where i1.salary > all ( select i2.salary	
					    from instructor i2					-- �׳� instructor�� �ص� ����
					    where i2.dept_name = 'Biology' )
order by i1.name


-- #6 ) ���� ���� �޿��� �޴� �а��� ���϶�.
select dept_name
from instructor
group by dept_name
having avg (salary) >= all ( select avg(salary)
							 from instructor
							 group by dept_name )


-- # 7 ) 2009�� ���� �б�� 2010�� �� �б� �� �� �ִ� ������ ���϶�.	--> not exists : 2010�� �� �б⿡�� ���� x
select course_id
from section as s1
where semester = 'Fall' and year = 2009 
	and exists ( select *
				 from section as s2
				 where semester = 'Spring' and year = 2010 
					and s1.course_id = s2.course_id )


-- # 8 ) �����а����� �����ϴ� ��� ������ �����ϴ� ��� �л��� ���϶�.
-- �����а��� ��� ���� �߿�, s.id�� �л��� �ش� �����а� ������ �������� ���� �� : �̷� s.id �л��� ������ ��� �л� ���ϱ�
select distinct s.id, s.name
from student as s			
where not exists ( (select course_id
					from course
					where dept_name = 'Biology')	-- �����а��� ������
					except	-- ������
					( select t.course_id
					  from teaches t
					  where s.id = t.id ) )			-- �л� s.id�� �����ϴ� ��� ����


-- # 9 ) 2009�⿡ ���ƾ� �ѹ� ������ ��� ������ ���϶�.
-- (if) 2009�⿡ ���� �����̶�� => ���� ����� null�� ���̴�. ==> unique ������� �� ������ ������ ����Ѵ�.
select c.course_id
from course c									-- course : ���� ����
where 1 = ( select s.course_id
			from section s						-- section : ��ü ���� ����  ( ���� + �б� + �⵵ + �ǹ� + ȣ�� )
			where c.course_id = s.course_id
				and s.year = 2009 )


-- # 10 ) ��� �޿��� $42,000 �̻��� �а��� �������� ��� �޿��� ���϶�.
select dept_name, avg_salary
from ( select dept_name, avg(salary)
	   from instructor 
	   group by dept_name ) as dept_name (dept_name, avg_salary)	-- ���� ���� select�� ���� ���� select �� ������� ��ġ�Ѵ�.
where avg_salary > 42000


-- # 11 ) �� �а��� �� �޿��� �ִ밪�� ���϶�.
select max(tot_salary) as max_tot_salary
from ( select dept_name, sum(salary)
	   from instructor
	   group by dept_name ) as dept_total(dept_name, tot_salary)


/* sql - server�� lateral ���� x
-- # 12 ) �� �������� �̸��� �׵��� �޿��� �׵��� �Ҽӵ� �а��� ��� �޿��� �Բ� ���
select name, salary, avg_salary
where instructor i1, lateral ( select avg(salary) as avg_salary
							  from instructor i2
							  where i1.dept_name = i1.dept_name )
*/


-- # 13 ) �а��� �� �޿��� ��� �а��� �� �޿����� ���� ��� �а��� ���϶�.
-- with : �������� ��Ȯ�ϰ� �����, ������ ���� ������ �� ���Ǹ� ����ϰ� �� �Ѵ�.
with dept_total (dept_name, value) as		-- >> �ӽ� table (1) dept_total
	( select dept_name, sum(salary)
	  from instructor
	  group by dept_name ),					--> �ӽ� table : �ٷ� �Ʒ� table���� ��ȿ��.
	dept_total_avg(value) as				-->> �ӽ� table (2) dept_total_avg
		( select avg(value)
		  from dept_total )
select dt.dept_name
from dept_total dt, dept_total_avg dta
where dt.value >= dta.value;


-- # 14 ) ��� �а��� �� �а��� �������� ���� �Բ� �����϶�.
select dept_name,
	( select count(*)
	  from department d, instructor i
	  where d.dept_name = i.dept_name ) as inst_cnt		--> ��Į�� ���� ���� : inst_cnt�� �̸��� ���� �� ��� ( count(*) )
from department


-- # 15 ) �繫���� ������� ���õ� instructor �����̼��� ��� ������ �����϶�.
delete from instructor
where dept_name = 'Finance'


-- # 16 ) �޿��� $13,000���� $15,000 ������ ��� �������� �����϶�.
delete from instructor
where salary between 13000 and 15000

delete from instructor 
where salary >= 15000 and salary <= 13000


-- # 17 ) Watson �ǹ��� ��ġ�� �а��� ���õ� instructor �����̼��� ��� ������ �����϶�.
delete from instructor
where dept_name in ( select dept_name
					 from department
					 where building = 'Watson' )


-- # 18 ) ������ ��պ��� ���� �޿��� ���� ��� ������ ���ڵ���� �����϶�.
delete from instructor
where salary < ( select avg(salary)
				 from instructor )


-- # 19 ) ��ǻ�Ͱ��а��� "database Systems:��� ������ CS-437, 4 ������ ������ �����϶�.
insert into course 
	values ('CS-437', 'Database Systems', 'Comp.Sci.', 4)

insert into course(course_id, title, dept_name,. credits)
	values ('CS-437', 'Database Systems', 'Comp.Sci.', 4)	--> ���� ������ ����ٸ�, ���� �ٲ� ��� x
	

-- # 20 ) �����а��� 144 ������ �Ѵ� �л��� �����а��� �޿� $18,000�� ������ ������.
insert into instructor
	select ID, name, dept_name, 18000
	from student
	where dept_name = 'Music' and tot_cred > 144


-- # 21 ) $70,000 �̸��� ������ 1.5�� �޿��� �λ��ض�.
update instructor
set salary = salary * 1.5
where salary < 70000


-- # 22 ) �ٸ� �������� 5%�� �λ��� ������, $100,000 �̻��� �޿��� �޴� �����鿡�� �޿��� 3% �λ��ض�.
-- update ���� ������ �ſ� �߿�! ���� �Ʒ� ���ǹ� ������ �ٲ�ٸ� ����� �޶��� ���� ����.
update instructor
set salary = salary * 1.03
where salary > 100000

update instructor
set salary = salary * 1.05
where salary <= 100000

-- # 22 ) ���� ���� -> case-end�� �̿�
update instructor
set salary = case 
				when salary <= 100000 then salary * 1.05
				else salary * 1.03
			 end


-- # 23 ) �� student ������ tot_cred �Ӽ��� �л��� �̼��� ������ ������ ������ �����ض�. 
-- �̶�, �л��� ����� 'F'�� �ΰ��� �ƴϸ� ������ �̼��� ������ �����Ѵ�.
update student 
set tot_cred 
		= ( select sum(credits)
			from takes t, course c
			where t.course_id = c.course_id
				and t.grade != 'F'
				and t.grade is not null	)
				
update student 
set tot_cred
		= ( select case
						when sum(credits) is not null then sum(credits)
						else 0
						end
			from takes t, course c
			where t.course_id = c.course_id
		  )


-- # 24 ) ������ �ѹ��� �������� ���� ��� �л��� ã�ƶ�.
--> takes �� student�� �ڿ� ���� �̋�, takes�� student ���� tuple�� ���´�. �׸��� student���� �ִ� tuple�� �״�� �������ش�.
--	student���� �ִ� tuple���� null���� �־��ش�.
select ID
from student natural left outer join takes
where course_id is null

select ID
from takes natural right outer join student
where course_id is null


-- # 25 ) '2009'�� '���� �б�'�� '�����а�'���� ������ '��� ������ ����'�� '������ �̷���� �ǹ�'�� '���ǽ� ��ȣ'�� ���϶�.
select s.course_id, s.sec_id, s.building, s.room_number
from course c, section s 
where c.course_id = s.course_id
	and c.dept_name = 'Physics'
	and s.year = 2009
	and s.semester = 'Fall'


-- # 26 ) 25�� ������ view�� ����
-- view : ���� ����� ������ �̸� ����ϰ�, ���� x / ���������� ����
--		-> �� �����̼��� ���ٵ� ������, ���� ����� ��������ν� ������ �����ȴ�. ( �ʿ��� ������ �����ȴ�. )
go
CREATE VIEW physics_fall_2009
AS 
select c.course_id, s.sec_id, s.building, s.room_number as rn
from course c, section s
where c.course_id = s.course_id
	and c.dept_name = 'Physics'
	and s.year = 2009
	and s.semester = 'Fall' 
go

select *
from physics_fall_2009


-- # 27 ) physics_fall_2009 �並 ����� 2009�� ������ Watson �������� �� ��� ������ ã�� ���Ǹ� �ۼ��ض�.
select course_id
from physics_fall_2009
where building = 'Watson'


-- # 28 ) �� �а� �� ��� ������ ������ ���� ���� �並 �ۼ��ض�.
go 
create view department_total_salary (dept_name, total_salary)
as 
	select dept_name, sum(salary)
	from instructor
	group by dept_name
go

select *
from department_total_salary

-- # 29 ) 2009�� ������ Watson �������� �� ��� ������ �����ִ� physics_fall_2009_watson �並 �����϶�.
go	-- �� �־��ֱ�
create view physics_fall_2009_watson5
as 
	( select course_id, building, room_number
	  from ( select c.course_id, s.building, s.room_number
			 from course c, section s
			 where c.course_id = s.course_id
				and c.dept_name = 'Physics'
				and s.year = 2010
				and s.semester = 'Fall' 
			) as physics_2009_fall
	  where building = 'Watson'
	 )
go	-- �� �־��ֱ�

select *
from physics_fall_2009_watson5


-- # 30 ) student �����̼��� �� ���ÿ� ���� tot_cred �Ӽ��� ���� ��ü ���� �߿��� 
--		  ���������� ������ ��ģ ������ ������ �հ� ���ƾ� �Ѵ�.
--> assertion : DB�� �׻� ������ų ���ϴ� ������ ǥ���ϴ� ����


-- # 31 ) ������ ���� �б��� ���� �ð��� ���� �ٸ� �� ��ҿ��� ������ ����ĥ �� ����.


-- # 32 ) ��¥�� �ð��� �����ض�.
date '2021-05-24'
time '00:46:30'
timestamp '2021-05-24 00:57:00'


-- # 33 ) student �����̼��� ID �Ӽ��� ���� �ε����� �����϶�.
-- index ��� ���� : �˻� ���� ��� 
-- index�� ���� ���� ����.
create index student_ID_index on student(ID)
drop index student.studeint_ID-index			--> ������ index ����


-- # ���� ��ü Ÿ�� : blob / clob
create table A (
	C1 int,
	C2 BLOB -- CLOB
	-- BLOB : bit stream
	-- CLOB : char stream
	-->  '��ġ��'�� ���� ��ü�� ���׸� �κе�� ����� �����´�.
)


-- # 'create type' : ���ο� �������� �����Ѵ�. / ������ ���ϴ� ������������ ������ ����� �� �ִ�.
-- final�� ���� ����
-- not null�� ���� ���� ������ ���� �� �ִ�.
-- create type���� ������ type�� �ƹ� �����̼ǿ����� ��� ���� ( db�ȿ��� ��ȣ��. )
--> �ش� column�� �ִ� ������ � �ǹ̿� ���� ���ΰ��� ���� create type�� �̿��Ѵ�.
create type Dollars from numeric(12,2) -- final; / as ��ſ� from
create type Money from numeric(12,2) not null;

create table department12
	( budget Dollars,
	  dept_name varchar(20),
	  building varchar(15) )


-- # 'create domain' : create type ���� ���ݴ� ��ȭ�� ����. (sql-server������ ����x)
-- not null�� ���� ���� ������ ���� �� �ִ�.
-- domain Ÿ���� �⺻ ���� ���� �� �ִ�.
create domain DDollars from numeric(12,2) not null;	


-- # 34 ) instructor�� ���� ��Ű���� ���� temp_instructor��� ���ο� table�� �����ض�.
create table temp_instructor as instructor


-- # 35 ) department �����̼ǿ� ���� select ������ ����� Amit�� Satoshi���� �ο��϶�.
grant select on department to Amit, Satoshi


-- # 36 ) ����� Amit, Satoshi���� department �����̼��� budget �Ӽ��� ���� ���� ������ �ο��ض�.
grant update (budget) on department to Amit, Satoshi


-- # 37 ) ���� ����
create role instructor


-- # 38 ) ���ҿ� ���� �ο� 
grant select on takes to instructor


-- # 39 ) �ٸ� ���ҿ��� ������ �ο�
grant instructor to Admit				-- Admit�� instructor ������ �ο� �޾ұ⿡, 
										-- instructor�� ������ �ִ� takes�� ���� select ���ѵ� �޴´�.


-- # 40 ) Mariano��� ����ڿ��� branch �����̼��� branch_name �Ӽ��� �ܷ� Ű�� ������ �� �ִ� ������ �ο��ض�.
grant references (branch_name) on branch to Mariano


-- # 41 ) Amit�� ������ �ִ� department �����̼ǿ� ���� select ������ �ٸ� ����ڿ��� �Ѱ��� �� �ֵ��� �ض�.
grant select on department to Amit with grant option


-- # 42 ) ���� ��Ҹ� �����ϱ� ���� 'restrict' ����� ����ض�.
revoke select on department from Amit restrict


-- # 43 ) create function ~
CREATE FUNCTION dept_count(@dept_name varchar(20))
	returns integer
	as
	begin
		declare @d_count integer
		select @d_count = count(*)
		from instructor
		where instructor.dept_name = @dept_name
	return @d_count
	end

-- # 43 ) Ȯ��
select dept_name, budget
from department
where dbo.dept_count(dept_name) > 2
