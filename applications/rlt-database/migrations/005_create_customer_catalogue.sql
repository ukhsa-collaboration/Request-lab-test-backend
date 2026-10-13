BEGIN;

-- ============================================================
-- 1. CUSTOMER ORGANISATION
--
-- Top-level organisation that requests testing.
--
-- Examples:
--   NHS Trust
--   NHS Foundation Trust
--   Private Healthcare Organisation
-- ============================================================

CREATE TABLE rlt_static.customer_organisation (
    customer_organisation_id UUID
        PRIMARY KEY
        DEFAULT gen_random_uuid(),

    organisation_code VARCHAR(100) NOT NULL,

    organisation_name VARCHAR(255) NOT NULL,

    organisation_type VARCHAR(100),

    description TEXT,

    active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_customer_organisation_code
        UNIQUE (organisation_code)
);


-- ============================================================
-- 2. CUSTOMER SITE
--
-- A site/location belonging to the customer organisation.
--
-- Important:
-- molis_customer_code is the customer/sender mapping used
-- when communicating with MOLIS.
--
-- ============================================================

CREATE TABLE rlt_static.customer_site (
    customer_site_id UUID
        PRIMARY KEY
        DEFAULT gen_random_uuid(),

    site_code VARCHAR(100) NOT NULL,

    customer_organisation_id UUID NOT NULL,

    site_name VARCHAR(255) NOT NULL,

    site_type VARCHAR(100),

    address TEXT,

    postcode VARCHAR(20),

    molis_customer_code VARCHAR(100),

    active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_customer_site_code
        UNIQUE (site_code),

    CONSTRAINT fk_customer_site_organisation
        FOREIGN KEY (customer_organisation_id)
        REFERENCES rlt_static.customer_organisation(
            customer_organisation_id
        )
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);


-- ============================================================
-- 3. CUSTOMER TEAM
--
-- A requesting team/clinic within a customer site.
--
-- Examples:
--   Sexual Health Clinic
--   Infectious Diseases
--   Microbiology
--   GP Practice Team
--
-- ============================================================

CREATE TABLE rlt_static.customer_team (
    customer_team_id UUID
        PRIMARY KEY
        DEFAULT gen_random_uuid(),

    team_code VARCHAR(100) NOT NULL,

    customer_site_id UUID NOT NULL,

    team_name VARCHAR(255) NOT NULL,

    description TEXT,

    active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_customer_team_code
        UNIQUE (team_code),

    CONSTRAINT fk_customer_team_site
        FOREIGN KEY (customer_site_id)
        REFERENCES rlt_static.customer_site(
            customer_site_id
        )
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);


-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_customer_organisation_active
    ON rlt_static.customer_organisation(active);


CREATE INDEX idx_customer_site_organisation
    ON rlt_static.customer_site(customer_organisation_id);


CREATE INDEX idx_customer_site_active
    ON rlt_static.customer_site(active);


CREATE INDEX idx_customer_site_molis_customer_code
    ON rlt_static.customer_site(molis_customer_code);


CREATE INDEX idx_customer_team_site
    ON rlt_static.customer_team(customer_site_id);


CREATE INDEX idx_customer_team_active
    ON rlt_static.customer_team(active);


COMMIT;