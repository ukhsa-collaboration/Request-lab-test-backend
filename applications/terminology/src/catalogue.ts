import type {
  TestTerminology
} from "./types.js";


const SNOMED =
  "http://snomed.info/sct";


export const terminologyCatalogue:
  TestTerminology[] = [
  {
    localCode:
      "HBA1C",

    display:
      "Haemoglobin A1c",

    request: {
      palmProcedure: {
        system:
          SNOMED,
        code:
          "43396009",
        display:
          "Haemoglobin A1c measurement"
      }
    },

    result: {
      palmObservable: {
        system:
            "http://snomed.info/sct",
        code:
            "999791000000106",
        display:
            "Haemoglobin A1c level - International Federation of Clinical Chemistry and Laboratory Medicine standardised"
      },

      pbcl: {
        system:
          SNOMED,
        code:
          "999791000000106",
        display:
          "Haemoglobin A1c level - International Federation of Clinical Chemistry and Laboratory Medicine standardised"
      }
    },


    molis: {
      orderCode:
        "MOLIS-HBA1C",
      resultCode:
        "MOLIS-HBA1C-RESULT"
    }
  }
];