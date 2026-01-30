-- Add column for project location
ALTER TABLE projects ADD COLUMN location JSON COMMENT 'JSON for location details' AFTER specs;

-- Add index if needed
ALTER TABLE tasks ADD KEY idx_due_date (due_date);

-- For updates: Add CHECK
ALTER TABLE resources ADD CONSTRAINT chk_quantity CHECK (quantity >= 0);

-- Remove partitioning if unsupported
ALTER TABLE users REBUILD PARTITION ALL;
ALTER TABLE projects REBUILD PARTITION ALL;
ALTER TABLE tasks REBUILD PARTITION ALL;
ALTER TABLE audit_logs REBUILD PARTITION ALL;