/**
 * Connect-RPC client setup for uni-app
 * Cross-platform RPC client supporting H5 and mini programs
 */
import { createConnectTransport } from '@connectrpc/connect-web';
import { createPromiseClient } from '@connectrpc/connect';
import { ReferenceService } from '@/gen/highschool/v1/reference_service_connect';
import { CandidateService } from '@/gen/highschool/v1/candidate_service_connect';
import { isH5, getApiBaseUrl } from '@/utils/platform';
import { createUniFetch } from './transport';

/**
 * Create Connect-RPC transport for the current platform
 */
function createPlatformTransport() {
  const baseUrl = getApiBaseUrl();

  if (isH5()) {
    // For H5, use standard web transport
    return createConnectTransport({
      baseUrl,
      // Use interceptors for credentials instead of fetchOptions
      interceptors: [],
    });
  }

  // For mini programs, use custom fetch adapter
  return createConnectTransport({
    baseUrl,
    fetch: createUniFetch(baseUrl) as typeof fetch,
  });
}

// Create singleton transport
const transport = createPlatformTransport();

/**
 * Reference service client
 * Provides access to district, school, and reference data APIs
 */
export const referenceClient = createPromiseClient(ReferenceService, transport);

/**
 * Candidate service client
 * Provides access to analysis, history, and candidate data APIs
 */
export const candidateClient = createPromiseClient(CandidateService, transport);
