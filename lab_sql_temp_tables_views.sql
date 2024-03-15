-- Step 1: Create a View
SELECT * FROM customer;
SELECT * FROM rental;

CREATE OR REPLACE VIEW summary_clients_rental_info AS
SELECT 
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    c.email, 
    COUNT(r.rental_id) AS rental_count
FROM customer AS c
JOIN rental AS r ON c.customer_id = r.customer_id
GROUP BY c.customer_id;

SELECT * FROM summary_clients_rental_info;

-- Step 2: Create a Temporary Table
SELECT * FROM payment;

DROP TEMPORARY TABLE IF EXISTS total_paid;

CREATE TEMPORARY TABLE total_paid
SELECT scri.*,SUM(p.amount) AS total_amount_by_client FROM summary_clients_rental_info AS scri
LEFT JOIN payment AS p
ON scri.customer_id = p.customer_id
GROUP BY scri.customer_id;

SELECT * FROM total_paid;

-- Step 3: Create a CTE and the Customer Summary Report
WITH cte_join AS (
SELECT 
	scri.first_name, 
    scri.last_name, 
    scri.email, 
    scri.rental_count,
    tp.total_amount_by_client
FROM summary_clients_rental_info AS scri
JOIN total_paid AS tp
ON scri.customer_id = tp.customer_id
)
SELECT 
	ctj.first_name, 
    ctj.last_name, 
    ctj.email, 
    ctj.rental_count,
    ctj.total_amount_by_client,
    ROUND(ctj.total_amount_by_client/ctj.rental_count,2) AS avegage_payment_per_rental
FROM cte_join AS ctj;