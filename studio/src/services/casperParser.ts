import { CasperAnswerSet, CasperParseResult, CasperMode, RawCasperJson } from '../types/casper';
import { parseEventAtom } from '../utils/atomParser';

function buildSummary(events: CasperAnswerSet['events']): CasperAnswerSet['summary'] {
  if (events.length === 0) {
    return {
      eventCount: 0,
      timeSpan: 0,
      start: 0,
      end: 0,
      types: {}
    };
  }

  const start = Math.min(...events.map((event) => event.start));
  const end = Math.max(...events.map((event) => event.end));
  const types = events.reduce<Record<string, number>>((acc, event) => {
    acc[event.type] = (acc[event.type] ?? 0) + 1;
    return acc;
  }, {});

  return {
    eventCount: events.length,
    timeSpan: end - start,
    start,
    end,
    types
  };
}

export function parseCasperJson(mode: CasperMode, json: RawCasperJson): CasperParseResult {
  const witnesses = json.Call?.[0]?.Witnesses ?? [];
  const answerSets: CasperAnswerSet[] = witnesses.map((witness, index) => {
    const events = witness.Value.map(parseEventAtom).filter(Boolean) as CasperAnswerSet['events'];
    return {
      id: `witness-${index + 1}`,
      witnessIndex: index,
      events,
      summary: buildSummary(events)
    };
  });

  return {
    mode,
    metadata: {
      solver: json.Solver,
      result: json.Result,
      models: json.Models,
      time: json.Time,
      threads: json.Threads,
      winner: json.Winner,
      stats: json.Stats
    },
    answerSets
  };
}
