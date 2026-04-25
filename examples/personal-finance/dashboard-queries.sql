-- Dashboard queries for the personal-finance example.
--
-- These four queries power the "Finance Overview" Metabase dashboard
-- shown in docs/screenshots/finance-dashboard.png. Each one is meant
-- to be pasted as its own Native (SQL) Question in Metabase. See
-- README.md in this directory for the full walkthrough.


-- 1. Monthly spending (bar chart)
-- Spend by month, excluding income and pending transactions.
SELECT
    date_trunc('month', posted_at)::date AS month,
    SUM(-amount) AS spent
FROM finance.transactions
WHERE pending = false
  AND amount < 0
GROUP BY 1
ORDER BY 1;


-- 2. Top categories, last 90 days (pie or row chart)
SELECT
    category,
    SUM(-amount) AS spent
FROM finance.transactions
WHERE pending = false
  AND amount < 0
  AND posted_at >= now() - interval '90 days'
GROUP BY 1
ORDER BY spent DESC;


-- 3. Recent transactions (table)
SELECT
    posted_at::date AS date,
    merchant,
    category,
    amount,
    a.name AS account
FROM finance.transactions t
JOIN finance.accounts a ON a.id = t.account_id
WHERE pending = false
ORDER BY posted_at DESC
LIMIT 25;


-- 4. Balance trend by account (line chart)
SELECT
    snapshot_at::date AS date,
    a.name AS account,
    balance
FROM finance.balance_snapshots b
JOIN finance.accounts a ON a.id = b.account_id
ORDER BY snapshot_at, a.name;
