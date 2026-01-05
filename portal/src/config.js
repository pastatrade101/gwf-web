export const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY,
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN,
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID,
  appId: import.meta.env.VITE_FIREBASE_APP_ID,
};

export const dataConnectConfig = {
  endpoint: import.meta.env.VITE_DATA_CONNECT_ENDPOINT,
  apiKey: import.meta.env.VITE_DATA_CONNECT_API_KEY || "",
};

export function getConfigErrors() {
  const errors = [];
  if (!firebaseConfig.apiKey) errors.push("VITE_FIREBASE_API_KEY is missing.");
  if (!firebaseConfig.authDomain) errors.push("VITE_FIREBASE_AUTH_DOMAIN is missing.");
  if (!firebaseConfig.projectId) errors.push("VITE_FIREBASE_PROJECT_ID is missing.");
  if (!firebaseConfig.appId) errors.push("VITE_FIREBASE_APP_ID is missing.");
  if (!dataConnectConfig.endpoint) errors.push("VITE_DATA_CONNECT_ENDPOINT is missing.");
  return errors;
}
