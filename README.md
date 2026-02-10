<p align="center">
  <img src="assets/logo.png" alt="casper logo" width="150">
</p>

# CASPER (Clinical ASP-based Event Recognition)
[![CASPER badge](https://img.shields.io/badge/CASPER-ready%20to%20use-brightgreen)](https://github.com/yvoawk/CASPER)
[![ASP badge](https://img.shields.io/badge/Build%20with-ASP-red)](https://github.com/yvoawk/CASPER)
[![license](https://img.shields.io/badge/License-MIT-blue)](https://github.com/yvoawk/CASPER/blob/master/LICENSE)

CASPER is an Answer Set Programming (ASP)–based framework for inferring high-level temporal events from raw, timestamped observations. It integrates domain knowledge, temporal reasoning, and confidence propagation to identify event initiation and termination intervals, while explicitly handling imperfect data through a dedicated temporal repair pipeline.

## 📂 Repository Structure

```text
CASPER/
├── app/                              # Clinical use-case applications
│   └── lung_cancer/
│       ├── domain/
│       │   └── atemporal_facts.lp
│       ├── facts/
│       │   └── facts.lp
│       └── user_parameters/
│           ├── simple_event.lp
│           └── meta_event.lp
├── encoding/                         # Core ASP encodings
│   ├── np_simple_event.lp
│   ├── p_simple_event.lp
│   ├── repair.lp
│   ├── greedy_preference.lp
│   ├── temporal_predicate.lp
│   └── ...
├── execution/
│   ├── parameters1.lp
│   ├── parameters2.lp
│   ├── parameters3.lp
│   └── run_casper.sh                 # Main entrypoint
├── utils/
│   ├── auxiliary.lp
│   ├── filter_fact.py
│   ├── process_answers.py
│   └── python.lp
├── results/                          # Generated outputs
└── LICENSE
```

## 🚀 Quick Start

CASPER has been tested using `Clingo 5.8.0` and `Python 3.12.9`.

### Prerequisites
> An easy way to set up the required configuration is to use Conda to create an environment with the specified Python version and install Clingo.

### 🔧 Recommended Setup (Using Conda)

You can easily configure the environment using [Conda](https://docs.conda.io/en/latest/):

```bash
conda create -n casper-env python=3.12.9
conda activate casper-env
conda install -c conda-forge clingo=5.8.0
```

### ▶️ Basic Execution
An example application focused on `lung cancer` can be found in the `./app` directory.
```bash
./execution/run_casper.sh --app=lung_cancer
```
> The results will be output to a subfolder named after your application, located inside the results directory.

To view usage instructions or available options for CASPER, use the --help flag:
```bash
./execution/run_casper.sh --help
```
The output:
```bash
CASPER version 1.0.3
Usage: ./execution/run_casper.sh --app=APP_NAME [OPTIONS]

Required:
  --app=APP_NAME           Name of the app (must match a folder in ./app/ and not contain spaces)

Options:
  --repair=(yes|no)        Enable or disable temporal repair mode (default: no).
  --timeline=<MODE>        Timeline mode (`naive|preferred|cautious`, default: naive).
  --thread-N=<N>           Number of parallel threads (integer >= 1, default: 1).
  --window=<start-end>       Numeric epoch window filter for observations. (format: start-end, both numeric)
                            Example: --window=1609459200-1609545600
                            Note: start must be less than end
  --unit=<seconds|minutes|hours|days>  Time unit constant used by encodings (default: `seconds`).
  --verbose                Print execution configuration before execution.
  --help                   Print usage text.
  --version                Print version information.
```

> ⚠️ **Note**:

> - `preferred` and `cautious` require `--repair=yes`.
> - When `--repair=yes` is set without `preferred` or `cautious`, the script internally switches to a `consistent` output timeline.

### Execution Examples

Simple events + meta-events (no repair):

```bash
./execution/run_casper.sh --app=lung_cancer
```

Repair mode with preferred timeline:

```bash
./execution/run_casper.sh --app=lung_cancer --repair=yes --timeline=preferred
```

Repair mode with cautious reasoning:

```bash
./execution/run_casper.sh --app=lung_cancer --repair=yes --timeline=cautious
```

Run with a time window and alternate unit:

```bash
./execution/run_casper.sh \
  --app=lung_cancer \
  --window=447072-447934 \
  --unit=hours \
  --verbose
```

### Output Layout

Results are written to:

```text
results/<app>/<timeline>/results_<YYYY-MM-DD_HH-MM-SS>.json
```

Timeline subfolders are created automatically (`naive`, `preferred`, `cautious`, or `consistent`).

## 📦 How to Add Your Application

To add a new application, create a folder named after your application (no spaces) in the `./app` directory. This folder should follow the structure below:
```text
./app/your_application_name/
├── domain/
│   └── atemporal_facts.lp
├── facts/
│   └── facts.lp
├── user_parameters/
│   ├── simple_event.lp
│   └── meta_event.lp  (optional)
```

### Folder Descriptions

- `domain/atemporal_facts.lp`:  
  Contains atemporal domain knowledge relevant to your application.

- `facts/facts.lp`:  
  Contains observation facts for your application.

- `user_parameters/simple_event.lp`:  
  Defines **simple events**, both persistent and non-persistent.

- `user_parameters/meta_event.lp` *(optional)*:  
  Defines **meta-events**, if your application includes any.

## 🧠 Core Predicates
CASPER uses a set of core predicates to represent observations, events, and temporal relationships. These predicates are used across the encodings and should be familiar to users defining their own applications.

### Observation

- `obs([observation_name], [Patient], ..., [Time])`:  
  Defines an observation fact at a given time.
  
  > ⚠️ **Death Observation Format**: Patient death must be recorded exactly as `obs(death, Patient, Time)` so the encodings can correctly detect and propagate the death information.

### Event Existence

- `exists([event_name], [Patient], [entity], [Time], [confidence_level])`:  
  Specifies the existence of a **non-persistent** simple event.

- `exists_pers([event_name], [Patient], [entity], [Time], [confidence_level])`:  
  Specifies the existence of a **persistent** simple event.

> ⚠️ **Note**:  
> - The `Time` argument must be a non-null integer.

### Termination

- `terminates(...)`:  
  Indicates the termination condition for both persistent and non-persistent simple events.  
  Same format as `exists` and `exists_pers`.

### Time Window

- `pt_window([event_name], [entity], [time_period])`:  
  Specifies the time window for identifying non-persistent simple events.

### Event

- `event([ID], [event_name], [Patient], [Entity], ([Start], [End]), [Confidence])`:
  
  Events capture clinically meaningful patterns identified from observations.
  
  > ⚠️ **Note**: For instance, the system does not yet support dynamic arguments during event definition, requiring events to be defined in this fixed format.  

### Meta-Event

- `m_event([meta_event_name], [Patient], [Entity], ([Start], [End]), [Confidence])` or `m_event([meta_event_name], [Patient], ([Start], [End]), [Confidence])`:
  
  Meta-events represent higher-level or composite clinical events derived from at least one event (simple or meta- event), based on temporal relationships or logical conjunctions.

## ⏱ Temporal Reasoning

The `temporal_predicate.lp` file defines the core predicates that enable `CASPER` to reason about the relative positions of timepoints and intervals. These predicates are essential for expressing and evaluating complex temporal relations between events, such as those required to construct meta-events.

### Interval Operations

- `intersection_of((T1,T2), (T3,T4), (T, T'))`:  
  Computes the intersection `(T, T')` of two intervals.
  
  Example:
  intersection_of((T1,T2), (T3,T4), (T,T')) computes the intersection (T, T') of intervals (T1, T2) and (T3, T4).

- `union_of(...)`:  
  Computes the union of two time intervals.

### Allen's Relations

You can express temporal relations between intervals using **Allen’s interval algebra**. All 13 relations are supported (e.g., *before*, *during*, *overlaps*, etc.).

### Vilain’s Relations (Subset)

Support for key point-based relations: `p_before/2, p_after/2, p_during/2, p_starts/2, p_finishes/2`.

## 🔧 Helper Predicates

- `start([event_name], [Patient], [Time], [confidence_level])`:  
  Returns the **earliest** time point of a given event.

- `end([event_name], [Patient], [Time], [confidence_level])`:  
  Returns the **latest** time point of a given event.

- `persist_end([Patient], [Time])`:  
  Indicates that the end time of an event is ongoing.

## 🛠️ Support Features

In addition to event inference, CASPER provides built-in support for:

- Confidence Propagation
  
  Ensures that the confidence of inferred (simple or meta) events reflects the lowest confidence among their supporting observations and sub-events.

- Repair Option (Temporal Repair Only)
  
  CASPER includes a repair mechanism to handle overlapping event intervals of the same type, selecting the most appropriate segment(s) based on temporal consistency and confidence preferences.

  > 🛠️ This allows correction of conflicting temporal segments.
  >
  > ❌ Domain repair (e.g., resolving logical inconsistencies in background knowledge) is currently not supported.

- Windowing
  
  CASPER also supports temporal windowing, allowing the system to restrict reasoning to a specific time interval.

- Two Modes
  
  - `preferred`: keep only the highest-confidence, longest-valid segments
  
  - `cautious (Clingo cautious reasoning)`: retain only segments that appear in all repairs, yielding minimal but guaranteed-safe intervals

---

📜 License

MIT License - See [LICENSE](https://github.com/yvoawk/CASPER/blob/master/LICENSE).
---
📬 Contact

For questions or contributions, please [open an issue](https://github.com/yvoawk/CASPER/issues) or contact the [maintainers](mailto:yvon.awuklu@gmail.com).
