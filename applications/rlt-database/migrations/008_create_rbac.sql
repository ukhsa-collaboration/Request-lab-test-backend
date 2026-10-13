BEGIN;

-- ============================================================
-- 1. APP USER
--
-- Application identity known to RLT.
--
-- Authentication itself remains the responsibility of the
-- configured identity provider.
-- ============================================================

CREATE TABLE rlt_static.app_user (
    user_id UUID
        PRIMARY KEY
        DEFAULT gen_random_uuid(),

    external_user_id VARCHAR(255) NOT NULL,

    email VARCHAR(320),

    display_name VARCHAR(255),

    identity_provider VARCHAR(100) NOT NULL,

    active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_app_user_external_id
        UNIQUE (external_user_id)
);


-- ============================================================
-- 2. ROLE
--
-- Defines application roles.
--
-- Examples:
--
-- UKHSA_SYSTEM_ADMIN
-- CUSTOMER_SITE_ADMIN
-- CUSTOMER_USER
-- UKHSA_LAB_ADMIN
-- ============================================================

CREATE TABLE rlt_static.role (
    role_id UUID
        PRIMARY KEY
        DEFAULT gen_random_uuid(),

    role_code VARCHAR(100) NOT NULL,

    role_name VARCHAR(255) NOT NULL,

    description TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_role_code
        UNIQUE (role_code)
);


-- ============================================================
-- 3. USER ROLE
--
-- Joining entity:
--
-- APP_USER N:M ROLE
--
-- Allows a user to have more than one role.
-- ============================================================

CREATE TABLE rlt_static.user_role (
    user_role_id UUID
        PRIMARY KEY
        DEFAULT gen_random_uuid(),

    user_role_code VARCHAR(150) NOT NULL,

    user_id UUID NOT NULL,

    role_id UUID NOT NULL,

    valid_from TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    valid_to TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_user_role_code
        UNIQUE (user_role_code),

    CONSTRAINT uq_user_role_assignment
        UNIQUE (
            user_id,
            role_id
        ),

    CONSTRAINT fk_user_role_user
        FOREIGN KEY (user_id)
        REFERENCES rlt_static.app_user(user_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT fk_user_role_role
        FOREIGN KEY (role_id)
        REFERENCES rlt_static.role(role_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT chk_user_role_validity
        CHECK (
            valid_to IS NULL
            OR valid_to >= valid_from
        )
);


-- ============================================================
-- 4. USER SITE ACCESS
--
-- Restricts users to particular customer sites.
--
-- This is especially important for:
--
-- CUSTOMER_SITE_ADMIN
-- CUSTOMER_USER
--
-- ============================================================

CREATE TABLE rlt_static.user_site_access (
    user_site_access_id UUID
        PRIMARY KEY
        DEFAULT gen_random_uuid(),

    access_code VARCHAR(150) NOT NULL,

    user_id UUID NOT NULL,

    customer_site_id UUID NOT NULL,

    can_read BOOLEAN NOT NULL DEFAULT TRUE,

    can_create BOOLEAN NOT NULL DEFAULT FALSE,

    can_update BOOLEAN NOT NULL DEFAULT FALSE,

    can_administer BOOLEAN NOT NULL DEFAULT FALSE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_user_site_access_code
        UNIQUE (access_code),

    CONSTRAINT uq_user_site_access_assignment
        UNIQUE (
            user_id,
            customer_site_id
        ),

    CONSTRAINT fk_user_site_access_user
        FOREIGN KEY (user_id)
        REFERENCES rlt_static.app_user(user_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT fk_user_site_access_site
        FOREIGN KEY (customer_site_id)
        REFERENCES rlt_static.customer_site(customer_site_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);


-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_app_user_active
    ON rlt_static.app_user(active);


CREATE INDEX idx_app_user_email
    ON rlt_static.app_user(email);


CREATE INDEX idx_user_role_user
    ON rlt_static.user_role(user_id);


CREATE INDEX idx_user_role_role
    ON rlt_static.user_role(role_id);


CREATE INDEX idx_user_site_access_user
    ON rlt_static.user_site_access(user_id);


CREATE INDEX idx_user_site_access_site
    ON rlt_static.user_site_access(customer_site_id);


COMMIT;