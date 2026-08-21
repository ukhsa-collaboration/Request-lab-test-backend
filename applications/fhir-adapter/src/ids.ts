import { randomUUID } from "node:crypto";

export function uuid(): string {
  return randomUUID();
}

export function urnUuid(id: string): string {
  return `urn:uuid:${id}`;
}