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
# Install dev dependencies and activate pre-commit hooks
pip install -r requirements-dev.txt
pre-commit install

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
| `scorecard.yml` | push to `main` + weekly (Mon 06:00 UTC) | OSSF Scorecard — publishes SARIF to Security → Code scanning |
| `deploy-docs.yml` | push to `main` when `docs/`, `mkdocs.yml`, or `README.md` changes | MkDocs build → GitHub Pages |

CI required checks for `main`/`dev`: **Lint & format check**, **Tests**.

All `uses:` in workflows are pinned to full commit SHAs (supply chain hardening).

## Security

- **`bandit`** — Python SAST, runs on every CI build (`bandit -r scripts/ -ll`)
- **`pip-audit`** — CVE scan on installed packages, runs on every CI build
- **CodeQL** — deep SAST via GitHub's analysis engine, results in Security → Code scanning
- **Dependabot** — weekly PRs for outdated `pip` and `github-actions` dependencies, targeting `dev`
- **OSSF Scorecard** — measures ~18 security practices; results in Security → Code scanning (`ossf-scorecard` category) and on [securityscorecards.dev](https://securityscorecards.dev)

## Docker

```bash
# Build
docker build -t uca-devops .

# Run
docker run --rm uca-devops
```

`Dockerfile` uses `python:3.12-slim`, installs deps in a cached layer, then copies `scripts/` and `data/`.

## Pre-commit Hooks

Run `pre-commit install` once after cloning. Hooks run automatically on every `git commit`:

| Hook | What it catches |
|------|----------------|
| `trailing-whitespace`, `end-of-file-fixer` | Whitespace issues |
| `check-yaml`, `check-json` | Syntax errors in config files |
| `check-merge-conflict` | Leftover conflict markers |
| `check-added-large-files` | Files > 1 MB |
| `detect-private-key` | Accidentally committed secrets |
| `black` | Auto-formats Python code |
| `flake8` | Style violations |
| `bandit` | Python security issues |

Run all hooks manually: `pre-commit run --all-files`

## Tool Configuration

- `pyproject.toml` — black (line-length 88, py312) and pytest (`testpaths = ["tests"]`, coverage on `scripts/`)
- `.flake8` — max-line-length 88, aligned with black
- `mkdocs.yml` — Material theme, `docs/` as source
- `.github/dependabot.yml` — weekly updates for pip + github-actions, PRs target `dev`
- `.pre-commit-config.yaml` — trailing-whitespace, end-of-file, yaml/json check, large files, detect-private-key, black, flake8, bandit

## Reference

- `LEARNING.md` — full annotated guide explaining every tool and decision in this repo; use it to reproduce this setup on any new project.
