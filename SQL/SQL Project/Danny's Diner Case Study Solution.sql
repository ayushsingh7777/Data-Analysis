/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

--BONUS QUESTIONS
-- 11.Danny and his team can use to quickly derive insights without needing to join the tables using SQL. Recreate the following table output using the available data.
-- 12 Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.



-- 1. What is the total amount each customer spent at the restaurant?

select customer_id,sum(price) as total_spend 
from sales s 
left join menu m on s.product_id=m.product_id
group by customer_id

-- 2. How many days has each customer visited the restaurant?

select customer_id,count(distinct order_date) as days_count 
from sales s 
group by customer_id

-- 3. What was the first item from the menu purchased by each customer?


with first_prod as
(
	select customer_id,product_name
	from sales s 
	join menu m on s.product_id=m.product_id
	where order_date in 
	(
		select min(order_date) from sales 
		group by customer_id
	)

)
select customer_id, STRING_AGG(product_name,', ') as product
from first_prod
group by customer_id


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

select top 1
	s.product_id,product_name,
	count(*) as totalPruchase
from sales s 
join menu m on s.product_id=m.product_id
group by s.product_id,product_name
order by totalPruchase desc
;


-- 5. Which item was the most popular for each customer?

with popularProd as (
	select 
		customer_id,product_id,
		count(*) as prodCount,
		ROW_NUMBER() over(partition by customer_id order by count(*) desc) as rankk
	from sales
	group by customer_id,product_id
)
select 
	customer_id, p.product_id,product_name
from popularProd p
left join menu m on p.product_id=m.product_id
where rankk=1

-- 6. Which item was purchased first by the customer after they became a member?



--Method 1 using Dense_rank

with cte as (
	select 
		me.customer_id,join_date,
		order_date,m.product_name,
	dense_rank() over(partition by me.customer_id order by order_date) as rankk
	from members me
	join sales s on me.customer_id=s.customer_id
	JOIN menu m on s.product_id=m.product_id
	where order_date>join_date
)
select 
	customer_id, join_date,
	order_date, product_name
from cte 
where rankk=1




--Method 2 Using LAG
with cte as (
	select 
		s.customer_id, 
		order_date, join_date,
		lag(order_date) over(partition by s.customer_id order by order_date) as previous_date,
		product_name
	from  sales s
	left join members m on m.customer_id= s.customer_id
	left join menu mu on s.product_id=mu.product_id
	where order_date>=join_date
),
cte2 as (
	select *,
	ROW_NUMBER() over(partition by customer_id order by order_date) as rankk
	from cte
)
select 
	customer_id,
	join_date,previous_date,
	product_name
from cte2 
where rankk=2

--Method 3 using Dense_rank
with cte as (
select me.customer_id,join_date,order_date,m.product_name,
dense_rank() over(partition by me.customer_id order by order_date) as rankk
from members me
join sales s on me.customer_id=s.customer_id
JOIN menu m on s.product_id=m.product_id
where order_date>join_date
)
select * from cte 
where rankk=1

-- 7. Which item was purchased just before the customer became a member?


with cte as (
		select 
			me.customer_id,join_date,
			order_date,m.product_name,
			dense_rank() over(partition by me.customer_id order by order_date desc) as rankk
	from members me
	join sales s on me.customer_id=s.customer_id
	JOIN menu m on s.product_id=m.product_id
	where order_date<join_date
)
select 
	customer_id, join_date,
	order_date, product_name
from cte 
where rankk=1


-- 8. What is the total items and amount spent for each member before they became a member?


select 
			distinct me.customer_id,
			max(join_date) as join_date,
			count(*) as total_item,
			sum(price) as total_spend
	from members me
	join sales s on me.customer_id=s.customer_id
	JOIN menu m on s.product_id=m.product_id
	where order_date<join_date
	group by me.customer_id
	order by me.customer_id


-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?


select 
		customer_id,
		sum(	
			case 
				when product_name='sushi' then price*20 
				else price*10 
			end
		) as Total_points
	from  sales s
	left join menu mu on s.product_id=mu.product_id
	group by customer_id
	

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?



with pointsTable as
(
	select s.*,join_date,product_name,price,
		case 
			when (order_date<join_date) and (product_name='sushi')
				then price*20 
			when order_date between join_date and dateadd(day,6,join_date)
				then price*20
			else price*10
		end as points
	from sales s
	inner join members me on s.customer_id=me.customer_id
	inner join menu m on s.product_id=m.product_id
	where month(order_date) = 1
)
select customer_id,
	sum(points) as totalpoints
from pointsTable
group by customer_id


-- 11. Danny and his team can use to quickly derive insights without needing to join the tables using SQL. Recreate the following table output using the available data.

select s.customer_id,order_date,product_name,price,
	case 
		when order_date>=join_date then 'Y' 
		when join_date is null then 'N'
		else 'N'
	end as member
from sales s 
 left join members me on s.customer_id=me.customer_id  
 left join menu m on s.product_id=m.product_id
 order by s.customer_id,order_date, price desc


 -- 12 Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.

------------------------------------------

WITH joint_sales AS (
	SELECT
	    sales.customer_id
	   , sales.order_date
	   , menu.product_name
	   , menu.price
	   , CASE 
  	    WHEN sales.order_date >= members.join_date THEN 'Y'
  	    ELSE 'N'
  	    END AS member
	FROM sales
	INNER JOIN members
	  ON sales.customer_id = members.customer_id
	INNER JOIN menu
	  ON sales.product_id = menu.product_id
	
)
SELECT
    customer_id
  , order_date
  , product_name
  , price
  , member
  , CASE
        WHEN member = 'N' THEN null
        ELSE
          RANK() OVER(PARTITION BY customer_id, member ORDER BY order_date)
      END AS ranking
FROM joint_sales
ORDER BY
    customer_id
  , order_date
;


/* Another way to answer this question */
SELECT
    sales.customer_id
  , sales.order_date
  , menu.product_name
  , menu.price
  , CASE 
      WHEN sales.order_date >= members.join_date THEN 'Y'
      ELSE 'N'
    END AS member
  , CASE
      WHEN sales.order_date >= members.join_date 
        THEN RANK() OVER(PARTITION BY sales.customer_id, 
          (CASE 
              WHEN sales.order_date >= members.join_date THEN 'Y'
              ELSE 'N'
              END)
          ORDER BY sales.order_date)
      ELSE null
    END AS ranking
FROM sales
LEFT JOIN members
  ON sales.customer_id = members.customer_id
LEFT JOIN menu
  ON sales.product_id = menu.product_id
ORDER BY
    sales.customer_id
  , sales.order_date;