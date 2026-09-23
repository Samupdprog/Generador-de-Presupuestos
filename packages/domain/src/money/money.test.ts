import { describe, expect, it } from "vitest";
import { money } from "./money.js";

describe("money", () => {
  it("keeps decimal arithmetic exact", () => {
    expect(money("0.1").plus("0.2").toString()).toBe("0.3");
  });
});
