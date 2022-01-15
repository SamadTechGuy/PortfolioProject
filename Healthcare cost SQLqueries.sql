DROP TABLE HospitalCosts;
CREATE TABLE HospitalCosts
(
	AGE		smallint,							
	FEMALE		smallint,
	LOS		smallint,
	RACE		smallint,
	TOTCHG		int,
	APRDRG		smallint
);
select * from HospitalCosts;

--AGE		Age of the patient discharged
--FEMALE	Binary variable that indicates if the patient is female
--LOS		Length of stay, in days
--RACE		Race of the patient (specified numerically)
--TOTCHG	Hospital discharge costs
--APRDRG	All Patient Refined Diagnosis Related Groups


--1. How many patients went to the hospital?

select count(age) as Total_no_of_patients
from HospitalCosts;

--2. Fetch the category of people who went to the hospital frequently
--and has maximum expenditure.

with t1 as
		(select age, totchg as hospital_discharge_costs
		from HospitalCosts
		group by age,totchg
		order by age desc,totchg desc),
t2 as
		(select distinct age, max(expenditure) as highest_costs
		 from t1
		group by age
		order by age desc, highest_costs desc)
select * 
from t2
order by 2 desc;

--3. Fetch the top 5 category of people who went
-- to the hospital and has highest costs.

with t1 as
		(select age, totchg as hospital_discharge_costs
		from HospitalCosts
		group by age,totchg
		order by age desc,totchg desc),
t2 as 
	(select *,
	rank() over(partition by age order by hospital_discharge_costs desc) rnk
	from t1
	)
select * 
from t2
where rnk <= 5;

--4. Fetch the bottom 5 category of people with the lowest costs.

with t1 as
		(select age, totchg as hospital_discharge_costs
		from HospitalCosts
		group by age,totchg
		order by age desc,totchg desc),
t2 as 
	(select *,
	rank() over(partition by age order by hospital_discharge_costs) rnk
	from t1
	)
select * 
from t2
where rnk <= 5;

--5. Fetch the total hospital discharge costs spent 
-- by each category of people

select * 
from HospitalCosts;

with t1 as
		(select age, totchg as hospital_discharge_costs
		from HospitalCosts
		group by age,totchg
		order by age desc,totchg desc),
t2 as
	(select distinct age, sum(hospital_discharge_costs) as total_discharge_costs
	 from t1
	 group by age
	order by total_discharge_costs desc	
)
 select * 
from t2
order by total_discharge_costs desc;

--6. Find the diagnosis related group that has maximum
-- hospitalization and expenditure.

with t1 as
		(select aprdrg as diagnosis_related_group
		 , max(los) as max_hospitalization
		 , max(totchg) as max_expenditure
		from hospitalcosts
		group by aprdrg 
		order by max_hospitalization desc
		, max_expenditure desc)
select *
from t1;

--7. Which patient refined diagnosis related groups 
-- had the highest and lowest expenditure?

with t1 as
		(select aprdrg as diagnosis_related_group,
		totchg as expenditure
		from hospitalcosts
		order by expenditure),
t2 as 
		(select diagnosis_related_group,
		 max(expenditure) as Highest_expenditure,
		 min(expenditure) as Lowest_expenditure
		 from t1
		 group by diagnosis_related_group
		 order by Highest_expenditure desc, lowest_expenditure asc
		)
	select diagnosis_related_group,
	Highest_expenditure,
	Lowest_expenditure
	from t2
	order by Highest_expenditure desc, Lowest_expenditure;

--8. Fetch the total number of females by each category
-- of people that went to the hospital. 

select age, count(1) as total_no_of_females
from hospitalcosts
where female != 0
group by age
order by age;

--9. Fetch the category of female that stayed long
--at the hospital with their discharge costs.

with t1 as
		(select distinct age, female, los as length_of_stay,
		totchg as discharge_costs
		from hospitalcosts
		where female != 0),
t2 as
	(select age, female, length_of_stay
	 , max(discharge_costs) as max_cost
	from t1
	 group by age, female, length_of_stay
	),
t3 as
	(select *,
	 rank() over(partition by age order by length_of_stay desc) rnk
	from t2)	
select age, female, length_of_stay,
max_cost
from t3
where rnk = 1;
	
--10.  Fetch the category of female that stayed less
--at the hospital with their discharge costs.

with t1 as
		(select distinct age, female, los as length_of_stay,
		totchg as discharge_costs
		from hospitalcosts
		where female != 0),
t2 as
	(select age, female, length_of_stay
	 , min(discharge_costs) as min_cost
	from t1
	 group by age, female, length_of_stay
	),
t3 as
	(select *,
	 rank() over(partition by age order by length_of_stay) rnk
	from t2)
select age, female, length_of_stay,
min_cost
from t3
where rnk = 1;

--11. Fetch the number of patient in each race.

select cast(race as varchar),count(1) as no_of_patient
from hospitalcosts
where race is not null
group by race
order by race;

