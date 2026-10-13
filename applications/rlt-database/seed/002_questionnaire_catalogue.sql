BEGIN;

INSERT INTO rlt_static.test_schema (
    schema_code,
    schema_name,
    version,
    description,
    active,
    effective_from
)
VALUES (
    'HCV_REQUEST_V1',
    'Hepatitis C Request Questionnaire',
    '1.0',
    'Questionnaire for Hepatitis C laboratory requests',
    TRUE,
    CURRENT_DATE
);

INSERT INTO rlt_static.question_definition (
    question_code,
    question_text,
    question_category,
    answer_type,
    required_default
)
VALUES
(
    'HCV_PREVIOUS_PCR_RESULT',
    'Previous HCV PCR result',
    'PRIOR_LAB_OBSERVATION',
    'CODED',
    FALSE
),
(
    'HCV_PREVIOUS_VIRAL_LOAD',
    'Previous HCV viral load',
    'PRIOR_LAB_OBSERVATION',
    'QUANTITY',
    FALSE
),
(
    'HCV_ANTIVIRAL_THERAPY',
    'Is the patient currently receiving antiviral therapy?',
    'PRIOR_CLINICAL_OBSERVATION',
    'BOOLEAN',
    FALSE
),
(
    'HCV_CLINICAL_INFORMATION',
    'Relevant clinical information',
    'PRIOR_CLINICAL_OBSERVATION',
    'TEXTAREA',
    FALSE
),
(
    'HEPATITIS_VACCINATION',
    'Has the patient previously received a hepatitis vaccination?',
    'PRIOR_IMMUNISATION',
    'BOOLEAN',
    FALSE
),
(
    'RECENT_TRAVEL',
    'Has the patient travelled outside the UK recently?',
    'PATIENT_CIRCUMSTANCE',
    'BOOLEAN',
    FALSE
),
(
    'TRAVEL_COUNTRY',
    'Country of recent travel',
    'PATIENT_CIRCUMSTANCE',
    'COUNTRY',
    FALSE
),
(
    'PATIENT_ETHNICITY',
    'Patient ethnicity',
    'PATIENT_CIRCUMSTANCE',
    'CODED',
    FALSE
);

INSERT INTO rlt_static.pathogen_test_schema (
    pathogen_test_schema_code,
    pathogen_test_id,
    test_schema_id
)
SELECT
    'HCV_VIRAL_LOAD_SCHEMA_V1',
    pt.pathogen_test_id,
    ts.test_schema_id
FROM rlt_static.pathogen_test pt
CROSS JOIN rlt_static.test_schema ts
WHERE pt.pathogen_test_code = 'HCV_VIRAL_LOAD'
AND ts.schema_code = 'HCV_REQUEST_V1';

INSERT INTO rlt_static.schema_question (
    schema_question_code,
    test_schema_id,
    question_id,
    required,
    display_order
)
SELECT
    'HCV_V1_PREVIOUS_PCR',
    ts.test_schema_id,
    q.question_id,
    FALSE,
    10
FROM rlt_static.test_schema ts
CROSS JOIN rlt_static.question_definition q
WHERE ts.schema_code = 'HCV_REQUEST_V1'
AND q.question_code = 'HCV_PREVIOUS_PCR_RESULT';


INSERT INTO rlt_static.schema_question (
    schema_question_code,
    test_schema_id,
    question_id,
    required,
    display_order
)
SELECT
    'HCV_V1_PREVIOUS_VIRAL_LOAD',
    ts.test_schema_id,
    q.question_id,
    FALSE,
    20
FROM rlt_static.test_schema ts
CROSS JOIN rlt_static.question_definition q
WHERE ts.schema_code = 'HCV_REQUEST_V1'
AND q.question_code = 'HCV_PREVIOUS_VIRAL_LOAD';


INSERT INTO rlt_static.schema_question (
    schema_question_code,
    test_schema_id,
    question_id,
    required,
    display_order
)
SELECT
    'HCV_V1_ANTIVIRAL_THERAPY',
    ts.test_schema_id,
    q.question_id,
    FALSE,
    30
FROM rlt_static.test_schema ts
CROSS JOIN rlt_static.question_definition q
WHERE ts.schema_code = 'HCV_REQUEST_V1'
AND q.question_code = 'HCV_ANTIVIRAL_THERAPY';


INSERT INTO rlt_static.schema_question (
    schema_question_code,
    test_schema_id,
    question_id,
    required,
    display_order
)
SELECT
    'HCV_V1_CLINICAL_INFO',
    ts.test_schema_id,
    q.question_id,
    FALSE,
    40
FROM rlt_static.test_schema ts
CROSS JOIN rlt_static.question_definition q
WHERE ts.schema_code = 'HCV_REQUEST_V1'
AND q.question_code = 'HCV_CLINICAL_INFORMATION';


INSERT INTO rlt_static.schema_question (
    schema_question_code,
    test_schema_id,
    question_id,
    required,
    display_order
)
SELECT
    'HCV_V1_VACCINATION',
    ts.test_schema_id,
    q.question_id,
    FALSE,
    50
FROM rlt_static.test_schema ts
CROSS JOIN rlt_static.question_definition q
WHERE ts.schema_code = 'HCV_REQUEST_V1'
AND q.question_code = 'HEPATITIS_VACCINATION';


INSERT INTO rlt_static.schema_question (
    schema_question_code,
    test_schema_id,
    question_id,
    required,
    display_order
)
SELECT
    'HCV_V1_RECENT_TRAVEL',
    ts.test_schema_id,
    q.question_id,
    FALSE,
    60
FROM rlt_static.test_schema ts
CROSS JOIN rlt_static.question_definition q
WHERE ts.schema_code = 'HCV_REQUEST_V1'
AND q.question_code = 'RECENT_TRAVEL';


INSERT INTO rlt_static.schema_question (
    schema_question_code,
    test_schema_id,
    question_id,
    required,
    display_order,
    conditional_rule
)
SELECT
    'HCV_V1_TRAVEL_COUNTRY',
    ts.test_schema_id,
    q.question_id,
    FALSE,
    70,

    '{
        "dependsOn": "RECENT_TRAVEL",
        "operator": "EQUALS",
        "value": true
    }'::jsonb

FROM rlt_static.test_schema ts
CROSS JOIN rlt_static.question_definition q
WHERE ts.schema_code = 'HCV_REQUEST_V1'
AND q.question_code = 'TRAVEL_COUNTRY';


INSERT INTO rlt_static.schema_question (
    schema_question_code,
    test_schema_id,
    question_id,
    required,
    display_order
)
SELECT
    'HCV_V1_ETHNICITY',
    ts.test_schema_id,
    q.question_id,
    FALSE,
    80
FROM rlt_static.test_schema ts
CROSS JOIN rlt_static.question_definition q
WHERE ts.schema_code = 'HCV_REQUEST_V1'
AND q.question_code = 'PATIENT_ETHNICITY';


COMMIT;