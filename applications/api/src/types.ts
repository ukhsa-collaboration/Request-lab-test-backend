export interface LabTestRequest {
  requestId: string;

  patient: {
    nhsNumber: string;
    firstName: string;
    lastName: string;
    dateOfBirth: string;
    gender?: "male" | "female" | "other" | "unknown";
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
    localCode: string;
    display: string;
  };

  specimen: {
    type: string;
    collectedAt?: string;
  };

  clinicalInformation?: string;

  requestedAt: string;
}