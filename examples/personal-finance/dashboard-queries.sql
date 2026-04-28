-- Dashboard queries for the personal-finance example.
--
-- Four Native Questions for Metabase. See examples/personal-finance/README.md
-- for the recreation walkthrough.


-- 1. Monthly spending (bar chart)
SELECT
    date_trunc('month', posted_at)::date AS month,
    SUM(-amount) AS spent
FROM finance.transactions
WHERE pending = false
  AND amount < 0
  AND category <> 'Transfer'
GROUP BY 1
ORDER BY 1;


-- 2. Top categories, last 90 days (pie or row chart)
-- Anchored to the latest transaction so it works against fixed seed data
-- as well as a live pipeline.
SELECT
    category,
    SUM(-amount) AS spent
FROM finance.transactions
WHERE pending = false
  AND amount < 0
  AND category <> 'Transfer'
  AND posted_at >= (SELECT MAX(posted_at) FROM finance.transactions) - interval '90 days'
GROUP BY 1
ORDER BY spent DESC;


-- 3. Recent transactions (table)
SELECT
    posted_at::date AS day,
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
    snapshot_at::date AS day,
    a.name AS account,
    balance
FROM finance.balance_snapshots b
JOIN finance.accounts a ON a.id = b.account_id
ORDER BY snapshot_at, a.name;
