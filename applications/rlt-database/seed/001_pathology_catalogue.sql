BEGIN;

-- ============================================================
-- PATHOGEN FAMILY
-- ============================================================

INSERT INTO rlt_static.pathogen_family (
    family_code,
    family_name,
    description
)
VALUES (
    'HEPATITIS',
    'Hepatitis',
    'Hepatitis virus family'
);


-- ============================================================
-- PATHOGENS
-- ============================================================

INSERT INTO rlt_static.pathogen (
    pathogen_code,
    pathogen_family_id,
    pathogen_name,
    description
)
SELECT
    'HAV',
    pathogen_family_id,
    'Hepatitis A',
    'Hepatitis A virus'
FROM rlt_static.pathogen_family
WHERE family_code = 'HEPATITIS';


INSERT INTO rlt_static.pathogen (
    pathogen_code,
    pathogen_family_id,
    pathogen_name,
    description
)
SELECT
    'HBV',
    pathogen_family_id,
    'Hepatitis B',
    'Hepatitis B virus'
FROM rlt_static.pathogen_family
WHERE family_code = 'HEPATITIS';


INSERT INTO rlt_static.pathogen (
    pathogen_code,
    pathogen_family_id,
    pathogen_name,
    description
)
SELECT
    'HCV',
    pathogen_family_id,
    'Hepatitis C',
    'Hepatitis C virus'
FROM rlt_static.pathogen_family
WHERE family_code = 'HEPATITIS';


-- ============================================================
-- TEST TYPES
-- ============================================================

INSERT INTO rlt_static.test_type (
    test_type_code,
    test_type_name,
    description
)
VALUES
(
    'VIRAL_LOAD',
    'Viral Load',
    'Quantification of viral nucleic acid'
),
(
    'IDENTIFICATION',
    'Identification',
    'Identification of pathogen'
),
(
    'ANTIGEN',
    'Antigen Testing',
    'Detection of pathogen antigen'
),
(
    'ANTIBODY',
    'Antibody Testing',
    'Detection of antibodies associated with infection'
),
(
    'AMR',
    'Antimicrobial Resistance',
    'Testing for antimicrobial resistance'
);


-- ============================================================
-- PATHOGEN TEST
--
-- Hepatitis C + Viral Load
-- ============================================================

INSERT INTO rlt_static.pathogen_test (
    pathogen_test_code,
    pathogen_id,
    test_type_id,
    display_name,
    lims_code,
    default_duration_minutes,
    base_charge,
    currency_code,
    active
)
SELECT
    'HCV_VIRAL_LOAD',
    p.pathogen_id,
    tt.test_type_id,
    'Hepatitis C Viral Load',
    'HCVVL',
    1440,
    50.00,
    'GBP',
    TRUE
FROM rlt_static.pathogen p
CROSS JOIN rlt_static.test_type tt
WHERE p.pathogen_code = 'HCV'
AND tt.test_type_code = 'VIRAL_LOAD';


COMMIT;