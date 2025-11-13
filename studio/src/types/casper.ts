export type CasperMode = 'naive' | 'consistent' | 'preferred' | 'cautious';

export type RawCasperWitness = {
  Time: number;
  Value: string[];
};

export interface RawCasperJson {
  Solver: string;
  Input: string[];
  Call: Array<{
    Start: number;
    Stop: number;
    Witnesses: RawCasperWitness[];
  }>;
  Result: string;
  Models: {
    Number: number;
    More: string;
  };
  Calls: number;
  Time: {
    Total: number;
    Solve: number;
    Model: number;
    Unsat: number;
    CPU: number;
  };
  Threads?: number;
  Winner?: number;
  Stats?: Record<string, unknown>;
}

export type CasperEvent = {
  id: string;
  type: string;
  patientId: string;
  attribute?: string;
  start: number;
  end: number;
  confidence: number;
  raw: string;
};

export interface CasperAnswerSet {
  id: string;
  witnessIndex: number;
  events: CasperEvent[];
  summary: {
    eventCount: number;
    timeSpan: number;
    start: number;
    end: number;
    types: Record<string, number>;
  };
}

export interface CasperMetadata {
  solver: string;
  result: string;
  models: RawCasperJson['Models'];
  time: RawCasperJson['Time'];
  threads?: number;
  winner?: number;
  stats?: RawCasperJson['Stats'];
}

export interface CasperParseResult {
  mode: CasperMode;
  metadata: CasperMetadata;
  answerSets: CasperAnswerSet[];
}

export type TimeUnit = 'seconds' | 'minutes' | 'hours' | 'days';

export interface TimeConfig {
  baseDate: string;
  unit: TimeUnit;
}
