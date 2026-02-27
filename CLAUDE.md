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

| Workflow | Trigger | Jobs |
|----------|---------|------|
| `ci.yml` | push/PR to `main` or `dev` | `lint`, `test`, `security` in parallel; `validate-opl` independently |
| `codeql.yml` | push/PR to `main`/`dev` + weekly (Mon 06:00 UTC) | CodeQL SAST on Python (`security-and-quality` suite) |
| `deploy-docs.yml` | push to `main` when `docs/`, `mkdocs.yml`, or `README.md` changes | MkDocs build → GitHub Pages |

CI required checks for `main`/`dev`: **Lint & format check**, **Tests**.

All `uses:` in workflows are pinned to full commit SHAs (supply chain hardening).

## Security

- **`bandit`** — Python SAST, runs on every CI build (`bandit -r scripts/ -ll`)
- **`pip-audit`** — CVE scan on installed packages, runs on every CI build
- **CodeQL** — deep SAST via GitHub's analysis engine, results in Security → Code scanning
- **Dependabot** — weekly PRs for outdated `pip` and `github-actions` dependencies, targeting `dev`

## Docker

```bash
# Build
docker build -t uca-devops .

# Run
docker run --rm uca-devops
```

`Dockerfile` uses `python:3.12-slim`, installs deps in a cached layer, then copies `scripts/` and `data/`.

## Tool Configuration

- `pyproject.toml` — black (line-length 88, py312) and pytest (`testpaths = ["tests"]`, coverage on `scripts/`)
- `.flake8` — max-line-length 88, aligned with black
- `mkdocs.yml` — Material theme, `docs/` as source
- `.github/dependabot.yml` — weekly updates for pip + github-actions, PRs target `dev`
