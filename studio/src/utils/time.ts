import { TimeConfig, TimeUnit } from '../types/casper';

const UNIT_TO_MS: Record<TimeUnit, number> = {
  seconds: 1000,
  minutes: 60 * 1000,
  hours: 60 * 60 * 1000,
  days: 24 * 60 * 60 * 1000
};

export function convertCasperTimeToDate(value: number, config: TimeConfig): Date {
  const base = new Date(config.baseDate).getTime();
  const unitMultiplier = UNIT_TO_MS[config.unit] ?? UNIT_TO_MS.seconds;
  return new Date(base + value * unitMultiplier);
}

export function formatDateRange(start: number, end: number, config: TimeConfig): string {
  const startDate = convertCasperTimeToDate(start, config);
  const endDate = convertCasperTimeToDate(end, config);
  return `${startDate.toISOString()} → ${endDate.toISOString()}`;
}
