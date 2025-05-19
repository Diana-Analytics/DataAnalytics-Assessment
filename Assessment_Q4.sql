SELECT 
    u.id AS customer_id,  -- Unique customer identifier
    CONCAT(u.first_name, ' ', u.last_name) AS name,  -- Full name of the customer

    -- Account tenure in months since the customer signed up
    TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months,

    -- Total number of transactions made by the customer
    COUNT(s.savings_id) AS total_transactions,

    -- Estimated CLV calculation:
    -- = (total_transactions / tenure_months) * 12 * average profit per transaction
    -- where average profit = 0.1% of transaction value
    ROUND(
        (
            (COUNT(s.savings_id) / NULLIF(TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()), 0)) 
            * 12 
            * (SUM(s.amount) * 0.001 / NULLIF(COUNT(s.savings_id), 0))
        ), 
        2
    ) AS estimated_clv

FROM 
    users_customuser u

JOIN 
    savings_savingsaccount s 
    ON u.id = s.owner_id  -- Link each customer to their transactions

GROUP BY 
    u.id, 
    u.first_name, 
    u.last_name, 
    u.date_joined  -- Grouping by customer to aggregate transaction data

ORDER BY 
    estimated_clv DESC;  -- Sort to show customers with highest estimated CLV first
