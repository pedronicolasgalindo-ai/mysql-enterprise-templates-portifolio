INSERT INTO permissions (name, description) VALUES ('matters.read', 'Read legal matters'), ('documents.manage', 'Manage documents');

INSERT INTO plans (name, description, price, features, billing_cycle) VALUES ('Legal Basic', 'Basic compliance tools', 49.99, '["50 matters", "document storage"]', 'monthly');

INSERT INTO tenants (name, domain) VALUES ('Test Legal', 'legal.example.com');

INSERT INTO roles (tenant_id, name, description) VALUES (NULL, 'Super Admin', 'Global admin'), (1, 'Lawyer', 'Handle cases');

INSERT INTO users (tenant_id, email, password_hash, first_name, last_name, consent_given_at, consent_version) VALUES (1, 'lawyer@test.com', 'hashed', 'Law', 'Yer', CURRENT_TIMESTAMP, 'v1');

INSERT INTO branding_settings (tenant_id, logo_url, colors) VALUES (1, 'https://logo.url', '{"primary": "#black"}');

INSERT INTO subscriptions (tenant_id, plan_id, status, start_date) VALUES (1, 1, 'active', CURDATE());

INSERT INTO role_permissions (role_id, permission_id) VALUES (1, 1), (1, 2);

INSERT INTO user_roles (user_id, role_id) VALUES (1, 1);

INSERT INTO clients (tenant_id, name, type) VALUES (1, 'Client A', 'corporate');

INSERT INTO matters (tenant_id, client_id, assigned_user_id, type, status) VALUES (1, 1, 1, 'litigation', 'open');

INSERT INTO documents (tenant_id, matter_id, name, status) VALUES (1, 1, 'Contract.pdf', 'approved');

INSERT INTO compliance_tasks (tenant_id, matter_id, assigned_user_id, description, due_date, status) VALUES (1, 1, 1, 'Annual audit', DATE_ADD(CURDATE(), INTERVAL 30 DAY), 'pending');

INSERT INTO audit_logs (tenant_id, user_id, action, entity, entity_id, changes) VALUES (1, 1, 'create', 'matters', 1, '{"old": null, "new": {"type": "litigation"}}');