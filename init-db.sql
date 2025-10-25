-- =========================================
-- Database Initialization Script
-- Creates application databases for the analytics stack
-- =========================================

-- Create n8n workflow automation database
CREATE DATABASE n8n;
GRANT ALL PRIVILEGES ON DATABASE n8n TO admin;

-- Create Metabase analytics app database
CREATE DATABASE metabase;
GRANT ALL PRIVILEGES ON DATABASE metabase TO admin;

-- Create Prefect workflow orchestration database
CREATE DATABASE prefect;
GRANT ALL PRIVILEGES ON DATABASE prefect TO admin;

-- Connect to main analytics database
\c analytics;

-- Create schema for storing processed/transformed data
CREATE SCHEMA IF NOT EXISTS data;
GRANT ALL ON SCHEMA data TO admin;

-- Example: Create a logs table for workflow execution logs
CREATE TABLE IF NOT EXISTS data.workflow_logs (
    id SERIAL PRIMARY KEY,
    workflow_name VARCHAR(255),
    workflow_type VARCHAR(50),  -- 'n8n', 'prefect', etc.
    execution_id VARCHAR(255),
    status VARCHAR(50),
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA data TO admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA data TO admin;

-- Print confirmation
\echo '========================================';
\echo 'Database initialization complete!';
\echo '========================================';
\echo 'Created databases:';
\echo '  - analytics (main data database)';
\echo '  - n8n (workflow automation)';
\echo '  - metabase (analytics & BI)';
\echo '  - prefect (workflow orchestration)';
\echo '========================================';
