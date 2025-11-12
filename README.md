<p align="center">
  <img src="assets/logo.png" alt="casper logo" width="150">
</p>

# CASPER (Clinical ASP-based Event Recognition)
[![CASPER badge](https://img.shields.io/badge/CASPER-ready%20to%20use-brightgreen)](https://github.com/yvoawk/CASPER)
[![ASP badge](https://img.shields.io/badge/Build%20with-♥%20and%20ASP-red)](https://github.com/yvoawk/CASPER)
[![licence](https://img.shields.io/badge/Licence-MIT%20%2B%20file%20LICENSE-blue)](https://github.com/yvoawk/CASPER/blob/master/LICENSE)

CASPER leverages the expressive power of ASP to model medical knowledge and infer clinical events from sequences of raw observations.
CASPER encodes rules that capture both expert knowledge and temporal patterns, enabling the identification of clinically meaningful events—including their initiation and termination—even in the presence of imperfect data.
An ASP solver (`Clingo`) is used to compute answer sets, which correspond to valid interpretations of events based on the encoded rules and the provided observations.

## 📂 Repository Structure  
```text
CASPER/
├── app/                              # Application directory
│   └── lung_cancer/                  # Use case on lung cancer
│       └── domain/                   # Folder for domain knowledge
│       │   ├── raw_atemporal_facts.lp# Optional plain atemporal facts
│       │   ├── atemporal_facts.lp    # Solver-ready file (editable fallback)
│       │   └── atemporal_facts.solver.lp # Auto-generated build artifact
│       ├── facts/                    # Folder for facts
│       │   ├── raw_facts.lp          # Optional plain obs/4 input
│       │   ├── facts.lp              # Solver-ready facts (editable fallback)
│       │   ├── facts.solver.lp       # Auto-generated solver facts
│       │   └── step_activation.lp    # Auto-generated activation facts
│       └── user_parameters/          # Folder for event description
│           ├── raw_simple_event.lp   # Optional plain simple-event rules
│           ├── raw_meta_event.lp     # Optional plain meta-event rules
│           ├── simple_event.lp       # Solver-ready simple events
│           ├── meta_event.lp         # Solver-ready meta-events (optional)
│           ├── simple_event.solver.lp# Auto-generated build artifact
│           └── meta_event.solver.lp  # Auto-generated build artifact
├── encoding/                         # CASPER system core
│   ├── expansion.lp                  # Expansion technique encoding
│   ├── linear.lp                     # Linear technique encoding
│   ├── preference.lp                 # Preference encoding
│   ├── repair.lp                     # Repair process encoding
│   └── temporal_predicate.lp         # Temporal predicate encoding (Allen's interval algebra relations, Vilain's point interval algebra relations, etc.)
├── execution/                        # Execution folder
│   ├── parameters1.lp    
│   ├── parameters2.lp            
│   ├── parameters3.lp           
│   └── run_casper.sh                 # CASPER execution script
├── utils/                            # Utility folder
│   ├── auxiliary.lp                  # Helper predicate
│   ├── filter_fact.py                # Python function to filter observation facts  
│   ├── generate_step_program.py      # Wraps raw obs/4 facts into #program step blocks
│   ├── generate_step_activation.py   # Creates activation facts for all steps
│   ├── generate_atemporal_facts.py   # Wraps raw atemporal facts with #program base
│   ├── generate_simple_events.py     # Wraps raw simple-event rules with guards
│   ├── generate_meta_events.py       # Wraps raw meta-event rules with guards
│   ├── process_answer.py             # Processing meta-event script      
│   └── python.lp                     # Embedded Python utility function
└── LICENSE                           # License file
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
> CASPER now runs entirely in one-shot mode; the runner prepares the necessary `#program step/step_time` files and activation facts automatically before calling Clingo once.

To view usage instructions or available options for CASPER, use the --help flag:
```bash
./execution/run_casper.sh --help
```


The output:
```bash
CASPER version 1.0.0
Usage: ./execution/run_casper.sh --app=APP_NAME [OPTIONS]

Required:
  --app=APP_NAME           Name of the app (must match a folder in ./app/ and not contain spaces)

Options:
  --repair=(yes|no)        Enable or disable repair mode (default: no)
  --timeline=MODE          Timeline mode (naive|preferred|cautious) (default: naive)
                           Note: 'preferred' & 'cautious' can only be used with --repair=yes
  --thread-N=N             Number of parallel threads (default: 1)
  --window=start-end       Time window for event recognition (format: start-end, both numeric)
                            Example: --window=1609459200-1609545600
                            Note: start must be less than end
  --unit=seconds           Units of the time used (default: seconds)
                           Other options: minutes, hours, days
  --verbose                Print configuration before execution
  --help                   Show helper message
  --version                Show CASPER version information
```
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

- `domain/raw_atemporal_facts.lp`:  
  Optional raw version of the domain facts without `#program` directives. If present, the runner converts it into `atemporal_facts.lp` automatically.

- `facts/raw_facts.lp`:  
  Contains the observations provided by the user (only `obs/4` literals, one per line).  
  The runner converts this file into the solver-ready `facts/facts.lp`. Keep `facts.lp` in version control only if you need to inspect it, but treat it as generated output.

- `facts/facts.lp`:  
  Generated automatically from `raw_facts.lp` and includes the `#program step(...)` and `step_time/2` directives required by the temporal encodings. Avoid editing this file manually unless you deliberately skip the generator.

- `user_parameters/raw_simple_event.lp`:  
  Contains the clinician-authored simple-event rules expressed without any `#program` sections or guard predicates. The runner wraps these rules automatically before execution.

- `user_parameters/simple_event.lp`:  
  Generated from `raw_simple_event.lp` and defines **simple events**, both persistent and non-persistent. Treat this as build output unless you opt out of the generator.

- `user_parameters/raw_meta_event.lp`:  
  Holds high-level/meta-event rules expressed without multi-shot boilerplate.

- `user_parameters/meta_event.lp` *(optional)*:  
  Generated from `raw_meta_event.lp`; defines **meta-events**, if your application includes any.

## 🧠 Predicates

### Observation

- `obs([observation_name], [Patient], ..., [Time])`:  
  Defines an observation fact at a given time.

### Event Existence

- `exists([event_name], [Patient], [entity], [Time], [confidence_level])`:  
  Specifies the existence of a **non-persistent** simple event.

- `exists_pers([event_name], [Patient], [entity], [Time], [confidence_level])`:  
  Specifies the existence of a **persistent** simple event.

> ⚠️ **Note**:  
> - The `Time` argument must be a non-null integer.  
> - CASPER currently supports **three levels of confidence** for initiation: `1` (highest), `2`, and `3` (lowest), and **one level for termination**.

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

  > ⚠️ CASPER supports up to 3 confidence levels for existence conditions (1 = high, 2, 3 = low), and a single level (1) for termination.

- Repair Option (Temporal Repair Only)
  
  CASPER includes a repair mechanism to handle overlapping event intervals of the same type, selecting the most appropriate segment(s) based on temporal consistency and confidence preferences.

  > 🛠️ This allows correction of conflicting temporal segments.
  >
  > ❌ Domain repair (e.g., resolving logical inconsistencies in background knowledge) is currently not supported.

- Windowing
  
  CASPER also supports temporal windowing, allowing the system to restrict reasoning to a specific time interval.

- Two Modes
  
  - `preferred`: keep only the highest-confidence, longest-valid segments
  
  - `cautious`: prioritize minimal but safe segments

---

📜 License

MIT License - See [LICENSE](https://github.com/yvoawk/CASPER/blob/master/LICENSE).
---
📬 Contact

For questions or contributions, please [open an issue](https://github.com/yvoawk/CASPER/issues) or contact the [maintainers](mailto:yvon.awuklu@gmail.com).
#### Supplying Observation Facts
1. Describe observations in `app/<app>/facts/raw_facts.lp` (preferred) using `obs(Name, Patient, Value, Timestamp).`.  
   - If you already maintain a solver-ready file in `facts/facts.lp` that includes `#program step(...)` sections, you can skip the raw file; the runner will use `facts.lp` directly.
2. When you launch `run_casper.sh`, the script automatically:
   - Applies the optional `--window` filter (only available when `raw_facts.lp` exists).
   - Converts the resulting facts into `facts/facts.solver.lp` with the required `#program step(t...)` and `step_time/2` atoms.
   - Generates `facts/step_activation.lp`, which turns on all `use_*` externals so Clingo can solve in one shot.
3. Treat `facts.solver.lp` and `step_activation.lp` as build artifacts; they are regenerated on each run.

#### Authoring Simple Event Rules
- Preferred: edit `app/<app>/user_parameters/raw_simple_event.lp` with plain ASP rules. The runner wraps them via `utils/generate_simple_events.py`, producing `simple_event.solver.lp`.
- If the raw file is absent, the runner uses `user_parameters/simple_event.lp` as-is. Ensure this file already contains the `#program base.` / `#program step(t).` sections and `use_simple_events/1` guards if you go this route.

#### Authoring Meta-Event Rules
- Follow the same pattern: `raw_meta_event.lp` → auto-generated `meta_event.solver.lp`.  
- `user_parameters/meta_event.lp` remains optional; if neither raw nor solver files exist, the meta stage is skipped.

#### Providing Atemporal Domain Facts
- You can keep a plain version in `domain/raw_atemporal_facts.lp`; the runner wraps it with `utils/generate_atemporal_facts.py`, resulting in `domain/atemporal_facts.solver.lp`.
- Without the raw file, `domain/atemporal_facts.lp` is used directly (it should already start with `#program base.`).
