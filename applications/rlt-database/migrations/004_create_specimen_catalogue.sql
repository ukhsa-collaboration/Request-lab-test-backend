BEGIN;

-- ============================================================
-- 1. SAMPLE TYPE
--
-- Reference catalogue of specimen/sample types.
--
-- Examples:
--   Serum
--   EDTA Plasma
--   Whole Blood
--   CSF
--   Urine
--   Swab
-- ============================================================

CREATE TABLE rlt_static.sample_type (
    sample_type_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    sample_type_code VARCHAR(100) NOT NULL,

    sample_type_name VARCHAR(255) NOT NULL,

    description TEXT,

    snomed_ct_code VARCHAR(50),

    active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_sample_type_code
        UNIQUE (sample_type_code)
);


-- ============================================================
-- 2. PATHOGEN TEST <-> SAMPLE TYPE
--
-- Joining table defining which sample types are acceptable
-- for a particular pathogen/test.
--
-- Example:
--
-- HCV_VIRAL_LOAD
--      |
--      +---- SERUM
--      |
--      +---- EDTA_PLASMA
--
-- ============================================================

CREATE TABLE rlt_static.pathogen_test_sample_type (
    pathogen_test_sample_type_id UUID
        PRIMARY KEY
        DEFAULT gen_random_uuid(),

    relationship_code VARCHAR(150) NOT NULL,

    pathogen_test_id UUID NOT NULL,

    sample_type_id UUID NOT NULL,

    preferred BOOLEAN NOT NULL DEFAULT FALSE,

    minimum_volume NUMERIC(10,2),

    volume_unit VARCHAR(30),

    notes TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_pathogen_test_sample_type_code
        UNIQUE (relationship_code),

    CONSTRAINT uq_pathogen_test_sample_type_relationship
        UNIQUE (
            pathogen_test_id,
            sample_type_id
        ),

    CONSTRAINT fk_pathogen_test_sample_type_test
        FOREIGN KEY (pathogen_test_id)
        REFERENCES rlt_static.pathogen_test(pathogen_test_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT fk_pathogen_test_sample_type_sample
        FOREIGN KEY (sample_type_id)
        REFERENCES rlt_static.sample_type(sample_type_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT chk_sample_minimum_volume
        CHECK (
            minimum_volume IS NULL
            OR minimum_volume >= 0
        ),

    CONSTRAINT chk_sample_volume_unit
        CHECK (
            (minimum_volume IS NULL AND volume_unit IS NULL)
            OR
            (minimum_volume IS NOT NULL AND volume_unit IS NOT NULL)
        )
);


-- ============================================================
-- 3. BODY LOCATION
--
-- Reference catalogue of anatomical specimen locations.
--
-- This is separate from SAMPLE_TYPE.
--
-- Example:
--   Blood
--   Throat
--   Nasopharynx
--   Skin
-- ============================================================

CREATE TABLE rlt_static.body_location (
    body_location_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    body_location_code VARCHAR(100) NOT NULL,

    name VARCHAR(255) NOT NULL,

    description TEXT,

    snomed_ct_code VARCHAR(50),

    active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_body_location_code
        UNIQUE (body_location_code)
);


-- ============================================================
-- 4. SUBSTANCE
--
-- Reference catalogue of specimen substances/materials.
--
-- Example:
--   Blood
--   Plasma
--   Serum
--   CSF
--
-- ============================================================

CREATE TABLE rlt_static.substance (
    substance_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    substance_code VARCHAR(100) NOT NULL,

    substance_name VARCHAR(255) NOT NULL,

    description TEXT,

    snomed_ct_code VARCHAR(50),

    active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_substance_code
        UNIQUE (substance_code)
);


-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_sample_type_active
    ON rlt_static.sample_type(active);

CREATE INDEX idx_pathogen_test_sample_type_test
    ON rlt_static.pathogen_test_sample_type(pathogen_test_id);

CREATE INDEX idx_pathogen_test_sample_type_sample
    ON rlt_static.pathogen_test_sample_type(sample_type_id);

CREATE INDEX idx_body_location_active
    ON rlt_static.body_location(active);

CREATE INDEX idx_substance_active
    ON rlt_static.substance(active);


COMMIT;