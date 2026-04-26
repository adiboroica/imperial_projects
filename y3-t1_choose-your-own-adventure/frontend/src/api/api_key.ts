/**
 * API-key domain wrappers — `/api-key` REST surface.
 */

import type { ApiKeyResponse } from "../types";
import { ApiClient } from "./clients/http";

export const apiKey = {
  /** `GET /api-key` — returns the decrypted key or `null` if unset. */
  get: async (): Promise<string | null> => {
    const response = await ApiClient.get<ApiKeyResponse>("/api-key");
    return response.apiKey;
  },

  /** `PUT /api-key` — store or rotate the user's key. */
  put: async (apiKeyValue: string): Promise<string | null> => {
    const response = await ApiClient.put<ApiKeyResponse>("/api-key", {
      apiKey: apiKeyValue,
    });
    return response.apiKey;
  },
};
