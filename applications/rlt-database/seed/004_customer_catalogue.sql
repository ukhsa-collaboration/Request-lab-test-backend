BEGIN;

-- ============================================================
-- CUSTOMER ORGANISATION
-- ============================================================

INSERT INTO rlt_static.customer_organisation (
    organisation_code,
    organisation_name,
    organisation_type,
    description
)
VALUES (
    'NHS_NEWCASTLE',
    'Newcastle NHS Organisation',
    'NHS',
    'POC customer organisation'
);


-- ============================================================
-- CUSTOMER SITE
-- ============================================================

INSERT INTO rlt_static.customer_site (
    site_code,
    customer_organisation_id,
    site_name,
    site_type,
    address,
    postcode,
    molis_customer_code
)
SELECT
    'NCL_HIGH_ST',

    customer_organisation_id,

    'Newcastle Lab High Street',

    'LABORATORY',

    'High Street, Newcastle upon Tyne',

    'NE1 1AA',

    'NCL001'

FROM rlt_static.customer_organisation

WHERE organisation_code = 'NHS_NEWCASTLE';


-- ============================================================
-- CUSTOMER TEAM
-- ============================================================

INSERT INTO rlt_static.customer_team (
    team_code,
    customer_site_id,
    team_name,
    description
)
SELECT
    'NCL_SEXUAL_HEALTH',

    customer_site_id,

    'Sexual Health Clinic',

    'Sexual health requesting team'

FROM rlt_static.customer_site

WHERE site_code = 'NCL_HIGH_ST';


COMMIT;