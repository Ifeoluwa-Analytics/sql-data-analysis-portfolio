-- Hotel Booking Analysis
-- Dataset: Hotel Booking Demand
-- Objective: Analyze booking patterns, customer behavior, and cancellations

SELECT TOP 5*
FROM CapProj
-- Preview the top 5 rows
  
--Q1: Which market segment generates the highest revenue? 
-- Approach 1: Ranking by room count (proxy for demand)
SELECT TOP 1 market_segment, COUNT(assigned_room_type) AS room_count
FROM CapProj
GROUP BY market_segment
ORDER BY COUNT(assigned_room_type) DESC

-- Approach 2: Ranking by total revenue
-- ADR (Average Daily Rate) = revenue per night
SELECT TOP 1 market_segment, 
       ROUND(SUM((stays_in_week_nights + stays_in_weekend_nights) * adr), 2) AS revenue
FROM CapProj
GROUP BY market_segment
ORDER BY revenue DESC

--Q2: What is the average lead time for bookings?
SELECT AVG(lead_time) AS avgleadtime
FROM CapProj

--Q3: Which room types have the highest cancellation rates?
SELECT TOP 1 reserved_room_type,
       ROUND(SUM(is_canceled)/COUNT(*)*100, 2) AS cancellation_rate 
	 FROM CapProj
GROUP BY reserved_room_type
ORDER BY cancellation_rate DESC;

--Q4: How many bookings were made per market segment? 
SELECT market_segment, COUNT(*) AS total_bookings
FROM CapProj
GROUP BY market_segment
ORDER BY total_bookings 

--Q5: What is the distribution of bookings across customer types? 
SELECT customer_type, COUNT(*) AS customertype_distr
FROM CapProj
GROUP BY customer_type
ORDER BY customertype_distr

--Q6: Which room types generate the highest revenue? 
SELECT TOP 1
    assigned_room_type,
    ROUND(SUM((stays_in_weekend_nights + stays_in_week_nights) * adr), 2) AS total_revenue
FROM CapProj
WHERE is_canceled = 0
GROUP BY assigned_room_type
ORDER BY total_revenue DESC;

--Q7: During which seasons is the revenue highest? 
SELECT 
    CASE 
        WHEN arrival_date_month IN ('December', 'January', 'February') THEN 'Winter'
        WHEN arrival_date_month IN ('March', 'April', 'May') THEN 'Spring'
        WHEN arrival_date_month IN ('June', 'July', 'August') THEN 'Summer'
        WHEN arrival_date_month IN ('September', 'October', 'November') THEN 'Autumn'
    END AS season,
    ROUND(SUM((stays_in_week_nights + stays_in_weekend_nights) * adr), 2) AS total_revenue
FROM CapProj
WHERE is_canceled = 0
GROUP BY 
    CASE 
        WHEN arrival_date_month IN ('December', 'January', 'February') THEN 'Winter'
        WHEN arrival_date_month IN ('March', 'April', 'May') THEN 'Spring'
        WHEN arrival_date_month IN ('June', 'July', 'August') THEN 'Summer'
        WHEN arrival_date_month IN ('September', 'October', 'November') THEN 'Autumn'
    END
ORDER BY total_revenue DESC;

--Q8: Which countries have the most bookings? 
SELECT TOP 5 country, COUNT(*) AS total_bookings
FROM CapProj
GROUP BY country
ORDER BY total_bookings DESC;

--Q9: What is the ratio of repeat customers versus new customers?
-- Approach 1: Step-by-step breakdown using conditional aggregation
-- First, count repeat and new customers, then calculate the ratio
-- Exploratory: Distribution of repeat vs new customers
SELECT 
    is_repeated_guest,
    COUNT(*) AS total_customers
FROM CapProj
GROUP BY is_repeated_guest;
SELECT 
    SUM(CASE WHEN is_repeated_guest = 1 THEN 1 ELSE 0 END) AS repeat_customers,
    SUM(CASE WHEN is_repeated_guest = 0 THEN 1 ELSE 0 END) AS new_customers,
    ROUND(
        CAST(SUM(CASE WHEN is_repeated_guest = 1 THEN 1 ELSE 0 END) AS FLOAT) /
        CAST(SUM(CASE WHEN is_repeated_guest = 0 THEN 1 ELSE 0 END) AS FLOAT), 
        2
    ) AS repeat_to_new_ratio
FROM CapProj;

-- Approach 2: Using a subquery to separate counting logic from ratio calculation
-- This improves readability and reusability of the counts
SELECT  
    repeat_customers,
    new_customers,
    ROUND(CAST(repeat_customers AS FLOAT) / new_customers, 2) AS repeat_to_new_ratio
FROM (
    SELECT  
        SUM(CASE WHEN is_repeated_guest = 1 THEN 1 ELSE 0 END) AS repeat_customers,
        SUM(CASE WHEN is_repeated_guest = 0 THEN 1 ELSE 0 END) AS new_customers
    FROM CapProj
) AS counts;

--Q10: What are the monthly trends in booking numbers?
-- Step 1: View monthly booking trends in chronological order
-- This helps identify seasonality and booking patterns over the year
SELECT 
    arrival_date_month,
    COUNT(*) AS total_bookings
FROM CapProj
GROUP BY arrival_date_month
ORDER BY 
    CASE arrival_date_month
        WHEN 'January' THEN 1  ---to show months in chronological order
        WHEN 'February' THEN 2
        WHEN 'March' THEN 3
        WHEN 'April' THEN 4
        WHEN 'May' THEN 5
        WHEN 'June' THEN 6
        WHEN 'July' THEN 7
        WHEN 'August' THEN 8
        WHEN 'September' THEN 9
        WHEN 'October' THEN 10
        WHEN 'November' THEN 11
        WHEN 'December' THEN 12
    END
	-- STEP 2: Rank months by booking volume
-- This highlights the highest and lowest performing months
	SELECT 
    arrival_date_month,
    COUNT(*) AS total_bookings
FROM CapProj
GROUP BY arrival_date_month
ORDER BY total_bookings DESC
