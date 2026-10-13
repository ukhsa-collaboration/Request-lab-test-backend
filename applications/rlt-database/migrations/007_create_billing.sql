BEGIN;

-- ============================================================
-- 1. BILLING GROUP
--
-- Represents how testing should be billed.
--
-- Examples:
--   BAU Free
--   BAU Commercial
--   Project
--   Survey
-- ============================================================

CREATE TABLE rlt_static.billing_group (
    billing_group_id UUID
        PRIMARY KEY
        DEFAULT gen_random_uuid(),

    billing_group_code VARCHAR(100) NOT NULL,

    billing_group_name VARCHAR(255) NOT NULL,

    billing_type VARCHAR(50) NOT NULL,

    description TEXT,

    active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_billing_group_code
        UNIQUE (billing_group_code),

    CONSTRAINT chk_billing_group_type
        CHECK (
            billing_type IN (
                'FREE',
                'COMMERCIAL',
                'MIXED'
            )
        )
);


-- ============================================================
-- 2. TARIFF
--
-- Monetary tariff definition.
--
-- Tariffs are date-versioned so historical requests can retain
-- the tariff applicable at the time of the request.
-- ============================================================

CREATE TABLE rlt_static.tariff (
    tariff_id UUID
        PRIMARY KEY
        DEFAULT gen_random_uuid(),

    tariff_code VARCHAR(100) NOT NULL,

    tariff_name VARCHAR(255) NOT NULL,

    amount NUMERIC(12,2) NOT NULL,

    currency CHAR(3) NOT NULL DEFAULT 'GBP',

    effective_from DATE NOT NULL,

    effective_to DATE,

    active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_tariff_code
        UNIQUE (tariff_code),

    CONSTRAINT chk_tariff_amount
        CHECK (amount >= 0),

    CONSTRAINT chk_tariff_dates
        CHECK (
            effective_to IS NULL
            OR effective_to >= effective_from
        )
);


-- ============================================================
-- 3. PATHOGEN TEST <-> TARIFF <-> BILLING GROUP
--
-- Joining entity determining which tariff applies to a
-- pathogen/test under a particular billing group.
--
-- Example:
--
-- HCV_VIRAL_LOAD
--        +
-- COMMERCIAL_BAU
--        =
-- HCV_VL_STANDARD_TARIFF
--
-- ============================================================

CREATE TABLE rlt_static.pathogen_test_tariff (
    pathogen_test_tariff_id UUID
        PRIMARY KEY
        DEFAULT gen_random_uuid(),

    relationship_code VARCHAR(150) NOT NULL,

    pathogen_test_id UUID NOT NULL,

    tariff_id UUID NOT NULL,

    billing_group_id UUID NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_pathogen_test_tariff_code
        UNIQUE (relationship_code),

    CONSTRAINT uq_pathogen_test_tariff_relationship
        UNIQUE (
            pathogen_test_id,
            tariff_id,
            billing_group_id
        ),

    CONSTRAINT fk_pathogen_test_tariff_test
        FOREIGN KEY (pathogen_test_id)
        REFERENCES rlt_static.pathogen_test(
            pathogen_test_id
        )
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT fk_pathogen_test_tariff_tariff
        FOREIGN KEY (tariff_id)
        REFERENCES rlt_static.tariff(
            tariff_id
        )
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT fk_pathogen_test_tariff_billing_group
        FOREIGN KEY (billing_group_id)
        REFERENCES rlt_static.billing_group(
            billing_group_id
        )
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);


-- ============================================================
-- 4. SITE BILLING RULE
--
-- Determines the billing group assigned to a customer site
-- and, optionally, a particular team.
--
-- customer_team_id is nullable intentionally.
--
-- Example site-wide rule:
--
-- Newcastle Lab
--      -> BAU_FREE
--
-- Example team-specific override:
--
-- Newcastle Lab
--      -> Sexual Health
--           -> PROJECT_FREE
--
-- ============================================================

CREATE TABLE rlt_static.site_billing_rule (
    site_billing_rule_id UUID
        PRIMARY KEY
        DEFAULT gen_random_uuid(),

    billing_rule_code VARCHAR(150) NOT NULL,

    customer_site_id UUID NOT NULL,

    customer_team_id UUID,

    billing_group_id UUID NOT NULL,

    effective_from DATE NOT NULL,

    effective_to DATE,

    active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_site_billing_rule_code
        UNIQUE (billing_rule_code),

    CONSTRAINT fk_site_billing_rule_site
        FOREIGN KEY (customer_site_id)
        REFERENCES rlt_static.customer_site(
            customer_site_id
        )
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT fk_site_billing_rule_team
        FOREIGN KEY (customer_team_id)
        REFERENCES rlt_static.customer_team(
            customer_team_id
        )
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT fk_site_billing_rule_group
        FOREIGN KEY (billing_group_id)
        REFERENCES rlt_static.billing_group(
            billing_group_id
        )
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT chk_site_billing_rule_dates
        CHECK (
            effective_to IS NULL
            OR effective_to >= effective_from
        )
);


-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_billing_group_active
    ON rlt_static.billing_group(active);


CREATE INDEX idx_tariff_active
    ON rlt_static.tariff(active);


CREATE INDEX idx_tariff_effective_dates
    ON rlt_static.tariff(
        effective_from,
        effective_to
    );


CREATE INDEX idx_pathogen_test_tariff_test
    ON rlt_static.pathogen_test_tariff(
        pathogen_test_id
    );


CREATE INDEX idx_pathogen_test_tariff_tariff
    ON rlt_static.pathogen_test_tariff(
        tariff_id
    );


CREATE INDEX idx_pathogen_test_tariff_group
    ON rlt_static.pathogen_test_tariff(
        billing_group_id
    );


CREATE INDEX idx_site_billing_rule_site
    ON rlt_static.site_billing_rule(
        customer_site_id
    );


CREATE INDEX idx_site_billing_rule_team
    ON rlt_static.site_billing_rule(
        customer_team_id
    );


CREATE INDEX idx_site_billing_rule_group
    ON rlt_static.site_billing_rule(
        billing_group_id
    );


COMMIT;