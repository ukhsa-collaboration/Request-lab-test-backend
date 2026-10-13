BEGIN;

-- ============================================================
-- 1. TESTING ORGANISATION
--
-- Organisation responsible for providing laboratory testing.
--
-- Examples:
--   UKHSA
--   Third-party laboratory provider
-- ============================================================

CREATE TABLE rlt_static.testing_organisation (
    testing_organisation_id UUID
        PRIMARY KEY
        DEFAULT gen_random_uuid(),

    organisation_code VARCHAR(100) NOT NULL,

    organisation_name VARCHAR(255) NOT NULL,

    organisation_type VARCHAR(100),

    active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_testing_organisation_code
        UNIQUE (organisation_code)
);


-- ============================================================
-- 2. TESTING LAB SITE
--
-- Physical/logical laboratory that performs testing.
-- ============================================================

CREATE TABLE rlt_static.testing_lab_site (
    testing_lab_site_id UUID
        PRIMARY KEY
        DEFAULT gen_random_uuid(),

    lab_site_code VARCHAR(100) NOT NULL,

    testing_organisation_id UUID NOT NULL,

    lab_name VARCHAR(255) NOT NULL,

    address TEXT,

    postcode VARCHAR(20),

    contact_details TEXT,

    active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_testing_lab_site_code
        UNIQUE (lab_site_code),

    CONSTRAINT fk_testing_lab_site_organisation
        FOREIGN KEY (testing_organisation_id)
        REFERENCES rlt_static.testing_organisation(
            testing_organisation_id
        )
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);


-- ============================================================
-- 3. SAMPLE RECEPTION SITE
--
-- Location where specimens are physically received.
--
-- A reception site is not necessarily the same thing as the
-- laboratory performing the test.
-- ============================================================

CREATE TABLE rlt_static.sample_reception_site (
    sample_reception_site_id UUID
        PRIMARY KEY
        DEFAULT gen_random_uuid(),

    reception_site_code VARCHAR(100) NOT NULL,

    testing_organisation_id UUID NOT NULL,

    reception_name VARCHAR(255) NOT NULL,

    address TEXT,

    postcode VARCHAR(20),

    active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_sample_reception_site_code
        UNIQUE (reception_site_code),

    CONSTRAINT fk_sample_reception_organisation
        FOREIGN KEY (testing_organisation_id)
        REFERENCES rlt_static.testing_organisation(
            testing_organisation_id
        )
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);


-- ============================================================
-- 4. LAB <-> SAMPLE RECEPTION
--
-- Joining table.
--
-- Defines which sample reception sites can receive samples
-- destined for a particular testing laboratory.
-- ============================================================

CREATE TABLE rlt_static.lab_sample_reception (
    lab_sample_reception_id UUID
        PRIMARY KEY
        DEFAULT gen_random_uuid(),

    relationship_code VARCHAR(150) NOT NULL,

    testing_lab_site_id UUID NOT NULL,

    sample_reception_site_id UUID NOT NULL,

    primary_reception BOOLEAN NOT NULL DEFAULT FALSE,

    active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_lab_sample_reception_code
        UNIQUE (relationship_code),

    CONSTRAINT uq_lab_sample_reception_relationship
        UNIQUE (
            testing_lab_site_id,
            sample_reception_site_id
        ),

    CONSTRAINT fk_lab_sample_reception_lab
        FOREIGN KEY (testing_lab_site_id)
        REFERENCES rlt_static.testing_lab_site(
            testing_lab_site_id
        )
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT fk_lab_sample_reception_site
        FOREIGN KEY (sample_reception_site_id)
        REFERENCES rlt_static.sample_reception_site(
            sample_reception_site_id
        )
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);


-- ============================================================
-- 5. LAB <-> PATHOGEN TEST
--
-- Defines which laboratory can perform which RLT test.
--
-- This is the key test-routing relationship.
--
-- Example:
--
-- HCV_VIRAL_LOAD
--       |
--       +---- COLINDALE_VIROLOGY
--
-- local_lims_code allows the lab/LIMS-specific code to differ
-- from RLT's pathogen_test_code.
-- ============================================================

CREATE TABLE rlt_static.lab_pathogen_test (
    lab_pathogen_test_id UUID
        PRIMARY KEY
        DEFAULT gen_random_uuid(),

    lab_test_code VARCHAR(150) NOT NULL,

    testing_lab_site_id UUID NOT NULL,

    pathogen_test_id UUID NOT NULL,

    local_lims_code VARCHAR(100),

    turnaround_minutes INTEGER,

    available BOOLEAN NOT NULL DEFAULT TRUE,

    valid_from DATE,

    valid_to DATE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_lab_pathogen_test_code
        UNIQUE (lab_test_code),

    CONSTRAINT uq_lab_pathogen_test_relationship
        UNIQUE (
            testing_lab_site_id,
            pathogen_test_id
        ),

    CONSTRAINT fk_lab_pathogen_test_lab
        FOREIGN KEY (testing_lab_site_id)
        REFERENCES rlt_static.testing_lab_site(
            testing_lab_site_id
        )
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT fk_lab_pathogen_test_test
        FOREIGN KEY (pathogen_test_id)
        REFERENCES rlt_static.pathogen_test(
            pathogen_test_id
        )
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT chk_lab_pathogen_test_turnaround
        CHECK (
            turnaround_minutes IS NULL
            OR turnaround_minutes > 0
        ),

    CONSTRAINT chk_lab_pathogen_test_dates
        CHECK (
            valid_to IS NULL
            OR valid_from IS NULL
            OR valid_to >= valid_from
        )
);


-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_testing_organisation_active
    ON rlt_static.testing_organisation(active);


CREATE INDEX idx_testing_lab_organisation
    ON rlt_static.testing_lab_site(testing_organisation_id);


CREATE INDEX idx_testing_lab_active
    ON rlt_static.testing_lab_site(active);


CREATE INDEX idx_reception_organisation
    ON rlt_static.sample_reception_site(testing_organisation_id);


CREATE INDEX idx_reception_active
    ON rlt_static.sample_reception_site(active);


CREATE INDEX idx_lab_reception_lab
    ON rlt_static.lab_sample_reception(testing_lab_site_id);


CREATE INDEX idx_lab_reception_site
    ON rlt_static.lab_sample_reception(sample_reception_site_id);


CREATE INDEX idx_lab_pathogen_test_lab
    ON rlt_static.lab_pathogen_test(testing_lab_site_id);


CREATE INDEX idx_lab_pathogen_test_test
    ON rlt_static.lab_pathogen_test(pathogen_test_id);


CREATE INDEX idx_lab_pathogen_test_available
    ON rlt_static.lab_pathogen_test(available);


COMMIT;