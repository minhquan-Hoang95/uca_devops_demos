# uca_devops_demos — Course Allocation Project

![CI](https://github.com/minhquan-Hoang95/uca_devops_demos/actions/workflows/ci.yml/badge.svg)

Optimization-based course allocation system developed as part of the S2 DevOps curriculum at UCA.

## Project Goal

Assign courses to instructors and rooms while satisfying scheduling constraints, using OPL/CPLEX for optimization and Python for data processing and analysis.

## Repository Structure

```
.
├── docs/           # Documentation, notes, LaTeX reports
├── opl/            # CPLEX OPL models (.mod) and data files (.dat)
├── data/
│   ├── raw/        # Original input data (CSV, JSON)
│   └── processed/  # Cleaned / transformed data
├── scripts/        # Python scripts (preprocessing, visualization, analysis)
├── notebooks/      # Jupyter notebooks for exploration and prototyping
├── results/        # Solver outputs, plots, logs
├── tests/          # Unit tests and example runs
├── examples/       # Sample datasets or minimal model runs
├── references/     # Papers, specifications, external docs
└── .github/        # Issue templates and CI workflows
```

## Getting Started

1. **OPL models** — open `.mod` files in IBM ILOG CPLEX Optimization Studio or run via `oplrun`.
2. **Python scripts** — install dependencies (`pip install -r requirements.txt` once added) then run scripts from `scripts/`.
3. **Notebooks** — launch with `jupyter notebook` from the repo root.

## Development Workflow

Work is tracked via GitHub Issues. See [CONTRIBUTING.md](CONTRIBUTING.md) for branch naming, commit conventions, and PR guidelines.
