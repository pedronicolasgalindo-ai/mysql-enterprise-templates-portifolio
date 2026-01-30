-- Niche: Legal & Compliance
CREATE DATABASE IF NOT EXISTS legal_compliance_db
DEFAULT CHARSET=utf8mb4
COLLATE utf8mb4_unicode_ci;

USE legal_compliance_db;

-- Table: permissions
-- Description: Defines granular system permissions.
CREATE TABLE permissions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique identifier for the permission',
    name VARCHAR(100) NOT NULL UNIQUE COMMENT 'Permission name (e.g., "users.read")',
    description TEXT COMMENT 'Description of the permission',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was created',
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was last updated',
    deleted_at TIMESTAMP NULL COMMENT 'Timestamp for soft delete'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: plans
-- Description: Subscription plans with flexible features in JSON.
CREATE TABLE plans (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique identifier for the plan',
    name VARCHAR(100) NOT NULL COMMENT 'Plan name (e.g., "Basic")',
    description TEXT COMMENT 'Plan description',
    price DECIMAL(10,2) NOT NULL COMMENT 'Monthly price',
    features JSON COMMENT 'JSON array of features (e.g., ["10 users", "basic support"])',
    billing_cycle VARCHAR(20) NOT NULL COMMENT 'Billing cycle (e.g., "monthly", "yearly")',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was created',
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was last updated',
    deleted_at TIMESTAMP NULL COMMENT 'Timestamp for soft delete',
    CHECK (price >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: tenants
-- Description: Multi-tenant core table with white-label domain support and compliance fields.
CREATE TABLE tenants (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique identifier for the tenant',
    name VARCHAR(255) NOT NULL COMMENT 'Tenant name',
    domain VARCHAR(255) NOT NULL UNIQUE COMMENT 'Custom domain for white-label (e.g., "tenant.example.com")',
    settings JSON COMMENT 'Flexible JSON settings for tenant-specific configurations',
    data_retention_period INT DEFAULT 365 COMMENT 'Data retention period in days for GDPR/LGPD compliance',
    erase_requested_at TIMESTAMP NULL COMMENT 'Timestamp when data erasure was requested (GDPR Art. 17)',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was created',
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was last updated',
    deleted_at TIMESTAMP NULL COMMENT 'Timestamp for soft delete'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: branding_settings
-- Description: Per-tenant branding for white-label customization.
CREATE TABLE branding_settings (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique identifier for branding settings',
    tenant_id BIGINT UNSIGNED NOT NULL COMMENT 'Reference to tenant',
    logo_url VARCHAR(255) COMMENT 'URL to logo image',
    colors JSON COMMENT 'JSON object for color scheme (e.g., {"primary": "# hex"})',
    fonts JSON COMMENT 'JSON object for font settings',
    custom_css TEXT COMMENT 'Custom CSS overrides',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was created',
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was last updated',
    deleted_at TIMESTAMP NULL COMMENT 'Timestamp for soft delete',
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    UNIQUE KEY (tenant_id) COMMENT 'One branding per tenant'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: roles
-- Description: Roles for RBAC, tenant-specific or system-wide.
CREATE TABLE roles (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique identifier for the role',
    tenant_id BIGINT UNSIGNED NULL COMMENT 'Reference to tenant (NULL for system roles)',
    name VARCHAR(100) NOT NULL COMMENT 'Role name (e.g., "admin")',
    description TEXT COMMENT 'Role description',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was created',
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was last updated',
    deleted_at TIMESTAMP NULL COMMENT 'Timestamp for soft delete',
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE SET NULL,
    UNIQUE KEY tenant_role_name (tenant_id, name) COMMENT 'Unique role name per tenant'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: users
-- Description: User accounts with security and compliance features. Encryption hint: password_hash with bcrypt/argon2; PII fields app-encrypted (e.g., AES).
CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique identifier for the user',
    tenant_id BIGINT UNSIGNED NOT NULL COMMENT 'Reference to tenant for multi-tenant isolation',
    email VARCHAR(255) NOT NULL COMMENT 'User email',
    password_hash VARCHAR(255) NOT NULL COMMENT 'Hashed password (bcrypt/argon2 recommended)',
    first_name VARCHAR(100) COMMENT 'First name',
    last_name VARCHAR(100) COMMENT 'Last name',
    consent_given_at TIMESTAMP NULL COMMENT 'Timestamp when consent was given (GDPR/LGPD)',
    consent_version VARCHAR(50) COMMENT 'Version of consent policy',
    erase_requested_at TIMESTAMP NULL COMMENT 'Timestamp when data erasure was requested (GDPR Art. 17)',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was created',
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was last updated',
    deleted_at TIMESTAMP NULL COMMENT 'Timestamp for soft delete',
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    UNIQUE KEY tenant_email (tenant_id, email) COMMENT 'Unique email per tenant',
    KEY idx_email (email) COMMENT 'Index for email lookups',
    CHECK (email LIKE '%@%')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
PARTITION BY KEY(tenant_id) PARTITIONS 16;

-- Table: subscriptions
-- Description: Tenant subscriptions with lifecycle status.
CREATE TABLE subscriptions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique identifier for the subscription',
    tenant_id BIGINT UNSIGNED NOT NULL COMMENT 'Reference to tenant',
    plan_id BIGINT UNSIGNED NOT NULL COMMENT 'Reference to plan',
    status VARCHAR(50) NOT NULL COMMENT 'Subscription status (e.g., "active", "cancelled")',
    start_date DATE NOT NULL COMMENT 'Start date of subscription',
    end_date DATE COMMENT 'End date if applicable',
    payment_method VARCHAR(50) COMMENT 'Payment method (e.g., "credit_card")',
    last_payment_date DATE COMMENT 'Last payment date',
    next_billing_date DATE COMMENT 'Next billing date',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was created',
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was last updated',
    deleted_at TIMESTAMP NULL COMMENT 'Timestamp for soft delete',
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    FOREIGN KEY (plan_id) REFERENCES plans(id) ON DELETE RESTRICT,
    KEY idx_tenant_status (tenant_id, status) COMMENT 'Composite index for queries by tenant and status'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: role_permissions
-- Description: Assigns permissions to roles.
CREATE TABLE role_permissions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique identifier for the assignment',
    role_id BIGINT UNSIGNED NOT NULL COMMENT 'Reference to role',
    permission_id BIGINT UNSIGNED NOT NULL COMMENT 'Reference to permission',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was created',
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was last updated',
    deleted_at TIMESTAMP NULL COMMENT 'Timestamp for soft delete',
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE,
    UNIQUE KEY role_permission (role_id, permission_id) COMMENT 'Prevent duplicates'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: user_roles
-- Description: Assigns roles to users.
CREATE TABLE user_roles (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique identifier for the assignment',
    user_id BIGINT UNSIGNED NOT NULL COMMENT 'Reference to user',
    role_id BIGINT UNSIGNED NOT NULL COMMENT 'Reference to role',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was created',
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was last updated',
    deleted_at TIMESTAMP NULL COMMENT 'Timestamp for soft delete',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    UNIQUE KEY user_role (user_id, role_id) COMMENT 'Prevent duplicates'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: clients
-- Description: Clients for legal services. Encryption hint: contact_email/phone app-encrypted.
CREATE TABLE clients (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique identifier for the client',
    tenant_id BIGINT UNSIGNED NOT NULL COMMENT 'Reference to tenant',
    name VARCHAR(255) NOT NULL COMMENT 'Client name',
    type VARCHAR(50) NOT NULL COMMENT 'Type (e.g., "individual", "corporate")',
    contact_email VARCHAR(255) COMMENT 'Contact email',
    consent_given_at TIMESTAMP NULL COMMENT 'Consent timestamp (GDPR/LGPD)',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was created',
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was last updated',
    deleted_at TIMESTAMP NULL COMMENT 'Timestamp for soft delete',
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    UNIQUE KEY tenant_name (tenant_id, name) COMMENT 'Unique name per tenant',
    CHECK (contact_email LIKE '%@%' OR contact_email IS NULL)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: matters
-- Description: Legal matters/cases.
CREATE TABLE matters (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique identifier for the matter',
    tenant_id BIGINT UNSIGNED NOT NULL COMMENT 'Reference to tenant',
    client_id BIGINT UNSIGNED NOT NULL COMMENT 'Reference to client',
    assigned_user_id BIGINT UNSIGNED NULL COMMENT 'Assigned lawyer/user',
    type VARCHAR(50) NOT NULL COMMENT 'Type (e.g., "litigation", "advisory")',
    description TEXT COMMENT 'Matter description',
    priority VARCHAR(50) COMMENT 'Priority (e.g., "high", "low")',
    details JSON COMMENT 'JSON for custom fields',
    status VARCHAR(50) NOT NULL COMMENT 'Status (e.g., "open", "closed")',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was created',
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was last updated',
    deleted_at TIMESTAMP NULL COMMENT 'Timestamp for soft delete',
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_user_id) REFERENCES users(id) ON DELETE SET NULL,
    KEY idx_tenant_status (tenant_id, status) COMMENT 'Composite index for queries'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
PARTITION BY KEY(tenant_id) PARTITIONS 16;

-- Table: documents
-- Description: Legal documents. Encryption hint: sensitive content AES-encrypted.
CREATE TABLE documents (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique identifier for the document',
    tenant_id BIGINT UNSIGNED NOT NULL COMMENT 'Reference to tenant',
    matter_id BIGINT UNSIGNED NOT NULL COMMENT 'Reference to matter',
    name VARCHAR(255) NOT NULL COMMENT 'Document name',
    file_url VARCHAR(255) COMMENT 'URL to document file',
    version INT NOT NULL DEFAULT 1 COMMENT 'Document version',
    metadata JSON COMMENT 'JSON for additional info',
    status VARCHAR(50) NOT NULL COMMENT 'Status (e.g., "draft", "approved")',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was created',
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was last updated',
    deleted_at TIMESTAMP NULL COMMENT 'Timestamp for soft delete',
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    FOREIGN KEY (matter_id) REFERENCES matters(id) ON DELETE CASCADE,
    KEY idx_matter_status (matter_id, status) COMMENT 'Composite index',
    CHECK (version > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
PARTITION BY KEY(tenant_id) PARTITIONS 16;

-- Table: compliance_tasks
-- Description: Compliance tasks/audits.
CREATE TABLE compliance_tasks (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique identifier for the task',
    tenant_id BIGINT UNSIGNED NOT NULL COMMENT 'Reference to tenant',
    matter_id BIGINT UNSIGNED NULL COMMENT 'Reference to matter (optional)',
    assigned_user_id BIGINT UNSIGNED NULL COMMENT 'Assigned user',
    description TEXT NOT NULL COMMENT 'Task description',
    due_date DATE NOT NULL COMMENT 'Due date',
    status VARCHAR(50) NOT NULL COMMENT 'Status (e.g., "pending", "completed")',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was created',
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp when the record was last updated',
    deleted_at TIMESTAMP NULL COMMENT 'Timestamp for soft delete',
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    FOREIGN KEY (matter_id) REFERENCES matters(id) ON DELETE SET NULL,
    FOREIGN KEY (assigned_user_id) REFERENCES users(id) ON DELETE SET NULL,
    KEY idx_tenant_status (tenant_id, status) COMMENT 'Composite index',
    KEY idx_due_date (due_date) COMMENT 'Index for due date queries'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: audit_logs
-- Description: Audit trail for changes. Encryption hint: Sensitive changes AES-encrypted in app.
CREATE TABLE audit_logs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY COMMENT 'Unique identifier for the log entry',
    tenant_id BIGINT UNSIGNED NOT NULL COMMENT 'Reference to tenant',
    user_id BIGINT UNSIGNED NULL COMMENT 'Reference to user performing the action',
    action VARCHAR(50) NOT NULL COMMENT 'Action type (e.g., "update")',
    entity VARCHAR(100) NOT NULL COMMENT 'Entity affected (e.g., "users")',
    entity_id BIGINT UNSIGNED NOT NULL COMMENT 'ID of the affected entity',
    changes JSON COMMENT 'JSON of old/new values for audit',
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp of the action',
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    KEY idx_tenant_action (tenant_id, action) COMMENT 'Composite index for tenant-specific audits',
    KEY idx_entity (entity, entity_id) COMMENT 'Index for entity lookups'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
PARTITION BY KEY(tenant_id) PARTITIONS 16;