import { useState } from 'react';
import { TimeUnit } from '../../types/casper';
import { useCasperData } from '../../hooks/useCasperData';

const TIME_UNITS: TimeUnit[] = ['seconds', 'minutes', 'hours', 'days'];

export const ConfigPanel = () => {
  const { appName, setAppName, timeConfig, updateTimeConfig, triggerRun, loading } = useCasperData();
  const [parameters, setParameters] = useState('');

  const handleRun = () => {
    const params = parameters ? { parameters } : undefined;
    void triggerRun(params);
  };

  return (
    <div className="config-panel">
      <div className="field">
        <label htmlFor="appName">Result folder</label>
        <input id="appName" value={appName} onChange={(event) => setAppName(event.target.value)} />
      </div>

      <div className="field">
        <label htmlFor="baseDate">Base date</label>
        <input
          id="baseDate"
          type="datetime-local"
          value={timeConfig.baseDate.slice(0, 16)}
          onChange={(event) => {
            const iso = new Date(event.target.value).toISOString();
            updateTimeConfig({ baseDate: iso });
          }}
        />
      </div>

      <div className="field">
        <label htmlFor="timeUnit">Time unit</label>
        <select id="timeUnit" value={timeConfig.unit} onChange={(event) => updateTimeConfig({ unit: event.target.value as TimeUnit })}>
          {TIME_UNITS.map((unit) => (
            <option key={unit} value={unit}>
              {unit}
            </option>
          ))}
        </select>
      </div>

      <div className="field" style={{ flex: 1 }}>
        <label htmlFor="parameters">CASPER parameters</label>
        <input
          id="parameters"
          placeholder="--const horizon=50 --const patient=1000582"
          value={parameters}
          onChange={(event) => setParameters(event.target.value)}
        />
      </div>

      <button type="button" onClick={handleRun} disabled={loading}>
        {loading ? 'Running…' : 'Run CASPER'}
      </button>
    </div>
  );
};
