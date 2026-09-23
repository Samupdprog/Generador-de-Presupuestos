import Decimal from "decimal.js";

export type Money = Decimal;
export type MoneyInput = Decimal.Value;

export function money(value: MoneyInput): Money {
  return new Decimal(value);
}

export function moneyString(value: Money): string {
  return value.toFixed(2);
}
