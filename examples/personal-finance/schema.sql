-- Personal finance example schema.
-- Loaded into the 'analytics' database by install.sh.

CREATE SCHEMA IF NOT EXISTS finance;

CREATE TABLE IF NOT EXISTS finance.accounts (
    id              TEXT PRIMARY KEY,
    name            TEXT NOT NULL,
    institution     TEXT,
    type            TEXT,
    currency        TEXT NOT NULL DEFAULT 'USD',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS finance.transactions (
    id              TEXT PRIMARY KEY,
    account_id      TEXT NOT NULL REFERENCES finance.accounts(id) ON DELETE CASCADE,
    posted_at       TIMESTAMPTZ NOT NULL,
    amount          NUMERIC(18, 2) NOT NULL,
    currency        TEXT NOT NULL DEFAULT 'USD',
    description     TEXT,
    merchant        TEXT,
    category        TEXT,
    pending         BOOLEAN NOT NULL DEFAULT false,
    raw             JSONB,
    inserted_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_transactions_account_posted
    ON finance.transactions (account_id, posted_at DESC);

CREATE INDEX IF NOT EXISTS idx_transactions_posted
    ON finance.transactions (posted_at DESC);

CREATE INDEX IF NOT EXISTS idx_transactions_category
    ON finance.transactions (category);

CREATE TABLE IF NOT EXISTS finance.balance_snapshots (
    account_id      TEXT NOT NULL REFERENCES finance.accounts(id) ON DELETE CASCADE,
    snapshot_at     TIMESTAMPTZ NOT NULL,
    balance         NUMERIC(18, 2) NOT NULL,
    currency        TEXT NOT NULL DEFAULT 'USD',
    PRIMARY KEY (account_id, snapshot_at)
);

CREATE OR REPLACE VIEW finance.v_monthly_spending AS
SELECT
    date_trunc('month', posted_at)::date AS month,
    category,
    SUM(CASE WHEN amount < 0 THEN -amount ELSE 0 END) AS spent,
    SUM(CASE WHEN amount > 0 THEN  amount ELSE 0 END) AS received,
    COUNT(*) AS txn_count
FROM finance.transactions
WHERE pending = false
GROUP BY 1, 2
ORDER BY 1 DESC, spent DESC;
