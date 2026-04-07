USE practice;

-- (1) Total Listings
SELECT COUNT(id) AS "total listings"
FROM airbnb;

-- (2) Average price
SELECT AVG(price) AS average_price
FROM airbnb;

-- (3) Listings per neighbourhood
SELECT neighbourhood, COUNT(*) AS number_of_listings
FROM airbnb
GROUP BY neighbourhood
ORDER BY number_of_listings DESC ;

-- (4) Average Price by Room Type
SELECT room_type, ROUND(AVG(price),2) AS Avg_Price
FROM airbnb
GROUP BY room_type ;


-- (5) Top 10 expensive listings
SELECT host_name , MAX(price) AS expensive
FROM airbnb
GROUP BY host_name
ORDER BY expensive DESC LIMIT 10;

-- (6) Listings with high reviews
SELECT host_name, MAX(number_of_reviews) AS Reviews_Count
FROM airbnb
GROUP BY host_name
ORDER BY Reviews_Count DESC LIMIT 10 ;

-- (7) Hosts with Multiple listings
SELECT DISTINCT host_name, calculated_host_listings_count
FROM airbnb
ORDER BY calculated_host_listings_count DESC ;

-- (8) Rank Listings by price
SELECT DISTINCT host_name, price,
RANK() OVER (ORDER BY price DESC) AS rank_number
FROM airbnb ;

-- (9) Top 3 listings per neighbourhood
SELECT host_name, neighbourhood,
ROW_NUMBER() OVER (PARTITION BY neighbourhood ORDER BY price DESC) AS top_listings
FROM airbnb ;

-- (10) Detection of Outliers
SELECT *
FROM airbnb
WHERE price > (SELECT AVG(price) + 2 * STDDEV(price) FROM airbnb)
OR price < (SELECT AVG(price) - 2 * STDDEV(price) FROM airbnb);

-- (11) Price vs Rating Trend  
SELECT 
CASE
WHEN rating >= 4.5 THEN "Excellent"
WHEN rating >= 4.0 THEN "Good"
ELSE 'Average'
END AS rating_category,
COUNT(*) AS total_listings,
ROUND(AVG(price),1) AS avg_price
FROM airbnb
GROUP BY rating_category;

-- (12) Host Segmentation
-- (1) Individual vs Professional hosts
SELECT 
CASE
WHEN calculated_host_listings_count = 1 THEN 'Individual'
ELSE 'Professional'
END AS host_type,
COUNT(*) AS total_listings,
ROUND(AVG(price),1) AS avg_price,
ROUND(AVG(rating),2) AS avg_rating
FROM airbnb
GROUP BY host_type;

-- (2) Top Professional Hosts
SELECT host_id, host_name,
COUNT(*) AS total_listings,
AVG(price) AS avg_price
FROM airbnb
GROUP BY host_id, host_name
HAVING COUNT(*) > 5
ORDER BY total_listings DESC LIMIT 10 ;


-- (13) Availability Level vs Average Price
SELECT 
CASE 
WHEN availability_365 <= 50 THEN 'Low'
WHEN availability_365 <= 170 THEN 'Medium'
ELSE 'High'
END AS availability_level,
COUNT(*) AS total_listings,
ROUND(AVG(price),2) AS avg_price
FROM airbnb
GROUP BY availability_level
ORDER BY avg_price DESC ;

-- (14) Monthly Price Trend
SELECT 
YEAR(last_review) AS year,
MONTH(last_review) AS month,
AVG(price) AS avg_price
FROM airbnb
WHERE last_review IS NOT NULL
GROUP BY year , month
ORDER BY year, month ;


-- (15) Find neighbourhoods where average price is higher than overall average price
WITH avg_price_neighbourhood AS (SELECT neighbourhood, AVG(price) AS avg_price 
FROM airbnb
GROUP BY neighbourhood),
overall_avg_price AS (SELECT AVG(price) AS overall_avg_price 
FROM airbnb)
SELECT a.neighbourhood , a.avg_price
FROM avg_price_neighbourhood a, overall_avg_price o
WHERE a.avg_price > o.overall_avg_price ;


-- (16) Find listings where price is greater than average price of their neighbourhood
SELECT * 
FROM airbnb a
WHERE price > (SELECT AVG(price) AS avg_price
FROM airbnb
WHERE neighbourhood = a.neighbourhood) ;


-- (17) Calculate running average price across listings
SELECT id, 
price,
AVG(price) OVER (PARTITION BY id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_avg
FROM airbnb ;


-- (18) top 3 expensive listings per neighbourhood
WITH ranked_listings AS (SELECT * ,
ROW_NUMBER() OVER ( PARTITION BY neighbourhood ORDER BY price DESC) AS rn
FROM airbnb
)
SELECT * 
FROM ranked_listings
WHERE rn <= 3 ;


-- (19) find hosts whoose number of listings is greater than average
SELECT * 
FROM airbnb
WHERE calculated_host_listings_count > (SELECT 
AVG(calculated_host_listings_count) FROM airbnb)