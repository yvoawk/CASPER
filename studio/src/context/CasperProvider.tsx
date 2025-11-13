import { createContext, ReactNode, useCallback, useEffect, useMemo, useState } from 'react';
import { CasperMode, CasperParseResult, TimeConfig } from '../types/casper';
import { defaultTimeConfig } from '../config/timeConfig';
import { fetchCasperData } from '../services/casperService';

interface CasperContextValue {
  mode: CasperMode;
  setMode: (mode: CasperMode) => void;
  appName: string;
  setAppName: (app: string) => void;
  data: CasperParseResult | null;
  selectedAnswerSetId: string | null;
  setSelectedAnswerSetId: (id: string) => void;
  timeConfig: TimeConfig;
  updateTimeConfig: (config: Partial<TimeConfig>) => void;
  loading: boolean;
  triggerRun: (params?: Record<string, unknown>) => Promise<void>;
}

export const CasperContext = createContext<CasperContextValue | undefined>(undefined);

export const CasperProvider = ({ children }: { children: ReactNode }) => {
  const [mode, setMode] = useState<CasperMode>('naive');
  const [appName, setAppName] = useState('lung_cancer');
  const [data, setData] = useState<CasperParseResult | null>(null);
  const [selectedAnswerSetId, setSelectedAnswerSetId] = useState<string | null>(null);
  const [timeConfig, setTimeConfig] = useState<TimeConfig>(defaultTimeConfig);
  const [loading, setLoading] = useState(false);

  const loadData = useCallback(async () => {
    setLoading(true);
    try {
      const parsed = await fetchCasperData(mode, appName);
      setData(parsed);
      setSelectedAnswerSetId(parsed.answerSets[0]?.id ?? null);
    } finally {
      setLoading(false);
    }
  }, [mode, appName]);

  useEffect(() => {
    void loadData();
  }, [loadData]);

  const updateTimeConfig = (config: Partial<TimeConfig>) => {
    setTimeConfig((prev) => ({ ...prev, ...config }));
  };

  const triggerRun = useCallback(async (params?: Record<string, unknown>) => {
    try {
      await fetch('/api/run', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ mode, appName, ...params })
      });
    } catch (error) {
      console.warn('CASPER execution endpoint is unavailable. Mocking run.', error);
    } finally {
      await loadData();
    }
  }, [mode, appName, loadData]);

  const value = useMemo(
    () => ({
      mode,
      setMode,
      appName,
      setAppName,
      data,
      selectedAnswerSetId,
      setSelectedAnswerSetId,
      timeConfig,
      updateTimeConfig,
      loading,
      triggerRun
    }),
    [mode, appName, data, selectedAnswerSetId, timeConfig, loading, triggerRun]
  );

  return <CasperContext.Provider value={value}>{children}</CasperContext.Provider>;
};
