BEGIN;

-- ============================================================
-- 1. TEST SCHEMA
--
-- Represents a versioned questionnaire/form definition.
--
-- Example:
--   HCV_REQUEST
--   Version 1.0
-- ============================================================

CREATE TABLE rlt_static.test_schema (
    test_schema_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    schema_code VARCHAR(100) NOT NULL,

    schema_name VARCHAR(255) NOT NULL,

    version VARCHAR(50) NOT NULL,

    description TEXT,

    active BOOLEAN NOT NULL DEFAULT TRUE,

    effective_from DATE,

    effective_to DATE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_test_schema_code
        UNIQUE (schema_code),

    CONSTRAINT chk_test_schema_effective_dates
        CHECK (
            effective_to IS NULL
            OR effective_from IS NULL
            OR effective_to >= effective_from
        )
);


-- ============================================================
-- 2. QUESTION DEFINITION
--
-- Reusable catalogue of questions.
--
-- Categories:
--
-- PRIOR_LAB_OBSERVATION
-- PRIOR_CLINICAL_OBSERVATION
-- PRIOR_IMMUNISATION
-- PATIENT_CIRCUMSTANCE
--
-- ============================================================

CREATE TABLE rlt_static.question_definition (
    question_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    question_code VARCHAR(100) NOT NULL,

    question_text TEXT NOT NULL,

    question_category VARCHAR(50) NOT NULL,

    answer_type VARCHAR(50) NOT NULL,

    unit VARCHAR(50),

    terminology_system VARCHAR(100),

    terminology_code VARCHAR(100),

    required_default BOOLEAN NOT NULL DEFAULT FALSE,

    active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_question_definition_code
        UNIQUE (question_code),

    CONSTRAINT chk_question_category
        CHECK (
            question_category IN (
                'PRIOR_LAB_OBSERVATION',
                'PRIOR_CLINICAL_OBSERVATION',
                'PRIOR_IMMUNISATION',
                'PATIENT_CIRCUMSTANCE'
            )
        ),

    CONSTRAINT chk_question_answer_type
        CHECK (
            answer_type IN (
                'TEXT',
                'TEXTAREA',
                'BOOLEAN',
                'INTEGER',
                'DECIMAL',
                'DATE',
                'DATETIME',
                'CODED',
                'MULTI_SELECT',
                'COUNTRY',
                'QUANTITY'
            )
        )
);


-- ============================================================
-- 3. PATHOGEN TEST <-> TEST SCHEMA
--
-- Joining table.
--
-- A pathogen/test may have different schemas over time.
-- A schema can potentially be reused.
-- ============================================================

CREATE TABLE rlt_static.pathogen_test_schema (
    pathogen_test_schema_id UUID
        PRIMARY KEY
        DEFAULT gen_random_uuid(),

    pathogen_test_schema_code VARCHAR(150) NOT NULL,

    pathogen_test_id UUID NOT NULL,

    test_schema_id UUID NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_pathogen_test_schema_code
        UNIQUE (pathogen_test_schema_code),

    CONSTRAINT uq_pathogen_test_schema_relationship
        UNIQUE (
            pathogen_test_id,
            test_schema_id
        ),

    CONSTRAINT fk_pathogen_test_schema_pathogen_test
        FOREIGN KEY (pathogen_test_id)
        REFERENCES rlt_static.pathogen_test(pathogen_test_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT fk_pathogen_test_schema_test_schema
        FOREIGN KEY (test_schema_id)
        REFERENCES rlt_static.test_schema(test_schema_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);


-- ============================================================
-- 4. SCHEMA QUESTION
--
-- Joining table between:
--
-- TEST_SCHEMA
--      |
--      |
-- SCHEMA_QUESTION
--      |
--      |
-- QUESTION_DEFINITION
--
-- Controls:
--
-- * required status
-- * display order
-- * conditional visibility
--
-- ============================================================

CREATE TABLE rlt_static.schema_question (
    schema_question_id UUID
        PRIMARY KEY
        DEFAULT gen_random_uuid(),

    schema_question_code VARCHAR(150) NOT NULL,

    test_schema_id UUID NOT NULL,

    question_id UUID NOT NULL,

    required BOOLEAN NOT NULL DEFAULT FALSE,

    display_order INTEGER NOT NULL,

    conditional_rule JSONB,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_schema_question_code
        UNIQUE (schema_question_code),

    CONSTRAINT uq_schema_question_relationship
        UNIQUE (
            test_schema_id,
            question_id
        ),

    CONSTRAINT fk_schema_question_schema
        FOREIGN KEY (test_schema_id)
        REFERENCES rlt_static.test_schema(test_schema_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT fk_schema_question_question
        FOREIGN KEY (question_id)
        REFERENCES rlt_static.question_definition(question_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT chk_schema_question_display_order
        CHECK (display_order > 0)
);


-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_pathogen_test_schema_pathogen_test
    ON rlt_static.pathogen_test_schema(pathogen_test_id);


CREATE INDEX idx_pathogen_test_schema_schema
    ON rlt_static.pathogen_test_schema(test_schema_id);


CREATE INDEX idx_schema_question_schema
    ON rlt_static.schema_question(test_schema_id);


CREATE INDEX idx_schema_question_question
    ON rlt_static.schema_question(question_id);


CREATE INDEX idx_question_category
    ON rlt_static.question_definition(question_category);


CREATE INDEX idx_question_active
    ON rlt_static.question_definition(active);


COMMIT;