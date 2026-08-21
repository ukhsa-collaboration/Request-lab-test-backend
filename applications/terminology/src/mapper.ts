import {
  terminologyCatalogue
} from "./catalogue.js";

import type {
  TestTerminology
} from "./types.js";


export function findByLocalCode(
  localCode: string
): TestTerminology | undefined {

  return terminologyCatalogue.find(
    item =>
      item.localCode.toLowerCase() ===
      localCode.toLowerCase()
  );
}


export function findByPalmProcedure(
  code: string
): TestTerminology | undefined {

  return terminologyCatalogue.find(
    item =>
      item.request
        .palmProcedure
        ?.code === code
  );
}


export function findByPalmObservable(
  code: string
): TestTerminology | undefined {

  return terminologyCatalogue.find(
    item =>
      item.result
        .palmObservable
        ?.code === code
  );
}


export function findByPbcl(
  code: string
): TestTerminology | undefined {

  return terminologyCatalogue.find(
    item =>
      item.result
        .pbcl
        ?.code === code
  );
}


export function findByMolisResultCode(
  code: string
): TestTerminology | undefined {

  return terminologyCatalogue.find(
    item =>
      item.molis.resultCode === code
  );
}