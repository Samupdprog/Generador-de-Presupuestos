export interface ClientRecord {
  id: string;
  installationId: string;
  name: string;
  taxId: string | null;
  email: string | null;
  phone: string | null;
  address: string | null;
  revision: number;
}

export interface CreateClientCommand {
  installationId: string;
  name: string;
  taxId?: string | undefined;
  email?: string | undefined;
  phone?: string | undefined;
  address?: string | undefined;
}

export interface UpdateClientCommand {
  installationId: string;
  id: string;
  expectedRevision: number;
  name?: string | undefined;
  taxId?: string | undefined;
  email?: string | undefined;
  phone?: string | undefined;
  address?: string | undefined;
}

export interface ClientRepository {
  create(input: CreateClientCommand): Promise<ClientRecord>;
  getById(installationId: string, id: string): Promise<ClientRecord | null>;
  search(installationId: string, query: string): Promise<ClientRecord[]>;
  update(input: UpdateClientCommand): Promise<ClientRecord>;
}