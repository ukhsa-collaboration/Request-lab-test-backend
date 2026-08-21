import { z } from "zod";

export const LabTestRequestSchema = z.object({
  requestId: z.string().min(1),

  patient: z.object({
    nhsNumber: z.string().min(1),
    firstName: z.string().min(1),
    lastName: z.string().min(1),
    dateOfBirth: z.string().regex(
      /^\d{4}-\d{2}-\d{2}$/,
      "Date must be YYYY-MM-DD"
    ),
    gender: z
      .enum(["male", "female", "other", "unknown"])
      .optional()
  }),

  requester: z.object({
    practitionerId: z.string().min(1),
    name: z.string().min(1),
    organisationCode: z.string().min(1)
  }),

  laboratory: z.object({
    organisationCode: z.string().min(1),
    name: z.string().min(1)
  }),

  test: z.object({
    localCode: z.string().min(1),
    display: z.string().min(1)
  }),

  specimen: z.object({
    type: z.string().min(1),
    collectedAt: z.string().optional()
  }),

  clinicalInformation: z.string().optional(),

  requestedAt: z.string()
});