*************************************************************************************
                         'Bussiness Questions'
**************************************************************************************

1. Demographic Insights (examples)
a. Who prefers energy drink more? (male/female/non-binary?)
b. Which age group prefers energy drinks more?
c. Which type of marketing reaches the most Youth (15-30)?

2. Consumer Preferences:
a. What are the preferred ingredients of energy drinks among respondents?
b. What packaging preferences do respondents have for energy drinks?

3. Competition Analysis:
a. Who are the current market leaders?
b. What are the primary reasons consumers prefer those brands over ours?

4. Marketing Channels and Brand Awareness:
a. Which marketing channel can be used to reach more customers?
b. How effective are different marketing strategies and channels in reaching our 
customers?

5. Brand Penetration:
a. What do people think about our brand? (overall rating)
b. Which cities do we need to focus more on?

6. Purchase Behavior:
a. Where do respondents prefer to purchase energy drinks?
b. What are the typical consumption situations for energy drinks among 
respondents?
c. What factors influence respondents purchase decisions, such as price range and 
limited edition packaging?

7. Product Development
a. Which area of business should we focus more on our product development? 
(Branding/taste/availability

***************************************************************************************
								'END'
***************************************************************************************



select * from dbo.dim_repondents order by Respondent_ID;
select * from dbo.dim_cities;
select * from dbo.fact_survey_responses order by Response_ID;

***************************************************************************************
							Part 1
***************************************************************************************

1. Demographic Insights (examples)
a. Who prefers energy drink more? (male/female/non-binary?)
b. Which age group prefers energy drinks more?
c. Which type of marketing reaches the most Youth (15-30)
***************************************************************************************

--1.a. Who prefers energy drink more? (male/female/non-binary?)

select Gender, count(*) as Total_response, 
	cast(round(((count(*) * 100.00)/(select count(*) from fact_survey_responses)),2) as decimal(4,2)
		) as Percentage
from fact_survey_responses f
left join dim_repondents d
on f.Respondent_ID=d.Respondent_ID
group by Gender
order by Total_response desc


--1.b. Which age group prefers energy drinks more?

select Age, count(*) as Total_response,
	cast(round(((count(*) * 100.00)/(select count(*) from fact_survey_responses)),2) as decimal(4,2)
	) as Percentage
from fact_survey_responses f
left join dim_repondents d
on f.Respondent_ID=d.Respondent_ID
group by Age
order by Total_response desc


--1.c. Which type of marketing reaches the most Youth (15-30)

select distinct Age from dim_repondents


select Marketing_channels, count(*) as "Total_response (15-30)",
cast(round(((count(*) * 100.00)/
	(
		select count(*) from fact_survey_responses f
		left join dim_repondents d
		on f.Respondent_ID=d.Respondent_ID
		where Age in('19-30','15-18')
	)
),2) as decimal(4,2)) as Percentage
from fact_survey_responses f
left join dim_repondents d
on f.Respondent_ID=d.Respondent_ID
where Age in('19-30','15-18')
group by Marketing_channels
order by "Total_response (15-30)" desc





***************************************************************************************
							Part 2
***************************************************************************************


2. Consumer Preferences:
a. What are the preferred ingredients of energy drinks among respondents?
b. What packaging preferences do respondents have for energy drinks?
***************************************************************************************

select * from dbo.dim_repondents order by Respondent_ID;
select * from dbo.dim_cities;
select * from dbo.fact_survey_responses order by Respondent_ID;


--2.a What are the preferred ingredients of energy drinks among respondents?

select Ingredients_expected, count(*) as Total_response,
	(cast(cast(round(((count(*) * 100.00)/(select count(*) from fact_survey_responses)),2) as decimal(4,2)) as varchar) +'%'
	) as Percentage
from fact_survey_responses
group by Ingredients_expected
order by Total_response desc


--2.b. What packaging preferences do respondents have for energy drinks?

select Packaging_preference,
	(cast(cast(round(((count(*) * 100.00)/(select count(*) from fact_survey_responses)),2) as decimal(4,2)) as varchar) +'%'
	) as Percentage
from fact_survey_responses
group by Packaging_preference
order by count(*) desc


***************************************************************************************
							Part 3
***************************************************************************************


3. Competition Analysis:
a. Who are the current market leaders?
b. What are the primary reasons consumers prefer those brands over ours?
***************************************************************************************

--3.a. Who are the current market leaders?


select current_brands,
	(cast(cast(round(((count(*) * 100.00)/(select count(*) from fact_survey_responses)),2) as decimal(4,2)) as varchar) +'%'
	) as Market_Share
from dbo.fact_survey_responses
group by current_brands
order by count(*) desc


-- 3.b. What are the primary reasons consumers prefer those brands over ours?

select Reasons_for_choosing_brands, 
	(cast(cast(round(((count(*) * 100.00)/(select count(*) from fact_survey_responses)),2) as decimal(4,2)) as varchar) +'%'
	) as Reason_Weightage
from dbo.fact_survey_responses
group by Reasons_for_choosing_brands
order by count(*) desc



***************************************************************************************
							Part 4
***************************************************************************************


4. Marketing Channels and Brand Awareness:
a. Which marketing channel can be used to reach more customers?
b. How effective are different marketing strategies and channels in reaching our 
customers?
***************************************************************************************

--4. a. Which marketing channel can be used to reach more customers?

select Marketing_channels, 
	(cast(cast(round(((count(*) * 100.00)/(select count(*) from fact_survey_responses)),2) as decimal(4,2)) as varchar) +'%'
	) as Reason_Weightage
from dbo.fact_survey_responses
group by Marketing_channels
order by count(*) desc

--4.b. How effective are different marketing strategies and channels in reaching our customers?

-- Merketing channels by target age groups

with cte as (
	select * from (
		select Marketing_channels,age, count(*) as total
		from fact_survey_responses f left join dim_repondents d
		on f.Respondent_ID=d.Respondent_ID
		where Age in('19-30','15-18','31-45')
		group by Marketing_channels,age
	)a
	pivot ( sum(total) for age in ([15-18],[19-30],[31-45]) 
		   )as pivot_table
)
select *, ([15-18]+[19-30]+[31-45]) as total from cte
order by total desc




***************************************************************************************
							Part 5
***************************************************************************************

5. Brand Penetration:
a. What do people think about our brand? (overall rating)
b. Which cities do we need to focus more on?

***************************************************************************************
select * from dbo.dim_repondents order by Respondent_ID;
select * from dbo.dim_cities;
select * from dbo.fact_survey_responses order by Respondent_ID;


-- 5.a. What do people think about our brand? (overall rating)

select Brand_perception,count(*) as Total_count
from fact_survey_responses
group by Brand_perception
order by Total_count desc

-- Overall Rating is out of 3
select avg(case when Brand_perception='Neutral' then 2
			when Brand_perception='Positive' then 3
			else 1
		end) as Brand_ratings
from fact_survey_responses


--b. Which cities do we need to focus more on?

with heardBefore as (
SELECT
  City,
  sum(CASE 
		WHEN CAST(Heard_before AS BIT) = 1 THEN 1 ELSE 0
	  END) AS Heard_before,
  sum(CASE 
		WHEN CAST(Heard_before AS BIT) = 0 THEN 1 ELSE 0 
	  END) AS Not_Heard_before,
  COUNT(*) AS total_response
FROM fact_survey_responses f
JOIN dim_repondents r ON f.Respondent_ID = r.Respondent_ID
JOIN dim_cities c ON c.City_ID = r.City_ID
GROUP BY City
), 
CodexResponse as (
SELECT
  City,count(*) as CodeX_response
FROM fact_survey_responses f
JOIN dim_repondents r ON f.Respondent_ID = r.Respondent_ID
JOIN dim_cities c ON c.City_ID = r.City_ID
where Current_brands = 'CodeX'
GROUP BY City
)
select h.city as City, 
		Not_Heard_before,Heard_before,
		CodeX_Response,total_response
from heardBefore h join CodeXResponse c
on h.City = c.City
order by Not_Heard_before ,CodeX_Response 


***************************************************************************************
							Part 6
***************************************************************************************

6. Purchase Behavior:
a. Where do respondents prefer to purchase energy drinks?
b. What are the typical consumption situations for energy drinks among 
respondents?
c. What factors influence respondents purchase decisions, such as price range and 
limited edition packaging?

***************************************************************************************


--6.a. Where do respondents prefer to purchase energy drinks?

select Purchase_location, count(*) as Total_count
from fact_survey_responses
group by Purchase_location
order by Total_count desc


select city, [Supermarkets],[Online retailers],
	[Gyms and fitness centers],[Local stores],
	[Other], ([Supermarkets]+[Online retailers]+
	[Gyms and fitness centers]+[Local stores]+
	[Other]) as Total 
from (
	select * from (
		SELECT
			City,Purchase_location, count(*) as Total_count
		FROM fact_survey_responses f
		JOIN dim_repondents r ON f.Respondent_ID = r.Respondent_ID
		JOIN dim_cities c ON c.City_ID = r.City_ID
		GROUP BY City,Purchase_location
	)a
	pivot (sum(Total_count) for Purchase_location 
	in ([Supermarkets],[Online retailers],
		[Gyms and fitness centers],[Local stores],
		[Other])
   ) as pivot_tables
)b
order by Total desc



-- 6.b. What are the typical consumption situations for energy drinks among respondents?

select Typical_consumption_situations, count(*) as Total_count
from dbo.fact_survey_responses
group by Typical_consumption_situations
order by Total_count desc


-- 6. c. What factors influence respondents purchase decisions, such as price range and limited edition packaging?

--PRICE RANGE
select Price_range, count(*) as Total_count
from dbo.fact_survey_responses
group by Price_range
order by Total_count desc

--LIMITED EDITION PACKAGING
select
case when Limited_edition_packaging=1 then 'Yes'
	 when Limited_edition_packaging=0 then 'No'
	 else 'Not Sure'
end as Limited_edition,
count(*) as Total_count
from dbo.fact_survey_responses
group by Limited_edition_packaging
order by Total_count desc
	
--HEALTH CONCERNS
SELECT health_concerns,COUNT(respondent_id) as T_count
FROM fact_survey_responses
GROUP BY health_concerns
ORDER BY T_count DESC


***************************************************************************************
							Part 7
***************************************************************************************

7. Product Development
a. Which area of business should we focus more on our product development? 
(Branding/taste/availability

***************************************************************************************


-- Top 3 Reason for choosing Brand

select top 3 Reasons_for_choosing_brands, 
	(cast(cast(round(((count(*) * 100.00)/(select count(*) from fact_survey_responses)),2) as decimal(4,2)) as varchar) +'%'
	) as distribution
from dbo.fact_survey_responses
group by Reasons_for_choosing_brands
order by count(*) desc

--Taste_experience across Age Groups

select Taste_experience,[15-18],[19-30],[31-45],
	([46-65]+[65+]) as [45+],
	([15-18]+[19-30]+[31-45]+[46-65]+[65+]) as total_count,
	cast(round((([15-18]+[19-30]+[31-45]+[46-65]+[65+])*100.00)/
				(select count(*) from fact_survey_responses),2) as decimal(4,2)
		 ) as per
from(
	select * from (
		select Taste_experience,Age, count(*) as total
		FROM fact_survey_responses f
		JOIN dbo.dim_repondents r ON f.Respondent_ID = r.Respondent_ID
		JOIN dim_cities c ON c.City_ID = r.City_ID
		group by Taste_experience,Age
	)a
	pivot ( sum(total) for Age in ([15-18],[19-30],[31-45],[46-65],[65+]) 
		  )as pivot_table
)b
order by total_count desc

	






