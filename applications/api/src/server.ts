import Fastify from "fastify";
import cors from "@fastify/cors";

import { LabTestRequestSchema } from "./schemas.js";
import type { LabTestRequest } from "./types.js";

const app = Fastify({
  logger: true
});

await app.register(cors, {
  origin: true
});


// --------------------------------------------------
// Health
// --------------------------------------------------

app.get("/health", async () => {
  return {
    status: "UP",
    service: "rlt-api"
  };
});


async function resolveTerminology(
  localCode: string
) {

  const response = await fetch(
    `http://localhost:4001/terminology/tests/${localCode}`
  );

  if (!response.ok) {

    throw new Error(
      `Terminology lookup failed for ${localCode}`
    );
  }

  return response.json();
}


// --------------------------------------------------
// Create laboratory test request
// --------------------------------------------------

app.post("/api/lab-requests", async (request, reply) => {

  const validation = LabTestRequestSchema.safeParse(request.body);

  if (!validation.success) {

    return reply.code(400).send({
      status: "REJECTED",

      errors: validation.error.flatten()
    });
  }

  const labRequest: LabTestRequest = validation.data;

  let terminology;

  try {

    terminology = await resolveTerminology(
      labRequest.test.localCode
    );

  } catch (error) {

    request.log.error(error);

    return reply.code(502).send({
      status: "TERMINOLOGY_ERROR",
      message: "Unable to resolve laboratory test terminology"
    });
  }

  console.log("\n==============================");
  console.log("LAB TEST REQUEST");
  console.log("==============================");

  console.log(
    JSON.stringify(
      labRequest,
      null,
      2
    )
  );

  return reply.code(201).send({
    status: "CREATED",

    request: labRequest,

    terminology
  });
});


// --------------------------------------------------
// Start server
// --------------------------------------------------

try {

  await app.listen({
    port: 4000,
    host: "0.0.0.0"
  });

  console.log(
    "RLT API running on http://localhost:4000"
  );

} catch (error) {

  app.log.error(error);

  process.exit(1);
}