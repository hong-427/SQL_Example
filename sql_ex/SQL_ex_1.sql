
-- # 1 ) Watson building에서 일하는 교수에 대한 정보)
--  -> department에서 building이 Watson인 모든 dept_name 찾기
--	-> instructor에서 해당 dept_name을 갖는 모든 교수 정보
select I.*, D.building
from instructor as I, department as D
where D.building = 'Watson' and I.dept_name = D.dept_name


-- # 2 ) instructor에서 salary > 85000을 만족하는 튜플
select I.ID, I.salary
from instructor as I
where I.salary > 85000


-- # 3 ) 모든 교수들의 이름 찾기
select name
from instructor


-- # 4 ) 모든 교수들의 소속 학과 이름을 찾아라
select distinct I.dept_name
from instructor as I


-- # 5 ) 컴퓨터공학과에서 급여가 $70,000가 넘는 모든 교수의 이름을 구하라
select I.name
from instructor as I
where I.salary > 70000 and I.dept_name = 'Comp. Sci.'


-- # 6 ) 모든 교수들의 이름과 함께, 그들의 학과 이름과 건물 이름을 구하라
select I.name as Instructor_name, I.dept_name, D.building
from instructor as I, department as D
where I.dept_name = D.dept_name 


-- # 7 ) 같은 ID값을 갖는 teaches, instructor 투플 연결하고, 교수 이름과 수업 아이디 출력
--	-> 아무 수업도 참여하지 않으면 그 교수는 출력되지 않는다.
select I.name as instructor_name, T.course_id 
from teaches as T, instructor as I
where T.ID = I.ID


-- # 8 ) 컴퓨터공학과 교수에 관해 교수 이름과 수업 아이디 출력
select I.name as Instructor_name, T.course_id, I.dept_name
from instructor as I, teaches as T
where I.dept_name = 'Comp. Sci.' and T.ID = I.ID 


-- # 9 ) 대학 내에서 수업을 하는 모든 교수에 대해,
--	 	 그들의 이름과 그들이 가르치는 수업의 수업 아이디를 찾아라
select I.name as Instructor_name, T.course_id
from instructor as I, teaches as T
where I.ID = T.ID


-- # 10 ) 적어도 생물학과한 교수보다 급여가 많은 모든 교수들의 이름을 구하여라  
--		  생물학과에서 가장 돈을 적게 받는 교수보다 
select I2.name as Instructor_name, I2.salary
from instructor as I1, instructor as I2
where I1.dept_name = 'Biology' and I2.salary > I1.salary


-- # 11 ) 이름에 'W'이라는 부분 문자열이 포함된 건물의 모든 학과의 이름을 구하라
select building
from department as D
where building like '%W%'


-- # 12 ) instructor의 전체를 salary에 대해 내림차순으로 정렬, 교수들의 이름을 오름차순 정렬
select name as instructor_name
from instructor
order by salary desc, name asc


-- # 13 ) 급여가 90,000과 100,000사이에 있는 교수들의 이름을 찾기
select name as Instructor_name1, salary
from instructor
where salary >= 90000 and salary <= 100000

select name as Instructor_name2, salary 
from instructor
where salary between 90000 and 100000


-- # 14 ) 생물학과에서 강의를 한 모든 교수들의 이름과 그들의 가르치는 모든 수업을 구하라
select I.name as Instructor_name1, T.course_id
from instructor as I, teaches as T
where I.dept_name = 'Biology' and I.ID = T.ID


-- # 15 ) 2009년 가을의 모든 수업의 집합
select course_id
from section as s
where s.semester = 'Fall' and s.year = 2009


-- # 16 ) 2010년 봄의 모든 수업의 집합
select course_id
from section as s
where s.semester = 'Spring' and s.year = 2010


-- # 17 ) 2009년 가을 & 2010년 봄에 연속해서 강의가 되었던 모든 수업의 집합
(select course_id
from section as s
where s.semester = 'Fall' and s.year = 2009)
except
(select course_id
from section as s
where s.semester = 'Spring' and s.year = 2010)


-- # 18 ) instructor에서 salary 값이 널 값으로 나타나는 모든 교수를 구하라
select name
from instructor
where salary is null


-- # 19 ) 컴퓨터공학과의 교수들의 평균 급여를 구하라
select avg(salary) as avg_salary
from instructor
where instructor.dept_name = 'Comp. Sci.'


-- # 20 ) 2010년 봄 학기에 수업을 하는 교수들의 수를 구하라
--        count(distinct ID) : 5 / count(ID) : 6 => 하나 이상의 수업을 하는 교수가 있는 경우이다.
select count(distinct ID) as spring_2009_teach_cnt
from teaches as T
where T.semester = 'Spring' and T.year = 2010


-- # 21 ) 각 학과의 평균 급여를 구하라
select dept_name, avg(salary)
from instructor
group by dept_name


-- # 22 ) 모든 교수들의 평균 급여를 구하라
select I.ID, avg(I.salary) as Instructor_avg_salary
from instructor as I
group by I.ID


-- # 23 ) 2010년 봄 학기에 각 학과에 수업을 하는 교수의 수를 구하라
select dept_name, count(distinct I.ID) as Instructor_cnt
from instructor as I, teaches as T
where T.semester = 'Spring' and T.year = 2010 and T.ID = I.ID
group by dept_name


-- # 24 ) 교수들의 평균 급여가 $42,000을 넘는 학과의 교수들의 평균 급여를 구하라
select I.dept_name, avg(salary) as Instructor_avg_salary
from instructor as I
group by I.dept_name
having avg(salary) > 42000

select *
from takes

-- # 25 ) 2009년에 제공되는 각각의 수업 분반에 대해서, 분반에 적어도 2명의 학생이 있으면 그 분반에 등록한 학생들의 평균과 전체 학점을 구하라
select s.ID, t.sec_id, semester, year, avg(s.tot_cred) as tot_cred_avg
from takes as t, student as s
where t.year = 2009 and t.ID = s.ID
group by s.ID, t.sec_id, semester, year
having count(s.ID) >= 2
