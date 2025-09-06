# Smart Contract Audit Tools Benchmark & Review  

📘 **Goal:**  
This project supports the development of a **review paper** and an **open benchmark suite** for smart contract vulnerability detection tools. We aim to:  

- Provide the **community** with a clear overview of tools and methodologies.  
- Explain how these tools **work**, what vulnerabilities they detect, and what **mitigation strategies** they enable.  
- Benchmark leading tools across categories and **compare their performance**.  
- Identify **research gaps** and outline **future directions** for smart contract security.  

---

## 🔍 Motivation  

Smart contracts underpin DeFi, DAOs, NFTs, and many blockchain applications. Their **immutability** and **complexity** make them highly vulnerable — billions of dollars have been lost in incidents such as the DAO hack, Parity wallet bugs, and flash loan exploits.  

Dozens of auditing tools exist, but they vary in **coverage, accuracy, usability, and maintenance**. There is no unified benchmark to systematically evaluate them. This project addresses that gap.  

---

## 🗃️ Dataset

We used https://github.com/shenyimings/FORGE-Artifacts as our base dataset of vulnerable smart contracts.

---

## 🧩 Categories of Tools & Selected Candidates  

We classify smart contract vulnerability detection tools into **seven categories**.  
For each, we list **five representative tools**.  
We will **run and benchmark the Top-3** in each category, then perform a **cross-category comparison** to extract insights.  

### 1. Static Analysis  
Analyzes code without execution; fast and scalable but prone to false positives.  
- **Slither**  
- **SmartCheck**  
- **Securify 2.0**  
- **MadMax** (gas-related DoS detection)  
- **Osiris** (integer bugs)  

👉 **Top-3 to benchmark:** Slither, SmartCheck, Securify 2.0  

---

### 2. Symbolic Execution  
Explores paths with symbolic inputs; precise but faces path explosion.  
- **Mythril**  
- **Manticore**  
- **Oyente**  
- **Harvey**  
- **Echidna** *(installed under FuzzingDynamic and referenced here)*  

👉 **Top-3 to benchmark:** Mythril, Manticore, Echidna  

---

### 3. Fuzzing / Dynamic Testing  
Executes contracts with random/mutated inputs to uncover runtime flaws.  
- **sFuzz**  
- **ContractFuzzer**  
- **ConFuzzius** *(installed under Hybrid and referenced here)*  
- **ILF (Intermediate Language Fuzzer)**  
- **sGuard**  
- **Echidna**  

👉 **Top-3 to benchmark:** sFuzz, ContractFuzzer, ConFuzzius  

---

### 4. Formal Verification  
Mathematically proves properties; strongest assurance but expensive and complex.  
- **Zeus**  
- **VeriSolid**  
- **KEVM**  
- **Certora Prover**  
- **VeriSmart**  

👉 **Top-3 to benchmark:** Zeus, Certora Prover, KEVM  

---

### 5. Machine Learning & Deep Learning  
Data-driven models trained on contract datasets.  
- **Eth2Vec**  
- **DeeSCVHunter**  
- **XSmart**  
- **ContractWard**  
- **SolAnalyser**  

👉 **Top-3 to benchmark:** DeeSCVHunter, Eth2Vec, XSmart  

---

### 6. Agentic LLM Models  
Use large language models to explain vulnerabilities, simulate exploits, and act as autonomous auditors.  
- **GPTScan**  
- **SmartGPT Auditor**  
- **CodeChain LLM Auditor**  
- **ChatGPT/Claude-based Auditors**  
- **Verifier-Guided LLM Pipelines**  

👉 **Top-3 to benchmark:** GPTScan, SmartGPT Auditor, CodeChain LLM Auditor  

---

### 7. Hybrid Frameworks  
Combine multiple methods for balanced coverage.  
- **MythX**  
- **ConFuzzius**  
- **NeuCheck**  
- **HoneyBadger**  
- **Echidna+Manticore Pipelines**  

👉 **Top-3 to benchmark:** MythX, ConFuzzius, NeuCheck  

---

## 📊 Evaluation Dimensions  

Tools will be compared across five dimensions:  

| Dimension              | Description |
|------------------------|-------------|
| **Vulnerability Coverage** | Types of flaws detected (reentrancy, access control, integer overflow, gas DoS, etc.). |
| **Detection Accuracy** | Precision, recall, false positives, false negatives. |
| **Scalability** | Ability to handle large or multi-contract systems. |
| **Usability** | CLI/GUI support, IDE integration, documentation. |
| **Maintenance** | Open-source activity, industry adoption, updates. |

---

## 🚀 Project Plan  

1. **Survey Phase** – Collect info on top 5 tools per category.  
2. **Benchmark Phase** – Run top 3 tools per category on standardized vulnerable contract datasets.  
3. **Comparison Phase** – Cross-compare results across categories.  
4. **Insight Phase** – Identify trade-offs, strengths, weaknesses, and research gaps.  
5. **Paper Publication** – Submit review paper (target: IEEE Access or similar).  

---

## 📌 Research Gaps to Explore  

- Lack of **standardized, updated benchmarks**.  
- **Scalability bottlenecks** in symbolic execution & formal verification.  
- **High false positives** in static analysis vs **false negatives** in fuzzing/symbolic tools.  
- **Reproducibility challenges** (custom datasets).  
- **LLM risks**: hallucinations, nondeterminism, evaluation difficulties.  
- **Integration gap**: few tools are CI/CD-ready.  

---

## 🛠 Orchestrator Workflow  

We provide an orchestrator that runs all tools and collects results in a consistent structure.  

### Config  
- **`orchestrator.config.yml`** – central settings (datasets, timeouts, contracts glob, Top-3 mode).  
- **`tools.manifest.json`** – auto-generated list of canonical tool locations.  

### Running  

```bash
# optional: switch to Top-3-only mode
sed -i 's/top3_only: False/top3_only: True/' orchestrator.config.yml

# run all tools
python3 run_all.py
```

- Each tool must implement its logic in `tools/<Category>/<Tool>/run_tool.sh`.  
- The orchestrator sets env vars:  
  - `DATASET_DIR`, `RESULTS_DIR`, `CONTRACTS_GLOB`, `TIMEOUT_SECONDS`  
- Required outputs per run:  
  - `report.json` (see schema in `docs/RESULTS_SCHEMA.md`)  
  - `summary.md`  
  - `raw.log`  

### Results  

- Written to `results/<Category>/<Tool>/run-<timestamp>/`.  
- Aggregates:  
  - `results/summary_index.csv` – overview per tool.  
  - `results/aggregation.json` – machine-readable metadata.  

---

## 📂 Repository Layout  

```
SmartContractAuditToolsBenchmark/
│
├── tools/                     # Tools organized by category
│   ├── StaticAnalysis/
│   │   ├── Slither/
│   │   └── ...
│   ├── SymbolicExecution/
│   └── ...
│
├── data/                      # Vulnerable contract datasets
├── results/                   # Benchmark results
├── docs/
│   └── RESULTS_SCHEMA.md      # JSON schema for report.json
│
├── run_all.py                 # Main orchestrator
├── orchestrator.config.yml     # Config file
├── tools.manifest.json         # Canonical tool manifest
├── README.md                   # This file
└── .gitignore
```

---

## 📜 License  

Released under the **MIT License** – free for academic and community use.  
