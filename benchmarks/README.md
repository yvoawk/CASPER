# Micro-benchmark Suite

The `benchmarks/` folder contains two synthetic workloads for regression and profiling:

| Scenario | Description | Steps |
|----------|-------------|-------|
| `dense`  | Compact 5-step timeline with overlapping initiations, multiple administrations, and a death event. | 5 |
| `sparse` | Three events spaced one week apart to stress long windows and incremental retention. | 3 |

Each dataset is encoded with `#program step(<timestamp>).` blocks and leverages the same domain and event definitions used in the lung cancer application.

## Running

Use the incremental driver:

```bash
python execution/multishot_driver.py \
  --facts benchmarks/dense/facts.lp \
  --base app/lung_cancer/domain/atemporal_facts.lp utils/auxiliary.lp \
  --step benchmarks/dense/facts.lp app/lung_cancer/user_parameters/simple_event.lp encoding/expansion.lp encoding/linear.lp \
  --check app/lung_cancer/user_parameters/meta_event.lp \
  --output benchmarks/dense/results.json
```

Swap `dense` for `sparse` to run the sparse benchmark. The resulting JSON captures the projected atoms after all steps have been processed.
