
-- # 1 ) Watson building���� ���ϴ� ������ ���� ����)
--  -> department���� building�� Watson�� ��� dept_name ã��
--	-> instructor���� �ش� dept_name�� ���� ��� ���� ����
select I.*, D.building
from instructor as I, department as D
where D.building = 'Watson' and I.dept_name = D.dept_name


-- # 2 ) instructor���� salary > 85000�� �����ϴ� Ʃ��
select I.ID, I.salary
from instructor as I
where I.salary > 85000


-- # 3 ) ��� �������� �̸� ã��
select name
from instructor


-- # 4 ) ��� �������� �Ҽ� �а� �̸��� ã�ƶ�
select distinct I.dept_name
from instructor as I


-- # 5 ) ��ǻ�Ͱ��а����� �޿��� $70,000�� �Ѵ� ��� ������ �̸��� ���϶�
select I.name
from instructor as I
where I.salary > 70000 and I.dept_name = 'Comp. Sci.'


-- # 6 ) ��� �������� �̸��� �Բ�, �׵��� �а� �̸��� �ǹ� �̸��� ���϶�
select I.name as Instructor_name, I.dept_name, D.building
from instructor as I, department as D
where I.dept_name = D.dept_name 


-- # 7 ) ���� ID���� ���� teaches, instructor ���� �����ϰ�, ���� �̸��� ���� ���̵� ���
--	-> �ƹ� ������ �������� ������ �� ������ ��µ��� �ʴ´�.
select I.name as instructor_name, T.course_id 
from teaches as T, instructor as I
where T.ID = I.ID


-- # 8 ) ��ǻ�Ͱ��а� ������ ���� ���� �̸��� ���� ���̵� ���
select I.name as Instructor_name, T.course_id, I.dept_name
from instructor as I, teaches as T
where I.dept_name = 'Comp. Sci.' and T.ID = I.ID 


-- # 9 ) ���� ������ ������ �ϴ� ��� ������ ����,
--	 	 �׵��� �̸��� �׵��� ����ġ�� ������ ���� ���̵� ã�ƶ�
select I.name as Instructor_name, T.course_id
from instructor as I, teaches as T
where I.ID = T.ID


-- # 10 ) ��� �����а��� �������� �޿��� ���� ��� �������� �̸��� ���Ͽ���  
--		  �����а����� ���� ���� ���� �޴� �������� 
select I2.name as Instructor_name, I2.salary
from instructor as I1, instructor as I2
where I1.dept_name = 'Biology' and I2.salary > I1.salary


-- # 11 ) �̸��� 'W'�̶�� �κ� ���ڿ��� ���Ե� �ǹ��� ��� �а��� �̸��� ���϶�
select building
from department as D
where building like '%W%'


-- # 12 ) instructor�� ��ü�� salary�� ���� ������������ ����, �������� �̸��� �������� ����
select name as instructor_name
from instructor
order by salary desc, name asc


-- # 13 ) �޿��� 90,000�� 100,000���̿� �ִ� �������� �̸��� ã��
select name as Instructor_name1, salary
from instructor
where salary >= 90000 and salary <= 100000

select name as Instructor_name2, salary 
from instructor
where salary between 90000 and 100000


-- # 14 ) �����а����� ���Ǹ� �� ��� �������� �̸��� �׵��� ����ġ�� ��� ������ ���϶�
select I.name as Instructor_name1, T.course_id
from instructor as I, teaches as T
where I.dept_name = 'Biology' and I.ID = T.ID


-- # 15 ) 2009�� ������ ��� ������ ����
select course_id
from section as s
where s.semester = 'Fall' and s.year = 2009


-- # 16 ) 2010�� ���� ��� ������ ����
select course_id
from section as s
where s.semester = 'Spring' and s.year = 2010


-- # 17 ) 2009�� ���� & 2010�� ���� �����ؼ� ���ǰ� �Ǿ��� ��� ������ ����
(select course_id
from section as s
where s.semester = 'Fall' and s.year = 2009)
except
(select course_id
from section as s
where s.semester = 'Spring' and s.year = 2010)


-- # 18 ) instructor���� salary ���� �� ������ ��Ÿ���� ��� ������ ���϶�
select name
from instructor
where salary is null


-- # 19 ) ��ǻ�Ͱ��а��� �������� ��� �޿��� ���϶�
select avg(salary) as avg_salary
from instructor
where instructor.dept_name = 'Comp. Sci.'


-- # 20 ) 2010�� �� �б⿡ ������ �ϴ� �������� ���� ���϶�
--        count(distinct ID) : 5 / count(ID) : 6 => �ϳ� �̻��� ������ �ϴ� ������ �ִ� ����̴�.
select count(distinct ID) as spring_2009_teach_cnt
from teaches as T
where T.semester = 'Spring' and T.year = 2010


-- # 21 ) �� �а��� ��� �޿��� ���϶�
select dept_name, avg(salary)
from instructor
group by dept_name


-- # 22 ) ��� �������� ��� �޿��� ���϶�
select I.ID, avg(I.salary) as Instructor_avg_salary
from instructor as I
group by I.ID


-- # 23 ) 2010�� �� �б⿡ �� �а��� ������ �ϴ� ������ ���� ���϶�
select dept_name, count(distinct I.ID) as Instructor_cnt
from instructor as I, teaches as T
where T.semester = 'Spring' and T.year = 2010 and T.ID = I.ID
group by dept_name


-- # 24 ) �������� ��� �޿��� $42,000�� �Ѵ� �а��� �������� ��� �޿��� ���϶�
select I.dept_name, avg(salary) as Instructor_avg_salary
from instructor as I
group by I.dept_name
having avg(salary) > 42000

select *
from takes

-- # 25 ) 2009�⿡ �����Ǵ� ������ ���� �йݿ� ���ؼ�, �йݿ� ��� 2���� �л��� ������ �� �йݿ� ����� �л����� ��հ� ��ü ������ ���϶�
select s.ID, t.sec_id, semester, year, avg(s.tot_cred) as tot_cred_avg
from takes as t, student as s
where t.year = 2009 and t.ID = s.ID
group by s.ID, t.sec_id, semester, year
having count(s.ID) >= 2
