import type { MolisOrder } from "./types.js";


const orders =
  new Map<string, MolisOrder>();


export function saveOrder(
  order: MolisOrder
): void {

  orders.set(
    order.accessionNumber,
    order
  );
}


export function getOrder(
  accessionNumber: string
): MolisOrder | undefined {

  return orders.get(
    accessionNumber
  );
}


export function getAllOrders(): MolisOrder[] {

  return Array.from(
    orders.values()
  );
}


export function updateOrder(
  accessionNumber: string,
  update: Partial<MolisOrder>
): MolisOrder | undefined {

  const existing =
    orders.get(accessionNumber);

  if (!existing) {
    return undefined;
  }

  const updated = {
    ...existing,
    ...update
  };

  orders.set(
    accessionNumber,
    updated
  );

  return updated;
}