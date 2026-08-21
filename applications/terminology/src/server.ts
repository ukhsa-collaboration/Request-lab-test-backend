import Fastify from "fastify";
import cors from "@fastify/cors";

import { terminologyCatalogue } from "./catalogue.js";

import {
  findByLocalCode,
  findByPalmProcedure,
  findByPalmObservable,
  findByPbcl,
  findByMolisResultCode
} from "./mapper.js";

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
    service: "rlt-terminology-service"
  };
});


// --------------------------------------------------
// List available tests
// --------------------------------------------------

app.get("/terminology/tests", async () => {

  return {
    count: terminologyCatalogue.length,
    tests: terminologyCatalogue
  };
});


// --------------------------------------------------
// Get terminology for one test
// --------------------------------------------------

app.get<{
  Params: {
    localCode: string;
  };
}>(
  "/terminology/tests/:localCode",
  async (request, reply) => {

    const localCode =
      request.params.localCode.toUpperCase();

    const test =
      terminologyCatalogue.find(
        item => item.localCode === localCode
      );

    if (!test) {

      return reply.code(404).send({
        status: "NOT_FOUND",
        message: `Test '${localCode}' was not found`
      });
    }

    return {
      status: "FOUND",
      test
    };
  }
);

// ==================================================
// LOCAL CODE
// ==================================================

app.get<{
  Params: {
    code: string;
  };
}>(
  "/terminology/local/:code",
  async (
    request,
    reply
  ) => {

    const result =
      findByLocalCode(
        request.params.code
      );


    if (!result) {

      return reply
        .code(404)
        .send({
          status:
            "NOT_FOUND"
        });
    }


    return result;
  }
);

// ==================================================
// PALM PROCEDURE
// ==================================================

app.get<{
  Params: {
    code: string;
  };
}>(
  "/terminology/palm/procedure/:code",
  async (
    request,
    reply
  ) => {

    const result =
      findByPalmProcedure(
        request.params.code
      );


    if (!result) {

      return reply
        .code(404)
        .send({
          status:
            "NOT_FOUND"
        });
    }


    return {

      source:
        "PALM_PROCEDURE",

      result

    };
  }
);

// ==================================================
// PALM OBSERVABLE
// ==================================================

app.get<{
  Params: {
    code: string;
  };
}>(
  "/terminology/palm/observable/:code",
  async (
    request,
    reply
  ) => {

    const result =
      findByPalmObservable(
        request.params.code
      );


    if (!result) {

      return reply
        .code(404)
        .send({
          status:
            "NOT_FOUND"
        });
    }


    return {

      source:
        "PALM_OBSERVABLE",

      result

    };
  }
);

// ==================================================
// PBCL
// ==================================================

app.get<{
  Params: {
    code: string;
  };
}>(
  "/terminology/pbcl/:code",
  async (
    request,
    reply
  ) => {

    const result =
      findByPbcl(
        request.params.code
      );


    if (!result) {

      return reply
        .code(404)
        .send({
          status:
            "NOT_FOUND"
        });
    }


    return {

      source:
        "PBCL",

      result

    };
  }
);

// ==================================================
// MOLIS RESULT CODE
// ==================================================

app.get<{
  Params: {
    code: string;
  };
}>(
  "/terminology/molis/result/:code",
  async (
    request,
    reply
  ) => {

    const result =
      findByMolisResultCode(
        request.params.code
      );


    if (!result) {

      return reply
        .code(404)
        .send({
          status:
            "NOT_FOUND"
        });
    }


    return {

      source:
        "MOLIS_RESULT",

      result

    };
  }
);

// --------------------------------------------------
// Start server
// --------------------------------------------------

try {

  await app.listen({
    port: 4001,
    host: "0.0.0.0"
  });

  console.log(
    "Terminology Service running on http://localhost:4001"
  );

} catch (error) {

  app.log.error(error);

  process.exit(1);
}