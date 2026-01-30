INSERT INTO permissions (name, description) VALUES ('projects.read', 'Read projects'), ('tasks.manage', 'Manage tasks');

INSERT INTO plans (name, description, price, features, billing_cycle) VALUES ('Construction Basic', 'Basic project tracking', 49.99, '["10 projects", "basic Gantt"]', 'monthly');

INSERT INTO tenants (name, domain) VALUES ('Test Construction', 'construct.example.com');

INSERT INTO roles (tenant_id, name, description) VALUES (NULL, 'Super Admin', 'Global admin'), (1, 'Project Manager', 'Manage projects');

INSERT INTO users (tenant_id, email, password_hash, first_name, last_name, consent_given_at, consent_version) VALUES (1, 'pm@test.com', 'hashed', 'Project', 'Manager', CURRENT_TIMESTAMP, 'v1');

INSERT INTO branding_settings (tenant_id, logo_url, colors) VALUES (1, 'https://logo.url', '{"primary": "#orange"}');

INSERT INTO subscriptions (tenant_id, plan_id, status, start_date) VALUES (1, 1, 'active', CURDATE());

INSERT INTO role_permissions (role_id, permission_id) VALUES (1, 1), (1, 2);

INSERT INTO user_roles (user_id, role_id) VALUES (1, 1);

INSERT INTO projects (tenant_id, assigned_user_id, name, start_date, budget, status) VALUES (1, 1, 'Building A', CURDATE(), 100000, 'planning');

INSERT INTO tasks (tenant_id, project_id, assigned_user_id, name, start_date, due_date, status) VALUES (1, 1, 1, 'Foundation', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 10 DAY), 'todo');

INSERT INTO resources (tenant_id, name, quantity, status) VALUES (1, 'Cement', 500, 'available');

INSERT INTO change_orders (tenant_id, project_id, description, budget_impact, status) VALUES (1, 1, 'Add extra floor', 20000, 'pending');

INSERT INTO audit_logs (tenant_id, user_id, action, entity, entity_id, changes) VALUES (1, 1, 'create', 'projects', 1, '{"old": null, "new": {"name": "Building A"}}');