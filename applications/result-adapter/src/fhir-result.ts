import { randomUUID } from "node:crypto";

import type {
  CanonicalLabResult
} from "./types.js";


const SNOMED_SYSTEM =
  "http://snomed.info/sct";

const NHS_NUMBER_SYSTEM =
  "https://fhir.nhs.uk/Id/nhs-number";

const UCUM_SYSTEM =
  "http://unitsofmeasure.org";


// --------------------------------------------------
// UK Core / UK Core Lab profiles
// --------------------------------------------------

const PROFILE_DIAGNOSTIC_REPORT =
  "https://fhir.hl7.org.uk/StructureDefinition/UKCore-DiagnosticReport-Lab";

const PROFILE_OBSERVATION =
  "https://fhir.hl7.org.uk/StructureDefinition/UKCore-Observation-Lab";


// --------------------------------------------------
// Main mapper
// --------------------------------------------------

export function buildFhirResultBundle(
  result: CanonicalLabResult
) {

  const diagnosticReportId =
    `report-${result.accessionNumber}`;

  const observationId =
    result.resultId ||
    randomUUID();


  const observationReference =
    `Observation/${observationId}`;


  const patientDisplay =
    buildPatientDisplay(result);


  // ==================================================
  // Observation
  // ==================================================

  const observation = {

    resourceType:
      "Observation",

    id:
      observationId,

    meta: {

      profile: [
        PROFILE_OBSERVATION
      ]
    },

    status:
      mapObservationStatus(
        result.status
      ),

    code: {

      coding: [

        {
          system:
            result.test.palmObservable?.system
            ??
            SNOMED_SYSTEM,

          code:
            result.test.palmObservable?.code
            ??
            result.test.localCode
            ??
            "UNKNOWN",

          display:
            result.test.palmObservable?.display
            ??
            result.test.display
        }

      ],

      text:
        result.test.display
    },


    subject: {

      identifier: {

        system:
          NHS_NUMBER_SYSTEM,

        value:
          result.patient.nhsNumber
      },

      display:
        patientDisplay
    },


    effectiveDateTime:
      result.issuedAt,


    issued:
      result.issuedAt,


    valueQuantity: {

      value:
        result.result.value,

      unit:
        result.result.unit,

      system:
        UCUM_SYSTEM,

      code:
        result.result.unit === "mmol/mol"
          ? "mmol/mol"
          : undefined
    },


    referenceRange:
      result.result.referenceRange
        ? [
            {
              low:
                result.result.referenceRange.low !==
                undefined
                  ? {
                      value:
                        result.result.referenceRange.low,

                      unit:
                        result.result.referenceRange.unit
                        ??
                        result.result.unit,

                      system:
                        UCUM_SYSTEM,

                      code:
                        result.result.referenceRange.unit
                        ??
                        result.result.unit
                    }
                  : undefined,

              high:
                result.result.referenceRange.high !==
                undefined
                  ? {
                      value:
                        result.result.referenceRange.high,

                      unit:
                        result.result.referenceRange.unit
                        ??
                        result.result.unit,

                      system:
                        UCUM_SYSTEM,

                      code:
                        result.result.referenceRange.unit
                        ??
                        result.result.unit
                    }
                  : undefined
            }
          ]
        : undefined,


    interpretation:
      result.result.interpretation
        ? [
            {
              text:
                result.result.interpretation
            }
          ]
        : undefined
  };


  // ==================================================
  // DiagnosticReport
  // ==================================================

  const diagnosticReport = {

    resourceType:
      "DiagnosticReport",

    id:
      diagnosticReportId,

    meta: {

      profile: [
        PROFILE_DIAGNOSTIC_REPORT
      ]
    },


    status:
      mapDiagnosticReportStatus(
        result.status
      ),


    code: {

      coding: [

        {
          system:
            result.test.palmObservable?.system
            ??
            SNOMED_SYSTEM,

          code:
            result.test.palmObservable?.code
            ??
            result.test.localCode
            ??
            "UNKNOWN",

          display:
            result.test.palmObservable?.display
            ??
            result.test.display
        }

      ],

      text:
        result.test.display
    },


    subject: {

      identifier: {

        system:
          NHS_NUMBER_SYSTEM,

        value:
          result.patient.nhsNumber
      },

      display:
        patientDisplay
    },


    effectiveDateTime:
      result.issuedAt,


    issued:
      result.issuedAt,


    performer:
      result.laboratory?.name
        ? [
            {
              display:
                result.laboratory.name
            }
          ]
        : undefined,


    result: [

      {
        reference:
          observationReference
      }

    ],


    conclusion:
      result.result.interpretation
  };


  // ==================================================
  // Bundle
  // ==================================================

  return {

    resourceType:
      "Bundle",

    id:
      randomUUID(),

    type:
      "collection",

    entry: [

      {

        fullUrl:
          `urn:uuid:${diagnosticReportId}`,

        resource:
          diagnosticReport

      },

      {

        fullUrl:
          `urn:uuid:${observationId}`,

        resource:
          observation

      }

    ]
  };
}


// ==================================================
// Helpers
// ==================================================

function buildPatientDisplay(
  result: CanonicalLabResult
): string {

  return [
    result.patient.firstName,
    result.patient.lastName
  ]
    .filter(Boolean)
    .join(" ");
}


function mapObservationStatus(
  status: CanonicalLabResult["status"]
) {

  switch (status) {

    case "FINAL":
      return "final";

    case "CANCELLED":
      return "cancelled";

    case "PRELIMINARY":
    default:
      return "preliminary";
  }
}


function mapDiagnosticReportStatus(
  status: CanonicalLabResult["status"]
) {

  switch (status) {

    case "FINAL":
      return "final";

    case "CANCELLED":
      return "cancelled";

    case "PRELIMINARY":
    default:
      return "preliminary";
  }
}