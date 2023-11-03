--Count all columns as total_rows
--Count the number of non-missing entries for description, listing_price, and last_visited
--Join info, finance, and traffic

SELECT 
    COUNT(*) as total_rows, 
    COUNT(description) as count_description,  
    COUNT(listing_price) as count_listing_price, 
    COUNT(last_visited) as count_last_visited
FROM info
INNER JOIN finance
ON info.product_id = finance.product_id
INNER JOIN traffic 
ON info.product_id = traffic.product_id


-- Select the brand, listing_price as an integer, and a count of all products in finance 
-- Join brands to finance on product_id
-- Filter for products with a listing_price more than zero
-- Aggregate results by brand and listing_price, and sort the results by listing_price in descending order

SELECT 
    brand, 
    CAST(listing_price as int), 
    COUNT(finance.product_id)
    FROM brands
    INNER JOIN finance
    ON brands.product_id = finance.product_id
    WHERE listing_price > 0
    GROUP BY brand, listing_price
    ORDER BY listing_price DESC;



-- Select the brand, a count of all products in the finance table, and total revenue
-- Create four labels for products based on their price range, aliasing as price_category
-- Join brands to finance on product_id and filter out products missing a value for brand
-- Group results by brand and price_category, sort by total_revenue

SELECT
    brand,
    count(finance.product_id),
    SUM(revenue) as total_revenue,
CASE 
    WHEN listing_price < 42 THEN 'Budget'
    WHEN listing_price BETWEEN 42 AND 74 THEN 'Average'
    WHEN listing_price BETWEEN 74 AND 129 THEN 'Expensive'
    ELSE 'Elite'
    END as price_category
FROM 
    brands
INNER JOIN
    finance
ON 
    finance.product_id = brands.product_id
WHERE 
    brand IS NOT NULL
GROUP BY 
    brand,
    price_category
ORDER BY 
    total_revenue DESC;




-- Select brand and average_discount as a percentage
-- Join brands to finance on product_id
-- Aggregate by brand
-- Filter for products without missing values for brand

SELECT
    brand, AVG(discount)*100 as average_discount
FROM brands
INNER JOIN finance
ON brands.product_id = finance.product_id
WHERE brand IS NOT NULL
GROUP BY brand;




-- Calculate the correlation between reviews and revenue as review_revenue_corr
-- Join the reviews and finance tables on product_id

SELECT CORR(reviews,revenue) as review_revenue_corr
FROM reviews
INNER JOIN finance
ON reviews.product_id = finance.product_id



-- Calculate description_length
-- Convert rating to a numeric data type and calculate average_rating
-- Join info to reviews on product_id and group the results by description_length
-- Filter for products without missing values for description, and sort results by description_length

SELECT 
    TRUNC(LENGTH(info.description),-2) as description_length,
    ROUND(AVG(reviews.rating::numeric),2) as average_rating   
FROM info
INNER JOIN reviews 
ON info.product_id = reviews.product_id
WHERE description IS NOT NULL
GROUP BY 
    description_length 
ORDER BY description_length ASC;



-- Select brand, month from last_visited, and a count of all products in reviews aliased as num_reviews
-- Join traffic with reviews and brands on product_id
-- Group by brand and month, filtering out missing values for brand and month
-- Order the results by brand and month

SELECT
    brands.brand, 
    EXTRACT(month from last_visited) as month, 
    COUNT(reviews.product_id) as num_reviews    
FROM reviews
INNER JOIN traffic
ON reviews.product_id = traffic.product_id
INNER JOIN brands
ON reviews.product_id = brands.product_id
WHERE EXTRACT(month from last_visited) IS NOT NULL AND brand IS NOT NULL
GROUP BY brand, EXTRACT(month from last_visited)
ORDER BY brand, month;



-- Create the footwear CTE, containing description and revenue
-- Filter footwear for products with a description containing %shoe%, %trainer, or %foot%
-- Also filter for products that are not missing values for description
-- Calculate the number of products and median revenue for footwear products

WITH footwear as (
SELECT
    description, 
    revenue
    FROM info
    INNER JOIN finance
    ON info.product_id = finance.product_id
    WHERE 
        description ILIKE '%shoe%' 
        OR description ILIKE '%trainer%' 
        OR description ILIKE '%foot%'
        AND description IS NOT NULL)
SELECT 
    COUNT(footwear) as num_footwear_products,
    percentile_disc(0.5) WITHIN GROUP(ORDER BY revenue) as median_footwear_revenue
    FROM footwear;




-- Copy the footwear CTE from the previous task
-- Calculate the number of products in info and median revenue from finance
-- Inner join info with finance on product_id
-- Filter the selection for products with a description not in footwear

WITH footwear as (
SELECT
    description, 
    revenue
    FROM info
    INNER JOIN finance
    ON info.product_id = finance.product_id
    WHERE 
        description ILIKE '%shoe%' 
        OR description ILIKE '%trainer%' 
        OR description ILIKE '%foot%'
        AND description IS NOT NULL)
SELECT 
    COUNT(*) as num_clothing_products,
    percentile_disc(0.5) WITHIN GROUP(ORDER BY revenue) as median_clothing_revenue
FROM 
    info
INNER JOIN finance
    ON info.product_id = finance.product_id
    WHERE description IS NOT NULL AND 
    description NOT IN (SELECT description FROM footwear);