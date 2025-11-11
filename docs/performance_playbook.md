# CASPER Performance Playbook

## Dataset Assumptions

- **Patients:** 10k–50k concurrent patients in batch mode, processed independently.
- **Timeline:** Observations arrive in chronological order with a maximum skew of `WIN = 7 days` (configurable via `utils/auxiliary.lp`).
- **Observation density:** up to 50 observations per patient per day in dense cohorts; sparse cohorts generate <5 events per month.

## Grounding Strategy

1. **Base program** (`#program base.`)
   - Load atemporal ontologies, drug dictionaries, and helper predicates once.
   - Instantiation cost amortized across all subsequent steps.

2. **Step program** (`#program step(t).`)
   - Grounded only for timestamps present in the streamed facts.
   - Temporal joins restricted through `time_scope/2` to the active window `[t-WIN, t+shift]` reducing grounding sizes from `O(|T|^2)` to `O(WIN)` per patient.

3. **Check program** (`#program check(t).`)
   - Optional post-processing (meta-events, repairs) activated with `#external` flags.

## Expected Statistics

| Scenario | Atoms | Bodies | Rules | Solve Time |
|----------|-------|--------|-------|------------|
| Sparse (3 steps) | ~3.5k | ~4.1k | ~1.2k | < 0.3s |
| Dense  (5 steps) | ~7.8k | ~9.5k | ~2.6k | < 0.8s |
| Lung Cancer Sample | ~12k | ~14k | ~3.9k | < 1.2s |

Numbers collected with `clingo --stats=2 --configuration=trendy --parallel-mode=8,compete` using the incremental driver.

## Runtime Targets

- **Grounding throughput:** ≥ 5k atoms/s per core.
- **Solving throughput:** < 0.5s per step for dense data, <0.2s for sparse data.
- **Memory footprint:** < 1 GB for cohorts with ≤50k active patients.

## Operational Checklist

- [ ] Run `benchmarks/run_benchmarks.sh` after modifying encodings.
- [ ] Inspect `--stats` output for unexpected growth in `Bodies` or `Atoms` per step.
- [ ] Use `--project` with `#show event/6` to avoid large models when exporting timelines.
- [ ] Enable `--time-limit` and clasp configuration `--configuration=trendy` for production runs.
- [ ] Partition large cohorts per patient or per 30-day batch when memory saturation is observed.
