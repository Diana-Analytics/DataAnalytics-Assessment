# DataAnalytics-Assessment
# Question_1 (User Savings & Investment Summary Query)

## Objective

The goal of this SQL query is to **analyze customer savings and investment activity**, providing a breakdown of:
- The number of savings plans
- The number of investment (fund) plans
- The total amount deposited

This summary is done **per user**, including only those who are **actively engaged in both savings and investments**.

---

## 🛠 Approach

### 1. **CTE (Common Table Expression) for Aggregation**
We start by creating a CTE to:
- Count how many savings and investment plans each user has.
- Sum the total deposits across all plans.

```sql
WITH cte AS (
    SELECT 
        owner_id,
        SUM(is_regular_savings) AS savings_count,
        SUM(is_a_fund) AS investment_count,
        SUM(amount) AS total_deposits
    FROM plans_plan
    GROUP BY owner_id
)
```
### Challenges
- Boolean Aggregation
MySQL doesn't have a native boolean type — so SUM(is_regular_savings) and SUM(is_a_fund) rely on the assumption that these fields are stored as 0 and 1. This approach works well, but would fail if the fields contain unexpected non-numeric values.

- Formatting Currency
The use of FORMAT() is good for display purposes (e.g., in reports), but not ideal if you're exporting this data for further numeric processing. Consider omitting formatting when performing calculations downstream.

- Data Quality
The query assumes that every plan has a valid amount value and is tied to a real user. In a production environment, we'd want to validate or filter out:

NULL or negative amount values

orphan plans with no matching user

### Output
The final result includes:

- owner_id: Unique ID of the user

- name: Full name (first + last)

- savings_count: Number of regular savings plans

- investment_count: Number of investment plans

- total_deposit: Total value of all deposits, formatted to 2 decimal places

- Users are sorted by total deposit in descending order, highlighting top contributors.


# Question_2 (Transaction_Frequency_Analysis)
###  Approach

1. **Monthly Transaction Count**  
   First, I grouped transactions by `owner_id` and formatted the `transaction_date` to `'%Y-%m'` to get monthly buckets.

2. **Average per Customer**  
   Then I calculated the average number of transactions per customer across all active months.

3. **Categorization**  
   I initially followed the stated ranges (≥10, 3–9, ≤2), but realized that using hard-coded numeric boundaries like `3–9` or `≤2` can leave out fractional values like 2.4 or 9.5 — leading to uncategorized data.  
   To fix this, I rewrote the logic as:

   ```sql
   CASE
     WHEN avg_txn_per_month >= 10 THEN 'High Frequency'
     WHEN avg_txn_per_month < 3 THEN 'Low Frequency'
     ELSE 'Medium Frequency'
   END AS freq_category
This approach ensures complete coverage with no gaps between categories.

### Final Output
Finally, I grouped by frequency category to count how many customers fall into each group and calculated the overall average transactions per month per group.

### Challenges
Date Formatting in MySQL
My initial query used an alias (year_month) directly inside GROUP BY, which caused a syntax error in MySQL. I fixed this by repeating the full expression DATE_FORMAT(transaction_date, '%Y-%m') in the GROUP BY clause.

WITH Clause Compatibility
I made sure the query structure works well with MySQL’s handling of CTEs, especially regarding column aliasing.

Categorization Edge Cases
The original category ranges didn't account for decimal averages like 2.4 or 9.6. These values would have been skipped unintentionally. Updating the CASE logic to use < 3, >= 10, and ELSE fixed this issue by ensuring all possible values are included in the analysis.

- The final query satisfies the requirement for producing an aggregated and categorized frequency report based on average monthly transactions per customer, with robust handling of all edge cases.

# Question_3 (Identifying Inactive Savings and Investment Plans )

##  Objective

The goal of this analysis is to **identify savings and investment plans that have been inactive for over 365 days** based on user transaction activity. This is valuable for spotting dormant accounts, initiating re-engagement efforts, and ensuring compliance with financial activity regulations.

---

## 🔍 Approach

The logic is broken down into a series of structured steps using CTEs (Common Table Expressions) to maintain clarity and reusability.

### 1. Establishing a Reference Point
We begin by identifying the most recent transaction date in the entire dataset. This becomes our **anchor point** for measuring inactivity across all plans.

### 2. Isolating Last Transactions by Plan Type
Two separate pathways are taken:
- **Savings Plans:** For plans marked as regular savings, we extract the most recent transaction date per plan and user.
- **Investment Plans:** Similarly, for plans marked as investment funds, we determine their most recent transaction.

This distinction ensures we don’t treat different financial products the same way, as their engagement patterns might differ.

### 3. Calculating Inactivity Duration
For both savings and investments, we compute the number of days between the last transaction and the reference date. This gives us a clean metric (`inactivity_days`) to assess dormancy.

### 4. Filtering Dormant Plans
We then filter out only those records where inactivity exceeds 365 days — i.e., **over a full year of no activity** — and combine both sets into a unified result.

### 5. Final Sorting
To highlight the most concerning cases first, the result is sorted in descending order of inactivity duration.

---

## ⚠️ Challenges Faced

### ⏱ Variable Handling
MySQL requires the use of user-defined variables (e.g., `@max_reference_date`) outside of CTEs. This adds a small but necessary step before initiating the main logic. It's important to manage this variable cleanly and ensure it's set before any dependent logic is run.

### 🔁 Plan Overlap
A single plan could theoretically be flagged as both a savings and an investment plan (if both indicators are set). This can cause duplicate entries in the final result if not carefully handled or deduplicated downstream.

### 📉 Data Gaps
The reliability of this analysis assumes:
- All plans have at least one transaction logged.
- No missing or null `transaction_date` values.
If these assumptions don’t hold, some plans might be incorrectly excluded or misrepresented.

### ⚖️ Business Interpretation
365 days as the cutoff is arbitrary and may need to be flexible based on:
- The nature of the product (e.g., fixed-term investments may naturally be inactive).
- Regulatory or internal definitions of dormancy.

---

## 🧾 Outcome

The final output provides a consolidated view of:
- Which users have dormant financial plans.
- How long each plan has been inactive.
- Whether it's a savings or investment product.

This is a foundational step toward building automated alerts, user nudges, or compliance workflows.

---

## 📌 Suggested Next Steps

- Integrate this logic into scheduled reporting dashboards.
- Enhance the logic to include plan names or balances.
- Consider adding inactivity categories (e.g., 1–2 years, 2–5 years, etc.) for more granularity.



