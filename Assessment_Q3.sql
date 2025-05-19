-- Question_3: Identify inactive savings and investment plans with over 365 days of no transactions

-- Step 1: Set the reference date to the most recent transaction date in the dataset
SET @max_reference_date = (
    SELECT MAX(transaction_date) 
    FROM savings_savingsaccount
);

-- Step 2: CTE to get the last savings transaction per plan
WITH last_saving_txn AS (
    SELECT 
        plan_id,
        p.owner_id AS owner_id,
        MAX(transaction_date) AS last_transaction_date
    FROM 
        savings_savingsaccount s
    JOIN 
        plans_plan p ON p.id = s.plan_id
    WHERE 
        is_regular_savings = 1
    GROUP BY 
        plan_id, owner_id
),

-- Step 3: CTE to calculate savings inactivity days from last transaction to max reference date
saving_txn AS (
    SELECT 
        plan_id,
        owner_id,
        'Savings' AS type,
        CAST(last_transaction_date AS DATE) AS last_transaction_date,
        DATEDIFF(@max_reference_date, last_transaction_date) AS inactivity_days
    FROM 
        last_saving_txn
),

-- Step 4: CTE to get the last investment (fund) transaction per plan
last_invest_txn AS (
    SELECT 
        plan_id,
        p.owner_id AS owner_id,
        MAX(transaction_date) AS last_transaction_date
    FROM 
        savings_savingsaccount s
    JOIN 
        plans_plan p ON p.id = s.plan_id
    WHERE 
        is_a_fund = 1
    GROUP BY 
        plan_id, owner_id
),

-- Step 5: CTE to calculate investment inactivity days from last transaction to max reference date
invest_txn AS (
    SELECT 
        plan_id,
        owner_id,
        'Investments' AS type,
        CAST(last_transaction_date AS DATE) AS last_transaction_date,
        DATEDIFF(@max_reference_date, last_transaction_date) AS inactivity_days
    FROM 
        last_invest_txn
)

-- Step 6: Combine savings and investment plans with inactivity greater than 365 days
(
    SELECT * 
    FROM saving_txn
    WHERE inactivity_days > 365
)
UNION
(
    SELECT * 
    FROM invest_txn
    WHERE inactivity_days > 365
)
ORDER BY 
    inactivity_days DESC;
