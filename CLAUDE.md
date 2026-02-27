# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Context

Optimization-based course allocation system developed as part of the S2 DevOps curriculum at UCA. Uses OPL/CPLEX for constraint-based optimization and Python for data processing and analysis.

## Branch Strategy

```
main  ←  dev  ←  input | output | solver | documentation
```

- Group branches (`input`, `output`, `solver`, `documentation`) are where each team works.
- PRs go group branch → `dev`, then `dev` → `main` when stable.
- `main` and `dev` are protected: PR + 1 review + CI required. Never push directly.

## Development Commands

```bash
# Install dev dependencies
pip install -r requirements-dev.txt

# Run tests with coverage
pytest

# Check formatting
black --check scripts/ tests/

# Check style
flake8 scripts/ tests/

# Auto-fix formatting
black scripts/ tests/

# Build docs site locally
pip install mkdocs mkdocs-material
mkdocs serve
```

## CI/CD

Two workflows in `.github/workflows/`:

| Workflow | Trigger | Jobs |
|----------|---------|------|
| `ci.yml` | push/PR to `main` or `dev` | `lint` and `test` run in parallel; `validate-opl` runs independently |
| `deploy-docs.yml` | push to `main` when `docs/`, `mkdocs.yml`, or `README.md` changes | builds MkDocs site → deploys to GitHub Pages |

CI required checks: **Lint & format check**, **Tests**.

## Tool Configuration

- `pyproject.toml` — black (line-length 88, py312) and pytest (`testpaths = ["tests"]`, coverage on `scripts/`)
- `.flake8` — max-line-length 88, aligned with black
- `mkdocs.yml` — Material theme, `docs/` as source
