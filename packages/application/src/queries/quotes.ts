import type { QuoteRepository } from "../ports/quotes.js";

export function getQuote(repository: QuoteRepository) {
  return (installationId: string, id: string) => repository.getQuoteById(installationId, id);
}

export function searchQuotes(repository: QuoteRepository) {
  return (installationId: string, query = "") => repository.searchQuotes(installationId, query);
}