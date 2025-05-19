-- Question_1: Count savings & investment plans and total deposits per user

-- Step 1: Create a CTE to aggregate savings, investment counts, and total deposits per user
WITH cte AS (
    SELECT 
        owner_id,
        SUM(is_regular_savings) AS savings_count,     -- Count of regular savings plans
        SUM(is_a_fund) AS investment_count,           -- Count of investment/fund plans
        SUM(amount) AS total_deposits                 -- Total amount deposited across all plans
    FROM 
        plans_plan
    GROUP BY 
        owner_id
)

-- Step 2: Join CTE with users table to get names and filter valid users
SELECT 
    c.owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,    -- Full name of the user
    c.savings_count,
    c.investment_count,
    FORMAT(c.total_deposits, 2) AS total_deposit       -- Format total deposits with 2 decimal places
FROM 
    cte c
JOIN 
    users_customuser u ON c.owner_id = u.id
WHERE 
    c.savings_count > 0        -- Include only users with savings
    AND c.investment_count > 0 -- Include only users with investments
ORDER BY 
    c.total_deposits DESC;     -- Highest total deposit first
