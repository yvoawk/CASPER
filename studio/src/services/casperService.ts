import { CasperMode, CasperParseResult, RawCasperJson } from '../types/casper';
import { parseCasperJson } from './casperParser';

const MOCK_MAP: Record<CasperMode, () => Promise<RawCasperJson>> = {
  async naive() {
    const data = await import('../mock/naive.json');
    return data.default;
  },
  async consistent() {
    const data = await import('../mock/consistent.json');
    return data.default;
  },
  async preferred() {
    const data = await import('../mock/preferred.json');
    return data.default;
  },
  async cautious() {
    const data = await import('../mock/cautious.json');
    return data.default;
  }
};

export async function fetchCasperData(mode: CasperMode, appName: string): Promise<CasperParseResult> {
  const endpoint = `/api/results?mode=${mode}&app=${encodeURIComponent(appName)}`;

  try {
    const response = await fetch(endpoint);
    if (!response.ok) {
      throw new Error('Failed to fetch CASPER results');
    }
    const json = (await response.json()) as RawCasperJson;
    return parseCasperJson(mode, json);
  } catch (error) {
    console.warn('Falling back to mock data for mode', mode, error);
    const mockLoader = MOCK_MAP[mode];
    const mockJson = await mockLoader();
    return parseCasperJson(mode, mockJson);
  }
}
