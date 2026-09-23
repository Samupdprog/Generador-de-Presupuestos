import type { ClientRepository } from "../ports/clients.js";

export function getClient(repository: ClientRepository) {
  return (installationId: string, id: string) => repository.getById(installationId, id);
}

export function searchClients(repository: ClientRepository) {
  return (installationId: string, query: string) => repository.search(installationId, query);
}