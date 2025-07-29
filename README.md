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
│       │   └── atemporal_facts.lp    # Relevant atemporal domain knowledge file
│       ├── facts/                    # Folder for facts
│       │   └── facts.lp              # Observation facts file
│       └── user_parameters/          # Folder for event description
│           ├── simple_event.lp       # Simple event definition file
│           └── meta_event.lp         # Meta-event defintion file
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
│   ├── process_answer.py             # Processeing meta-event script      
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
  --timeline=MODE          Timeline mode (naïve|preferred|cautious) (default: naïve)
                           Note: 'preferred' & 'cautious' can only be used with --repair=yes
  --thread-N=N             Number of parallel threads (default: 1)
  --window=start-end       Time window for event recognition (format: start-end, both numeric)
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

- `facts/facts.lp`:  
  Contains observation facts for your application.

- `user_parameters/simple_event.lp`:  
  Defines **simple events**, both persistent and non-persistent.

- `user_parameters/meta_event.lp` *(optional)*:  
  Defines **meta-events**, if your application includes any.

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

### Meta-Event

- `m_event([meta_event_name], [Patient], [Entity], ([Start], [End]), [Confidence])`:
  
  Meta-events represent higher-level or composite clinical events derived from at least one simple event, based on temporal relationships or logical conjunctions.

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
  Indicates that the end time of a persistent event is ongoing.

## 🛠️ Support Features

In addition to event inference, CASPER provides built-in support for:

- Confidence Propagation
  
  Ensures that the confidence of inferred (simple or meta) events reflects the lowest confidence among their supporting observations and sub-events.

  > ⚠️ CASPER supports up to 3 confidence levels for existence conditions (1 = high, 2, 3 = low), and a single level (1) for termination.

- Repair Mode (Temporal Repair Only)
  
  CASPER includes a repair mechanism to handle overlapping event intervals of the same type, selecting the most appropriate segment(s) based on temporal consistency and confidence preferences.

  > 🛠️ This allows correction of conflicting temporal segments.
  >
  > ❌ Domain repair (e.g., resolving logical inconsistencies in background knowledge) is currently not supported.

- Parallel Execution
  
  Speed up computation by leveraging multiple threads via the `--thread-N` option. Useful for large-scale datasets or multiple patient timelines.

- Preference Modes
  When multiple temporal segments are possible for a given event, CASPER allows selection of the most clinically plausible one using:

  - `naïve`: keep all
  
  - `preferred`: keep only the highest-confidence, longest-valid segments
  
  - `cautious`: prioritize minimal but safe segments

---

📜 License

MIT License - See [LICENSE](https://github.com/yvoawk/CASPER/blob/master/LICENSE).
---
📬 Contact

For questions or contributions, please [open an issue](https://github.com/yvoawk/CASPER/issues) or contact the [maintainers](mailto:.....).
