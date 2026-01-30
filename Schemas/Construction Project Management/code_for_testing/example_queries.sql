-- Active projects with tasks count
SELECT p.*, COUNT(t.id) AS task_count FROM projects p LEFT JOIN tasks t ON p.id = t.project_id WHERE p.tenant_id = 1 AND p.status = 'planning' AND p.deleted_at IS NULL GROUP BY p.id;

-- Overdue tasks
SELECT t.*, p.name AS project_name FROM tasks t JOIN projects p ON t.project_id = p.id WHERE t.tenant_id = 1 AND t.due_date < CURDATE() AND t.status != 'done' AND t.deleted_at IS NULL;

-- Low resources
SELECT * FROM resources WHERE tenant_id = 1 AND quantity < low_threshold AND deleted_at IS NULL;

-- Change orders for a project
SELECT * FROM change_orders WHERE project_id = 1 AND status = 'pending' AND deleted_at IS NULL;

-- Compliance: Users requesting erasure
SELECT * FROM users WHERE erase_requested_at IS NOT NULL;