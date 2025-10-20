-- =========================================
-- Database Initialization Script
-- Creates separate databases for n8n and Metabase
-- =========================================

-- Create n8n database
CREATE DATABASE n8n_db;
GRANT ALL PRIVILEGES ON DATABASE n8n_db TO admin;

-- Create Metabase database
CREATE DATABASE metabase_app;
GRANT ALL PRIVILEGES ON DATABASE metabase_app TO admin;

-- Connect to main analytics database and create example schema
\c streamline_analytics_db;

-- Example: Create a schema for storing processed data
CREATE SCHEMA IF NOT EXISTS processed;
GRANT ALL ON SCHEMA processed TO admin;

-- Example: Create a logs table that n8n can write to
CREATE TABLE IF NOT EXISTS processed.workflow_logs (
    id SERIAL PRIMARY KEY,
    workflow_name VARCHAR(255),
    execution_id VARCHAR(255),
    status VARCHAR(50),
    data JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA processed TO admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA processed TO admin;

-- Print confirmation
\echo 'Database initialization complete!'
\echo 'Created databases: n8n_db, metabase_app'
\echo 'Main analytics database: streamline_analytics_db'

