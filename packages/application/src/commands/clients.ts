import type { ClientRepository, CreateClientCommand, UpdateClientCommand } from "../ports/clients.js";

export function createClient(repository: ClientRepository) {
  return (input: CreateClientCommand) => repository.create(input);
}

export function updateClient(repository: ClientRepository) {
  return (input: UpdateClientCommand) => repository.update(input);
}