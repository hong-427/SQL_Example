-- # 1 ) 2009년 가을의 수업이면서, 2010년 봄의 수업을 구하라.
select course_id
from section
where semester = 'Fall' and year = 2009 and 
	course_id in ( select course_id
				   from section
				   where semester = 'Spring' and year = 2010)


-- # 2 ) 2009년 가을의 수업이지만, 2010년 봄에는 없는 수업을 구하라.
select  course_id
from section
where semester = 'Fall' and year = 2009 and
	course_id not in (select course_id
				  from section	
				  where semester = 'Spring' and year = 2010)


-- # 3 ) ID 110011의 교수가 가르치는 수업 분반을 수강하는 학생 수를 구하라.
--> sql-server은 여러 개 비교 불가능
select count(distinct ID)
from takes					-- 학생 : 이수강좌
where (course_id, sec_id, semester, year) in (select course_id, sec_id, semester, year
											   from teaches
											   where teaches.ID = 110011 ) 


-- # 4 ) 생물학과의 적어도 한 교수보다도 급여가 많은 모든 교수들의 이름을 구하라.
select distinct i1.name										-- distinct 상관 x
from instructor i1, instructor i2
where i1.salary > i2.salary and i2.dept_name = 'Biology'

select distinct i1.name										-- distinct 상관 x
from instructor i1											-- 그냥 instructor로 해도 가능
where i1.salary > some( select i2.salary
						from instructor i2					-- 그냥 instructor로 해도 가능
						where i2.dept_name = 'Biology' )


-- # 5 ) 생물학과의 각 교수들보다 급여가 많은 모든 교수들의 이름을 구하라.
select distinct i1.name										-- distinct 상관 x
from instructor i1											-- 그냥 instructor로 해도 가능
where i1.salary > all ( select i2.salary	
					    from instructor i2					-- 그냥 instructor로 해도 가능
					    where i2.dept_name = 'Biology' )
order by i1.name


-- #6 ) 가장 높은 급여를 받는 학과를 구하라.
select dept_name
from instructor
group by dept_name
having avg (salary) >= all ( select avg(salary)
							 from instructor
							 group by dept_name )


-- # 7 ) 2009년 가을 학기와 2010년 봄 학기 둘 다 있는 수업을 구하라.	--> not exists : 2010년 봄 학기에는 개설 x
select course_id
from section as s1
where semester = 'Fall' and year = 2009 
	and exists ( select *
				 from section as s2
				 where semester = 'Spring' and year = 2010 
					and s1.course_id = s2.course_id )


-- # 8 ) 생물학과에서 제공하는 모든 수업을 수강하는 모든 학생을 구하라.
-- 생물학과의 모든 수업 중에, s.id의 학생이 해당 생물학과 수업을 수강하지 않을 때 : 이런 s.id 학생을 제외한 모든 학생 구하기
select distinct s.id, s.name
from student as s			
where not exists ( (select course_id
					from course
					where dept_name = 'Biology')	-- 생물학과의 모든수업
					except	-- 차집합
					( select t.course_id
					  from teaches t
					  where s.id = t.id ) )			-- 학생 s.id가 수강하는 모든 수업


-- # 9 ) 2009년에 많아야 한번 제공된 모든 수업을 구하라.
-- (if) 2009년에 없는 수업이라면 => 질의 결과는 null일 것이다. ==> unique 서술어는 빈 집합을 참으로 계산한다.
select c.course_id
from course c									-- course : 수업 정보
where 1 = ( select s.course_id
			from section s						-- section : 전체 수업 정보  ( 수업 + 학기 + 년도 + 건물 + 호실 )
			where c.course_id = s.course_id
				and s.year = 2009 )


-- # 10 ) 평균 급여가 $42,000 이상인 학과의 교수들의 평균 급여를 구하라.
select dept_name, avg_salary
from ( select dept_name, avg(salary)
	   from instructor 
	   group by dept_name ) as dept_name (dept_name, avg_salary)	-- 상위 질의 select와 하위 질의 select 절 순서대로 일치한다.
where avg_salary > 42000


-- # 11 ) 각 학과의 총 급여의 최대값을 구하라.
select max(tot_salary) as max_tot_salary
from ( select dept_name, sum(salary)
	   from instructor
	   group by dept_name ) as dept_total(dept_name, tot_salary)


/* sql - server은 lateral 지원 x
-- # 12 ) 각 교수들의 이름을 그들의 급여와 그들의 소속된 학과의 평균 급여와 함께 출력
select name, salary, avg_salary
where instructor i1, lateral ( select avg(salary) as avg_salary
							  from instructor i2
							  where i1.dept_name = i1.dept_name )
*/


-- # 13 ) 학과의 총 급여가 평균 학과의 총 급여보다 많은 모든 학과를 구하라.
-- with : 논리적으로 명확하게 만들고, 질의의 여러 곳에서 뷰 정의를 사용하게 끔 한다.
with dept_total (dept_name, value) as		-- >> 임시 table (1) dept_total
	( select dept_name, sum(salary)
	  from instructor
	  group by dept_name ),					--> 임시 table : 바로 아래 table에만 유효함.
	dept_total_avg(value) as				-->> 임시 table (2) dept_total_avg
		( select avg(value)
		  from dept_total )
select dt.dept_name
from dept_total dt, dept_total_avg dta
where dt.value >= dta.value;


-- # 14 ) 모든 학과와 그 학과의 교수들의 수를 함께 나열하라.
select dept_name,
	( select count(*)
	  from department d, instructor i
	  where d.dept_name = i.dept_name ) as inst_cnt		--> 스칼라 하위 질의 : inst_cnt의 이름을 갖는 열 출력 ( count(*) )
from department


-- # 15 ) 재무과의 교수들과 관련된 instructor 릴레이션의 모든 투플을 삭제하라.
delete from instructor
where dept_name = 'Finance'


-- # 16 ) 급여가 $13,000에서 $15,000 사이인 모든 교수들을 삭제하라.
delete from instructor
where salary between 13000 and 15000

delete from instructor 
where salary >= 15000 and salary <= 13000


-- # 17 ) Watson 건물에 위치한 학과와 관련된 instructor 릴레이션의 모든 교수를 삭제하라.
delete from instructor
where dept_name in ( select dept_name
					 from department
					 where building = 'Watson' )


-- # 18 ) 대학의 평균보다 낮은 급여를 가진 모든 교수의 레코드들을 삭제하라.
delete from instructor
where salary < ( select avg(salary)
				 from instructor )


-- # 19 ) 컴퓨터공학과에 "database Systems:라는 제목의 CS-437, 4 학점의 수업을 삽입하라.
insert into course 
	values ('CS-437', 'Database Systems', 'Comp.Sci.', 4)

insert into course(course_id, title, dept_name,. credits)
	values ('CS-437', 'Database Systems', 'Comp.Sci.', 4)	--> 위와 순서만 맞춘다면, 순서 바뀌어도 상관 x
	

-- # 20 ) 음악학과에 144 학점이 넘는 학생을 음악학과의 급여 $18,000의 교수로 만들어라.
insert into instructor
	select ID, name, dept_name, 18000
	from student
	where dept_name = 'Music' and tot_cred > 144


-- # 21 ) $70,000 미만인 교수만 1.5배 급여를 인상해라.
update instructor
set salary = salary * 1.5
where salary < 70000


-- # 22 ) 다른 교수들이 5%의 인상을 받지만, $100,000 이상의 급여를 받는 교수들에게 급여를 3% 인상해라.
-- update 문은 순서가 매우 중요! 만일 아래 질의문 순서가 바뀐다면 결과가 달라질 수도 있음.
update instructor
set salary = salary * 1.03
where salary > 100000

update instructor
set salary = salary * 1.05
where salary <= 100000

-- # 22 ) 같은 문제 -> case-end문 이용
update instructor
set salary = case 
				when salary <= 100000 then salary * 1.05
				else salary * 1.03
			 end


-- # 23 ) 각 student 투플의 tot_cred 속성을 학생이 이수한 수업의 학점의 합으로 설정해라. 
-- 이때, 학생의 등급이 'F'나 널값이 아니면 수업을 이수한 것으로 가정한다.
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


-- # 24 ) 수업을 한번도 수강하지 않은 모든 학생을 찾아라.
--> takes 와 student를 자연 조인 이떄, takes와 student 같은 tuple로 묶는다. 그리고 student에만 있는 tuple을 그대로 유지해준다.
--	student에만 있는 tuple에는 null값을 넣어준다.
select ID
from student natural left outer join takes
where course_id is null

select ID
from takes natural right outer join student
where course_id is null


-- # 25 ) '2009'년 '가을 학기'에 '물리학과'에서 제공한 '모든 수업의 정보'와 '수업이 이루어진 건물'과 '강의실 번호'를 구하라.
select s.course_id, s.sec_id, s.building, s.room_number
from course c, section s 
where c.course_id = s.course_id
	and c.dept_name = 'Physics'
	and s.year = 2009
	and s.semester = 'Fall'


-- # 26 ) 25번 문제를 view로 생성
-- view : 질의 결과의 투플을 미리 계산하고, 저장 x / 개념적으로 포함
--		-> 뷰 릴레이션이 접근될 떄마다, 질의 결과를 계산함으로써 투플이 생성된다. ( 필요할 때마다 생성된다. )
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


-- # 27 ) physics_fall_2009 뷰를 사용해 2009년 가을에 Watson 빌딩에서 한 모든 수업을 찾는 질의를 작성해라.
select course_id
from physics_fall_2009
where building = 'Watson'


-- # 28 ) 각 학과 별 모든 교수의 연봉의 합을 갖는 뷰를 작성해라.
go 
create view department_total_salary (dept_name, total_salary)
as 
	select dept_name, sum(salary)
	from instructor
	group by dept_name
go

select *
from department_total_salary

-- # 29 ) 2009년 가을에 Watson 빌딩에서 한 모든 수업을 보여주는 physics_fall_2009_watson 뷰를 정의하라.
go	-- 꼭 넣어주기
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
go	-- 꼭 넣어주기

select *
from physics_fall_2009_watson5


-- # 30 ) student 릴레이션의 각 투플에 대해 tot_cred 속성의 값은 전체 수업 중에서 
--		  성공적으로 수강을 마친 수업의 학점의 합과 같아야 한다.
--> assertion : DB가 항상 만족시킬 원하는 조건을 표현하는 술어


-- # 31 ) 교수는 같은 학기의 같은 시간에 서로 다른 두 장소에서 수업을 가르칠 수 없다.


-- # 32 ) 날짜와 시간을 지정해라.
date '2021-05-24'
time '00:46:30'
timestamp '2021-05-24 00:57:00'


-- # 33 ) student 릴레이션의 ID 속성에 대한 인덱스를 생성하라.
-- index 사용 이유 : 검색 성능 향상 
-- index를 통해 정렬 가능.
create index student_ID_index on student(ID)
drop index student.studeint_ID-index			--> 생성한 index 삭제


-- # 대형 객체 타입 : blob / clob
create table A (
	C1 int,
	C2 BLOB -- CLOB
	-- BLOB : bit stream
	-- CLOB : char stream
	-->  '위치자'가 대형 객체를 조그만 부분들로 나누어서 가져온다.
)


-- # 'create type' : 새로운 도메인을 정의한다. / 본인이 원하는 데이터유형을 생성해 사용할 수 있다.
-- final은 생략 가능
-- not null과 같은 제약 조건을 가질 수 있다.
-- create type으로 생성한 type은 아무 릴레이션에서나 사용 가능 ( db안에서 유호함. )
--> 해당 column에 있는 값들이 어떤 의미에 의한 값인가를 위해 create type을 이용한다.
create type Dollars from numeric(12,2) -- final; / as 대신에 from
create type Money from numeric(12,2) not null;

create table department12
	( budget Dollars,
	  dept_name varchar(20),
	  building varchar(15) )


-- # 'create domain' : create type 보다 조금더 심화된 단위. (sql-server에서는 지원x)
-- not null과 같은 제약 조건을 가질 수 있다.
-- domain 타입은 기본 값을 가질 수 있다.
create domain DDollars from numeric(12,2) not null;	


-- # 34 ) instructor와 같은 스키마를 갖는 temp_instructor라는 새로운 table을 생성해라.
create table temp_instructor as instructor


-- # 35 ) department 릴레이션에 대한 select 권한을 사용자 Amit와 Satoshi에게 부여하라.
grant select on department to Amit, Satoshi


-- # 36 ) 사용자 Amit, Satoshi에게 department 릴레이션의 budget 속성에 대한 갱신 권한을 부여해라.
grant update (budget) on department to Amit, Satoshi


-- # 37 ) 역할 생성
create role instructor


-- # 38 ) 역할에 권한 부여 
grant select on takes to instructor


-- # 39 ) 다른 역할에도 역할을 부여
grant instructor to Admit				-- Admit는 instructor 권한을 부여 받았기에, 
										-- instructor이 가지고 있는 takes에 대한 select 권한도 받는다.


-- # 40 ) Mariano라는 사용자에게 branch 릴레이션의 branch_name 속성에 외래 키를 선언할 수 있는 권한을 부여해라.
grant references (branch_name) on branch to Mariano


-- # 41 ) Amit가 가지고 있는 department 릴레이션에 대한 select 권한을 다른 사용자에게 넘겨줄 수 있도록 해라.
grant select on department to Amit with grant option


-- # 42 ) 연쇄 취소를 방지하기 위해 'restrict' 지정어를 사용해라.
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

-- # 43 ) 확인
select dept_name, budget
from department
where dbo.dept_count(dept_name) > 2
