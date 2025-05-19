---Question 2

-- Step 1: Get monthly transaction count per customer
WITH txn_per_month AS (
    SELECT 
        owner_id,
        DATE_FORMAT(transaction_date, '%Y-%m') AS txn_month,      -- Extract year and month from transaction date
        COUNT(transaction_reference) AS monthly_txn_count         -- Count transactions per customer per month
    FROM savings_savingsaccount
    GROUP BY 
        owner_id, 
        DATE_FORMAT(transaction_date, '%Y-%m')
),

-- Step 2: Compute average transactions per customer across all months
avg_txn AS (
    SELECT 
        owner_id,
        AVG(monthly_txn_count) AS avg_txn_per_month               -- Average number of monthly transactions per customer
    FROM txn_per_month
    GROUP BY owner_id
),

-- Step 3: Categorize each customer based on average transactions
cte3 AS (
    SELECT 
        owner_id,
        avg_txn_per_month,
        CASE 
            WHEN avg_txn_per_month >= 10 THEN 'High Frequency'
            WHEN avg_txn_per_month < 3 THEN 'Low Frequency'
            ELSE 'Medium Frequency'
        END AS frequency_category                                 -- Ensure full coverage of all average values
    FROM avg_txn
)

-- Step 4: Final aggregation by frequency category
SELECT 
    frequency_category,
    COUNT(owner_id) AS customer_count,                            -- Total customers in each frequency category
    ROUND(AVG(avg_txn_per_month), 1) AS avg_transactions_per_month -- Average transactions in each category
FROM cte3
GROUP BY frequency_category;
