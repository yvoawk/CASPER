import clsx from 'clsx';
import { useMemo } from 'react';
import { CasperAnswerSet } from '../../types/casper';
import { useCasperData } from '../../hooks/useCasperData';
import { convertCasperTimeToDate } from '../../utils/time';

interface Props {
  answerSet: CasperAnswerSet;
}

export const AnswerSetCard = ({ answerSet }: Props) => {
  const { selectedAnswerSetId, setSelectedAnswerSetId, timeConfig } = useCasperData();
  const isActive = selectedAnswerSetId === answerSet.id;

  const topTypes = useMemo(() => Object.entries(answerSet.summary.types).sort((a, b) => b[1] - a[1]).slice(0, 3), [answerSet.summary.types]);
  const hasEvents = answerSet.summary.eventCount > 0;
  const startDate = hasEvents ? convertCasperTimeToDate(answerSet.summary.start, timeConfig) : null;
  const endDate = hasEvents ? convertCasperTimeToDate(answerSet.summary.end, timeConfig) : null;

  return (
    <div className={clsx('answer-card', { active: isActive })} onClick={() => setSelectedAnswerSetId(answerSet.id)} role="button">
      <h3>Timeline {answerSet.witnessIndex + 1}</h3>
      <p style={{ marginTop: 0, marginBottom: '0.75rem', color: 'var(--text-muted)' }}>{answerSet.summary.eventCount} events</p>
      <div style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>
        {hasEvents && startDate && endDate ? (
          <strong style={{ display: 'block', color: 'var(--primary)' }}>
            Span: {startDate.toLocaleDateString()} → {endDate.toLocaleDateString()}
          </strong>
        ) : (
          <strong style={{ display: 'block', color: 'var(--text-muted)' }}>No events</strong>
        )}
        {topTypes.map(([type, count]) => (
          <div key={type}>
            {type}: {count}
          </div>
        ))}
      </div>
      <small style={{ color: 'var(--text-muted)' }}>Base date: {new Date(timeConfig.baseDate).toLocaleString()}</small>
    </div>
  );
};
