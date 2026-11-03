
CREATE TABLE telecom_customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    gender VARCHAR(20),
    age INTEGER,
    married VARCHAR(10),
    number_of_dependents INTEGER,
    city TEXT,
    zip_code VARCHAR(10),
    latitude NUMERIC(10,6),
    longitude NUMERIC(10,6),
    number_of_referrals INTEGER,
    tenure_in_months INTEGER,
    offer VARCHAR(30),
    phone_service VARCHAR(10),
    avg_monthly_long_distance_charges NUMERIC(12,2),
    multiple_lines VARCHAR(20),
    internet_service VARCHAR(10),
    internet_type VARCHAR(30),
    avg_monthly_gb_download NUMERIC(12,2),
    online_security VARCHAR(20),
    online_backup VARCHAR(20),
    device_protection_plan VARCHAR(20),
    premium_tech_support VARCHAR(20),
    streaming_tv VARCHAR(20),
    streaming_movies VARCHAR(20),
    streaming_music VARCHAR(20),
    unlimited_data VARCHAR(20),
    contract VARCHAR(30),
    paperless_billing VARCHAR(10),
    payment_method VARCHAR(60),
    monthly_charge NUMERIC(12,2),
    total_charges NUMERIC(14,2),
    total_refunds NUMERIC(12,2),
    total_extra_data_charges NUMERIC(12,2),
    total_long_distance_charges NUMERIC(12,2),
    total_revenue NUMERIC(14,2),
    customer_status VARCHAR(20),
    churn_category VARCHAR(60),
    churn_reason TEXT
);
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public';

SELECT COUNT(*) AS total_customers
FROM telecom_customers;
-- ==========================================
-- QUESTION 1: CUSTOMER STATUS DISTRIBUTION
-- ==========================================
-- Business Question:
-- How many customers Stayed, Churned, or Joined?
SELECT customer_status, COUNT(*) AS total_customers
FROM telecom_customers
GROUP BY customer_status
ORDER BY total_customers DESC;


-- ==========================================
-- QUESTION 2: OVERALL CUSTOMER CHURN RATE
-- ==========================================
-- Business Question:
-- What is the overall customer churn rate?
SELECT COUNT(*) AS total_existing_customers,
COUNT(*) FILTER (WHERE customer_status = 'Churned') AS churned_customers,
ROUND(100.0 * COUNT(*) FILTER (WHERE customer_status = 'Churned') / COUNT(*), 2) AS churn_rate_percentage
FROM telecom_customers
WHERE customer_status IN ('Stayed', 'Churned');

-- ==========================================
-- QUESTION 3: CONTRACT-WISE CHURN ANALYSIS
-- ==========================================
-- Business Question:
-- Which contract type has the highest churn rate?
SELECT contract, COUNT(*) AS total_customers,
COUNT(*) FILTER (WHERE customer_status = 'Churned') AS churned_customers,
ROUND(100.0 * COUNT(*) FILTER (WHERE customer_status = 'Churned') / COUNT(*), 2) AS churn_rate
FROM telecom_customers
WHERE customer_status IN ('Stayed', 'Churned')
GROUP BY contract
ORDER BY churn_rate DESC;


-- ==========================================
-- QUESTION 4: TENURE GROUP-WISE CHURN
-- ==========================================
-- Business Question:
-- How does customer tenure affect churn?
SELECT CASE
    WHEN tenure_in_months <= 6 THEN '0-6 Months'
    WHEN tenure_in_months <= 12 THEN '7-12 Months'
    WHEN tenure_in_months <= 24 THEN '13-24 Months'
    WHEN tenure_in_months <= 48 THEN '25-48 Months'
    ELSE '49-72 Months'
END AS tenure_group,
COUNT(*) AS total_customers,
COUNT(*) FILTER (WHERE customer_status = 'Churned') AS churned_customers,
ROUND(100.0 * COUNT(*) FILTER (WHERE customer_status = 'Churned') / COUNT(*), 2) AS churn_rate
FROM telecom_customers
WHERE customer_status IN ('Stayed', 'Churned')
GROUP BY tenure_group
ORDER BY MIN(tenure_in_months);


-- ==========================================
-- QUESTION 5: PAYMENT METHOD-WISE CHURN
-- ==========================================
-- Business Question:
-- Which payment method has the highest churn rate?
SELECT payment_method, COUNT(*) AS total_customers,
COUNT(*) FILTER (WHERE customer_status = 'Churned') AS churned_customers,
ROUND(100.0 * COUNT(*) FILTER (WHERE customer_status = 'Churned') / COUNT(*), 2) AS churn_rate
FROM telecom_customers
WHERE customer_status IN ('Stayed', 'Churned')
GROUP BY payment_method
ORDER BY churn_rate DESC;


-- ==========================================
-- QUESTION 6: TOP 10 CHURN REASONS
-- ==========================================
-- Business Question:
-- What are the top 10 reasons for customer churn?
SELECT churn_reason, COUNT(*) AS total_customers,
ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM telecom_customers WHERE customer_status = 'Churned'), 2) AS percentage_of_churned
FROM telecom_customers
WHERE customer_status = 'Churned'
GROUP BY churn_reason
ORDER BY total_customers DESC
LIMIT 10;


-- ==========================================
-- QUESTION 7: REVENUE ANALYSIS
-- =========================================

-- Business Objective:
-- Compare revenue contribution of Stayed and Churned customers.
-- Analyse average monthly charges and average total revenue.
-- Identify which customer segment contributes more revenue.

SELECT customer_status, COUNT(*) AS total_customers,
ROUND(AVG(monthly_charge), 2) AS avg_monthly_charge,
ROUND(AVG(total_revenue), 2) AS avg_total_revenue,
ROUND(SUM(total_revenue), 2) AS total_revenue
FROM telecom_customers
WHERE customer_status IN ('Stayed', 'Churned')
GROUP BY customer_status
ORDER BY total_revenue DESC;


-- ==========================================
-- QUESTION 8: INTERNET TYPE VS CHURN
-- ==========================================

-- Business Objective:
-- Compare customer churn across different internet types.
-- Identify internet services with high churn rates.
-- Find which internet segment needs retention improvement.
SELECT internet_type, COUNT(*) AS total_customers,
COUNT(*) FILTER (WHERE customer_status = 'Churned') AS churned_customers,
ROUND(100.0 * COUNT(*) FILTER (WHERE customer_status = 'Churned') / COUNT(*), 2) AS churn_rate
FROM telecom_customers
WHERE customer_status IN ('Stayed', 'Churned') AND internet_service = 'Yes'
GROUP BY internet_type
ORDER BY churn_rate DESC;


-- ==========================================
-- QUESTION 9: AGE GROUP VS CUSTOMER CHURN
-- ==========================================

-- Business Objective:
-- Analyse customer churn across different age groups.
-- Identify high-risk age segments.
-- Recommend targeted customer retention strategies.

SELECT CASE
    WHEN age BETWEEN 18 AND 25 THEN '18-25'
    WHEN age BETWEEN 26 AND 35 THEN '26-35'
    WHEN age BETWEEN 36 AND 45 THEN '36-45'
    WHEN age BETWEEN 46 AND 55 THEN '46-55'
    ELSE '56+'
END AS age_group,
COUNT(*) AS total_customers,
COUNT(*) FILTER (WHERE customer_status = 'Churned') AS churned_customers,
ROUND(100.0 * COUNT(*) FILTER (WHERE customer_status = 'Churned') / COUNT(*), 2) AS churn_rate
FROM telecom_customers
WHERE customer_status IN ('Stayed', 'Churned')
GROUP BY age_group
ORDER BY MIN(age);

-- ==========================================
-- QUESTION 10: GENDER VS CUSTOMER CHURN
-- ==========================================

-- Business Objective:
-- Compare churn rates between male and female customers.
-- Identify differences in customer retention.
-- Understand whether gender is associated with churn behaviour.
SELECT gender, COUNT(*) AS total_customers,
COUNT(*) FILTER (WHERE customer_status = 'Churned') AS churned_customers,
ROUND(100.0 * COUNT(*) FILTER (WHERE customer_status = 'Churned') / COUNT(*), 2) AS churn_rate
FROM telecom_customers
WHERE customer_status IN ('Stayed', 'Churned')
GROUP BY gender
ORDER BY churn_rate DESC;

