BEGIN;

-- ============================================================
-- BILLING GROUPS
-- ============================================================

INSERT INTO rlt_static.billing_group (
    billing_group_code,
    billing_group_name,
    billing_type,
    description
)
VALUES
(
    'BAU_FREE',
    'BAU Free',
    'FREE',
    'Business-as-usual testing provided without a charge'
),
(
    'BAU_COMMERCIAL',
    'BAU Commercial',
    'COMMERCIAL',
    'Business-as-usual testing charged commercially'
),
(
    'PROJECT_FREE',
    'Project Free',
    'FREE',
    'Testing funded under a project arrangement'
),
(
    'PROJECT_COMMERCIAL',
    'Project Commercial',
    'COMMERCIAL',
    'Commercial testing associated with a project'
),
(
    'SURVEY_FREE',
    'Survey Free',
    'FREE',
    'Testing provided as part of a surveillance programme'
),
(
    'MIXED',
    'Mixed Billing',
    'MIXED',
    'Billing determined according to additional business rules'
);

-- ============================================================
-- TARIFFS
-- ============================================================

INSERT INTO rlt_static.tariff (
    tariff_code,
    tariff_name,
    amount,
    currency,
    effective_from
)
VALUES
(
    'HCV_VL_STANDARD_2026',
    'HCV Viral Load Standard Tariff 2026',
    50.00,
    'GBP',
    DATE '2026-01-01'
),
(
    'HCV_VL_FREE_2026',
    'HCV Viral Load Free Tariff 2026',
    0.00,
    'GBP',
    DATE '2026-01-01'
);

-- ============================================================
-- HCV VIRAL LOAD -> COMMERCIAL TARIFF
-- ============================================================

INSERT INTO rlt_static.pathogen_test_tariff (
    relationship_code,
    pathogen_test_id,
    tariff_id,
    billing_group_id
)
SELECT
    'HCV_VL_BAU_COMMERCIAL_2026',

    pt.pathogen_test_id,

    tariff.tariff_id,

    bg.billing_group_id

FROM rlt_static.pathogen_test pt

CROSS JOIN rlt_static.tariff tariff

CROSS JOIN rlt_static.billing_group bg

WHERE pt.pathogen_test_code = 'HCV_VIRAL_LOAD'

AND tariff.tariff_code = 'HCV_VL_STANDARD_2026'

AND bg.billing_group_code = 'BAU_COMMERCIAL';

-- ============================================================
-- HCV VIRAL LOAD -> FREE TARIFF
-- ============================================================

INSERT INTO rlt_static.pathogen_test_tariff (
    relationship_code,
    pathogen_test_id,
    tariff_id,
    billing_group_id
)
SELECT
    'HCV_VL_BAU_FREE_2026',

    pt.pathogen_test_id,

    tariff.tariff_id,

    bg.billing_group_id

FROM rlt_static.pathogen_test pt

CROSS JOIN rlt_static.tariff tariff

CROSS JOIN rlt_static.billing_group bg

WHERE pt.pathogen_test_code = 'HCV_VIRAL_LOAD'

AND tariff.tariff_code = 'HCV_VL_FREE_2026'

AND bg.billing_group_code = 'BAU_FREE';


-- ============================================================
-- CUSTOMER TEAM -> BILLING GROUP
-- ============================================================

INSERT INTO rlt_static.site_billing_rule (
    billing_rule_code,
    customer_site_id,
    customer_team_id,
    billing_group_id,
    effective_from,
    active
)
SELECT
    'NCL_SEXUAL_HEALTH_BAU_FREE',

    cs.customer_site_id,

    ct.customer_team_id,

    bg.billing_group_id,

    CURRENT_DATE,

    TRUE

FROM rlt_static.customer_site cs

JOIN rlt_static.customer_team ct
    ON ct.customer_site_id =
       cs.customer_site_id

CROSS JOIN rlt_static.billing_group bg

WHERE cs.site_code = 'NCL_HIGH_ST'

AND ct.team_code = 'NCL_SEXUAL_HEALTH'

AND bg.billing_group_code = 'BAU_FREE';


COMMIT;
