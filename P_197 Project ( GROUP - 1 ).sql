show databases;
create database P197;
use P197;
set sql_safe_updates = 0;
show tables;


# importing table finance_2
create table finance_2(id int,delinq_2yrs int,earliest_cr_line char(30),inq_last_6mths int,mths_since_last_delinq char(30),mths_since_last_record char(30),open_acc int,
	pub_rec int,revol_bal int,revol_util int,total_acc int,initial_list_status char(30),out_prncp int,out_prncp_inv int,total_pymnt double,total_pymnt_inv double,
	total_rec_prncp int,total_rec_int double,total_rec_late_fee double,recoveries double,collection_recovery_fee double,last_pymnt_d char(30),last_pymnt_amnt double,
    next_pymnt_d char(30),last_credit_pull_d char(30));
    
select * from finance_2;

load data infile "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Finance_2.csv"
into table finance_2 fields terminated by ',' enclosed by '"' lines terminated by '\n'
ignore 1 rows;

-- Correct date format in the update statement
UPDATE finance_2 SET earliest_cr_line = DATE_FORMAT(STR_TO_DATE(earliest_cr_line, '%d-%m-%Y'), '%Y-%m-%d')
WHERE earliest_cr_line  IS NOT NULL;
UPDATE finance_2 SET earliest_cr_line = STR_TO_DATE(earliest_cr_line, '%y-%m-%d');-


# importing table finance_1
create table finance_1(id int,member_id int,loan_amnt int,funded_amnt int,funded_amnt_inv double,term char(30),int_rate varchar(30),
installment double,grade varchar(50),sub_grade varchar(30),emp_title varchar(100),emp_length varchar(50),home_ownership varchar(50),
annual_inc int,verification_status varchar(50),issue_d char(30),loan_status varchar(30),pymnt_plan varchar(30),descrip varchar(4000),
purpose varchar(300),title varchar(300),zip_code varchar(30),addr_state varchar(60),dti double);

select * from finance_1;

load data infile "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Finance_1.csv"
into table finance_1 fields terminated by ',' enclosed by '"' lines terminated by '\n'
ignore 1 rows;

-- Correct date format in the update statement
UPDATE finance_1 SET issue_d = DATE_FORMAT(STR_TO_DATE(issue_d, '%d-%m-%Y'), '%Y-%m-%d')
WHERE issue_d IS NOT NULL;

-- tables
select * from finance_1;
select * from finance_2;
SELECT COUNT(*) FROM finance_1;
SELECT COUNT(*) FROM finance_2;

-- KPI_1 (year_wise loan amount)
select year(issue_d), sum(loan_amnt) from finance_1 group by year(issue_d) order by year(issue_d);

-- KPI_2 (grade and sub-grade wise revol_bal)
select grade, sub_grade, sum(revol_bal) from finance_1 inner join finance_2 on finance_1.id = finance_2.id 
group by grade, sub_grade order by grade, sub_grade;

-- KPI_3 (total payment for verified status vs total payment for non-verified status)
select verification_status, round(sum(total_pymnt),2) from finance_1 inner join finance_2 on finance_1.id = finance_2.id 
group by verification_status;

-- KPI_4 (state wise and month wise loan_status)
select addr_state as state, date_format(issue_d, '%b') as month_, loan_status from finance_1 inner join finance_2 on finance_1.id = finance_2.id
order by state, month_;

create view state as select addr_state as state, date_format(issue_d, '%b') as month_, loan_status from finance_1 inner join finance_2 on finance_1.id = finance_2.id
order by state, month_;

select * from state;

-- KPI_5 (home_ownership vs last_payment_date stats)
select home_ownership, count(last_pymnt_d) from finance_1 inner join finance_2 on finance_1.id = finance_2.id
group by home_ownership;