export const scopes = [
  "clients:read",
  "clients:write",
  "quotes:read",
  "quotes:write",
  "holded:read",
  "holded:write"
] as const;

export type Scope = (typeof scopes)[number];
