import { uuid, urnUuid } from "./ids.js";

import type {
  CanonicalLabRequest,
  FhirAdapterRequest
} from "./types.js";


const FHIR_SYSTEM_SNOMED =
  "http://snomed.info/sct";

const NHS_NUMBER_SYSTEM =
  "https://fhir.nhs.uk/Id/nhs-number";

const ODS_ORGANISATION_SYSTEM =
  "https://fhir.nhs.uk/Id/ods-organization-code";

const GMC_SYSTEM =
  "https://fhir.hl7.org.uk/Id/gmc-number";

const PROFILE_BUNDLE =
  "https://fhir.hl7.org.uk/StructureDefinition/UKCore-Bundle";

const PROFILE_MESSAGE_HEADER =
  "https://fhir.hl7.org.uk/StructureDefinition/UKCore-MessageHeader";

const PROFILE_PATIENT =
  "https://fhir.hl7.org.uk/StructureDefinition/UKCore-Patient";

const PROFILE_PRACTITIONER =
  "https://fhir.hl7.org.uk/StructureDefinition/UKCore-Practitioner";

const PROFILE_ORGANIZATION =
  "https://fhir.hl7.org.uk/StructureDefinition/UKCore-Organization";

const PROFILE_SERVICE_REQUEST =
  "https://fhir.hl7.org.uk/StructureDefinition/UKCore-ServiceRequest-Lab";

const PROFILE_SPECIMEN =
  "https://fhir.hl7.org.uk/StructureDefinition/UKCore-Specimen";


export function buildPathologyRequestBundle(
  input: FhirAdapterRequest
) {

  const request: CanonicalLabRequest =
    input.request;

  const terminology =
    input.terminology.test;


  // ----------------------------------------------
  // Generate IDs
  // ----------------------------------------------

  const bundleId = uuid();

  const messageHeaderId = uuid();

  const patientId = uuid();

  const requesterOrgId = uuid();

  const laboratoryOrgId = uuid();

  const practitionerId = uuid();

  const serviceRequestId = uuid();

  const specimenId = uuid();


  // ----------------------------------------------
  // URN references
  // ----------------------------------------------

  const patientRef = urnUuid(patientId);

  const requesterOrgRef =
    urnUuid(requesterOrgId);

  const laboratoryOrgRef =
    urnUuid(laboratoryOrgId);

  const practitionerRef =
    urnUuid(practitionerId);

  const serviceRequestRef =
    urnUuid(serviceRequestId);

  const specimenRef =
    urnUuid(specimenId);

  const messageHeaderRef =
    urnUuid(messageHeaderId);


  // ----------------------------------------------
  // Bundle
  // ----------------------------------------------

  const bundle = {

    resourceType: "Bundle",

    id: bundleId,

    meta: {
      profile: [
        PROFILE_BUNDLE
      ],

      lastUpdated: request.requestedAt
    },

    type: "message",

    entry: [

      // ------------------------------------------
      // MessageHeader
      // ------------------------------------------

      {
        fullUrl: messageHeaderRef,

        resource: {

          resourceType: "MessageHeader",

          id: messageHeaderId,

          meta: {
            profile: [
              PROFILE_MESSAGE_HEADER
            ]
          },

          eventCoding: {
            system: FHIR_SYSTEM_SNOMED,

            // Taken from the Pathology IG
            // HbA1c request example.
            code: "371528001",

            display: "Pathology report"
          },

          destination: [
            {
              name: request.laboratory.name,

              endpoint: "http://localhost:4010/molis",

              receiver: {
                reference: laboratoryOrgRef
              }
            }
          ],

          sender: {
            reference: requesterOrgRef
          },

          source: {
            endpoint: "http://localhost:4002"
          },

          focus: [
            {
              reference: serviceRequestRef
            }
          ],

          definition:
            "https://fhir.nhs.uk/England/MessageDefinition/England-Pathology-Request"
        }
      },


      // ------------------------------------------
      // Performing Organization
      // ------------------------------------------

      {
        fullUrl: laboratoryOrgRef,

        resource: {

          resourceType: "Organization",

          id: laboratoryOrgId,

          meta: {
            profile: [
              PROFILE_ORGANIZATION
            ]
          },

          identifier: [
            {
              system: ODS_ORGANISATION_SYSTEM,

              value:
                request.laboratory.organisationCode
            }
          ],

          name: request.laboratory.name
        }
      },


      // ------------------------------------------
      // Requesting Organization
      // ------------------------------------------

      {
        fullUrl: requesterOrgRef,

        resource: {

          resourceType: "Organization",

          id: requesterOrgId,

          meta: {
            profile: [
              PROFILE_ORGANIZATION
            ]
          },

          identifier: [
            {
              system: ODS_ORGANISATION_SYSTEM,

              value:
                request.requester.organisationCode
            }
          ],

          name:
            request.requester.organisationCode
        }
      },


      // ------------------------------------------
      // Practitioner
      // ------------------------------------------

      {
        fullUrl: practitionerRef,

        resource: {

          resourceType: "Practitioner",

          id: practitionerId,

          meta: {
            profile: [
              PROFILE_PRACTITIONER
            ]
          },

          identifier: [
            {
              system: GMC_SYSTEM,

              value:
                request.requester.practitionerId
            }
          ],

          name: [
            {
              use: "official",

              text:
                request.requester.name
            }
          ]
        }
      },


      // ------------------------------------------
      // Patient
      // ------------------------------------------

      {
        fullUrl: patientRef,

        resource: {

          resourceType: "Patient",

          id: patientId,

          meta: {
            profile: [
              PROFILE_PATIENT
            ]
          },

          identifier: [
            {
              system: NHS_NUMBER_SYSTEM,

              value:
                request.patient.nhsNumber
            }
          ],

          name: [
            {
              use: "official",

              family:
                request.patient.lastName,

              given: [
                request.patient.firstName
              ]
            }
          ],

          gender:
            request.patient.gender,

          birthDate:
            request.patient.dateOfBirth
        }
      },


      // ------------------------------------------
      // ServiceRequest
      // ------------------------------------------

      {
        fullUrl: serviceRequestRef,

        resource: {

          resourceType: "ServiceRequest",

          id: serviceRequestId,

          meta: {
            profile: [
              PROFILE_SERVICE_REQUEST
            ]
          },

          identifier: [
            {
              system:
                "https://rlt.example/request",

              value:
                request.requestId
            }
          ],

          status: "active",

          intent: "order",

          priority: "routine",

          code: {

            coding: [
              {
                system:
                  terminology.palmRequestable?.system
                  ?? FHIR_SYSTEM_SNOMED,

                code:
                  terminology.palmRequestable?.code
                  ?? "",

                display:
                  terminology.palmRequestable?.display
                  ?? request.test.display
              }
            ]
          },

          subject: {

            reference:
              patientRef,

            display:
              `${request.patient.firstName} ${request.patient.lastName}`
          },

          authoredOn:
            request.requestedAt,

          requester: {

            reference:
              practitionerRef,

            display:
              request.requester.name
          },

          performer: [

            {
              reference:
                laboratoryOrgRef,

              display:
                request.laboratory.name
            }
          ],

          specimen: [

            {
              reference:
                specimenRef
            }
          ],

          reasonCode:
            request.clinicalInformation
              ? [
                  {
                    text:
                      request.clinicalInformation
                  }
                ]
              : undefined
        }
      },


      // ------------------------------------------
      // Specimen
      // ------------------------------------------

      {
        fullUrl: specimenRef,

        resource: {

          resourceType: "Specimen",

          id: specimenId,

          meta: {
            profile: [
              PROFILE_SPECIMEN
            ]
          },

          identifier: [
            {
              system:
                "https://rlt.example/specimen",

              value:
                `${request.requestId}-SPECIMEN`
            }
          ],

          status: "available",

          type: {

            coding: [

              {
                system:
                  FHIR_SYSTEM_SNOMED,

                // Venous blood specimen
                code:
                  "122555007",

                display:
                  "Venous blood specimen"
              }

            ]
          },

          subject: {

            reference:
              patientRef,

            display:
              `${request.patient.firstName} ${request.patient.lastName}`
          },

          collection:
            request.specimen.collectedAt
              ? {
                  collectedDateTime:
                    request.specimen.collectedAt
                }
              : undefined
        }
      }

    ]
  };


  return bundle;
}