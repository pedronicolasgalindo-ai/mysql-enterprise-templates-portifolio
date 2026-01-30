-- Add column for matter deadline
ALTER TABLE matters ADD COLUMN deadline DATE COMMENT 'Matter deadline' AFTER status;

-- Add index if needed
ALTER TABLE compliance_tasks ADD KEY idx_assigned_user (assigned_user_id);

-- For updates: Add CHECK
ALTER TABLE documents ADD CONSTRAINT chk_version CHECK (version > 0);

-- Remove partitioning if unsupported
ALTER TABLE users REBUILD PARTITION ALL;
ALTER TABLE matters REBUILD PARTITION ALL;
ALTER TABLE documents REBUILD PARTITION ALL;
ALTER TABLE audit_logs REBUILD PARTITION ALL;