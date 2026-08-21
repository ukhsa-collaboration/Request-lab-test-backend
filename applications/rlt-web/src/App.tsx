import { useState } from "react";
import type { SyntheticEvent } from "react";

import "./App.css";
import type { RltState } from "./types";
import RequestProgress from "./components/RequestProgress";

const ORCHESTRATOR_URL =
  import.meta.env.VITE_ORCHESTRATOR_URL ??
  "http://localhost:4005";

interface LabRequest {
  requestId: string;

  patient: {
    nhsNumber: string;
    firstName: string;
    lastName: string;
    dateOfBirth: string;
    gender: string;
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
  };

  clinicalInformation: string;
  requestedAt: string;
}

interface RequestStatus {
  requestId: string;
  state: RltState;
  progress: number;
  message: string;
  updatedAt: string;
  error?: string;
}

interface OrchestrationResponse {
  status: string;
  requestId: string;
  accessionNumber?: string;

  canonicalRequest?: unknown;
  fhirRequest?: unknown;
  molis?: unknown;
  molisProcess?: unknown;
  fhirResult?: any;
  canonicalResult?: any;
  fhirDocument?: any;

  validation?: {
    valid: boolean;
    resourceCount: number;
  };
}

interface FormState {
  nhsNumber: string;
  firstName: string;
  lastName: string;
  dateOfBirth: string;
  gender: string;
  test: string;
  specimen: string;
  clinicalInformation: string;
}

const INITIAL_FORM: FormState = {
  nhsNumber: "9999999999",
  firstName: "John",
  lastName: "Smith",
  dateOfBirth: "1975-03-12",
  gender: "male",
  test: "HBA1C",
  specimen: "Blood specimen",
  clinicalInformation: "Routine diabetes monitoring",
};

function createRequestId(): string {
  return `RLT-${Date.now()}`;
}

function findResource(
  bundle: any,
  resourceType: string
): any | undefined {
  if (!bundle?.entry || !Array.isArray(bundle.entry)) {
    return undefined;
  }

  return bundle.entry
    .map((entry: any) => entry?.resource)
    .find(
      (resource: any) =>
        resource?.resourceType === resourceType
    );
}

function App() {
  const [form, setForm] =
    useState<FormState>(INITIAL_FORM);

  const [requestId, setRequestId] =
    useState<string | null>(null);

  const [requestStatus, setRequestStatus] =
    useState<RequestStatus | null>(null);

  const [result, setResult] =
    useState<OrchestrationResponse | null>(null);

  const [error, setError] =
    useState<string | null>(null);

  const [submitting, setSubmitting] =
    useState(false);

  const [showTechnicalDetails, setShowTechnicalDetails] =
    useState(false);

  function updateField(
    field: keyof FormState,
    value: string
  ) {
    setForm((previous) => ({
      ...previous,
      [field]: value,
    }));
  }

  async function getRequestStatus(
    id: string
  ): Promise<RequestStatus> {
    const response = await fetch(
      `${ORCHESTRATOR_URL}/lab-requests/${id}/status`
    );

    const data = await response.json();

    if (!response.ok) {
      throw new Error(
        data?.message ??
          "Unable to retrieve request status"
      );
    }

    return data;
  }

  async function submitRequest(
    event: SyntheticEvent<HTMLFormElement>
  ) {
    event.preventDefault();

    setError(null);
    setResult(null);
    setRequestStatus(null);
    setShowTechnicalDetails(false);

    const id = createRequestId();

    setRequestId(id);
    setSubmitting(true);

    /*
     * This is the canonical request that the
     * orchestrator expects.
     */
    const request: LabRequest = {
      requestId: id,

      patient: {
        nhsNumber: form.nhsNumber,
        firstName: form.firstName,
        lastName: form.lastName,
        dateOfBirth: form.dateOfBirth,
        gender: form.gender,
      },

      requester: {
        practitionerId: "GMC-1234567",
        name: "Dr John Smith",
        organisationCode: "RLT001",
      },

      laboratory: {
        organisationCode: "LAB001",
        name: "Fake MOLIS Pathology Laboratory",
      },

      test: {
        localCode: form.test,
        display: "Haemoglobin A1c",
      },

      specimen: {
        type: form.specimen,
      },

      clinicalInformation:
        form.clinicalInformation,

      requestedAt:
        new Date().toISOString(),
    };

    /*
     * Show the initial UI state.
     */
    setRequestStatus({
      requestId: id,
      state: "SUBMITTED",
      progress: 5,
      message:
        "Laboratory request submitted",
      updatedAt: new Date().toISOString(),
    });

    try {
      const response = await fetch(
        `${ORCHESTRATOR_URL}/lab-requests`,
        {
          method: "POST",

          headers: {
            "Content-Type":
              "application/json",
          },

          body: JSON.stringify(request),
        }
      );

      const data =
        await response.json();

      if (!response.ok) {
        throw new Error(
          data?.message ??
            "Laboratory request failed"
        );
      }

      /*
       * The current POC orchestrator returns
       * the complete response synchronously.
       */
      setResult(data);

      /*
       * Try the status endpoint if it exists.
       *
       * If the current orchestrator doesn't have
       * it yet, simply show COMPLETED because the
       * POST itself completed successfully.
       */
      try {
        const finalStatus =
          await getRequestStatus(id);

        setRequestStatus(
          finalStatus
        );
      } catch {
        setRequestStatus({
          requestId: id,
          state: "COMPLETED",
          progress: 100,
          message:
            "Laboratory request completed",
          updatedAt:
            new Date().toISOString(),
        });
      }
    } catch (err) {
      const message =
        err instanceof Error
          ? err.message
          : "Unable to submit laboratory request";

      setError(message);

      setRequestStatus({
        requestId: id,
        state: "FAILED",
        progress: 0,
        message,
        updatedAt:
          new Date().toISOString(),
        error: message,
      });
    } finally {
      setSubmitting(false);
    }
  }

  function resetForm() {
    setForm(INITIAL_FORM);
    setRequestId(null);
    setRequestStatus(null);
    setResult(null);
    setError(null);
    setShowTechnicalDetails(false);
  }

  const observation =
    findResource(
      result?.fhirDocument,
      "Observation"
    );

  const diagnosticReport =
    findResource(
      result?.fhirDocument,
      "DiagnosticReport"
    );

  const resultValue =
    observation?.valueQuantity?.value ??
    result?.canonicalResult?.result?.value;

  const resultUnit =
    observation?.valueQuantity?.unit ??
    result?.canonicalResult?.result?.unit ??
    "";

  const interpretation =
    observation?.interpretation?.[0]?.text ??
    result?.canonicalResult?.result?.interpretation ??
    diagnosticReport?.conclusion ??
    "—";

  const referenceLow =
    observation?.referenceRange?.[0]?.low?.value ??
    result?.canonicalResult?.result?.referenceRange?.low;

  const referenceHigh =
    observation?.referenceRange?.[0]?.high?.value ??
    result?.canonicalResult?.result?.referenceRange?.high;

  const referenceUnit =
    observation?.referenceRange?.[0]?.low?.unit ??
    result?.canonicalResult?.result?.referenceRange?.unit ??
    resultUnit;

  const isAbnormal =
    interpretation === "ABNORMAL";

  return (
    <div className="app">

      {/* ===================================== */}
      {/* HEADER */}
      {/* ===================================== */}

      <header className="app-header">

        <div className="header-inner">

          <div className="brand">

            <div className="brand-mark">
              RLT
            </div>

            <div>

              <h1>
                Request Lab Test
              </h1>

              <p>
                Digital pathology test request
              </p>

            </div>

          </div>

          <div className="environment-badge">
            POC
          </div>

        </div>

      </header>


      {/* ===================================== */}
      {/* MAIN */}
      {/* ===================================== */}

      <main className="app-container">

        {/* =================================== */}
        {/* FORM */}
        {/* =================================== */}

        {!result && (

          <section className="card">

            <div className="card-header">

              <div>

                <div className="eyebrow">
                  NEW REQUEST
                </div>

                <h2>
                  Request a laboratory test
                </h2>

                <p>
                  Enter the patient, test and
                  clinical information required
                  to create a pathology request.
                </p>

              </div>

            </div>


            <form
              onSubmit={submitRequest}
            >

              {/* ============================= */}
              {/* PATIENT */}
              {/* ============================= */}

              <div className="form-section">

                <div className="section-title">

                  <span className="section-number">
                    1
                  </span>

                  <div>

                    <h3>
                      Patient details
                    </h3>

                    <p>
                      Identify the patient for
                      whom the test is required.
                    </p>

                  </div>

                </div>


                <div className="form-grid">

                  <div className="field">

                    <label>
                      NHS Number
                    </label>

                    <input
                      value={
                        form.nhsNumber
                      }
                      onChange={(event) =>
                        updateField(
                          "nhsNumber",
                          event.target.value
                        )
                      }
                      placeholder="9999999999"
                      required
                    />

                  </div>


                  <div className="field">

                    <label>
                      First name
                    </label>

                    <input
                      value={
                        form.firstName
                      }
                      onChange={(event) =>
                        updateField(
                          "firstName",
                          event.target.value
                        )
                      }
                      required
                    />

                  </div>


                  <div className="field">

                    <label>
                      Last name
                    </label>

                    <input
                      value={
                        form.lastName
                      }
                      onChange={(event) =>
                        updateField(
                          "lastName",
                          event.target.value
                        )
                      }
                      required
                    />

                  </div>


                  <div className="field">

                    <label>
                      Date of birth
                    </label>

                    <input
                      type="date"
                      value={
                        form.dateOfBirth
                      }
                      onChange={(event) =>
                        updateField(
                          "dateOfBirth",
                          event.target.value
                        )
                      }
                      required
                    />

                  </div>


                  <div className="field">

                    <label>
                      Gender
                    </label>

                    <select
                      value={
                        form.gender
                      }
                      onChange={(event) =>
                        updateField(
                          "gender",
                          event.target.value
                        )
                      }
                    >

                      <option value="male">
                        Male
                      </option>

                      <option value="female">
                        Female
                      </option>

                      <option value="other">
                        Other
                      </option>

                      <option value="unknown">
                        Unknown
                      </option>

                    </select>

                  </div>

                </div>

              </div>


              {/* ============================= */}
              {/* TEST */}
              {/* ============================= */}

              <div className="form-section">

                <div className="section-title">

                  <span className="section-number">
                    2
                  </span>

                  <div>

                    <h3>
                      Laboratory test
                    </h3>

                    <p>
                      Select the test and
                      specimen required.
                    </p>

                  </div>

                </div>


                <div className="form-grid">

                  <div className="field">

                    <label>
                      Test
                    </label>

                    <select
                      value={
                        form.test
                      }
                      onChange={(event) =>
                        updateField(
                          "test",
                          event.target.value
                        )
                      }
                    >

                      <option value="HBA1C">
                        Haemoglobin A1c
                      </option>

                    </select>

                  </div>


                  <div className="field">

                    <label>
                      Specimen
                    </label>

                    <select
                      value={
                        form.specimen
                      }
                      onChange={(event) =>
                        updateField(
                          "specimen",
                          event.target.value
                        )
                      }
                    >

                      <option value="Blood specimen">
                        Blood specimen
                      </option>

                    </select>

                  </div>

                </div>

              </div>


              {/* ============================= */}
              {/* CLINICAL */}
              {/* ============================= */}

              <div className="form-section">

                <div className="section-title">

                  <span className="section-number">
                    3
                  </span>

                  <div>

                    <h3>
                      Clinical information
                    </h3>

                    <p>
                      Provide the clinical reason
                      for requesting the test.
                    </p>

                  </div>

                </div>


                <div className="field">

                  <label>
                    Reason for test
                  </label>

                  <textarea
                    value={
                      form.clinicalInformation
                    }
                    onChange={(event) =>
                      updateField(
                        "clinicalInformation",
                        event.target.value
                      )
                    }
                    rows={4}
                    placeholder="Enter clinical information"
                    required
                  />

                </div>

              </div>


              {/* ============================= */}
              {/* REQUESTER */}
              {/* ============================= */}

              <div className="form-section">

                <div className="section-title">

                  <span className="section-number">
                    4
                  </span>

                  <div>

                    <h3>
                      Requester
                    </h3>

                    <p>
                      The practitioner submitting
                      the request.
                    </p>

                  </div>

                </div>


                <div className="requester-summary">

                  <div className="requester-item">

                    <span>
                      Practitioner
                    </span>

                    <strong>
                      Dr John Smith
                    </strong>

                  </div>


                  <div className="requester-item">

                    <span>
                      GMC number
                    </span>

                    <strong>
                      GMC-1234567
                    </strong>

                  </div>


                  <div className="requester-item">

                    <span>
                      Organisation
                    </span>

                    <strong>
                      RLT001
                    </strong>

                  </div>

                </div>

              </div>


              {/* ============================= */}
              {/* SUBMIT */}
              {/* ============================= */}

              <div className="form-actions">

                <button
                  type="submit"
                  disabled={submitting}
                  className="primary-button"
                >

                  {submitting ? (
                    <>
                      <span className="spinner" />
                      Submitting request...
                    </>
                  ) : (
                    <>
                      Request lab test
                      <span className="button-arrow">
                        →
                      </span>
                    </>
                  )}

                </button>

              </div>

            </form>

          </section>

        )}


        {/* =================================== */}
        {/* ERROR */}
        {/* =================================== */}

        {error && (

          <section className="error-card">

            <div className="error-icon">
              !
            </div>

            <div>

              <h3>
                Request failed
              </h3>

              <p>
                {error}
              </p>

            </div>

          </section>

        )}


        {/* =================================== */}
        {/* PROGRESS */}
        {/* =================================== */}

        {requestStatus && (

          <section className="card progress-card">

            <RequestProgress
              state={
                requestStatus.state
              }
              progress={
                requestStatus.progress
              }
              message={
                requestStatus.message
              }
            />

            {requestId && (

              <div className="request-id">

                <span>
                  Request ID
                </span>

                <strong>
                  {requestId}
                </strong>

              </div>

            )}

          </section>

        )}


        {/* =================================== */}
        {/* RESULT */}
        {/* =================================== */}

        {result && (

          <section className="card result-card">

            <div className="result-header">

              <div>

                <div className="eyebrow">
                  LABORATORY RESULT
                </div>

                <h2>
                  {result.canonicalResult
                    ?.test?.display ??
                    diagnosticReport
                      ?.code?.text ??
                    "Laboratory result"}
                </h2>

                <p>
                  Final pathology result received
                  from the laboratory.
                </p>

              </div>

              <div className="completed-badge">
                <span>
                  ✓
                </span>
                Completed
              </div>

            </div>


            {/* ============================= */}
            {/* RESULT META */}
            {/* ============================= */}

            <div className="result-meta">

              <div className="result-meta-item">

                <span>
                  Request ID
                </span>

                <strong>
                  {result.requestId}
                </strong>

              </div>


              <div className="result-meta-item">

                <span>
                  Accession number
                </span>

                <strong>
                  {result.accessionNumber ??
                    result.canonicalResult
                      ?.accessionNumber ??
                    "—"}
                </strong>

              </div>


              <div className="result-meta-item">

                <span>
                  Patient
                </span>

                <strong>
                  {form.firstName}{" "}
                  {form.lastName}
                </strong>

              </div>

            </div>


            {/* ============================= */}
            {/* RESULT VALUE */}
            {/* ============================= */}

            <div
              className={`result-value-card ${
                isAbnormal
                  ? "result-abnormal"
                  : ""
              }`}
            >

              <div className="result-value-top">

                <div>

                  <span className="result-label">
                    Result
                  </span>

                  <div className="result-value">

                    {resultValue ?? "—"}

                    <span>
                      {resultUnit}
                    </span>

                  </div>

                  <div className="result-test">
                    {observation
                      ?.code?.text ??
                      result.canonicalResult
                        ?.test?.display ??
                      "Laboratory test"}
                  </div>

                </div>


                <div
                  className={`interpretation-badge ${
                    isAbnormal
                      ? "abnormal"
                      : "normal"
                  }`}
                >

                  {isAbnormal
                    ? "Abnormal"
                    : interpretation}

                </div>

              </div>

            </div>


            {/* ============================= */}
            {/* DETAILS */}
            {/* ============================= */}

            <div className="result-details">

              <div className="result-detail">

                <span>
                  Interpretation
                </span>

                <strong
                  className={
                    isAbnormal
                      ? "abnormal-text"
                      : ""
                  }
                >
                  {interpretation}
                </strong>

              </div>


              <div className="result-detail">

                <span>
                  Reference range
                </span>

                <strong>

                  {referenceLow ??
                    "—"}

                  {" – "}

                  {referenceHigh ??
                    "—"}

                  {" "}

                  {referenceUnit}

                </strong>

              </div>


              <div className="result-detail">

                <span>
                  Status
                </span>

                <strong>
                  {result.canonicalResult
                    ?.status ??
                    diagnosticReport
                      ?.status ??
                    "FINAL"}
                </strong>

              </div>

            </div>


            {/* ============================= */}
            {/* TECHNICAL DETAILS */}
            {/* ============================= */}

            <div className="technical-section">

              <button
                type="button"
                className="technical-toggle"
                onClick={() =>
                  setShowTechnicalDetails(
                    (value) => !value
                  )
                }
              >

                <span>
                  {showTechnicalDetails
                    ? "−"
                    : "+"}
                </span>

                {showTechnicalDetails
                  ? "Hide technical details"
                  : "Show technical details"}

              </button>


              {showTechnicalDetails && (

                <div className="technical-content">

                  <TechnicalBlock
                    title="Canonical request"
                    value={
                      result.canonicalRequest
                    }
                  />

                  <TechnicalBlock
                    title="FHIR request"
                    value={
                      result.fhirRequest
                    }
                  />

                  <TechnicalBlock
                    title="MOLIS response"
                    value={
                      result.molis
                    }
                  />

                  <TechnicalBlock
                    title="MOLIS process"
                    value={
                      result.molisProcess
                    }
                  />

                  <TechnicalBlock
                    title="FHIR result"
                    value={
                      result.fhirResult
                    }
                  />

                  <TechnicalBlock
                    title="Canonical result"
                    value={
                      result.canonicalResult
                    }
                  />

                  <TechnicalBlock
                    title="Final FHIR document"
                    value={
                      result.fhirDocument
                    }
                  />

                  <TechnicalBlock
                    title="Validation"
                    value={
                      result.validation
                    }
                  />

                </div>

              )}

            </div>


            {/* ============================= */}
            {/* NEW REQUEST */}
            {/* ============================= */}

            <div className="result-actions">

              <button
                type="button"
                className="secondary-button"
                onClick={resetForm}
              >
                ← Request another test
              </button>

            </div>

          </section>

        )}

      </main>


      {/* ===================================== */}
      {/* FOOTER */}
      {/* ===================================== */}

      <footer className="app-footer">

        <div>
          Request Lab Test — Pathology FHIR POC
        </div>

        <div>
          RLT → FHIR R4 → MOLIS → FHIR R4
        </div>

      </footer>

    </div>
  );
}


/* ========================================= */
/* TECHNICAL BLOCK */
/* ========================================= */

function TechnicalBlock({
  title,
  value,
}: {
  title: string;
  value: unknown;
}) {
  return (
    <div className="technical-block">

      <h4>
        {title}
      </h4>

      <pre>
        {JSON.stringify(
          value,
          null,
          2
        )}
      </pre>

    </div>
  );
}

export default App;