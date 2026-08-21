export type MolisOrderStatus =
  | "RECEIVED"
  | "SPECIMEN_RECEIVED"
  | "IN_PROGRESS"
  | "RESULT_AVAILABLE"
  | "CANCELLED"
  | "ERROR";


export interface MolisOrder {

  accessionNumber: string;

  requestId: string;

  status: MolisOrderStatus;

  receivedAt: string;

  patient: {
    nhsNumber: string;
    firstName: string;
    lastName: string;
    dateOfBirth: string;
  };

  requester: {
    practitionerId: string;
    name: string;
    organisationCode: string;
  };

  laboratory: {
    organisationCode: string;
    name: string;
  };

  test: {
    code: string;
    display: string;
  };

  specimen: {
    id: string;
    type: string;
  };

  result?: LabResult;
}


export interface LabResult {

  observationId: string;

  testCode: string;

  testDisplay: string;

  value: number;

  unit: string;

  referenceRange: {
    low: number;
    high: number;
    unit: string;
  };

  interpretation: string;

  issuedAt: string;
}