BEGIN;

-- ============================================================
-- ROLES
-- ============================================================

INSERT INTO rlt_static.role (
    role_code,
    role_name,
    description
)
VALUES
(
    'UKHSA_SYSTEM_ADMIN',
    'UKHSA System Administrator',
    'Global administration of RLT static data'
),
(
    'CUSTOMER_SITE_ADMIN',
    'Customer Site Administrator',
    'Administration restricted to assigned customer sites'
),
(
    'CUSTOMER_USER',
    'Customer User',
    'Standard customer user with access to assigned sites'
),
(
    'UKHSA_LAB_ADMIN',
    'UKHSA Laboratory Administrator',
    'Administration of laboratory-related configuration'
);

-- ============================================================
-- USERS
--
-- These identities are POC values only.
-- ============================================================

INSERT INTO rlt_static.app_user (
    external_user_id,
    email,
    display_name,
    identity_provider
)
VALUES
(
    'poc-ukhsa-admin-001',
    'ukhsa.admin@example.test',
    'POC UKHSA Administrator',
    'POC_IDP'
),
(
    'poc-newcastle-admin-001',
    'newcastle.admin@example.test',
    'POC Newcastle Site Administrator',
    'POC_IDP'
);

INSERT INTO rlt_static.user_role (
    user_role_code,
    user_id,
    role_id
)
SELECT
    'POC_UKHSA_ADMIN_SYSTEM_ADMIN',

    u.user_id,

    r.role_id

FROM rlt_static.app_user u

CROSS JOIN rlt_static.role r

WHERE u.external_user_id = 'poc-ukhsa-admin-001'

AND r.role_code = 'UKHSA_SYSTEM_ADMIN';



INSERT INTO rlt_static.user_role (
    user_role_code,
    user_id,
    role_id
)
SELECT
    'POC_NEWCASTLE_ADMIN_SITE_ADMIN',

    u.user_id,

    r.role_id

FROM rlt_static.app_user u

CROSS JOIN rlt_static.role r

WHERE u.external_user_id = 'poc-newcastle-admin-001'

AND r.role_code = 'CUSTOMER_SITE_ADMIN';

INSERT INTO rlt_static.user_site_access (
    access_code,
    user_id,
    customer_site_id,
    can_read,
    can_create,
    can_update,
    can_administer
)
SELECT
    'POC_NEWCASTLE_ADMIN_NCL_HIGH_ST',

    u.user_id,

    cs.customer_site_id,

    TRUE,
    TRUE,
    TRUE,
    TRUE

FROM rlt_static.app_user u

CROSS JOIN rlt_static.customer_site cs

WHERE u.external_user_id =
      'poc-newcastle-admin-001'

AND cs.site_code = 'NCL_HIGH_ST';


COMMIT;
