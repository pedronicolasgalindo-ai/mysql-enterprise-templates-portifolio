-- Add column for appointment type
ALTER TABLE appointments ADD COLUMN type VARCHAR(50) COMMENT 'Type (e.g., "consultation")' AFTER status;

-- Add index if needed
ALTER TABLE health_records ADD KEY idx_record_date (record_date);

-- For updates: Add CHECK
ALTER TABLE appointments ADD CONSTRAINT chk_duration CHECK (duration > 0);

-- Remove partitioning if unsupported
ALTER TABLE users REBUILD PARTITION ALL;
ALTER TABLE members REBUILD PARTITION ALL;
ALTER TABLE appointments REBUILD PARTITION ALL;
ALTER TABLE health_records REBUILD PARTITION ALL;
ALTER TABLE audit_logs REBUILD PARTITION ALL;