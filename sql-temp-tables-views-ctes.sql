-- First, create a view that summarizes rental information for each 
-- customer. The view should include the customer's ID, name, email 
-- address, and total number of rentals (rental_count).
use sakila;

CREATE VIEW customer_rental_summary AS
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name, c.email, COUNT(r.rental_id) AS rental_count
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id;

select *
from customer_rental_summary;

-- Next, create a Temporary Table that calculates the total amount
-- paid by each customer (total_paid). The Temporary Table should 
-- use the rental summary view created in Step 1 to join with the 
-- payment table and calculate the total amount paid by each customer.
create temporary table customer_total_amount_2
select p.customer_id, sum(p.amount) as total_amount
from payment as p
join customer_rental_summary as cr
on p.customer_id = cr.customer_id
group by p.customer_id;

select *
from customer_total_amount_2;


-- Create a CTE that joins the rental summary View with the 
-- customer payment summary Temporary Table created in Step 2. 
-- The CTE should include the customer's name, email address, 
-- rental count, and total amount paid. 
WITH cte_rental_total AS (
  SELECT crs.customer_id, 
         crs.rental_count, 
         cta.total_amount
  FROM customer_rental_summary AS crs
  JOIN customer_total_amount_2 AS cta ON crs.customer_id = cta.customer_id
)
SELECT 
  cte.customer_id, 
  CONCAT(c.first_name, ' ', c.last_name) AS customer_name, 
  c.email, 
  round(cte.total_amount / cte.rental_count,2) AS average_payment_per_rental
FROM 
  cte_rental_total AS cte
JOIN 
  customer AS c ON c.customer_id = cte.customer_id;

-- Next, using the CTE, create the query to generate the final 
-- customer summary report, which should include: customer name, 
-- email, rental_count, total_paid and average_payment_per_rental, 
-- this last column is a derived column from total_paid and 
-- rental_count.
WITH cte_customer_summary AS (
  SELECT
    crs.customer_name,
    crs.email,
    crs.rental_count,
    cta.total_amount AS total_paid
  FROM
    customer_rental_summary crs
  JOIN
    customer_total_amount_2 cta ON crs.customer_id = cta.customer_id
)
SELECT
  customer_name,
  email,
  rental_count,
  total_paid,
  ROUND(total_paid / rental_count, 2) AS average_payment_per_rental
FROM
  cte_customer_summary;
