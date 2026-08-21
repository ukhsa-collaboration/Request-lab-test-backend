import type {
  MolisOrder
} from "./types.js";


const SNOMED_SYSTEM =
  "http://snomed.info/sct";

const LOINC_SYSTEM =
  "http://loinc.org";


export function buildDiagnosticReport(
  order: MolisOrder
) {

  if (!order.result) {

    throw new Error(
      "Order does not contain a result"
    );
  }


  const result =
    order.result;


  const observationId =
    result.observationId;


  const reportId =
    `report-${order.accessionNumber}`;


  const observationReference =
    `Observation/${observationId}`;


  return {

    resourceType:
      "DiagnosticReport",

    id:
      reportId,

    status:
      "final",

    code: {

      coding: [

        {
          system:
            SNOMED_SYSTEM,

          code:
            result.testCode,

          display:
            result.testDisplay
        }

      ],

      text:
        result.testDisplay
    },


    subject: {

      identifier: {

        system:
          "https://fhir.nhs.uk/Id/nhs-number",

        value:
          order.patient.nhsNumber

      },

      display:
        `${order.patient.firstName} ${order.patient.lastName}`
    },


    effectiveDateTime:
      result.issuedAt,


    issued:
      result.issuedAt,


    performer: [

      {
        display:
          order.laboratory.name
      }

    ],


    result: [

      {
        reference:
          observationReference
      }

    ],


    conclusion:
      result.interpretation
  };
}


export function buildObservation(
  order: MolisOrder
) {

  if (!order.result) {

    throw new Error(
      "Order does not contain a result"
    );
  }


  const result =
    order.result;


  return {

    resourceType:
      "Observation",

    id:
      result.observationId,

    status:
      "final",


    code: {

      coding: [

        {
          system:
            SNOMED_SYSTEM,

          code:
            result.testCode,

          display:
            result.testDisplay
        }

      ],

      text:
        result.testDisplay
    },


    subject: {

      identifier: {

        system:
          "https://fhir.nhs.uk/Id/nhs-number",

        value:
          order.patient.nhsNumber
      },

      display:
        `${order.patient.firstName} ${order.patient.lastName}`
    },


    effectiveDateTime:
      result.issuedAt,


    valueQuantity: {

      value:
        result.value,

      unit:
        result.unit,

      system:
        "http://unitsofmeasure.org",

      code:
        "mmol/mol"
    },


    referenceRange: [

      {
        low: {

          value:
            result.referenceRange.low,

          unit:
            result.referenceRange.unit,

          system:
            "http://unitsofmeasure.org",

          code:
            "mmol/mol"
        },

        high: {

          value:
            result.referenceRange.high,

          unit:
            result.referenceRange.unit,

          system:
            "http://unitsofmeasure.org",

          code:
            "mmol/mol"
        }
      }

    ],


    interpretation: [

      {
        text:
          result.interpretation
      }

    ]
  };
}