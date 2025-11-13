import { useEffect, useMemo, useRef } from 'react';
import { Timeline, DataSet } from 'vis-timeline/standalone';
import 'vis-timeline/dist/vis-timeline-graph2d.min.css';
import { useCasperData } from '../../hooks/useCasperData';
import { convertCasperTimeToDate } from '../../utils/time';

export const TimelineView = () => {
  const { data, selectedAnswerSetId, timeConfig, loading } = useCasperData();
  const containerRef = useRef<HTMLDivElement | null>(null);
  const timelineRef = useRef<Timeline | null>(null);

  const selectedAnswerSet = useMemo(() => data?.answerSets.find((set) => set.id === selectedAnswerSetId), [data, selectedAnswerSetId]);

  useEffect(() => {
    if (containerRef.current && !timelineRef.current) {
      timelineRef.current = new Timeline(containerRef.current);
    }
    return () => {
      timelineRef.current?.destroy();
      timelineRef.current = null;
    };
  }, []);

  useEffect(() => {
    if (!timelineRef.current) {
      return;
    }

    const events = selectedAnswerSet?.events ?? [];
    const items = new DataSet(
      events.map((event) => {
        const startDate = convertCasperTimeToDate(event.start, timeConfig);
        const endDate = convertCasperTimeToDate(event.end, timeConfig);
        const isPoint = event.start === event.end;

        return {
          id: event.id,
          content: `<strong>${event.type}</strong>`,
          start: startDate,
          end: isPoint ? undefined : endDate,
          type: isPoint ? 'point' : 'range',
          className: `confidence-${event.confidence}${isPoint ? ' point-item' : ''}`,
          title: `Patient: ${event.patientId}\n${event.attribute ?? 'n/a'}\n${startDate.toISOString()} → ${endDate.toISOString()}`
        };
      })
    );

    timelineRef.current.setItems(items);
    if (events.length > 0) {
      timelineRef.current.fit();
    }
  }, [selectedAnswerSet, timeConfig]);

  if (!data) {
    return <p style={{ margin: 0 }}>{loading ? 'Loading data…' : 'Load an app to visualize results.'}</p>;
  }

  return (
    <div>
      <div className="timeline-header">
        <h2>Timeline</h2>
        <span style={{ color: 'var(--text-muted)' }}>{selectedAnswerSet?.events.length ?? 0} events</span>
      </div>
      <div ref={containerRef} className="timeline-container" />
    </div>
  );
};
