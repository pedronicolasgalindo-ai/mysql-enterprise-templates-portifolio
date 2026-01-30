-- Open matters by client
SELECT m.*, c.name AS client_name FROM matters m JOIN clients c ON m.client_id = c.id WHERE m.tenant_id = 1 AND m.status = 'open' AND m.deleted_at IS NULL;

-- Documents for a matter
SELECT * FROM documents WHERE matter_id = 1 AND status = 'approved' AND deleted_at IS NULL;

-- Overdue compliance tasks
SELECT * FROM compliance_tasks WHERE tenant_id = 1 AND due_date < CURDATE() AND status = 'pending' AND deleted_at IS NULL;

-- Assigned matters for a user
SELECT m.* FROM matters m WHERE assigned_user_id = 1 AND deleted_at IS NULL;

-- Compliance: Users requesting erasure
SELECT * FROM users WHERE erase_requested_at IS NOT NULL;