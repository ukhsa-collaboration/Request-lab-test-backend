export interface Coding {
  system: string;
  code: string;
  display?: string;
}

export interface CanonicalLabRequest {
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

export interface ResolvedTerminology {
  status: string;

  test: {
    localCode: string;
    display: string;
    specimenType: string;

    palmRequestable?: Coding;

    palmReportable?: Coding;

    pbcl?: Coding;

    molis: {
      orderCode: string;
      resultCode: string;
    };
  };
}

export interface FhirAdapterRequest {
  request: CanonicalLabRequest;
  terminology: ResolvedTerminology;
}