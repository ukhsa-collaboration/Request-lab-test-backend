
// export interface Coding {
//   system: string;
//   code: string;
//   display: string;
// }

// export interface TestTerminology {
//   localCode: string;
//   display: string;

//   specimenType: string;

//   palmRequestable?: Coding;

//   palmReportable?: Coding;

//   pbcl?: Coding;

//   molis: {
//     orderCode: string;
//     resultCode: string;
//   };
// }

export interface Coding {
  system: string;
  code: string;
  display: string;
}


export type TerminologySource =
  | "PALM_PROCEDURE"
  | "PALM_OBSERVABLE"
  | "PBCL"
  | "LOCAL";


export interface TestTerminology {

  localCode: string;

  display: string;

  request: {
    palmProcedure?: Coding;
  };

  result: {
    palmObservable?: Coding;
    pbcl?: Coding;
    local?: Coding;
  };

  molis: {
    orderCode: string;
    resultCode: string;
  };
}