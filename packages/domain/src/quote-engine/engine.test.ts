import { describe, expect, it } from "vitest";
import { Decimal } from "decimal.js";
import {
  allocateProportionalAdjustment,
  applyConsecutiveDiscounts,
  calculateLine,
  calculateQuote,
} from "./engine.js";

const value = (input: { type: "unit_price" | "fixed_line_total" | "add_euros_per_unit" | "add_percentage"; value: string; baseUnitPrice?: string }) => ({
  id: "line-1",
  type: "material" as const,
  quantity: "1",
  saleRule: input,
});

describe("quote engine", () => {
  it("keeps decimal arithmetic exact", () => {
    expect(calculateLine(value({ type: "unit_price", value: "0.1" })).sale.plus("0.2").toString()).toBe("0.3");
  });

  it("applies supplier discounts consecutively without intermediate rounding", () => {
    expect(applyConsecutiveDiscounts("100", [{ percentage: "20" }, { percentage: "5" }]).toString()).toBe("76");
  });

  it("calculates unit price and rounds only the final money value", () => {
    const discountedCost = calculateLine({ ...value({ type: "unit_price", value: "33.33" }), quantity: "3", supplierUnitPrice: "33.33", supplierDiscounts: [{ percentage: "10" }] });
    expect(discountedCost.cost.toFixed(2)).toBe("89.99");
    expect(calculateLine({ ...value({ type: "unit_price", value: "33.33" }), quantity: "3", directUnitCost: "33.33" }).cost.toFixed(2)).toBe("99.99");
  });

  it("supports fixed totals and per-unit additions", () => {
    expect(calculateLine({ ...value({ type: "fixed_line_total", value: "115" }), quantity: "5" }).sale.toFixed(2)).toBe("115.00");
    expect(calculateLine({ ...value({ type: "add_euros_per_unit", value: "3", baseUnitPrice: "20" }), quantity: "5" }).sale.toFixed(2)).toBe("115.00");
    expect(calculateLine({ ...value({ type: "add_percentage", value: "10", baseUnitPrice: "20" }), quantity: "5" }).sale.toFixed(2)).toBe("110.00");
  });

  it("aggregates multiple labor employees into one commercial line", () => {
    const result = calculateLine({
      ...value({ type: "unit_price", value: "0" }),
      type: "labor",
      laborEntries: [
        { employeeName: "Alejandro", hours: "6", costRate: "10", saleRate: "20" },
        { employeeName: "Kevin", hours: "4", costRate: "12", saleRate: "25" },
      ],
    });
    expect(result.cost.toFixed(2)).toBe("108.00");
    expect(result.sale.toFixed(2)).toBe("220.00");
  });

  it("reports positive, negative, zero-cost and zero-sale metrics", () => {
    const positive = calculateLine({ ...value({ type: "unit_price", value: "100" }), directUnitCost: "40" });
    const negative = calculateLine({ ...value({ type: "unit_price", value: "20" }), directUnitCost: "40" });
    const zeroCost = calculateLine(value({ type: "unit_price", value: "20" }));
    const zeroSale = calculateLine({ ...value({ type: "unit_price", value: "0" }), directUnitCost: "20" });
    expect(positive.profit.toFixed(2)).toBe("60.00");
    expect(negative.profit.toFixed(2)).toBe("-20.00");
    expect(zeroCost.profitOnCostPct).toBeNull();
    expect(zeroSale.marginOnSalePct).toBeNull();
  });

  it("applies line, global percentage and target-total adjustments", () => {
    const lines = [
      { ...value({ type: "unit_price", value: "100" }), id: "a" },
      { ...value({ type: "unit_price", value: "200" }), id: "b" },
    ];
    expect(calculateQuote(lines, [{ id: "line-adjustment", scope: "line", mode: "amount", value: "100", targetLineIds: ["a"], baseQuoteRevision: 0 }]).subtotal.toFixed(2)).toBe("400.00");
    expect(calculateQuote(lines, [{ id: "global-percentage", scope: "quote", mode: "percentage", value: "5", baseQuoteRevision: 0 }]).subtotal.toFixed(2)).toBe("315.00");
    expect(calculateQuote(lines, [{ id: "target", scope: "quote", mode: "target_total", value: "1000", baseQuoteRevision: 0 }]).subtotal.toFixed(2)).toBe("1000.00");
  });

  it("preserves adjustment semantics when the quote base changes", () => {
    const lines = [{ ...value({ type: "unit_price", value: "100" }), id: "a" }];
    const line = lines[0]!;
    const amount = { id: "amount", scope: "quote" as const, mode: "amount" as const, value: "25", baseQuoteRevision: 0 };
    const percentage = { id: "percentage", scope: "quote" as const, mode: "percentage" as const, value: "10", baseQuoteRevision: 0 };
    const target = { id: "target", scope: "quote" as const, mode: "target_total" as const, value: "150", baseQuoteRevision: 0 };
    expect(calculateQuote(lines, [amount]).subtotal.toFixed(2)).toBe("125.00");
    expect(calculateQuote([{ ...line, saleRule: { type: "unit_price", value: "200" } }], [amount]).subtotal.toFixed(2)).toBe("225.00");
    expect(calculateQuote(lines, [percentage]).subtotal.toFixed(2)).toBe("110.00");
    expect(calculateQuote([{ ...line, saleRule: { type: "unit_price", value: "200" } }], [percentage]).subtotal.toFixed(2)).toBe("220.00");
    expect(calculateQuote(lines, [target]).subtotal.toFixed(2)).toBe("150.00");
    expect(calculateQuote([{ ...line, saleRule: { type: "unit_price", value: "200" } }], [target]).subtotal.toFixed(2)).toBe("150.00");
  });

  it("allocates cents deterministically and excludes adjustment lines", () => {
    const allocations = allocateProportionalAdjustment("0.02", [
      { id: "a", type: "material", sale: new Decimal("1"), eligibleForPriceAllocation: true },
      { id: "b", type: "material", sale: new Decimal("1"), eligibleForPriceAllocation: true },
      { id: "internal", type: "adjustment", sale: new Decimal("100"), eligibleForPriceAllocation: true },
    ]);
    expect(allocations.get("a")?.toFixed(2)).toBe("0.01");
    expect(allocations.get("b")?.toFixed(2)).toBe("0.01");
    expect(allocations.has("internal")).toBe(false);
  });
});