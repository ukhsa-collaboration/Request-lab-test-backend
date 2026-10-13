BEGIN;

-- ============================================================
-- SAMPLE TYPES
-- ============================================================

INSERT INTO rlt_static.sample_type (
    sample_type_code,
    sample_type_name,
    description
)
VALUES

(
    'SERUM',
    'Serum',
    'Serum specimen'
),

(
    'EDTA_PLASMA',
    'EDTA Plasma',
    'Plasma specimen collected using EDTA'
),

(
    'WHOLE_BLOOD',
    'Whole Blood',
    'Whole blood specimen'
),

(
    'CSF',
    'Cerebrospinal Fluid',
    'Cerebrospinal fluid specimen'
),

(
    'URINE',
    'Urine',
    'Urine specimen'
),

(
    'SWAB',
    'Swab',
    'Swab specimen'
);

-- ============================================================
-- HCV VIRAL LOAD -> SERUM
-- ============================================================

INSERT INTO rlt_static.pathogen_test_sample_type (
    relationship_code,
    pathogen_test_id,
    sample_type_id,
    preferred,
    minimum_volume,
    volume_unit,
    notes
)
SELECT
    'HCV_VIRAL_LOAD_SERUM',

    pt.pathogen_test_id,

    st.sample_type_id,

    TRUE,

    2.00,

    'mL',

    'Preferred specimen type for POC'

FROM rlt_static.pathogen_test pt

CROSS JOIN rlt_static.sample_type st

WHERE pt.pathogen_test_code = 'HCV_VIRAL_LOAD'

AND st.sample_type_code = 'SERUM';

-- ============================================================
-- HCV VIRAL LOAD -> EDTA PLASMA
-- ============================================================

INSERT INTO rlt_static.pathogen_test_sample_type (
    relationship_code,
    pathogen_test_id,
    sample_type_id,
    preferred,
    minimum_volume,
    volume_unit,
    notes
)
SELECT
    'HCV_VIRAL_LOAD_EDTA_PLASMA',

    pt.pathogen_test_id,

    st.sample_type_id,

    FALSE,

    2.00,

    'mL',

    'Alternative acceptable specimen type for POC'

FROM rlt_static.pathogen_test pt

CROSS JOIN rlt_static.sample_type st

WHERE pt.pathogen_test_code = 'HCV_VIRAL_LOAD'

AND st.sample_type_code = 'EDTA_PLASMA';

-- ============================================================
-- BODY LOCATIONS
-- ============================================================

INSERT INTO rlt_static.body_location (
    body_location_code,
    name,
    description
)
VALUES

(
    'BLOOD',
    'Blood',
    'Blood specimen collection location/category'
),

(
    'THROAT',
    'Throat',
    'Throat specimen collection location'
),

(
    'NASOPHARYNX',
    'Nasopharynx',
    'Nasopharyngeal specimen collection location'
),

(
    'SKIN',
    'Skin',
    'Skin specimen collection location'
);

-- ============================================================
-- SUBSTANCES
-- ============================================================

INSERT INTO rlt_static.substance (
    substance_code,
    substance_name,
    description
)
VALUES

(
    'BLOOD',
    'Blood',
    'Whole blood material'
),

(
    'SERUM',
    'Serum',
    'Serum derived from blood'
),

(
    'PLASMA',
    'Plasma',
    'Plasma derived from blood'
),

(
    'CSF',
    'Cerebrospinal Fluid',
    'Cerebrospinal fluid'
);

COMMIT;
