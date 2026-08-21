# Docker setup for RLT Pathology FHIR POC

This pack adds Docker support for the POC components:

- `rlt-web`
- `pathology-orchestrator`
- `terminology`
- `fhir-adapter`
- `fake-molis`
- `result-adapter`
- `api` (legacy/low-level API from the original POC)

The original backend source uses some `localhost` URLs. Inside Docker, those must be changed to Docker Compose service names. The compose file therefore provides environment variables for the target URLs.

## Expected repository layout

```text
rlt-poc/
├── apps/
│   ├── api/
│   ├── fake-molis/
│   ├── fhir-adapter/
│   ├── pathology-orchestrator/
│   ├── result-adapter/
│   ├── terminology/
│   └── rlt-web/
├── docker/
│   ├── api.Dockerfile
│   ├── fake-molis.Dockerfile
│   ├── fhir-adapter.Dockerfile
│   ├── pathology-orchestrator.Dockerfile
│   ├── result-adapter.Dockerfile
│   ├── terminology.Dockerfile
│   └── rlt-web.Dockerfile
├── docker-compose.yml
└── .dockerignore
```

The uploaded POC source confirms the existing service ports and endpoints: terminology uses `4001`, FHIR Adapter uses `4002` and `POST /fhir/requests`, Fake MOLIS uses `4010` and `POST /molis/orders`, Result Adapter uses `4003`, and the original API uses `4000`. The FHIR Adapter also calls Fake MOLIS from its request flow.

## Required source changes for Docker

### 1. Terminology URL in `apps/api/src/server.ts`

Replace:

```ts
fetch(`http://localhost:4001/terminology/tests/${localCode}`)
```

with:

```ts
const terminologyUrl =
  process.env.TERMINOLOGY_URL ?? "http://localhost:4001";

fetch(
  `${terminologyUrl}/terminology/tests/${localCode}`
)
```

### 2. MOLIS URL in `apps/fhir-adapter/src/server.ts`

Replace the hard-coded:

```ts
"http://localhost:4010/molis/orders"
```

with:

```ts
const molisUrl =
  process.env.MOLIS_URL ?? "http://localhost:4010";

`${molisUrl}/molis/orders`
```

### 3. Orchestrator service URLs

Your existing orchestrator should read:

```text
TERMINOLOGY_URL=http://terminology:4001
FHIR_ADAPTER_URL=http://fhir-adapter:4002
MOLIS_URL=http://fake-molis:4010
RESULT_ADAPTER_URL=http://result-adapter:4003
```

Do not use `localhost` for service-to-service calls inside the Docker network.

### 4. Port handling

The compose file assumes each service reads its `PORT` environment variable. If your current `server.ts` has a hard-coded port, change:

```ts
port: 4001
```

to:

```ts
port: Number(process.env.PORT ?? 4001)
```

and similarly for the other services.

## RLT Web

The current RLT Web POC calls the orchestrator at:

```text
http://localhost:4005
```

For a Docker build, change the frontend to use:

```ts
const API_BASE_URL =
  import.meta.env.VITE_ORCHESTRATOR_URL ??
  "http://localhost:4005";
```

Then use `API_BASE_URL` for the request.

The Dockerfile passes:

```text
VITE_ORCHESTRATOR_URL=http://localhost:4005
```

because the browser runs outside the Docker network. Do **not** set the browser URL to `http://pathology-orchestrator:4005`; that hostname is only resolvable by containers on the Compose network.

## Start everything

From the repository root:

```bash
docker compose build
docker compose up
```

Or:

```bash
docker compose up --build
```

RLT Web:

```text
http://localhost:5173
```

Orchestrator:

```text
http://localhost:4005
```

Terminology:

```text
http://localhost:4001
```

FHIR Adapter:

```text
http://localhost:4002
```

Result Adapter:

```text
http://localhost:4003
```

Legacy API:

```text
http://localhost:4000
```

Fake MOLIS:

```text
http://localhost:4010
```

## Test health

```bash
curl http://localhost:4001/health
curl http://localhost:4002/health
curl http://localhost:4003/health
curl http://localhost:4005/health
curl http://localhost:4010/health
```

## View logs

```bash
docker compose logs -f pathology-orchestrator
docker compose logs -f fhir-adapter
docker compose logs -f fake-molis
docker compose logs -f result-adapter
docker compose logs -f terminology
```

## Stop

```bash
docker compose down
```

To remove containers and the build-created network:

```bash
docker compose down --remove-orphans
```

## Important architecture point

The browser calls:

```text
RLT Web
   |
   v
http://localhost:4005
   |
   v
Pathology Orchestrator
```

Container-to-container communication uses Compose DNS:

```text
orchestrator
   |
   +--> http://terminology:4001
   |
   +--> http://fhir-adapter:4002
   |
   +--> http://fake-molis:4010
   |
   +--> http://result-adapter:4003
```

This is why `localhost` should only be used for browser-to-host access, not for backend-to-backend calls inside Docker.
