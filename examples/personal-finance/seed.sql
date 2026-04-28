-- Personal-finance example: seed data.
--
-- Synthetic transactions across 6 months (Nov 2025 - Apr 2026), 3 fake
-- accounts, 8 categories. Balance snapshots are derived from the
-- transactions below so the trend chart reconciles.
--
-- Re-runnable. Truncates first; the install.sh wrapper guards against
-- running this on top of real data.

TRUNCATE finance.balance_snapshots, finance.transactions, finance.accounts CASCADE;

INSERT INTO finance.accounts (id, name, institution, type) VALUES
  ('acme-checking', 'Acme Checking', 'Acme Bank',    'checking'),
  ('acme-savings',  'Acme Savings',  'Acme Bank',    'savings'),
  ('demo-credit',   'Demo Rewards',  'Demo Card Co', 'credit');

INSERT INTO finance.transactions
  (id, account_id, posted_at, amount, description, merchant, category) VALUES
  -- November 2025
  ('t-2025-11-01', 'acme-checking', '2025-11-03 09:12:00+00', -86.40,  'Weekly groceries',     'Sample Grocer',     'Groceries'),
  ('t-2025-11-02', 'demo-credit',   '2025-11-04 19:30:00+00', -38.10,  'Dinner with friend',   'Demo Diner',        'Dining'),
  ('t-2025-11-03', 'acme-checking', '2025-11-05 14:00:00+00', -112.55, 'Electric bill',        'Acme Utilities',    'Utilities'),
  ('t-2025-11-04', 'demo-credit',   '2025-11-08 11:20:00+00', -9.99,   'Streaming service',    'Mock Stream Co',    'Subscriptions'),
  ('t-2025-11-05', 'acme-checking', '2025-11-10 17:45:00+00',  2750.00,'Paycheck',             'Acme Employer',     'Income'),
  ('t-2025-11-06', 'demo-credit',   '2025-11-12 18:00:00+00', -52.30,  'Lunch out',            'Demo Diner',        'Dining'),
  ('t-2025-11-07', 'demo-credit',   '2025-11-15 13:25:00+00', -41.80,  'Gas',                  'Sample Fuel',       'Transportation'),
  ('t-2025-11-08', 'demo-credit',   '2025-11-22 20:10:00+00', -78.20,  'Online order',         'Mock Marketplace',  'Shopping'),
  ('t-2025-11-09', 'acme-checking', '2025-11-24 17:45:00+00',  2750.00,'Paycheck',             'Acme Employer',     'Income'),
  ('t-2025-11-10', 'demo-credit',   '2025-11-27 21:00:00+00', -28.50,  'Concert tickets',      'Demo Entertainment','Entertainment'),
  ('t-2025-11-11', 'acme-savings',  '2025-11-30 23:00:00+00',  14.20,  'Interest credit',      'Acme Bank',         'Income'),
  ('t-2025-11-12', 'acme-checking', '2025-11-28 12:00:00+00', -248.89, 'Credit card payment',  'Demo Card Co',      'Transfer'),
  ('t-2025-11-13', 'demo-credit',   '2025-11-28 12:00:00+00',  248.89, 'Payment received',     'Demo Card Co',      'Transfer'),

  -- December 2025
  ('t-2025-12-01', 'acme-checking', '2025-12-02 08:50:00+00', -94.10,  'Weekly groceries',     'Sample Grocer',     'Groceries'),
  ('t-2025-12-02', 'demo-credit',   '2025-12-04 12:15:00+00', -22.00,  'Coffee meeting',       'Sample Coffee Co',  'Dining'),
  ('t-2025-12-03', 'acme-checking', '2025-12-06 14:00:00+00', -118.40, 'Electric bill',        'Acme Utilities',    'Utilities'),
  ('t-2025-12-04', 'demo-credit',   '2025-12-08 11:20:00+00', -9.99,   'Streaming service',    'Mock Stream Co',    'Subscriptions'),
  ('t-2025-12-05', 'acme-checking', '2025-12-10 17:45:00+00',  2750.00,'Paycheck',             'Acme Employer',     'Income'),
  ('t-2025-12-06', 'demo-credit',   '2025-12-14 19:00:00+00', -64.75,  'Holiday dinner',       'Demo Diner',        'Dining'),
  ('t-2025-12-07', 'demo-credit',   '2025-12-18 13:25:00+00', -45.30,  'Gas',                  'Sample Fuel',       'Transportation'),
  ('t-2025-12-08', 'demo-credit',   '2025-12-21 16:40:00+00', -210.00, 'Holiday gifts',        'Mock Marketplace',  'Shopping'),
  ('t-2025-12-09', 'acme-checking', '2025-12-24 17:45:00+00',  2750.00,'Paycheck',             'Acme Employer',     'Income'),
  ('t-2025-12-10', 'demo-credit',   '2025-12-30 22:00:00+00', -55.00,  'Movie night',          'Demo Entertainment','Entertainment'),
  ('t-2025-12-11', 'acme-savings',  '2025-12-31 23:00:00+00',  14.30,  'Interest credit',      'Acme Bank',         'Income'),
  ('t-2025-12-12', 'acme-checking', '2025-12-28 12:00:00+00', -407.04, 'Credit card payment',  'Demo Card Co',      'Transfer'),
  ('t-2025-12-13', 'demo-credit',   '2025-12-28 12:00:00+00',  407.04, 'Payment received',     'Demo Card Co',      'Transfer'),

  -- January 2026
  ('t-2026-01-01', 'acme-checking', '2026-01-04 09:00:00+00', -82.60,  'Weekly groceries',     'Sample Grocer',     'Groceries'),
  ('t-2026-01-02', 'demo-credit',   '2026-01-06 18:30:00+00', -36.40,  'Dinner out',           'Demo Diner',        'Dining'),
  ('t-2026-01-03', 'acme-checking', '2026-01-07 14:00:00+00', -105.20, 'Electric bill',        'Acme Utilities',    'Utilities'),
  ('t-2026-01-04', 'demo-credit',   '2026-01-08 11:20:00+00', -9.99,   'Streaming service',    'Mock Stream Co',    'Subscriptions'),
  ('t-2026-01-05', 'acme-checking', '2026-01-09 17:45:00+00',  2800.00,'Paycheck',             'Acme Employer',     'Income'),
  ('t-2026-01-06', 'demo-credit',   '2026-01-13 12:30:00+00', -18.50,  'Lunch',                'Sample Coffee Co',  'Dining'),
  ('t-2026-01-07', 'demo-credit',   '2026-01-17 13:25:00+00', -39.90,  'Gas',                  'Sample Fuel',       'Transportation'),
  ('t-2026-01-08', 'acme-checking', '2026-01-23 17:45:00+00',  2800.00,'Paycheck',             'Acme Employer',     'Income'),
  ('t-2026-01-09', 'demo-credit',   '2026-01-28 20:10:00+00', -125.00, 'New jacket',           'Mock Marketplace',  'Shopping'),
  ('t-2026-01-10', 'acme-savings',  '2026-01-31 23:00:00+00',  14.40,  'Interest credit',      'Acme Bank',         'Income'),
  ('t-2026-01-11', 'acme-checking', '2026-01-28 12:00:00+00', -229.79, 'Credit card payment',  'Demo Card Co',      'Transfer'),
  ('t-2026-01-12', 'demo-credit',   '2026-01-28 12:00:00+00',  229.79, 'Payment received',     'Demo Card Co',      'Transfer'),

  -- February 2026
  ('t-2026-02-01', 'acme-checking', '2026-02-02 09:30:00+00', -91.80,  'Weekly groceries',     'Sample Grocer',     'Groceries'),
  ('t-2026-02-02', 'demo-credit',   '2026-02-05 19:00:00+00', -48.20,  'Date night',           'Demo Diner',        'Dining'),
  ('t-2026-02-03', 'acme-checking', '2026-02-06 14:00:00+00', -98.70,  'Electric bill',        'Acme Utilities',    'Utilities'),
  ('t-2026-02-04', 'demo-credit',   '2026-02-08 11:20:00+00', -9.99,   'Streaming service',    'Mock Stream Co',    'Subscriptions'),
  ('t-2026-02-05', 'acme-checking', '2026-02-09 17:45:00+00',  2800.00,'Paycheck',             'Acme Employer',     'Income'),
  ('t-2026-02-06', 'demo-credit',   '2026-02-14 19:30:00+00', -72.00,  'Valentine dinner',     'Demo Diner',        'Dining'),
  ('t-2026-02-07', 'demo-credit',   '2026-02-19 13:25:00+00', -42.10,  'Gas',                  'Sample Fuel',       'Transportation'),
  ('t-2026-02-08', 'acme-checking', '2026-02-23 17:45:00+00',  2800.00,'Paycheck',             'Acme Employer',     'Income'),
  ('t-2026-02-09', 'demo-credit',   '2026-02-26 21:30:00+00', -34.00,  'Concert',              'Demo Entertainment','Entertainment'),
  ('t-2026-02-10', 'acme-savings',  '2026-02-28 23:00:00+00',  14.50,  'Interest credit',      'Acme Bank',         'Income'),
  ('t-2026-02-11', 'acme-checking', '2026-02-26 12:00:00+00', -206.29, 'Credit card payment',  'Demo Card Co',      'Transfer'),
  ('t-2026-02-12', 'demo-credit',   '2026-02-26 12:00:00+00',  206.29, 'Payment received',     'Demo Card Co',      'Transfer'),

  -- March 2026
  ('t-2026-03-01', 'acme-checking', '2026-03-03 09:15:00+00', -88.20,  'Weekly groceries',     'Sample Grocer',     'Groceries'),
  ('t-2026-03-02', 'demo-credit',   '2026-03-06 12:00:00+00', -24.50,  'Coffee + pastry',      'Sample Coffee Co',  'Dining'),
  ('t-2026-03-03', 'acme-checking', '2026-03-07 14:00:00+00', -89.40,  'Electric bill',        'Acme Utilities',    'Utilities'),
  ('t-2026-03-04', 'demo-credit',   '2026-03-08 11:20:00+00', -9.99,   'Streaming service',    'Mock Stream Co',    'Subscriptions'),
  ('t-2026-03-05', 'acme-checking', '2026-03-09 17:45:00+00',  2800.00,'Paycheck',             'Acme Employer',     'Income'),
  ('t-2026-03-06', 'demo-credit',   '2026-03-15 18:45:00+00', -56.30,  'Dinner out',           'Demo Diner',        'Dining'),
  ('t-2026-03-07', 'demo-credit',   '2026-03-19 13:25:00+00', -44.60,  'Gas',                  'Sample Fuel',       'Transportation'),
  ('t-2026-03-08', 'acme-checking', '2026-03-23 17:45:00+00',  2800.00,'Paycheck',             'Acme Employer',     'Income'),
  ('t-2026-03-09', 'demo-credit',   '2026-03-28 16:00:00+00', -180.00, 'Spring wardrobe',      'Mock Marketplace',  'Shopping'),
  ('t-2026-03-10', 'acme-savings',  '2026-03-31 23:00:00+00',  14.60,  'Interest credit',      'Acme Bank',         'Income'),
  ('t-2026-03-11', 'acme-checking', '2026-03-30 12:00:00+00', -315.39, 'Credit card payment',  'Demo Card Co',      'Transfer'),
  ('t-2026-03-12', 'demo-credit',   '2026-03-30 12:00:00+00',  315.39, 'Payment received',     'Demo Card Co',      'Transfer'),

  -- April 2026
  ('t-2026-04-01', 'acme-checking', '2026-04-02 09:00:00+00', -92.10,  'Weekly groceries',     'Sample Grocer',     'Groceries'),
  ('t-2026-04-02', 'demo-credit',   '2026-04-05 19:15:00+00', -41.20,  'Dinner out',           'Demo Diner',        'Dining'),
  ('t-2026-04-03', 'acme-checking', '2026-04-07 14:00:00+00', -84.90,  'Electric bill',        'Acme Utilities',    'Utilities'),
  ('t-2026-04-04', 'demo-credit',   '2026-04-08 11:20:00+00', -9.99,   'Streaming service',    'Mock Stream Co',    'Subscriptions'),
  ('t-2026-04-05', 'acme-checking', '2026-04-09 17:45:00+00',  2800.00,'Paycheck',             'Acme Employer',     'Income'),
  ('t-2026-04-06', 'demo-credit',   '2026-04-13 12:30:00+00', -19.80,  'Lunch',                'Sample Coffee Co',  'Dining'),
  ('t-2026-04-07', 'demo-credit',   '2026-04-18 13:25:00+00', -43.20,  'Gas',                  'Sample Fuel',       'Transportation'),
  ('t-2026-04-08', 'acme-checking', '2026-04-23 17:45:00+00',  2800.00,'Paycheck',             'Acme Employer',     'Income'),
  ('t-2026-04-09', 'demo-credit',   '2026-04-24 20:00:00+00', -62.00,  'Movie + dinner',       'Demo Entertainment','Entertainment'),
  ('t-2026-04-10', 'acme-savings',  '2026-04-30 23:00:00+00',  14.70,  'Interest credit',      'Acme Bank',         'Income');

-- Balance snapshots derived from the transactions above. Starting balances
-- (Nov 1 2025) are 4500 / 12000 / 0; each month-end snapshot is the
-- starting balance plus all transactions on that account through that
-- timestamp. acme-savings stays roughly flat (only interest credits).
INSERT INTO finance.balance_snapshots (account_id, snapshot_at, balance)
WITH starts (account_id, balance) AS (VALUES
    ('acme-checking', 4500.00::numeric),
    ('acme-savings', 12000.00::numeric),
    ('demo-credit',     0.00::numeric)),
month_ends (snapshot_at) AS (VALUES
    ('2025-11-30 23:59:59+00'::timestamptz),
    ('2025-12-31 23:59:59+00'::timestamptz),
    ('2026-01-31 23:59:59+00'::timestamptz),
    ('2026-02-28 23:59:59+00'::timestamptz),
    ('2026-03-31 23:59:59+00'::timestamptz),
    ('2026-04-30 23:59:59+00'::timestamptz))
SELECT
    s.account_id,
    m.snapshot_at,
    s.balance + COALESCE((
        SELECT SUM(t.amount)
        FROM finance.transactions t
        WHERE t.account_id = s.account_id
          AND t.posted_at <= m.snapshot_at
    ), 0)::numeric(18, 2)
FROM starts s
CROSS JOIN month_ends m;
