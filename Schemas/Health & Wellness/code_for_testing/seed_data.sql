INSERT INTO permissions (name, description) VALUES ('appointments.read', 'Read appointments'), ('records.manage', 'Manage health records');

INSERT INTO plans (name, description, price, features, billing_cycle) VALUES ('Wellness Basic', 'Basic health tracking', 9.99, '["unlimited records", "appointments"]', 'monthly');

INSERT INTO tenants (name, domain) VALUES ('Test Wellness', 'wellness.example.com');

INSERT INTO roles (tenant_id, name, description) VALUES (NULL, 'Super Admin', 'Global admin'), (1, 'Provider', 'Health provider');

INSERT INTO users (tenant_id, email, password_hash, first_name, last_name, consent_given_at, consent_version) VALUES (1, 'provider@test.com', 'hashed', 'Provider', 'User', CURRENT_TIMESTAMP, 'v1');

INSERT INTO branding_settings (tenant_id, logo_url, colors) VALUES (1, 'https://logo.url', '{"primary": "#green"}');

INSERT INTO subscriptions (tenant_id, plan_id, status, start_date) VALUES (1, 1, 'active', CURDATE());

INSERT INTO role_permissions (role_id, permission_id) VALUES (1, 1), (1, 2);

INSERT INTO user_roles (user_id, role_id) VALUES (1, 1);

INSERT INTO members (tenant_id, first_name, last_name, status) VALUES (1, 'Member', 'One', 'active');

INSERT INTO providers (tenant_id, user_id, status) VALUES (1, 1, 'active');

INSERT INTO appointments (tenant_id, member_id, provider_id, appointment_time, duration, status) VALUES (1, 1, 1, CURRENT_TIMESTAMP, 30, 'booked');

INSERT INTO health_records (tenant_id, member_id, record_date, data, status) VALUES (1, 1, CURDATE(), '{"weight": 70}', 'verified');

INSERT INTO wellness_programs (tenant_id, member_id, name, start_date, status) VALUES (1, 1, 'Fitness Plan', CURDATE(), 'ongoing');

INSERT INTO audit_logs (tenant_id, user_id, action, entity, entity_id, changes) VALUES (1, 1, 'create', 'appointments', 1, '{"old": null, "new": {"status": "booked"}}');