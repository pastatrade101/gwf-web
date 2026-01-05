import { dataConnectConfig } from "./config.js";

export async function dataConnectRequest({ query, variables, token }) {
  if (!dataConnectConfig.endpoint) {
    throw new Error("Missing VITE_DATA_CONNECT_ENDPOINT");
  }

  const headers = {
    "Content-Type": "application/json",
  };
  if (dataConnectConfig.apiKey) {
    headers["x-goog-api-key"] = dataConnectConfig.apiKey;
  }
  if (token) {
    headers.Authorization = `Bearer ${token}`;
  }

  const resp = await fetch(dataConnectConfig.endpoint, {
    method: "POST",
    headers,
    body: JSON.stringify({ query, variables }),
  });

  if (!resp.ok) {
    const text = await resp.text();
    throw new Error(`Data Connect error (${resp.status}): ${text}`);
  }

  const json = await resp.json();
  if (json.errors?.length) {
    throw new Error(json.errors.map((e) => e.message).join(", "));
  }
  return json.data;
}

export const QUERIES = {
  listDepartments: `
    query ListDepartments {
      departments {
        id
        name
        contactEmail
        website
        address
        phoneNumber
      }
    }
  `,
  listServices: `
    query ListServices {
      services {
        id
        name
        description
        contactInfo
        onlineLink
        requirements
        department {
          id
          name
        }
      }
    }
  `,
  createService: `
    mutation CreateService(
      $departmentId: UUID!
      $name: String!
      $description: String!
      $requirements: String
      $onlineLink: String
      $contactInfo: String
    ) {
      service_insert(
        data: {
          departmentId: $departmentId
          name: $name
          description: $description
          requirements: $requirements
          onlineLink: $onlineLink
          contactInfo: $contactInfo
        }
      )
    }
  `,
  createDepartment: `
    mutation CreateDepartment(
      $name: String!
      $contactEmail: String!
      $website: String
      $address: String
      $phoneNumber: String
    ) {
      department_insert(
        data: {
          name: $name
          contactEmail: $contactEmail
          website: $website
          address: $address
          phoneNumber: $phoneNumber
        }
      )
    }
  `,
};
