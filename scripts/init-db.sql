-- =========================================
-- Database Initialization Script
-- Creates application databases for the analytics stack
-- =========================================

-- Application databases. CREATE DATABASE makes the connecting role
-- (POSTGRES_USER, whatever the operator set) the owner, so no explicit
-- GRANTs are needed — and hardcoding a role name here would silently
-- fail for anyone who set POSTGRES_USER to something other than admin.
CREATE DATABASE n8n;
CREATE DATABASE metabase;
CREATE DATABASE prefect;

-- Switch to the main analytics database and add a utility schema.
\c analytics;
CREATE SCHEMA IF NOT EXISTS data;

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
