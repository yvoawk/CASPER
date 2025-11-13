import { useMemo } from 'react';
import { useCasperData } from '../../hooks/useCasperData';
import { formatDateRange } from '../../utils/time';

export const StatsPanel = () => {
  const { data, selectedAnswerSetId, timeConfig } = useCasperData();

  const selected = useMemo(() => data?.answerSets.find((set) => set.id === selectedAnswerSetId), [data, selectedAnswerSetId]);

  if (!data) {
    return <p style={{ margin: 0 }}>No data loaded yet.</p>;
  }

  const stats = [
    { label: 'Result', value: data.metadata.result },
    { label: 'Models', value: data.metadata.models.Number },
    { label: 'Threads', value: data.metadata.threads ?? 'n/a' },
    { label: 'Solve time (s)', value: data.metadata.time.Total }
  ];

  return (
    <div>
      <h2 style={{ marginTop: 0 }}>Solver statistics</h2>
      <div className="stats-grid">
        {stats.map((stat) => (
          <div key={stat.label} className="stat-card">
            <h4>{stat.label}</h4>
            <strong>{stat.value}</strong>
          </div>
        ))}
      </div>
      {selected && selected.summary.eventCount > 0 && (
        <div style={{ marginTop: '1rem' }}>
          <h3>Current timeline</h3>
          <p style={{ marginTop: 0 }}>
            {selected.summary.eventCount} events · {formatDateRange(selected.summary.start, selected.summary.end, timeConfig)}
          </p>
        </div>
      )}
    </div>
  );
};
