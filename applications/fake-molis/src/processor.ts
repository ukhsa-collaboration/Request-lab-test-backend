import { randomUUID } from "node:crypto";

import {
  getOrder,
  updateOrder
} from "./store.js";

import type {
  LabResult,
  MolisOrder
} from "./types.js";


let accessionSequence = 10000;


export function generateAccessionNumber(): string {

  accessionSequence++;

  return `MOLIS-${accessionSequence}`;
}


export function processOrder(
  accessionNumber: string
): MolisOrder | undefined {

  const order =
    getOrder(accessionNumber);

  if (!order) {
    return undefined;
  }


  // ----------------------------------------------
  // SPECIMEN_RECEIVED
  // ----------------------------------------------

  updateOrder(
    accessionNumber,
    {
      status: "SPECIMEN_RECEIVED"
    }
  );


  // ----------------------------------------------
  // IN_PROGRESS
  // ----------------------------------------------

  updateOrder(
    accessionNumber,
    {
      status: "IN_PROGRESS"
    }
  );


  // ----------------------------------------------
  // Generate HbA1c result
  // ----------------------------------------------

  const result: LabResult = {

    observationId:
      randomUUID(),

    testCode:
      "43396009",

    testDisplay:
      "Haemoglobin A1c measurement",

    // Example fake result
    value:
      48,

    unit:
      "mmol/mol",

    referenceRange: {
      low: 20,
      high: 42,
      unit: "mmol/mol"
    },

    interpretation:
      "ABNORMAL",

    issuedAt:
      new Date().toISOString()
  };


  // ----------------------------------------------
  // RESULT_AVAILABLE
  // ----------------------------------------------

  return updateOrder(
    accessionNumber,
    {
      status: "RESULT_AVAILABLE",
      result
    }
  );
}