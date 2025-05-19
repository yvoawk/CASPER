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
│       │   └── domain_knowledge.lp   # Domain knowledge description file
│       ├── facts/                    # Folder for facts
│       │   └── facts.lp              # Observation facts file
│       └── user_parameters/          # Folder for event description
│           ├── simple_event.lp       # Simple event definition file
│           └── meta_event.lp   # Meta-event defintion file
├── encoding/                         # CASPER system core
│   ├── expansion.lp                  # Expansion technique encoding
│   ├── linear.lp                     # Linear technique encoding
│   ├── preference.lp                 # Preference encoding
│   ├── repair.lp                     # Repair process encoding
│   └── temporal_predicate.lp         # Temporal predicate encoding (Allen's interval algebra relation, etc.)
├── execution/                        # Execution folder
│   ├── parameters1.lp    
│   ├── parameters2.lp            
│   ├── parameters3.lp           
│   └── run_casper.sh                 # CASPER execution script
├── utils/                            # Utility folder
│   ├── auxiliary.lp                  # Helper predicate
│   ├── filter_fact.py                # Python function to filter observation facts  
│   ├── process_answer.py             # Processeing meta-event script      
│   └── python/lp                     # Embedded Python utility function
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
