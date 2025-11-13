import { CasperEvent } from '../types/casper';

const EVENT_PREFIX = 'event(';

const CONFIDENCE_LEVELS = [1, 2, 3];

function splitArguments(atomBody: string): string[] {
  const args: string[] = [];
  let current = '';
  let depth = 0;

  for (const char of atomBody) {
    if (char === '(') {
      depth += 1;
    }
    if (char === ')') {
      depth -= 1;
    }

    if (char === ',' && depth === 0) {
      args.push(current.trim());
      current = '';
    } else {
      current += char;
    }
  }

  if (current) {
    args.push(current.trim());
  }

  return args;
}

function parseInterval(raw: string): { start: number; end: number } | null {
  const cleaned = raw.replace(/[()]/g, '');
  const [start, end] = cleaned.split(',').map((value) => Number(value.trim()));
  if (Number.isNaN(start) || Number.isNaN(end)) {
    return null;
  }
  return { start, end };
}

export function parseEventAtom(atom: string): CasperEvent | null {
  if (!atom.startsWith(EVENT_PREFIX) || !atom.endsWith(')')) {
    return null;
  }

  const body = atom.slice(EVENT_PREFIX.length, -1);
  const args = splitArguments(body);

  if (args.length < 5) {
    return null;
  }

  const [id, type, patientId] = args;
  const maybeInterval = args[3];

  let attribute: string | undefined;
  let intervalArg: string;
  let confidenceArg: string;

  if (maybeInterval?.startsWith('(')) {
    intervalArg = maybeInterval;
    confidenceArg = args[4];
  } else {
    attribute = maybeInterval;
    intervalArg = args[4];
    confidenceArg = args[5];
  }

  const interval = parseInterval(intervalArg);
  if (!interval) {
    return null;
  }

  const confidence = Number(confidenceArg);
  const normalizedConfidence = CONFIDENCE_LEVELS.includes(confidence)
    ? confidence
    : Math.min(Math.max(Math.round(confidence), 1), 3);

  return {
    id: id.trim(),
    type: type.trim(),
    patientId: patientId.trim(),
    attribute: attribute?.trim(),
    start: interval.start,
    end: interval.end,
    confidence: normalizedConfidence,
    raw: atom
  };
}
