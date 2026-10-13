BEGIN;

-- ============================================================
-- TESTING ORGANISATION
-- ============================================================

INSERT INTO rlt_static.testing_organisation (
    organisation_code,
    organisation_name,
    organisation_type
)
VALUES (
    'UKHSA',
    'UK Health Security Agency',
    'PUBLIC_HEALTH'
);

-- ============================================================
-- TESTING LAB
-- ============================================================

INSERT INTO rlt_static.testing_lab_site (
    lab_site_code,
    testing_organisation_id,
    lab_name,
    address,
    postcode,
    contact_details
)
SELECT
    'COLINDALE_VIROLOGY',

    testing_organisation_id,

    'Colindale Virology Laboratory',

    'Colindale, London',

    'NW9',

    'POC contact details'

FROM rlt_static.testing_organisation

WHERE organisation_code = 'UKHSA';

-- ============================================================
-- SAMPLE RECEPTION
-- ============================================================

INSERT INTO rlt_static.sample_reception_site (
    reception_site_code,
    testing_organisation_id,
    reception_name,
    address,
    postcode
)
SELECT
    'COLINDALE_SR',

    testing_organisation_id,

    'Colindale Sample Reception',

    'Colindale, London',

    'NW9'

FROM rlt_static.testing_organisation

WHERE organisation_code = 'UKHSA';


-- ============================================================
-- LAB -> SAMPLE RECEPTION
-- ============================================================

INSERT INTO rlt_static.lab_sample_reception (
    relationship_code,
    testing_lab_site_id,
    sample_reception_site_id,
    primary_reception,
    active
)
SELECT
    'COLINDALE_VIROLOGY_COLINDALE_SR',

    lab.testing_lab_site_id,

    reception.sample_reception_site_id,

    TRUE,

    TRUE

FROM rlt_static.testing_lab_site lab

CROSS JOIN rlt_static.sample_reception_site reception

WHERE lab.lab_site_code = 'COLINDALE_VIROLOGY'

AND reception.reception_site_code = 'COLINDALE_SR';


-- ============================================================
-- HCV VIRAL LOAD -> COLINDALE VIROLOGY
-- ============================================================

INSERT INTO rlt_static.lab_pathogen_test (
    lab_test_code,
    testing_lab_site_id,
    pathogen_test_id,
    local_lims_code,
    turnaround_minutes,
    available,
    valid_from
)
SELECT
    'COLINDALE_HCV_VIRAL_LOAD',

    lab.testing_lab_site_id,

    pt.pathogen_test_id,

    'HCVVL',

    1440,

    TRUE,

    CURRENT_DATE

FROM rlt_static.testing_lab_site lab

CROSS JOIN rlt_static.pathogen_test pt

WHERE lab.lab_site_code = 'COLINDALE_VIROLOGY'

AND pt.pathogen_test_code = 'HCV_VIRAL_LOAD';


COMMIT;
