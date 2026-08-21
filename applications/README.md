# RLT Pathology FHIR Interoperability POC

## Request Lab Test (RLT) --- End-to-End Pathology Request and Result Flow

This repository contains a Proof of Concept (POC) for **Request Lab Test
(RLT)**, a web-based pathology test requesting solution.

The POC demonstrates an end-to-end flow where a pathology request is
captured through the RLT web application, resolved against terminology,
converted into an RLT canonical model, translated into **HL7 FHIR R4**,
submitted to a simulated **MOLIS/LIMS**, processed into a laboratory
result, and then translated back into a canonical result and FHIR
document for presentation to the user.

> **Important:** This is a technical POC and is not a production NHS
> pathology implementation. Production use would require appropriate
> interoperability, security, clinical safety, information governance,
> terminology, validation and operational controls.

------------------------------------------------------------------------

## Architecture

``` text
                         RLT PATHOLOGY PLATFORM

 ┌──────────────┐
 │    RLT Web   │
 │ React/TS     │
 └──────┬───────┘
        │ Test Request
        ▼
 ┌──────────────────────┐
 │    ORCHESTRATOR      │
 │                      │
 │ Workflow coordination│
 │ Request correlation  │
 │ Error handling       │
 └──────┬───────────────┘
        │
        ├──────────────► ┌────────────────────┐
        │                │ TERMINOLOGY SERVICE │
        │                │                    │
        │                │ SNOMED CT          │
        │                │ PBCL               │
        │                │ PaLM               │
        │                │ Local codes        │
        │                └────────────────────┘
        │
        ▼
 ┌──────────────────────┐
 │   CANONICAL MODEL    │
 │                      │
 │ Patient              │
 │ Requester            │
 │ Organisation         │
 │ Test                 │
 │ Specimen             │
 │ Clinical information │
 │ Result               │
 └──────────┬───────────┘
            │
            ▼
 ┌──────────────────────┐
 │     FHIR ADAPTER     │
 │                      │
 │ Canonical → FHIR R4  │
 └──────────┬───────────┘
            │ FHIR R4 Bundle
            ▼
 ┌──────────────────────┐
 │     FAKE MOLIS       │
 │        / LIMS        │
 │                      │
 │ Order processing     │
 │ Accession generation │
 │ Result generation    │
 └──────────┬───────────┘
            │ FHIR Result
            ▼
 ┌──────────────────────┐
 │    RESULT ADAPTER    │
 │                      │
 │ FHIR → Canonical     │
 └──────────┬───────────┘
            │
            ▼
 ┌──────────────────────┐
 │  FHIR DOCUMENT       │
 │  BUNDLE              │
 └──────────┬───────────┘
            │
            ▼
       ┌──────────┐
       │ RLT Web  │
       │ Results  │
       └──────────┘
```

------------------------------------------------------------------------

## End-to-End Flow

``` text
RLT Web
   ↓
Pathology Orchestrator
   ↓
Terminology Resolution
   ↓
Canonical Request
   ↓
FHIR Adapter
   ↓
HL7 FHIR R4 Request Bundle
   ↓
Fake MOLIS / LIMS
   ↓
Laboratory Result
   ↓
FHIR Result Bundle
   ↓
Result Adapter
   ↓
Canonical Result
   ↓
FHIR Document Bundle
   ↓
RLT Web
```

The complete round trip is:

``` text
WEB → CANONICAL → FHIR → MOLIS → FHIR → CANONICAL → WEB
```

------------------------------------------------------------------------

## Components

### 1. RLT Web

React + TypeScript frontend responsible for:

-   Capturing patient information
-   Capturing requester information
-   Selecting pathology tests
-   Capturing specimen information
-   Capturing clinical information
-   Submitting requests
-   Displaying request progress
-   Displaying laboratory results

The UI exposes the workflow state, for example:

``` text
✓ Request submitted
✓ Terminology resolved
✓ Canonical request created
✓ FHIR request created
✓ MOLIS order received
✓ Result available
✓ FHIR result received
✓ Result converted
✓ Report generated
```

### 2. Pathology Orchestrator

The orchestrator coordinates the complete request-to-result workflow.

Responsibilities:

-   Correlation/request ID management
-   Terminology resolution
-   Canonical request creation
-   FHIR Adapter invocation
-   MOLIS order processing
-   FHIR result retrieval
-   Result Adapter invocation
-   Final document generation
-   Returning the workflow response to RLT Web

### 3. Terminology Service

The POC considers:

-   SNOMED CT
-   PBCL
-   PaLM
-   Local laboratory/test codes

Example:

``` text
HBA1C
  ↓
SNOMED CT
  ↓
43396009
  ↓
Haemoglobin A1c measurement
```

### 4. Canonical Request

The canonical model keeps RLT business data independent of FHIR and
MOLIS.

Example:

``` json
{
  "requestId": "RLT-10001",
  "patient": {
    "nhsNumber": "9999999999",
    "firstName": "John",
    "lastName": "Smith",
    "dateOfBirth": "1975-03-12",
    "gender": "male"
  },
  "requester": {
    "practitionerId": "GMC-1234567",
    "name": "Dr John Smith",
    "organisationCode": "RLT001"
  },
  "laboratory": {
    "organisationCode": "LAB001",
    "name": "Fake MOLIS Pathology Laboratory"
  },
  "test": {
    "localCode": "HBA1C",
    "display": "Haemoglobin A1c"
  },
  "specimen": {
    "type": "Blood specimen"
  },
  "clinicalInformation": "Routine diabetes monitoring"
}
```

### 5. FHIR Adapter

Converts the canonical request into an HL7 FHIR R4 Bundle.

The POC demonstrates resources including:

``` text
Bundle
 ├── MessageHeader
 ├── Organization
 ├── Practitioner
 ├── Patient
 ├── ServiceRequest
 └── Specimen
```

Known POC endpoint:

``` text
POST http://localhost:4002/fhir/requests
```

### 6. Fake MOLIS

Simulates a laboratory information management system.

It receives the FHIR request, creates an accession/order and generates a
result.

Example:

``` text
Accession Number:
MOLIS-10009

Test:
Haemoglobin A1c measurement

Value:
48 mmol/mol

Reference Range:
20 - 42 mmol/mol

Interpretation:
ABNORMAL
```

### 7. Result Adapter

Converts the FHIR laboratory result into an RLT canonical result.

Conceptually:

``` text
FHIR DiagnosticReport
        +
FHIR Observation
        ↓
Result Adapter
        ↓
Canonical Result
```

### 8. FHIR Document Bundle

The completed report can be represented as a document-style Bundle
containing:

``` text
Composition
Patient
Organization
Specimen
DiagnosticReport
Observation
```

------------------------------------------------------------------------

## Example End-to-End Scenario

### Request

``` text
Patient:
John Smith

NHS Number:
9999999999

Test:
Haemoglobin A1c

Local Code:
HBA1C

Clinical Information:
Routine diabetes monitoring

Specimen:
Blood specimen
```

### Terminology

``` text
HBA1C
  ↓
SNOMED CT 43396009
  ↓
Haemoglobin A1c measurement
```

### FHIR Request

``` text
FHIR R4 Bundle
 ├── MessageHeader
 ├── Patient
 ├── Practitioner
 ├── Organization
 ├── ServiceRequest
 └── Specimen
```

### MOLIS

``` text
Accession:
MOLIS-10009

Status:
ORDER_RECEIVED
```

### Laboratory Result

``` text
Test:
Haemoglobin A1c measurement

Value:
48 mmol/mol

Reference Range:
20 - 42 mmol/mol

Interpretation:
ABNORMAL
```

### Final Result

``` text
Request ID:
RLT-10001

Accession:
MOLIS-10009

Status:
FINAL

Result:
48 mmol/mol

Interpretation:
ABNORMAL
```

------------------------------------------------------------------------

## Repository Structure

``` text
rlt-poc/
│
├── apps/
│   ├── rlt-web/
│   ├── pathology-orchestrator/
│   ├── terminology/
│   ├── fhir-adapter/
│   ├── fake-molis/
│   └── result-adapter/
│
├── package.json
└── README.md
```

The exact source structure may vary with the current checkout.

------------------------------------------------------------------------

## Local Services

The POC is designed as a set of independently running services.

``` text
RLT Web
   |
   v
Pathology Orchestrator
   |
   +── Terminology Service
   |
   +── FHIR Adapter
   |
   +── Fake MOLIS
   |
   +── Result Adapter
```

Known endpoints in the current POC include:

``` text
FHIR Adapter:
http://localhost:4002

Pathology Orchestrator:
http://localhost:4005

Fake MOLIS:
http://localhost:4010/molis
```

Other ports should be taken from the service configuration in the
repository.

------------------------------------------------------------------------

## Running the POC

Start the backend services in this logical order:

``` text
1. Terminology Service
2. FHIR Adapter
3. Fake MOLIS
4. Result Adapter
5. Pathology Orchestrator
6. RLT Web
```

Then open RLT Web and submit a pathology test request.

The orchestrator should coordinate the complete request/result workflow.

------------------------------------------------------------------------

## Technology Stack

  Layer                   Technology
  ----------------------- ----------------------------------
  Frontend                React + TypeScript
  Backend                 Node.js + TypeScript
  API                     HTTP / REST
  Interoperability        HL7 FHIR R4
  Terminology             SNOMED CT / PBCL / PaLM concepts
  Orchestration           Node.js / TypeScript
  Laboratory simulator    Fake MOLIS
  Result transformation   Result Adapter
  Development             Local multi-service environment

The backend remains JavaScript/TypeScript-oriented so the POC can be
developed without introducing a separate backend language.

------------------------------------------------------------------------

## Why the Canonical Model?

The canonical model is the key architectural boundary.

``` text
                     RLT DOMAIN
                         |
                         v
                ┌────────────────┐
                │ Canonical Model│
                └───────┬────────┘
                        │
              ┌─────────┴─────────┐
              │                   │
              ▼                   ▼
        FHIR Adapter         Future Adapter
              │                   │
              ▼                   ▼
           FHIR R4              HL7 v2
              │                   │
              ▼                   ▼
            MOLIS             Other LIMS
```

RLT therefore does not need to understand the internal data model of
every laboratory system.

A future adapter can be introduced without changing the core RLT domain
model.

------------------------------------------------------------------------

## Future-State Direction

The POC can evolve into a broader pathology interoperability platform:

``` text
                         ┌──────────────┐
                         │   RLT Web    │
                         └──────┬───────┘
                                │
                         ┌──────▼───────┐
                         │ API Gateway  │
                         └──────┬───────┘
                                │
                         ┌──────▼───────┐
                         │ Orchestrator │
                         └──────┬───────┘
                                │
                ┌───────────────┼────────────────┐
                │               │                │
                ▼               ▼                ▼
           Terminology     Validation       Canonical
             Platform       Services         Model
                │               │                │
                └───────────────┼────────────────┘
                                │
                      Interoperability Layer
                                │
               ┌────────────────┼────────────────┐
               │                │                │
               ▼                ▼                ▼
            FHIR R4           HL7 v2         Future
            Adapter           Adapter        Adapter
               │                │                │
               ▼                ▼                ▼
             MOLIS            LIMS #2          LIMS #3
               │                │                │
               └────────────────┼────────────────┘
                                │
                                ▼
                         Result Pipeline
                                │
                                ▼
                          Result Adapter
                                │
                                ▼
                         Canonical Result
                                │
                                ▼
                         FHIR Document
                                │
                                ▼
                            RLT Web
```

Potential future capabilities include:

-   Multiple LIMS integrations
-   Additional HL7/FHIR adapters
-   Event-driven processing
-   Queue-based retry and resilience
-   Centralised audit
-   Observability and distributed tracing
-   Production terminology services
-   Authentication and authorisation
-   NHS-connected services
-   Automated FHIR profile validation
-   Operational analytics

------------------------------------------------------------------------

## Current POC vs Production

  Capability          Current POC    Future
  ------------------- -------------- ------------------------------------
  RLT Web             Yes            Yes
  Canonical request   Yes            Yes
  Terminology         POC            Production terminology integration
  SNOMED CT           Demonstrated   Production integration
  PBCL                Considered     Full integration
  PaLM                Considered     Full integration
  FHIR R4             Demonstrated   Full profile validation
  FHIR Adapter        Yes            Production integration layer
  MOLIS               Simulated      Real integration
  Result Adapter      Yes            Production mapping
  FHIR Document       Demonstrated   Profile-validated implementation
  Authentication      POC scope      Production identity
  Authorisation       POC scope      RBAC/policy-based access
  Audit               POC scope      Production audit trail
  Observability       Basic          Centralised monitoring
  Resilience          Basic          Retry/queue/DLQ/idempotency
  Deployment          Local          Production infrastructure

------------------------------------------------------------------------

## Important Limitations

This repository is a technical Proof of Concept.

Before production use, the following areas require further
implementation and validation:

-   Production authentication and authorisation
-   NHS number validation
-   Production terminology services
-   Complete SNOMED CT/PBCL/PaLM mapping
-   Full FHIR profile validation
-   Real MOLIS integration
-   Secure secret management
-   Encryption and certificate management
-   Audit logging
-   Data retention
-   Consent and privacy controls
-   Retry and dead-letter processing
-   Idempotency
-   Distributed tracing
-   High availability
-   Monitoring and alerting
-   Automated test coverage
-   Clinical safety assessment
-   Information governance assessment
-   Production deployment

------------------------------------------------------------------------

## POC Success Criteria

The main success criterion is demonstrating the complete
request-to-result round trip:

``` text
                 REQUEST
                    │
                    ▼
              ┌───────────┐
              │  RLT Web  │
              └─────┬─────┘
                    │
                    ▼
              Canonical Request
                    │
                    ▼
              FHIR R4 Request
                    │
                    ▼
                  MOLIS
                    │
                    ▼
              Laboratory Result
                    │
                    ▼
              FHIR R4 Result
                    │
                    ▼
              Canonical Result
                    │
                    ▼
             FHIR Document
                    │
                    ▼
              ┌───────────┐
              │  RLT Web  │
              │  Result   │
              └───────────┘
```

------------------------------------------------------------------------

## Demo Scenario

For a demonstration:

1.  Start all backend services.
2.  Start RLT Web.
3.  Enter patient details.
4.  Select `Haemoglobin A1c`.
5.  Submit the request.
6.  Observe request progress.
7.  Show terminology resolution.
8.  Show the canonical request.
9.  Show the FHIR R4 request Bundle.
10. Show the MOLIS accession number.
11. Show the generated laboratory result.
12. Show the FHIR `DiagnosticReport` and `Observation`.
13. Show the canonical result.
14. Show the final result/report in RLT Web.

The complete demonstration should show:

``` text
WEB
 ↓
CANONICAL
 ↓
FHIR
 ↓
MOLIS
 ↓
FHIR
 ↓
CANONICAL
 ↓
WEB
```

------------------------------------------------------------------------

## Disclaimer

This project is a technical Proof of Concept for exploring an RLT
pathology request and result interoperability architecture. It is not a
production NHS implementation or a clinical system and should not be
used with real patient data without appropriate security, clinical
safety, information governance, interoperability and regulatory
controls.
