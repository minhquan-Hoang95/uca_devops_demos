# DevSecOps — Complete Learning Guide

A standalone, project-agnostic guide you can follow to set up any repository
professionally. Each section explains the *concept*, the *why*, the *how*, what
it *looks like on the job*, and includes a *self-check* so you can verify you
actually understood it — not just copied it.

---

## How to use this guide

1. **Read the concept** — understand what problem it solves before touching any file
2. **Follow the steps** — apply it to a real repo, not a toy example
3. **Answer the self-check** — if you can't answer without looking, re-read
4. **Adapt it** — every section has an adaptation table for different stacks

Work through sections in order the first time. After that, use the
**Master Checklist** (Section 17) as your starting point for any new project.

---

## Table of Contents

1. [The DevSecOps Mental Model](#1-the-devsecops-mental-model)
2. [Repository Structure](#2-repository-structure)
3. [Documentation Files](#3-documentation-files)
4. [Branch Strategy](#4-branch-strategy)
5. [Python Tooling](#5-python-tooling)
6. [Pre-commit Hooks](#6-pre-commit-hooks)
7. [GitHub Actions — Core Concepts](#7-github-actions--core-concepts)
8. [CI Pipeline](#8-ci-pipeline)
9. [Security Workflows — CodeQL & OSSF Scorecard](#9-security-workflows--codeql--ossf-scorecard)
10. [Automated Dependency Updates — Dependabot](#10-automated-dependency-updates--dependabot)
11. [Supply Chain Security — SHA Pinning](#11-supply-chain-security--sha-pinning)
12. [Branch Protection Rules](#12-branch-protection-rules)
13. [Docker](#13-docker)
14. [Documentation Site — MkDocs](#14-documentation-site--mkdocs)
15. [GitHub Issue Templates](#15-github-issue-templates)
16. [Day-to-Day Developer Workflow](#16-day-to-day-developer-workflow)
17. [Master Checklist — Any New Project](#17-master-checklist--any-new-project)
18. [How to Talk About This in an Interview](#18-how-to-talk-about-this-in-an-interview)
19. [Common Mistakes to Avoid](#19-common-mistakes-to-avoid)
20. [Concepts Glossary](#20-concepts-glossary)

---

## 1. The DevSecOps Mental Model

### The concept

**DevOps** = automate the path from code to production (Dev + Ops).
**DevSecOps** = embed security at every step, not as an afterthought (Dev + Sec + Ops).

The core idea: **catch problems as early and as cheaply as possible.**

```
Cost of fixing a bug:

  pre-commit hook    →  $0      (seconds, only you affected)
  CI failure         →  $low    (minutes, only your branch affected)
  code review        →  $medium (hours, reviewer's time spent)
  production         →  $high   (users affected, reputation at stake)
```

### The three feedback loops

```
Developer loop  (seconds)  : write → pre-commit → commit
CI loop         (minutes)  : push  → lint → test → security scan → merge
CD loop         (min/hours): merge → build → deploy → monitor
```

### Defence in depth — security layers

Each layer catches what the previous one missed:

```
┌──────────────────────────────────────────────┐
│  Supply chain (SHA-pinned actions)           │ prevents hijacked actions
│  ┌────────────────────────────────────────┐  │
│  │  Dependabot (weekly)                   │  │ keeps deps patched
│  │  ┌──────────────────────────────────┐  │  │
│  │  │  OSSF Scorecard (weekly)         │  │  │ measures posture
│  │  │  ┌────────────────────────────┐  │  │  │
│  │  │  │  CodeQL (every PR)         │  │  │  │ deep SAST
│  │  │  │  ┌──────────────────────┐  │  │  │  │
│  │  │  │  │  CI: bandit+pip-audit│  │  │  │  │ fast SAST + CVE scan
│  │  │  │  │  ┌────────────────┐  │  │  │  │  │
│  │  │  │  │  │  pre-commit    │  │  │  │  │  │ instant, local
│  │  │  │  │  └────────────────┘  │  │  │  │  │
│  │  │  │  └──────────────────────┘  │  │  │  │
│  │  │  └────────────────────────────┘  │  │  │
│  │  └──────────────────────────────────┘  │  │
│  └────────────────────────────────────────┘  │
└──────────────────────────────────────────────┘
```

### On the job

In a job interview or on a team, you'll hear: *"How do you handle security in your
pipeline?"* The answer is this diagram — each layer, what it catches, and why you
need all of them.

### Self-check

- What is the difference between DevOps and DevSecOps?
- Why is a pre-commit failure cheaper than a production bug?
- Name three layers of the defence-in-depth model and what each catches.

---

## 2. Repository Structure

### The concept

A consistent structure lets any contributor — human or AI — navigate the codebase
without asking. It also signals professionalism to employers reviewing your work.

### Universal structure

```
project-root/
├── src/                    # Main application source code
│   └── <package_name>/
├── scripts/                # Standalone runnable scripts
├── tests/                  # All test files (mirrors src/ structure)
├── docs/                   # Documentation source (markdown, LaTeX)
├── data/
│   ├── raw/                # Original input data — never modify
│   └── processed/          # Cleaned/transformed data
├── notebooks/              # Jupyter notebooks — exploration only, not production
├── results/                # Outputs: plots, logs, reports
├── examples/               # Minimal runnable examples for new contributors
├── references/             # Papers, specs, external documentation
├── .github/
│   ├── workflows/          # All GitHub Actions YAML files
│   └── ISSUE_TEMPLATE/     # Issue form templates
├── .pre-commit-config.yaml
├── pyproject.toml          # Central tool configuration
├── .flake8                 # flake8 config (can't live in pyproject.toml)
├── Dockerfile
├── mkdocs.yml              # Docs site config
├── requirements.txt        # Runtime dependencies
├── requirements-dev.txt    # Dev/test/lint dependencies
├── README.md
├── CONTRIBUTING.md
└── CLAUDE.md               # Context file for AI assistants
```

### How to create it

```bash
# Replace the folder names with what your project needs
mkdir -p src/<package> scripts tests docs data/raw data/processed \
         notebooks results examples references \
         .github/workflows .github/ISSUE_TEMPLATE

# Git doesn't track empty directories — placeholders solve this
find . -type d -empty -not -path './.git/*' -exec touch {}/.gitkeep \;

git add .
git commit -m "Initialize repository structure"
```

### Adapting for other stacks

| Stack | Source code | Tests |
|-------|-------------|-------|
| Python | `src/<package>/` | `tests/` |
| Node.js | `src/` | `__tests__/` or `test/` |
| Go | `cmd/` + `internal/` | `*_test.go` alongside source |
| Java/Maven | `src/main/java/` | `src/test/java/` |
| Rust | `src/` | `tests/` (integration) |

### Self-check

- Why do we separate `raw/` and `processed/` data?
- Why do we add `.gitkeep` files?
- What is the difference between `src/` and `scripts/`?

---

## 3. Documentation Files

### The concept

Three files every professional repository needs:

| File | Audience | Purpose |
|------|----------|---------|
| `README.md` | Anyone landing on the repo | What it is, how to get started |
| `CONTRIBUTING.md` | Contributors | How to work here (branches, commits, PRs) |
| `CLAUDE.md` | AI assistants (Claude Code) | Project context for productive AI sessions |

### README.md — what to include

```markdown
# Project Name

One-sentence description.

## Project Goal
What problem does this solve?

## Repository Structure
Folder tree with one-line descriptions.

## Getting Started
The exact commands to go from zero to running.

## Development Workflow
Pointer to CONTRIBUTING.md.
```

### CONTRIBUTING.md — what to include

```markdown
# Contributing

## Branch Strategy
Diagram + table (who works where, what merges where).

## Branch Protection Rules
Table showing what is enforced on each branch.

## Commits
Format and examples.

## Pull Requests
Rules: focused scope, describe why, review required.

## Issues
All work starts with an issue.
```

### CLAUDE.md — what to include

```markdown
# CLAUDE.md
This file provides guidance to Claude Code when working in this repository.

## Project Context
Stack, purpose, domain.

## Branch Strategy
Diagram + rules.

## Development Commands
Every command a developer runs day-to-day.

## CI/CD
Table: workflow → trigger → jobs.

## Security
List of tools and where their results appear.

## Docker
Build and run commands.

## Tool Configuration
Where each config lives and its key settings.
```

**Update CLAUDE.md every time you add a workflow, tool, or change a command.**

### Self-check

- What is the difference between README.md and CONTRIBUTING.md?
- Who reads CLAUDE.md and when?
- What should you NOT put in README.md (hint: implementation details)?

---

## 4. Branch Strategy

### The concept

Without a branch strategy, teams break each other's work by pushing to `main`.
A strategy isolates risk and enables parallel work.

**The rule:** the more people and the higher the stakes, the more protection
layers between feature work and `main`.

### Choose your model based on team size

**Solo project:**
```
main  ←  dev  ←  feature/xxx | fix/xxx | docs/xxx
```

**Small team (2–6 people) or grouped work:**
```
main  ←  dev  ←  team-a | team-b | team-c
```

**Startup / staging environment:**
```
main  ←  staging  ←  dev  ←  feature/xxx
```

**Enterprise (GitFlow):**
```
main  ←  release/x.y  ←  develop  ←  feature/xxx | hotfix/xxx
```

### How to create branches

```bash
# From main, create and push each branch
for branch in dev team-a team-b team-c; do
  git checkout -b $branch
  git push -u origin $branch
  git checkout main
done
```

### Syncing main → all branches

Run this after every commit to `main` to keep all branches up to date:

```bash
for branch in dev team-a team-b team-c; do
  git checkout $branch
  git merge main --no-edit
  git push origin $branch
done
git checkout main
```

> `--no-edit` skips the commit message prompt for auto-resolved merges.
> Remove it if you want to write a custom merge message.

### Naming conventions for short-lived branches

```
feature/<what-you-are-building>     e.g. feature/user-authentication
fix/<what-you-are-fixing>           e.g. fix/login-redirect-loop
docs/<what-you-are-documenting>     e.g. docs/api-reference
```

### Self-check

- Why do we never commit directly to `main`?
- What is `dev` for?
- In a 4-team project, where does each team's PR go?
- Why do you sync `main` → other branches (not the other way)?

---

## 5. Python Tooling

### The concept

Separate runtime from dev dependencies. Use a central config file. Every tool
that touches code style or quality should be configured consistently.

### `requirements-dev.txt`

```
pytest>=8.0          # test runner
pytest-cov>=5.0      # coverage reports
black>=24.0          # opinionated auto-formatter (non-negotiable style)
flake8>=7.0          # style linter (catches what black doesn't format)
bandit>=1.8          # security linter — finds common Python vulnerabilities
pip-audit>=2.7       # CVE scanner for installed packages
pre-commit>=4.0      # hook manager
```

Install: `pip install -r requirements-dev.txt`

### `pyproject.toml` — explained

```toml
[tool.black]
line-length = 88          # black's default — always use this, don't fight it
target-version = ["py312"] # replace with your Python version

[tool.pytest.ini_options]
testpaths = ["tests"]     # where pytest looks — avoids accidental test discovery
addopts = "--cov=src --cov-report=term-missing --cov-report=xml"
# --cov=src              : measure coverage on your source package
# --cov-report=term-missing : print uncovered lines in terminal
# --cov-report=xml       : write coverage.xml (used by CI artifact upload)
```

### `.flake8` — must be separate (flake8 ignores pyproject.toml)

```ini
[flake8]
max-line-length = 88    # MUST match black's line-length
extend-ignore = E203, W503  # black produces these — ignore them
exclude = .git, __pycache__, .venv, build, dist
```

### Running tools manually

```bash
# Testing
pytest                             # run all tests
pytest tests/test_foo.py           # run one file
pytest tests/test_foo.py::test_bar # run one specific test
pytest -k "keyword"                # run tests matching keyword
pytest --cov=src                   # with coverage

# Formatting
black src/ tests/                  # auto-format (modifies files)
black --check src/ tests/          # check only (CI mode — no changes)
black --diff src/ tests/           # show what would change

# Linting
flake8 src/ tests/                 # style violations

# Security
bandit -r src/ -ll                 # -r: recursive, -ll: medium+ severity only
bandit -r src/ -f json             # JSON output for automation
pip-audit                          # scan for CVEs in installed packages
pip-audit --fix                    # auto-upgrade vulnerable packages
```

### Adapting for other stacks

| Stack | Formatter | Linter | Test runner | Security |
|-------|-----------|--------|-------------|---------|
| JavaScript | `prettier` | `eslint` | `jest` or `vitest` | `npm audit` |
| TypeScript | `prettier` | `eslint` + `tsc` | `jest` or `vitest` | `npm audit` |
| Go | `gofmt` | `golangci-lint` | `go test` | `gosec` |
| Rust | `rustfmt` | `clippy` | `cargo test` | `cargo audit` |
| Java | `google-java-format` | `checkstyle` | `JUnit` | `dependency-check` |

### Self-check

- What is the difference between `requirements.txt` and `requirements-dev.txt`?
- Why does `.flake8` exist as a separate file instead of in `pyproject.toml`?
- What does `--cov-report=xml` produce and who uses it?
- What does `bandit -ll` mean?

---

## 6. Pre-commit Hooks

### The concept

A pre-commit hook is a script that runs **automatically before `git commit`
completes**. If it fails, the commit is aborted. The developer fixes the issue
immediately — before it wastes anyone else's time.

```
Without hooks:  commit → push → CI waits → CI fails → fix → push again  (~5 min wasted)
With hooks:     commit → hook fails → fix right now → commit succeeds     (~10 sec)
```

### One-time setup (per developer, per clone)

```bash
pip install pre-commit
pre-commit install        # registers the hook in .git/hooks/pre-commit
```

### `.pre-commit-config.yaml` — full annotated template

```yaml
repos:
  # ── Universal file hygiene ────────────────────────────────────────────
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v5.0.0                   # always pin to a tag
    hooks:
      - id: trailing-whitespace   # removes trailing spaces from all files
      - id: end-of-file-fixer     # ensures every file ends with a newline
      - id: check-yaml            # validates YAML syntax (catches broken CI files)
      - id: check-json            # validates JSON syntax
      - id: check-toml            # validates TOML syntax (pyproject.toml, etc.)
      - id: check-merge-conflict  # blocks files containing <<<<<<< markers
      - id: check-added-large-files
        args: ["--maxkb=1024"]    # blocks files over 1 MB (models, datasets, etc.)
      - id: detect-private-key    # blocks RSA/SSH/PGP private keys

  # ── Python formatter ──────────────────────────────────────────────────
  - repo: https://github.com/psf/black
    rev: 25.1.0
    hooks:
      - id: black
        language_version: python3.12   # match your project's Python version

  # ── Python style linter ───────────────────────────────────────────────
  - repo: https://github.com/PyCQA/flake8
    rev: 7.1.2
    hooks:
      - id: flake8

  # ── Python security linter ────────────────────────────────────────────
  - repo: https://github.com/PyCQA/bandit
    rev: 1.8.3
    hooks:
      - id: bandit
        args: ["-r", "src/", "-ll"]
        pass_filenames: false     # scan the directory, not individual files
```

### Useful commands

```bash
pre-commit run --all-files          # run all hooks on everything (first-time check)
pre-commit run black --all-files    # run only one hook
pre-commit autoupdate               # update all hook revisions to latest tags
pre-commit uninstall                # remove the hook (rarely needed)
git commit --no-verify              # bypass hooks — emergency use only
```

### Adding hooks for other stacks

| Stack | Hook |
|-------|------|
| JavaScript/TypeScript | `prettier`, `eslint` |
| Go | `gofmt`, `golangci-lint-mirror` |
| Rust | `rustfmt` |
| Shell scripts | `shellcheck` |
| Dockerfiles | `hadolint` |
| Secrets (extra layer) | `gitleaks` or `detect-secrets` |
| Markdown | `markdownlint` |

### Self-check

- What happens when a pre-commit hook fails?
- Why do you run `pre-commit install` and not just `pip install pre-commit`?
- What does `pass_filenames: false` do for bandit?
- When would you use `git commit --no-verify`? What is the risk?

---

## 7. GitHub Actions — Core Concepts

### The concept

GitHub Actions is a CI/CD platform. You define automated workflows in YAML files
that run on GitHub's servers in response to events (push, PR, schedule, etc.).

### Vocabulary

| Term | Definition |
|------|------------|
| **Workflow** | A YAML file in `.github/workflows/`. Defines the automation. |
| **Event** | What triggers the workflow (push, pull_request, schedule, etc.) |
| **Job** | A group of steps that run on one machine. Jobs run **in parallel by default**. |
| **Step** | A single command or action within a job. Steps run **sequentially**. |
| **Action** | A reusable step packaged by someone (`uses: actions/checkout@...`) |
| **Runner** | The VM that executes the job (`ubuntu-latest` = Ubuntu 24.04) |
| **Artifact** | A file produced by a job, stored for download or use by other jobs |
| **Secret** | An encrypted value stored in GitHub, accessed via `${{ secrets.NAME }}` |

### Anatomy of a workflow file

```yaml
name: My Workflow           # displayed in the Actions tab

on:                         # what triggers this workflow
  push:
    branches: [main, dev]
  pull_request:
    branches: [main, dev]
  schedule:
    - cron: "0 6 * * 1"    # every Monday at 06:00 UTC
  workflow_dispatch:         # allows manual trigger from the UI

jobs:
  my-job:                   # job ID (used in 'needs:')
    name: My Job            # displayed in the UI
    runs-on: ubuntu-latest  # runner type

    # Optional: only run if another job passed
    needs: other-job

    # Optional: minimal permissions (security best practice)
    permissions:
      contents: read

    steps:
      - name: Step name
        uses: actions/checkout@<SHA>  # use a pre-built action

      - name: Run a command
        run: echo "Hello"

      - name: Multi-line command
        run: |
          pip install -r requirements.txt
          pytest
```

### Key triggers — reference

```yaml
on:
  push:
    branches: [main]        # only on pushes to main
    paths: ["src/**"]       # only when src/ changes
  pull_request:
    types: [opened, synchronize, reopened]
  schedule:
    - cron: "0 6 * * 1"    # Mon 06:00 UTC
    # cron format: minute hour day-of-month month day-of-week
    # "0 6 * * 1" = minute 0, hour 6, any day, any month, Monday (1)
  workflow_dispatch:
    inputs:                 # optional: ask for input when manually triggered
      environment:
        description: "Target environment"
        required: true
```

### Job parallelism

```yaml
jobs:
  lint:           # starts immediately
    ...
  test:           # also starts immediately (parallel with lint)
    ...
  deploy:
    needs: [lint, test]   # waits for BOTH to succeed
    ...
```

### Self-check

- What is the difference between a job and a step?
- Why do jobs run in parallel by default?
- What does `needs:` do?
- What is `workflow_dispatch` for?
- How do you make a workflow only run when files in `src/` change?

---

## 8. CI Pipeline

### The concept

CI (Continuous Integration) automatically validates every code change before
it is merged. A well-designed CI pipeline gives developers fast, clear feedback.

### The standard jobs

| Job | What it checks | When it fails |
|-----|----------------|---------------|
| **lint** | Code style and formatting | Someone forgot to run black/flake8 |
| **test** | Correctness + coverage | A test broke or coverage dropped |
| **security** | Known vulnerabilities | bandit finds an issue or pip-audit finds a CVE |
| **build** (if compiled) | Build succeeds | Syntax/compile error |

### Full annotated `ci.yml`

```yaml
name: CI

on:
  push:
    branches: [main, dev]     # adapt to your branch strategy
  pull_request:
    branches: [main, dev]
  workflow_dispatch:

jobs:
  # ── Lint ──────────────────────────────────────────────────────────────
  lint:
    name: Lint & format check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@<SHA> # vX

      - uses: actions/setup-python@<SHA> # vX
        with:
          python-version: "3.12"    # match your project
          cache: pip                # reuse pip downloads between runs (~30s saved)

      - run: pip install -r requirements-dev.txt

      - run: black --check src/ tests/
        # --check: exits with error if any file would be reformatted
      - run: flake8 src/ tests/

  # ── Test ──────────────────────────────────────────────────────────────
  test:
    name: Tests
    runs-on: ubuntu-latest
    # No 'needs: lint' → runs in PARALLEL with lint for faster feedback
    steps:
      - uses: actions/checkout@<SHA> # vX

      - uses: actions/setup-python@<SHA> # vX
        with:
          python-version: "3.12"
          cache: pip

      - name: Install dependencies
        run: |
          pip install -r requirements-dev.txt
          [ -f requirements.txt ] && pip install -r requirements.txt || true
          # [ -f ... ]: only install if the file exists

      - run: pytest

      - uses: actions/upload-artifact@<SHA> # vX
        if: always()              # upload EVEN if tests fail — you need it most then
        with:
          name: coverage-report
          path: coverage.xml
          retention-days: 14      # keep for 2 weeks

  # ── Security ──────────────────────────────────────────────────────────
  security:
    name: Security scan
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@<SHA> # vX

      - uses: actions/setup-python@<SHA> # vX
        with:
          python-version: "3.12"
          cache: pip

      - name: Install dependencies
        run: |
          pip install -r requirements-dev.txt
          [ -f requirements.txt ] && pip install -r requirements.txt || true

      - name: bandit — Python SAST
        run: bandit -r src/ -ll
        # Catches: hardcoded passwords, SQL injection, unsafe deserialization,
        #          use of weak hash functions, subprocess injection, etc.

      - name: pip-audit — CVE scan
        run: pip-audit
        # Checks every installed package against OSV, PyPI Advisory DB, and NVD
```

### Adapting for other stacks

**Node.js:**
```yaml
- uses: actions/setup-node@<SHA>
  with: { node-version: "20", cache: "npm" }
- run: npm ci             # clean install (faster and more reliable than npm install)
- run: npm run lint
- run: npm test -- --coverage
```

**Go:**
```yaml
- uses: actions/setup-go@<SHA>
  with: { go-version: "1.22", cache: true }
- run: go vet ./...
- run: go test ./... -coverprofile=coverage.out -race
  # -race: detects race conditions — always run this
```

**Java/Maven:**
```yaml
- uses: actions/setup-java@<SHA>
  with: { java-version: "21", distribution: "temurin", cache: "maven" }
- run: mvn verify -B    # -B: batch mode (no interactive prompts)
```

### Design principles

| Principle | Implementation |
|-----------|----------------|
| Fail fast | Put lint before test in dependency chain (or parallel — both valid) |
| Cache aggressively | `cache: pip` / `cache: npm` / Maven cache action |
| Upload on failure | `if: always()` on artifact steps |
| Keep jobs focused | One job = one concern (lint ≠ test ≠ security) |
| Parallel by default | Only add `needs:` when a job truly depends on another's output |

### Self-check

- Why do `lint` and `test` run in parallel rather than sequentially?
- What does `if: always()` do on the artifact upload step?
- What is `cache: pip` doing and why does it matter?
- What does `bandit -ll` mean? What does it miss?
- What is the difference between bandit and pip-audit?

---

## 9. Security Workflows — CodeQL & OSSF Scorecard

### CodeQL

#### The concept

bandit catches common patterns. CodeQL is deeper: it builds a semantic model of
your entire codebase and runs queries that can trace data flow across files.
It finds vulnerabilities that no regex-based tool can.

Example: CodeQL can detect that user input from `request.GET["name"]` flows
into `subprocess.call()` three files later — a command injection.

#### `codeql.yml`

```yaml
name: CodeQL

on:
  push:
    branches: [main, dev]
  pull_request:
    branches: [main, dev]
  schedule:
    - cron: "0 6 * * 1"   # weekly scan even without code changes
  workflow_dispatch:

jobs:
  analyze:
    name: Analyze (${{ matrix.language }})
    runs-on: ubuntu-latest
    permissions:
      security-events: write  # required: uploads results to Security tab
      actions: read
      contents: read

    strategy:
      fail-fast: false
      matrix:
        language: [python]
        # For multi-language repos: [python, javascript, go]
        # Supported: python, javascript, typescript, go, java, cpp, csharp, ruby, swift

    steps:
      - uses: actions/checkout@<SHA> # vX

      - name: Initialize CodeQL
        uses: github/codeql-action/init@<SHA> # vX
        with:
          languages: ${{ matrix.language }}
          queries: security-and-quality
          # Options:
          # security-and-quality   → good balance (recommended)
          # security-extended      → more checks, more false positives
          # default                → minimal checks

      - name: Autobuild
        uses: github/codeql-action/autobuild@<SHA> # vX
        # For compiled languages (Java, C++): attempts to build your project
        # For Python/JS: does nothing (no compilation needed)

      - name: Perform Analysis
        uses: github/codeql-action/analyze@<SHA> # vX
        with:
          category: "/language:${{ matrix.language }}"
```

Results appear in: **GitHub → Security → Code scanning**

Each alert shows the vulnerable line, the data flow path, and a fix suggestion.

---

### OSSF Scorecard

#### The concept

Scorecard measures your repository against ~18 security best practices and gives
a score from 0 to 10. It's used by open source projects and employers to
evaluate security maturity.

#### What it checks (the ones that matter most)

| Check | What it looks for | How to pass |
|-------|-------------------|-------------|
| `Branch-Protection` | Protected branches with required reviews | Done in Section 12 |
| `CI-Tests` | Tests running on every PR | Done in Section 8 |
| `Code-Review` | PRs reviewed before merging | Branch protection rules |
| `Pinned-Dependencies` | Actions pinned to SHAs | Done in Section 11 |
| `Dependency-Update-Tool` | Dependabot or Renovate present | Done in Section 10 |
| `SAST` | Static analysis running (bandit, CodeQL) | Done in Sections 8–9 |
| `Token-Permissions` | Workflows use minimal permissions | `permissions: read-all` + per-job overrides |
| `Vulnerabilities` | No open CVEs in deps | pip-audit + Dependabot |

#### `scorecard.yml`

```yaml
name: OSSF Scorecard

on:
  push:
    branches: [main]
  schedule:
    - cron: "0 6 * * 1"
  workflow_dispatch:

permissions: read-all     # start with minimal, add per-job as needed

jobs:
  analyze:
    name: Scorecard analysis
    runs-on: ubuntu-latest
    permissions:
      security-events: write
      id-token: write         # needed for keyless signing (publish_results)
      contents: read
      actions: read

    steps:
      - uses: actions/checkout@<SHA> # vX
        with:
          persist-credentials: false  # don't expose credentials to subprocesses

      - name: Run OSSF Scorecard
        uses: ossf/scorecard-action@<SHA> # vX
        with:
          results_file: scorecard-results.sarif
          results_format: sarif
          publish_results: true   # publishes to https://securityscorecards.dev

      - name: Upload results
        uses: github/codeql-action/upload-sarif@<SHA> # vX
        with:
          sarif_file: scorecard-results.sarif
          category: ossf-scorecard
```

> **SARIF** = Static Analysis Results Interchange Format. A standard JSON format
> that GitHub understands natively. Any security tool that outputs SARIF can feed
> results into Security → Code scanning.

### Self-check

- What is the difference between bandit and CodeQL?
- Give an example of a vulnerability CodeQL can find that bandit cannot.
- What does `permissions: read-all` do and why is it a security best practice?
- Name 3 things OSSF Scorecard checks.
- What is SARIF?

---

## 10. Automated Dependency Updates — Dependabot

### The concept

Outdated dependencies are the most common source of known vulnerabilities.
Dependabot opens PRs automatically when a newer version is available, so your
repo stays patched without manual work.

### `.github/dependabot.yml`

```yaml
version: 2
updates:
  # ── Your language's packages ──────────────────────────────────────────
  - package-ecosystem: pip          # replace with your stack (see table below)
    directory: "/"                  # where your package manifest lives
    schedule:
      interval: weekly
      day: monday                   # consistent with other weekly scans
    open-pull-requests-limit: 5     # don't flood your board with PRs
    target-branch: dev              # PRs go to dev, not main
    labels:
      - dependencies                # label for easy filtering

  # ── GitHub Actions ────────────────────────────────────────────────────
  # Always add this — it keeps your SHA pins up to date automatically
  - package-ecosystem: github-actions
    directory: "/"
    schedule:
      interval: weekly
      day: monday
    open-pull-requests-limit: 5
    target-branch: dev
    labels:
      - dependencies
      - github-actions
```

### `package-ecosystem` values for every stack

| Stack | Value |
|-------|-------|
| Python (pip) | `pip` |
| Node.js (npm) | `npm` |
| Node.js (yarn) | `yarn` |
| Node.js (pnpm) | `npm` (pnpm not natively supported) |
| Go | `gomod` |
| Rust | `cargo` |
| Java (Maven) | `maven` |
| Java (Gradle) | `gradle` |
| Docker | `docker` |
| Terraform | `terraform` |
| GitHub Actions | `github-actions` |

### How to handle Dependabot PRs

```bash
# List all open Dependabot PRs
gh pr list --author app/dependabot

# Check CI status before merging
gh pr view <number> --json statusCheckRollup

# Approve and merge (if CI passes and change is low-risk)
gh pr review <number> --approve --body "LGTM"
gh pr merge <number> --squash

# Merge with admin override (when CI fails for unrelated reasons)
gh pr merge <number> --squash --admin
```

**Rule of thumb for Dependabot PRs:**
- Patch version (1.0.x → 1.0.y): merge immediately if CI passes
- Minor version (1.x → 1.y): review changelog, merge if no breaking changes
- Major version (1.x → 2.x): read migration guide, test manually first

### Self-check

- Why do Dependabot PRs target `dev` and not `main`?
- What is `open-pull-requests-limit` for?
- What is the difference between a patch, minor, and major version bump?
- Why should you always include `github-actions` in Dependabot config?

---

## 11. Supply Chain Security — SHA Pinning

### The attack this prevents

GitHub Actions version tags (like `@v4`) are **mutable**. Any maintainer with
write access to the action's repo can move that tag to point to a completely
different — potentially malicious — commit.

**Real example:** In January 2023, the `tj-actions/changed-files` action was
compromised. Attackers moved its version tags to code that printed CI secrets to
logs. Thousands of repositories were affected.

**SHA pinning** makes your workflow reference an **immutable** specific commit.
The tag can be moved — but your workflow won't follow it.

### How to find the SHA for any action

```bash
# Step 1: get the object behind the tag
gh api repos/<owner>/<action>/git/ref/tags/<tag> \
  --jq '{sha: .object.sha, type: .object.type}'

# Two possible results:
# {"sha": "abc123...", "type": "commit"}  → use this SHA directly
# {"sha": "def456...", "type": "tag"}     → annotated tag, needs dereferencing

# Step 2: if type was "tag", dereference to get the commit SHA
gh api repos/<owner>/<action>/git/tags/<SHA-from-step-1> \
  --jq '.object.sha'
# This gives you the actual commit SHA to use
```

### Example for `actions/checkout@v4`

```bash
gh api repos/actions/checkout/git/ref/tags/v4 \
  --jq '{sha: .object.sha, type: .object.type}'
# → {"sha": "11bd71901bbe5b1630ceea73d27597364c9af683", "type": "commit"}
# type is "commit" → use directly
```

### How to write it in a workflow

```yaml
# ❌ Vulnerable — tag can be moved to malicious code
- uses: actions/checkout@v4

# ✅ Safe — immutable commit reference
- uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4
#                                                                    ↑ comment for humans
```

### Keeping pins up to date

Add `github-actions` to Dependabot (Section 10). It will automatically open PRs
that update both the SHA and the comment when a new version is released.

### Self-check

- Why is using `@v4` in a workflow a security risk?
- What real-world attack did SHA pinning prevent?
- How do you find the commit SHA for `actions/setup-python@v5`?
- Why keep the `# v4` comment after the SHA?

---

## 12. Branch Protection Rules

### The concept

Without protection, anyone (including yourself by accident) can push broken code
directly to `main`, delete a branch, or rewrite history with force-push.
Branch protection rules enforce process at the GitHub level — they can't be
bypassed without admin rights.

### Applying rules via GitHub CLI

```bash
# ── High protection: main and integration branches ────────────────────
gh api repos/<owner>/<repo>/branches/<branch>/protection \
  -X PUT \
  --input - <<'EOF'
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["Lint & format check", "Tests"]
  },
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "dismiss_stale_reviews": true
  },
  "restrictions": null
}
EOF

# ── Light protection: team/feature branches ───────────────────────────
gh api repos/<owner>/<repo>/branches/<branch>/protection \
  -X PUT \
  --input - <<'EOF'
{
  "required_status_checks": {
    "strict": false,
    "contexts": ["Lint & format check", "Tests"]
  },
  "enforce_admins": false,
  "required_pull_request_reviews": null,
  "restrictions": null
}
EOF
```

### Field-by-field explanation

| Field | Value | Meaning |
|-------|-------|---------|
| `strict` | `true` | Branch must be up to date with target before merging |
| `contexts` | `["Lint & format check", "Tests"]` | **Must match the `name:` in your workflow job exactly** |
| `enforce_admins` | `false` | Admins can bypass rules (set `true` for strict compliance) |
| `required_approving_review_count` | `1` | At least 1 human must approve |
| `dismiss_stale_reviews` | `true` | New commits invalidate existing approvals |
| `restrictions` | `null` | No restriction on who can push |

> **Critical:** `contexts` must exactly match the `name:` field in your CI workflow,
> not the workflow file name. If CI hasn't run yet, add them via the API — they'll
> link up automatically on the first CI run.

### Protection levels by team size

| Branch | Solo | Small team | Large team |
|--------|------|-----------|------------|
| `main` | CI required | PR + 1 review + CI | PR + 2 reviews + CI |
| `dev` / integration | — | PR + CI | PR + 1 review + CI |
| Feature branches | — | CI only | CI only |

### Self-check

- What does `strict: true` mean in `required_status_checks`?
- What happens when `dismiss_stale_reviews` is `true` and someone adds a commit?
- Why must `contexts` match the `name:` in the workflow exactly?
- What is the difference between `enforce_admins: true` and `false`?

---

## 13. Docker

### The concept

Docker packages your application and its dependencies into an **image** — a
portable, reproducible environment that runs identically on any machine.

- **Reproducibility** — eliminates "works on my machine"
- **Isolation** — dependencies don't conflict with other projects
- **Portability** — deploy the same image to dev, staging, and production

### Vocabulary

| Term | Definition |
|------|------------|
| **Image** | A read-only template (like a class in OOP) |
| **Container** | A running instance of an image (like an object) |
| **Dockerfile** | Instructions to build an image |
| **Layer** | Each `RUN`, `COPY`, `ADD` instruction creates a cached layer |
| **Tag** | A label on an image (e.g. `myapp:1.0.0`, `myapp:latest`) |

### Annotated `Dockerfile`

```dockerfile
# ── Choose your base image ────────────────────────────────────────────
FROM python:3.12-slim
# python:3.12          → full image (~900MB) — has build tools
# python:3.12-slim     → smaller (~100MB) — no build tools (use for most apps)
# python:3.12-alpine   → tiny (~50MB) — use carefully, C extensions can break

# ── Set working directory ─────────────────────────────────────────────
WORKDIR /app
# All subsequent COPY/RUN commands are relative to /app

# ── COPY DEPENDENCIES FIRST (before source code) ─────────────────────
COPY requirements.txt* requirements-dev.txt ./
RUN pip install --no-cache-dir -r requirements-dev.txt \
    && if [ -f requirements.txt ]; then \
         pip install --no-cache-dir -r requirements.txt; \
       fi
# WHY copy deps first?
# Docker caches each layer. If you copy source first, any code change
# invalidates ALL subsequent layers including the pip install.
# By copying only the requirements files first, the pip install layer
# is only rebuilt when dependencies actually change.

# ── THEN copy source code ─────────────────────────────────────────────
COPY src/ ./src/
COPY scripts/ ./scripts/

# ── Default command ───────────────────────────────────────────────────
CMD ["python", "-m", "src.main"]
# Override at runtime: docker run myapp python scripts/process.py
```

### Essential Docker commands

```bash
# Build
docker build -t myapp .                    # build with tag "myapp:latest"
docker build -t myapp:1.0.0 .             # build with version tag
docker build --no-cache -t myapp .        # force rebuild (ignore cache)

# Run
docker run --rm myapp                      # run and delete container on exit
docker run --rm -it myapp bash            # interactive shell (debugging)
docker run --rm -v $(pwd)/data:/app/data myapp  # mount local directory
docker run --rm -e API_KEY=secret myapp   # pass environment variable

# Inspect
docker images                              # list all local images
docker ps                                  # list running containers
docker ps -a                               # list all containers (incl. stopped)
docker logs <container-id>                # view container logs

# Cleanup
docker rm <container-id>                  # remove stopped container
docker rmi myapp                          # remove image
docker system prune                       # remove all unused images/containers
docker system prune -a                    # remove everything including cached layers
```

### Adding Docker to CI

```yaml
- name: Build Docker image
  run: docker build -t myapp:${{ github.sha }} .
  # github.sha = the commit SHA — unique per build, traceable

- name: Run tests in container
  run: docker run --rm myapp:${{ github.sha }} pytest
```

### `.dockerignore` — always create this

```
.git
.github
__pycache__
*.pyc
.env
.venv
venv
*.egg-info
dist
build
.pre-commit-config.yaml
*.md
tests/
notebooks/
data/raw/
results/
```

### Self-check

- What is the difference between an image and a container?
- Why do we copy `requirements.txt` before copying source code?
- What does `docker run --rm` do?
- What is `.dockerignore` for?
- What does `python:3.12-slim` give you compared to `python:3.12`?

---

## 14. Documentation Site — MkDocs

### The concept

MkDocs turns your `docs/` markdown files into a professional static website.
The Material theme is the industry standard for technical documentation.
GitHub Pages hosts it for free.

### `mkdocs.yml`

```yaml
site_name: My Project                          # displayed in browser tab
site_description: What the project does        # for SEO and sharing
site_url: https://<username>.github.io/<repo>/ # your GitHub Pages URL

docs_dir: docs       # where your .md source files are
site_dir: _site      # where built HTML goes (add _site/ to .gitignore)

theme:
  name: material
  palette:
    scheme: default
    primary: indigo    # accent colour
  features:
    - navigation.instant  # single-page app navigation (faster)
    - navigation.top      # back-to-top button
    - content.code.copy   # copy button on all code blocks

nav:
  - Home: index.md
  - User Guide: guide.md
  - API Reference: api.md
  - Contributing: ../CONTRIBUTING.md  # can reference files outside docs/
```

### Local development

```bash
pip install mkdocs mkdocs-material
mkdocs serve            # live-reload dev server at http://127.0.0.1:8000
mkdocs build            # build to _site/
mkdocs build --strict   # fail on warnings (used in CI)
```

### One-time GitHub setup

**Settings → Pages → Source → GitHub Actions**

### Self-check

- What does `mkdocs build --strict` do differently from `mkdocs build`?
- Where does MkDocs look for source files by default?
- What setting in GitHub enables Pages deployment from Actions?

---

## 15. GitHub Issue Templates

### The concept

Without templates, issues are vague: *"it doesn't work"*. Templates prompt
contributors to provide structured, actionable information.

### `.github/ISSUE_TEMPLATE/bug_report.md`

```markdown
---
name: Bug report
about: Report something that isn't working
labels: bug
assignees: ''
---

## Description
<!-- A clear, concise description of the bug -->

## Steps to reproduce
1.
2.
3.

## Expected behaviour

## Actual behaviour

## Environment
- OS:
- Python version:
- Relevant package versions:

## Additional context
<!-- Screenshots, logs, etc. -->
```

### `.github/ISSUE_TEMPLATE/feature_request.md`

```markdown
---
name: Feature request
about: Propose a new feature or improvement
labels: enhancement
assignees: ''
---

## Summary
<!-- One sentence: what do you want? -->

## Motivation
<!-- Why is this needed? What problem does it solve? -->

## Proposed approach
<!-- How might this be implemented? (optional) -->

## Acceptance criteria
- [ ]
- [ ]
- [ ]
```

### Self-check

- What is the `about:` field in the frontmatter for?
- What is the `labels:` field for?
- Why do acceptance criteria use checkboxes?

---

## 16. Day-to-Day Developer Workflow

### The full cycle — from issue to production

```
1. Create a GitHub Issue describing the work
   → gives every change a traceable reason

2. Checkout your branch and pull latest
   git checkout <your-branch>
   git pull origin <your-branch>

3. Write code + tests

4. Commit (pre-commit hooks run automatically)
   git add <specific files>     ← never: git add .
   git commit -m "Add X to solve Y"

5. Push
   git push origin <your-branch>

6. Open a Pull Request on GitHub
   → title: what changed (imperative, ≤72 chars)
   → body: why it was needed + "Closes #<issue>"

7. CI runs automatically
   → fix anything that fails

8. Get review + approval

9. Merge PR → CI runs on integration branch (dev)

10. When dev is stable → PR: dev → main
    → deploy workflow runs automatically
```

### Commit message format

```
<verb> <what> [in <where>]

<optional body: why this was needed, not what was done>

Closes #<issue-number>
```

**Good examples:**
```
Add input validation to the user registration form

Prevents empty strings and SQL injection patterns from reaching the database.
Previously any string was accepted without sanitisation.

Closes #42
```

```
Fix off-by-one error in pagination calculation
```

```
Update dependencies to address CVE-2024-12345
```

**Bad examples:**
```
fix stuff              ← too vague
WIP                    ← never commit WIP to a shared branch
added the feature      ← not imperative, no context
```

### PR checklist

Before requesting review:
- [ ] CI is fully green (all jobs pass)
- [ ] New code has tests
- [ ] No debug prints or `TODO` left in
- [ ] PR description explains *why*, not just *what*
- [ ] Linked to the issue (`Closes #N`)
- [ ] No unrelated changes in this PR

### Self-check

- Why do we use `git add <specific files>` instead of `git add .`?
- What does `Closes #42` in a commit message do?
- What should the PR *body* explain — what or why?
- What is wrong with a commit message like `"fix stuff"`?

---

## 17. Master Checklist — Any New Project

Use this for every new project. Replace `<placeholders>` with your values.
Estimated time: **~2 hours** for a complete setup.

---

### Phase 1 — Repository skeleton (~30 min)

- [ ] Create repo on GitHub (initialise with README)
- [ ] Clone locally: `git clone git@github.com:<owner>/<repo>.git`
- [ ] Create folder structure:
  ```bash
  mkdir -p src/<package> tests docs data/raw data/processed \
           scripts notebooks results examples references \
           .github/workflows .github/ISSUE_TEMPLATE
  find . -type d -empty -not -path './.git/*' -exec touch {}/.gitkeep \;
  ```
- [ ] Write `README.md` (project goal, structure, getting started)
- [ ] Write `CONTRIBUTING.md` (branch strategy, commit style, PR process)
- [ ] Write `CLAUDE.md` (project context, commands, CI/CD summary)
- [ ] First commit + push

---

### Phase 2 — Tooling (~20 min)

- [ ] Create `requirements-dev.txt` with: pytest, pytest-cov, black, flake8, bandit, pip-audit, pre-commit
- [ ] Create `pyproject.toml` with black + pytest config
- [ ] Create `.flake8` config (max-line-length = 88)
- [ ] Create `.pre-commit-config.yaml` (pre-commit-hooks, black, flake8, bandit)
- [ ] Install and activate hooks:
  ```bash
  pip install -r requirements-dev.txt
  pre-commit install
  pre-commit run --all-files   # verify all hooks pass on current state
  ```

---

### Phase 3 — Branch strategy (~10 min)

- [ ] Decide on your model (solo / small team / enterprise)
- [ ] Create branches:
  ```bash
  for branch in dev <team-branches...>; do
    git checkout -b $branch
    git push -u origin $branch
    git checkout main
  done
  ```
- [ ] Document the strategy in CONTRIBUTING.md

---

### Phase 4 — GitHub Actions workflows (~30 min)

**First: resolve SHAs for every action you'll use**
```bash
# For each action (repeat for checkout, setup-python, upload-artifact, etc.)
gh api repos/<owner>/<action>/git/ref/tags/<tag> \
  --jq '{sha: .object.sha, type: .object.type}'
# If type is "tag": gh api repos/<owner>/<action>/git/tags/<sha> --jq '.object.sha'
```

- [ ] Create `.github/workflows/ci.yml` (lint, test, security — all in parallel)
- [ ] Create `.github/workflows/codeql.yml` (push/PR to main+dev + weekly)
- [ ] Create `.github/workflows/scorecard.yml` (push to main + weekly)
- [ ] Create `.github/workflows/deploy-docs.yml` (if you have docs)
- [ ] Create `.github/dependabot.yml` (pip + github-actions, target dev)
- [ ] Verify: all `uses:` lines are pinned to commit SHAs

---

### Phase 5 — Docker (~15 min)

- [ ] Create `Dockerfile` (slim base, deps-first layer order)
- [ ] Create `.dockerignore`
- [ ] Test locally:
  ```bash
  docker build -t <project> .
  docker run --rm <project>
  ```

---

### Phase 6 — GitHub configuration (~20 min)

- [ ] Apply high protection to `main` and `dev`:
  ```bash
  gh api repos/<owner>/<repo>/branches/main/protection -X PUT --input - <<'EOF'
  {
    "required_status_checks": { "strict": true, "contexts": ["Lint & format check", "Tests"] },
    "enforce_admins": false,
    "required_pull_request_reviews": { "required_approving_review_count": 1, "dismiss_stale_reviews": true },
    "restrictions": null
  }
  EOF
  ```
- [ ] Apply light protection to team/feature branches (CI required, no PR needed)
- [ ] Add issue templates (bug_report.md, feature_request.md)
- [ ] Enable GitHub Pages: **Settings → Pages → Source → GitHub Actions**
- [ ] Enable secret scanning: **Settings → Security → Secret scanning → Enable**
- [ ] Enable Dependabot security updates: **Settings → Security → Dependabot → Enable**

---

### Phase 7 — Documentation (~15 min)

- [ ] Create `mkdocs.yml` (Material theme, docs/ source)
- [ ] Create `docs/index.md` (seed from README)
- [ ] Sync all branches with main:
  ```bash
  for branch in dev <other-branches>; do
    git checkout $branch && git merge main --no-edit && git push origin $branch
  done
  git checkout main
  ```
- [ ] Update CLAUDE.md to reflect final state

---

### Verification — run through this before calling it done

- [ ] Push a test commit → CI runs and passes (or fails for known reasons only)
- [ ] Open a test PR → protection rules trigger
- [ ] Check Security tab → CodeQL results appear after first run
- [ ] Check Actions tab → all workflows listed and triggering correctly
- [ ] `docker build -t test . && docker run --rm test` succeeds locally
- [ ] `pre-commit run --all-files` passes with no errors

---

## 18. How to Talk About This in an Interview

### What interviewers ask

**"Walk me through your CI/CD pipeline."**

> "I use GitHub Actions with four parallel jobs: lint (black + flake8),
> test (pytest with coverage), security (bandit for SAST and pip-audit for CVE
> scanning), and a domain-specific validation step. For security beyond CI,
> I add CodeQL for deep semantic analysis and OSSF Scorecard for posture
> measurement. All action references are SHA-pinned to prevent supply chain
> attacks, and Dependabot keeps them updated automatically."

---

**"How do you handle security in your repositories?"**

> "I use defence in depth: pre-commit hooks catch issues locally before they
> reach CI. CI runs bandit and pip-audit on every PR. CodeQL does deep static
> analysis weekly and on every PR to main. Dependabot opens weekly PRs to keep
> dependencies patched. OSSF Scorecard measures the overall posture and publishes
> results to securityscorecards.dev. And all GitHub Actions are pinned to commit
> SHAs, not mutable version tags."

---

**"What is a supply chain attack and how do you prevent it?"**

> "A supply chain attack targets a dependency or tool rather than your code
> directly. In 2023, the tj-actions/changed-files GitHub Action was compromised
> by moving its version tag to malicious code that exfiltrated CI secrets. I
> prevent this by pinning every action to a full commit SHA — immutable references
> that can't be moved. Dependabot then automatically opens PRs to update those
> SHAs when new versions are released."

---

**"What is the difference between SAST and DAST?"**

> "SAST (Static Application Security Testing) analyses source code without
> running it — tools like bandit and CodeQL. It catches issues early in the
> development cycle at low cost. DAST (Dynamic Application Security Testing)
> tests the running application — tools like OWASP ZAP. DAST catches runtime
> issues that SAST misses, like authentication flaws and business logic errors,
> but requires a deployed environment."

---

**"What does OSSF Scorecard score?"**

> "About 18 practices including: whether main branches are protected and require
> reviews, whether CI tests run on every PR, whether dependencies are kept updated,
> whether actions are pinned to SHAs, whether SAST is running, and whether
> workflows follow principle of least privilege with minimal permissions."

---

### Keywords to know

When a job description says these, you now have the experience:

| Job description says | You have done |
|---------------------|---------------|
| "CI/CD pipeline" | GitHub Actions with lint/test/security |
| "DevSecOps" | Pre-commit + CI security + CodeQL + Scorecard |
| "Supply chain security" | SHA pinning + Dependabot |
| "SAST" | bandit + CodeQL |
| "Dependency management" | Dependabot + pip-audit |
| "Branch strategy" | Feature → dev → main with protection rules |
| "Containerisation" | Dockerfile with layer caching |
| "Infrastructure as Code" | GitHub Actions YAML + Dependabot config |
| "Shift left security" | Pre-commit hooks catching issues before CI |

---

## 19. Common Mistakes to Avoid

### Workflow mistakes

| Mistake | Consequence | Fix |
|---------|-------------|-----|
| Using `@v4` tags instead of SHAs | Vulnerable to supply chain attack | SHA-pin every action |
| `git add .` in commits | Accidentally commits `.env`, large files, etc. | Always `git add <specific files>` |
| Committing directly to `main` | Bypasses all quality gates | Branch protection rules |
| No `--no-cache-dir` in Dockerfile RUN | Larger image than necessary | Always add it to pip install |
| Copying source before requirements in Dockerfile | Slow builds (cache invalidated on every code change) | Copy requirements first |
| `continue-on-error: true` permanently | Hides real failures | Use only temporarily, remove when feature is stable |
| `enforce_admins: false` forever | Admins bypass their own rules | Enable when ready for full compliance |

### Security mistakes

| Mistake | Consequence | Fix |
|---------|-------------|-----|
| Hardcoding secrets in code | Leaked to anyone with repo access | Use GitHub Secrets + `${{ secrets.NAME }}` |
| No `.dockerignore` | `.env` files baked into image | Always create `.dockerignore` |
| `permissions: write-all` on workflows | Over-privileged, expands blast radius | Use `permissions: read-all` + per-job overrides |
| Ignoring Dependabot PRs | Accumulating CVEs | Review and merge weekly |
| Using `pip install` without pinned versions | Non-reproducible builds | Use `requirements.txt` with pinned versions |

### Process mistakes

| Mistake | Consequence | Fix |
|---------|-------------|-----|
| Not updating CLAUDE.md | AI assistant gives wrong advice | Update after every structural change |
| Not syncing `main` to other branches | Teams work on stale code, merge conflicts accumulate | Sync after every main commit |
| Giant PRs | Impossible to review, hard to revert | One concern per PR |
| Vague commit messages | Can't understand history 6 months later | Imperative verb + what + why |
| Skipping issue creation | No traceability, can't measure velocity | Every PR links to an issue |

---

## 20. Concepts Glossary

| Term | Definition |
|------|------------|
| **Artifact** | A file produced by a CI job, stored for download or use by other jobs |
| **bandit** | Python security linter — finds common vulnerabilities in source code |
| **Branch protection** | GitHub rules that enforce process (PR required, CI must pass, etc.) on a branch |
| **CD** (Continuous Deployment/Delivery) | Automatically deploy code after CI passes |
| **CI** (Continuous Integration) | Automatically build, test, and validate code on every push |
| **CodeQL** | GitHub's semantic code analysis engine — traces data flow across files |
| **Concurrency group** | GitHub Actions setting that prevents duplicate workflow runs |
| **Container** | A running instance of a Docker image |
| **CVE** | Common Vulnerabilities and Exposures — a public record of a known vulnerability |
| **DAST** | Dynamic Application Security Testing — tests running applications |
| **Defence in depth** | Multiple security layers, each catching what the previous missed |
| **Dependabot** | GitHub bot that opens PRs to update outdated dependencies |
| **Docker image** | A portable, reproducible environment built from a Dockerfile |
| **Job** | A group of steps in GitHub Actions that runs on one machine |
| **Layer (Docker)** | Each instruction in a Dockerfile creates a cached layer |
| **MkDocs** | Static site generator that turns Markdown files into a docs website |
| **OSSF** | Open Source Security Foundation |
| **pip-audit** | CVE scanner for Python packages |
| **pre-commit hook** | Script that runs before `git commit` completes |
| **Runner** | The virtual machine that executes a GitHub Actions job |
| **SARIF** | Static Analysis Results Interchange Format — standard format for security findings |
| **SAST** | Static Application Security Testing — analyses source code without running it |
| **SHA pinning** | Referencing a Git commit by its immutable hash instead of a mutable tag |
| **Scorecard** | OSSF tool that scores a repository's security practices 0–10 |
| **Step** | A single command or action within a GitHub Actions job |
| **Supply chain attack** | Compromising a dependency or tool to attack its downstream users |
| **Workflow** | A YAML file in `.github/workflows/` that defines automation |
