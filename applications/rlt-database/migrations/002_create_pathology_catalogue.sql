BEGIN;

-- ============================================================
-- 1. PATHOGEN FAMILY
-- Examples:
--   Hepatitis
--   Influenza
--   HIV
-- ============================================================

CREATE TABLE rlt_static.pathogen_family (
    pathogen_family_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    family_code VARCHAR(50) NOT NULL,
    family_name VARCHAR(150) NOT NULL,

    description TEXT,

    active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_pathogen_family_code
        UNIQUE (family_code)
);


-- ============================================================
-- 2. PATHOGEN
-- Examples:
--   Hepatitis A
--   Hepatitis B
--   Hepatitis C
-- ============================================================

CREATE TABLE rlt_static.pathogen (
    pathogen_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    pathogen_code VARCHAR(50) NOT NULL,

    pathogen_family_id UUID NOT NULL,

    pathogen_name VARCHAR(150) NOT NULL,

    description TEXT,

    snomed_ct_code VARCHAR(50),

    active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_pathogen_code
        UNIQUE (pathogen_code),

    CONSTRAINT fk_pathogen_family
        FOREIGN KEY (pathogen_family_id)
        REFERENCES rlt_static.pathogen_family(pathogen_family_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);


-- ============================================================
-- 3. TEST TYPE
-- Examples:
--   Viral Load
--   Identification
--   Antigen Testing
--   Antibody Testing
--   AMR
-- ============================================================

CREATE TABLE rlt_static.test_type (
    test_type_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    test_type_code VARCHAR(50) NOT NULL,

    test_type_name VARCHAR(150) NOT NULL,

    description TEXT,

    outcome_description TEXT,

    active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_test_type_code
        UNIQUE (test_type_code)
);


-- ============================================================
-- 4. PATHOGEN TEST
--
-- Joining entity between:
--
-- PATHOGEN <---- PATHOGEN_TEST ----> TEST_TYPE
--
-- Example:
--   Hepatitis C + Viral Load
--              =
--   HCV_VIRAL_LOAD
-- ============================================================

CREATE TABLE rlt_static.pathogen_test (
    pathogen_test_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    pathogen_test_code VARCHAR(100) NOT NULL,

    pathogen_id UUID NOT NULL,

    test_type_id UUID NOT NULL,

    display_name VARCHAR(255) NOT NULL,

    snomed_ct_procedure_code VARCHAR(50),

    lims_code VARCHAR(100),

    default_duration_minutes INTEGER,

    base_charge NUMERIC(12,2),

    currency_code CHAR(3),

    active BOOLEAN NOT NULL DEFAULT TRUE,

    valid_from DATE,

    valid_to DATE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_pathogen_test_code
        UNIQUE (pathogen_test_code),

    CONSTRAINT fk_pathogen_test_pathogen
        FOREIGN KEY (pathogen_id)
        REFERENCES rlt_static.pathogen(pathogen_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT fk_pathogen_test_type
        FOREIGN KEY (test_type_id)
        REFERENCES rlt_static.test_type(test_type_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT chk_pathogen_test_duration
        CHECK (
            default_duration_minutes IS NULL
            OR default_duration_minutes > 0
        ),

    CONSTRAINT chk_pathogen_test_charge
        CHECK (
            base_charge IS NULL
            OR base_charge >= 0
        ),

    CONSTRAINT chk_pathogen_test_valid_dates
        CHECK (
            valid_to IS NULL
            OR valid_from IS NULL
            OR valid_to >= valid_from
        )
);


-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_pathogen_family_id
    ON rlt_static.pathogen(pathogen_family_id);

CREATE INDEX idx_pathogen_test_pathogen_id
    ON rlt_static.pathogen_test(pathogen_id);

CREATE INDEX idx_pathogen_test_test_type_id
    ON rlt_static.pathogen_test(test_type_id);

CREATE INDEX idx_pathogen_active
    ON rlt_static.pathogen(active);

CREATE INDEX idx_pathogen_test_active
    ON rlt_static.pathogen_test(active);


COMMIT;