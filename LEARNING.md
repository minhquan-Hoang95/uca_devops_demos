# DevSecOps Repository Setup — Complete Learning Guide

This guide teaches you how to build a professional DevSecOps repository from scratch,
for any project, independently. Each section explains not just *what* to do but *why*,
so you can adapt it to any stack or team.

---

## Table of Contents

1. [Mental Model — What is DevSecOps?](#1-mental-model--what-is-devsecops)
2. [Repository Structure](#2-repository-structure)
3. [Branch Strategy](#3-branch-strategy)
4. [Python Tooling Setup](#4-python-tooling-setup)
5. [Pre-commit Hooks](#5-pre-commit-hooks)
6. [GitHub Actions — CI Pipeline](#6-github-actions--ci-pipeline)
7. [GitHub Actions — Security Workflows](#7-github-actions--security-workflows)
8. [GitHub Actions — Deploy Workflow](#8-github-actions--deploy-workflow)
9. [Dependabot — Automated Dependency Updates](#9-dependabot--automated-dependency-updates)
10. [Docker](#10-docker)
11. [Branch Protection Rules](#11-branch-protection-rules)
12. [Documentation Site with MkDocs](#12-documentation-site-with-mkdocs)
13. [GitHub Issue Templates](#13-github-issue-templates)
14. [SHA Pinning — Supply Chain Security](#14-sha-pinning--supply-chain-security)
15. [CLAUDE.md — AI Assistant Context](#15-claudemd--ai-assistant-context)
16. [Day-to-Day Workflow](#16-day-to-day-workflow)
17. [Checklist for Any New Project](#17-checklist-for-any-new-project)
18. [Concepts Glossary](#18-concepts-glossary)

---

## 1. Mental Model — What is DevSecOps?

**DevOps** = Development + Operations: automate the path from code to production.
**DevSecOps** = Dev + Sec + Ops: embed security at every step, not as an afterthought.

### The Three Loops

```
Developer loop (seconds):    write code → pre-commit hooks → commit
CI loop (minutes):           push → lint → test → security scan → merge
CD loop (minutes/hours):     merge to main → build → deploy → monitor
```

The goal is to **catch problems as early and cheaply as possible**.
A bug caught by a pre-commit hook costs nothing.
A bug caught in production costs everything.

### Security Layers (Defence in Depth)

```
┌─────────────────────────────────────────┐
│  Supply chain (SHA-pinned actions)      │  ← prevent action hijacking
│  ┌───────────────────────────────────┐  │
│  │  Dependabot (weekly dep updates)  │  │  ← stay patched
│  │  ┌─────────────────────────────┐  │  │
│  │  │  OSSF Scorecard (weekly)    │  │  │  ← posture measurement
│  │  │  ┌───────────────────────┐  │  │  │
│  │  │  │  CodeQL (every PR)    │  │  │  │  ← deep SAST
│  │  │  │  ┌─────────────────┐  │  │  │  │
│  │  │  │  │  CI: bandit +   │  │  │  │  │  ← fast SAST + CVE scan
│  │  │  │  │  pip-audit      │  │  │  │  │
│  │  │  │  │  ┌───────────┐  │  │  │  │  │
│  │  │  │  │  │ pre-commit│  │  │  │  │  │  ← local, instant
│  │  │  │  │  └───────────┘  │  │  │  │  │
│  │  │  │  └─────────────────┘  │  │  │  │
│  │  │  └───────────────────────┘  │  │  │
│  │  └─────────────────────────────┘  │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

---

## 2. Repository Structure

### Why structure matters

A consistent structure means any contributor — human or AI — can navigate the codebase
without asking. It also signals professionalism to collaborators and employers.

### Universal structure (adapt as needed)

```
project-root/
├── docs/           # All documentation (LaTeX, markdown, notes)
├── src/            # Main application source code
│   └── <package>/
├── scripts/        # Standalone scripts (data processing, analysis)
├── tests/          # All test files — mirrors src/ structure
├── data/
│   ├── raw/        # Original data — never modify
│   └── processed/  # Cleaned/transformed data
├── notebooks/      # Jupyter notebooks for exploration only
├── results/        # Outputs: plots, logs, solver results
├── examples/       # Minimal runnable examples for new contributors
├── references/     # Papers, specs, external docs
├── .github/
│   ├── workflows/  # All GitHub Actions YAML files
│   └── ISSUE_TEMPLATE/
├── .pre-commit-config.yaml
├── pyproject.toml
├── .flake8
├── Dockerfile
├── mkdocs.yml
├── requirements.txt        # Runtime dependencies
├── requirements-dev.txt    # Dev/test dependencies
├── README.md
├── CONTRIBUTING.md
├── CLAUDE.md
└── LEARNING.md
```

### How to create it

```bash
mkdir -p docs src/mypackage scripts tests data/raw data/processed \
         notebooks results examples references \
         .github/workflows .github/ISSUE_TEMPLATE

# Git doesn't track empty directories — add a placeholder
find . -type d -empty -not -path './.git/*' -exec touch {}/.gitkeep \;
```

### Adapting for other stacks

| Stack | Replace `scripts/` with | Replace `tests/` with |
|-------|--------------------------|----------------------|
| Node.js | `src/` | `__tests__/` or `test/` |
| Java/Maven | `src/main/java/` | `src/test/java/` |
| Go | `cmd/` + `internal/` | `*_test.go` in same package |
| Rust | `src/` | `tests/` (integration) |

---

## 3. Branch Strategy

### Why this matters

Without a clear strategy, teams push to `main`, break each other's work, and lose
history. A good strategy isolates risk and enables parallel work.

### The model used in this project

```
main          ← production-ready only. Protected. Never commit directly.
 └── dev      ← integration. Protected. Merge here from group branches.
      ├── input        ← team 1
      ├── output       ← team 2
      ├── solver       ← team 3
      └── documentation← team 4
```

### How to create branches

```bash
# Create each branch from main and push it
for branch in dev input output solver documentation; do
  git checkout -b $branch
  git push -u origin $branch
  git checkout main
done
```

### Adapting the strategy to other projects

**Solo project:**
```
main ← dev ← feature/xxx, fix/xxx, docs/xxx
```

**Startup / small team:**
```
main ← staging ← dev ← feature/xxx
```

**Large team (GitFlow):**
```
main ← release/x.y ← develop ← feature/xxx, hotfix/xxx
```

**Rule of thumb:** the more people, the more branches between feature work and `main`.

### Syncing main to all branches

After every change to `main`, keep all branches up to date:

```bash
for branch in dev input output solver documentation; do
  git checkout $branch
  git merge main --no-edit
  git push origin $branch
done
git checkout main
```

> Why `--no-edit`? It skips the commit message editor for fast-forward or
> auto-resolved merges. Remove it if you want to customise merge messages.

---

## 4. Python Tooling Setup

### `requirements-dev.txt`

Separate dev tools from runtime deps. Runtime deps go in `requirements.txt`.

```
pytest>=8.0          # test runner
pytest-cov>=5.0      # coverage plugin
black>=24.0          # auto-formatter
flake8>=7.0          # style linter
bandit>=1.8          # security linter
pip-audit>=2.7       # CVE scanner
pre-commit>=4.0      # hook manager
```

Install: `pip install -r requirements-dev.txt`

### `pyproject.toml`

Central config file. Replaces `setup.cfg`, `tox.ini`, and scattered tool configs.

```toml
[tool.black]
line-length = 88          # black's default — don't change it
target-version = ["py312"]

[tool.pytest.ini_options]
testpaths = ["tests"]     # where pytest looks for tests
addopts = "--cov=scripts --cov-report=term-missing --cov-report=xml"
# --cov=scripts     : measure coverage of the scripts/ package
# --cov-report=xml  : produces coverage.xml for CI artifact upload
```

### `.flake8`

Must be a separate file because flake8 doesn't read `pyproject.toml`.

```ini
[flake8]
max-line-length = 88    # must match black
extend-ignore = E203, W503  # black generates these — ignore them
exclude = .git, __pycache__, .venv
```

> **Why 88?** Black chose 88 as a compromise between 79 (PEP8) and 120 (common in
> teams). The key is consistency — choose one and stick to it.

### Running tools manually

```bash
pytest                          # run all tests
pytest tests/test_foo.py        # run a single file
pytest -k "test_name"           # run tests matching a pattern
black scripts/ tests/           # auto-format (modifies files)
black --check scripts/ tests/   # check only (used in CI)
flake8 scripts/ tests/          # style check
bandit -r scripts/ -ll          # security scan (-ll = medium+ severity)
pip-audit                       # CVE scan
```

---

## 5. Pre-commit Hooks

### What they are

Scripts that run automatically before `git commit` completes. If any hook fails,
the commit is aborted. The developer fixes the issue locally — before it ever
reaches CI or code review.

### Why they matter

```
Without hooks:  commit → push → CI runs (2 min) → fail → fix → push again
With hooks:     commit → hook fails instantly → fix → commit succeeds
```

### Installation (once per developer, once per repo clone)

```bash
pip install pre-commit
pre-commit install   # installs the hook into .git/hooks/pre-commit
```

### `.pre-commit-config.yaml` — explained line by line

```yaml
repos:
  # ── Standard hooks from the pre-commit project ────────────────────────
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v5.0.0          # always pin to a specific version
    hooks:
      - id: trailing-whitespace    # removes trailing spaces
      - id: end-of-file-fixer      # ensures files end with a newline
      - id: check-yaml             # validates YAML syntax
      - id: check-json             # validates JSON syntax
      - id: check-merge-conflict   # blocks <<<<<<< markers
      - id: check-added-large-files
        args: ["--maxkb=1024"]     # blocks files > 1 MB
      - id: detect-private-key     # blocks RSA/SSH/PGP keys

  # ── Python formatter ─────────────────────────────────────────────────
  - repo: https://github.com/psf/black
    rev: 25.1.0
    hooks:
      - id: black
        language_version: python3.12

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
        args: ["-r", "scripts/", "-ll"]
        pass_filenames: false   # run on the whole directory, not per file
```

### Useful commands

```bash
pre-commit run --all-files          # run all hooks on all files (first-time check)
pre-commit run black --all-files    # run only black
pre-commit autoupdate               # update all hook versions to latest
git commit --no-verify              # bypass hooks (emergency only — never in CI)
```

### Adding hooks for other stacks

| Stack | Hook to add |
|-------|-------------|
| JavaScript | `eslint`, `prettier` |
| TypeScript | `tsc --noEmit` |
| Go | `gofmt`, `golangci-lint` |
| Rust | `rustfmt`, `clippy` |
| Docker | `hadolint` (Dockerfile linter) |
| Shell | `shellcheck` |
| Secrets | `gitleaks` or `detect-secrets` |

---

## 6. GitHub Actions — CI Pipeline

### Concepts

**Workflow** = a YAML file in `.github/workflows/`. Defines when and what to run.
**Job** = a group of steps running on one machine (runner).
**Step** = a single command or action within a job.
**Runner** = the virtual machine that executes the job (`ubuntu-latest` = Ubuntu 24.04).

Jobs in the same workflow run **in parallel by default**. Use `needs:` to make them sequential.

### Trigger events

```yaml
on:
  push:
    branches: [main, dev]         # runs when code is pushed
  pull_request:
    branches: [main, dev]         # runs when a PR targets these branches
  schedule:
    - cron: "0 6 * * 1"           # every Monday at 06:00 UTC
  workflow_dispatch:               # allows manual trigger from GitHub UI
```

### Full annotated `ci.yml`

```yaml
name: CI

on:
  push:
    branches: [main, dev]
  pull_request:
    branches: [main, dev]
  workflow_dispatch:

jobs:
  # ── Job 1: Lint ───────────────────────────────────────────────────────
  lint:
    name: Lint & format check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@<SHA> # v4
        # Downloads your repo code onto the runner

      - uses: actions/setup-python@<SHA> # v5
        with:
          python-version: "3.12"
          cache: pip               # caches pip downloads between runs

      - run: pip install -r requirements-dev.txt
      - run: black --check scripts/ tests/
      - run: flake8 scripts/ tests/

  # ── Job 2: Test ───────────────────────────────────────────────────────
  test:
    name: Tests
    runs-on: ubuntu-latest
    # No 'needs: lint' → runs in PARALLEL with lint
    steps:
      - uses: actions/checkout@<SHA> # v4
      - uses: actions/setup-python@<SHA> # v5
        with:
          python-version: "3.12"
          cache: pip

      - name: Install dependencies
        run: |
          pip install -r requirements-dev.txt
          [ -f requirements.txt ] && pip install -r requirements.txt || true

      - run: pytest

      - uses: actions/upload-artifact@<SHA> # v4
        if: always()                 # upload even if tests fail
        with:
          name: coverage-report
          path: coverage.xml
          retention-days: 14

  # ── Job 3: Security ───────────────────────────────────────────────────
  security:
    name: Security scan
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@<SHA> # v4
      - uses: actions/setup-python@<SHA> # v5
        with:
          python-version: "3.12"
          cache: pip

      - name: Install dependencies
        run: |
          pip install -r requirements-dev.txt
          [ -f requirements.txt ] && pip install -r requirements.txt || true

      - name: bandit – Python security linter
        run: bandit -r scripts/ -ll
        # -r : recursive
        # -ll: only report medium severity and above

      - name: pip-audit – CVE scan
        run: pip-audit
        # scans all installed packages against OSV/PyPI Advisory Database

  # ── Job 4: Domain-specific validation (adapt this) ───────────────────
  validate-opl:
    name: Validate OPL files
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@<SHA> # v4
      - name: Check .mod files have an objective function
        run: |
          mods=$(find opl/ -name "*.mod")
          [ -z "$mods" ] && echo "No .mod files yet." && exit 0
          failed=0
          for f in $mods; do
            grep -qE "minimize|maximize" "$f" || \
              { echo "WARN: $f missing objective"; failed=1; }
          done
          exit $failed
        continue-on-error: true
```

### Key CI design decisions

| Decision | Why |
|----------|-----|
| `lint` and `test` in parallel | Faster feedback — no need to wait for lint to start testing |
| `if: always()` on artifact upload | You need the coverage report *especially* when tests fail |
| `cache: pip` | Saves ~30s per run by reusing downloaded packages |
| `continue-on-error: true` on OPL | Domain-specific check — don't block CI while still developing |

### Adapting CI to other stacks

**Node.js:**
```yaml
- run: npm ci
- run: npm run lint
- run: npm test
```

**Go:**
```yaml
- uses: actions/setup-go@<SHA>
  with: { go-version: "1.22" }
- run: go vet ./...
- run: go test ./... -coverprofile=coverage.out
```

**Java/Maven:**
```yaml
- uses: actions/setup-java@<SHA>
  with: { java-version: "21", distribution: "temurin" }
- run: mvn verify
```

---

## 7. GitHub Actions — Security Workflows

### CodeQL

CodeQL is GitHub's static analysis engine. It builds a database of your code and
runs semantic queries to find vulnerabilities that simple grep can't catch.

```yaml
# .github/workflows/codeql.yml
name: CodeQL

on:
  push:
    branches: [main, dev]
  pull_request:
    branches: [main, dev]
  schedule:
    - cron: "0 6 * * 1"   # weekly even if no code changes
  workflow_dispatch:

jobs:
  analyze:
    runs-on: ubuntu-latest
    permissions:
      security-events: write   # required to upload results
      actions: read
      contents: read

    strategy:
      matrix:
        language: [python]     # add javascript, go, java, etc. as needed

    steps:
      - uses: actions/checkout@<SHA> # v4

      - name: Initialize CodeQL
        uses: github/codeql-action/init@<SHA> # v3
        with:
          languages: ${{ matrix.language }}
          queries: security-and-quality
          # security-extended  → more checks, more false positives
          # security-and-quality → good balance for most projects

      - name: Autobuild
        uses: github/codeql-action/autobuild@<SHA> # v3
        # Tries to build compiled languages automatically
        # For Python this step does nothing (interpreted)

      - name: Perform CodeQL Analysis
        uses: github/codeql-action/analyze@<SHA> # v3
        with:
          category: "/language:${{ matrix.language }}"
```

Results appear in **Security → Code scanning** on GitHub. Each alert shows:
- The vulnerable line of code
- Why it's a problem
- How to fix it

### OSSF Scorecard

Scorecard evaluates your repository against ~18 security best practices and gives
a score from 0 to 10. Useful for demonstrating security maturity to employers.

**Checks it performs:**
- `Branch-Protection` — are your main branches protected?
- `CI-Tests` — do you run tests?
- `Code-Review` — are PRs reviewed before merging?
- `Dangerous-Workflow` — do your workflows use safe patterns?
- `Dependency-Update-Tool` — do you have Dependabot/Renovate?
- `Pinned-Dependencies` — are actions pinned to SHAs?
- `SAST` — do you run static analysis?
- `Token-Permissions` — do workflows use minimal permissions?
- `Vulnerabilities` — are there open CVEs in your dependencies?
- ...and more

```yaml
# .github/workflows/scorecard.yml
name: OSSF Scorecard

on:
  push:
    branches: [main]
  schedule:
    - cron: "0 6 * * 1"
  workflow_dispatch:

permissions: read-all   # minimal permissions by default

jobs:
  analyze:
    runs-on: ubuntu-latest
    permissions:
      security-events: write
      id-token: write
      contents: read
      actions: read

    steps:
      - uses: actions/checkout@<SHA> # v4
        with:
          persist-credentials: false   # security best practice

      - name: Run OSSF Scorecard
        uses: ossf/scorecard-action@<SHA> # v2.4.3
        with:
          results_file: scorecard-results.sarif
          results_format: sarif
          publish_results: true   # publishes to securityscorecards.dev

      - name: Upload to code scanning
        uses: github/codeql-action/upload-sarif@<SHA> # v3
        with:
          sarif_file: scorecard-results.sarif
          category: ossf-scorecard
```

> **SARIF** = Static Analysis Results Interchange Format. A standard JSON format
> for security tool results. GitHub understands it natively.

---

## 8. GitHub Actions — Deploy Workflow

### MkDocs deploy to GitHub Pages

```yaml
# .github/workflows/deploy-docs.yml
name: Deploy docs

on:
  push:
    branches: [main]
    paths:
      - "docs/**"        # only run when docs actually change
      - "mkdocs.yml"
      - "README.md"
  workflow_dispatch:

concurrency:
  group: pages
  cancel-in-progress: true   # cancel old deploy if a new one starts

permissions:
  contents: read
  pages: write
  id-token: write

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@<SHA> # v4
      - uses: actions/setup-python@<SHA> # v5
        with:
          python-version: "3.12"
          cache: pip
      - run: pip install mkdocs mkdocs-material
      - run: mkdocs build --strict --site-dir _site
        # --strict: treat warnings as errors
      - uses: actions/upload-pages-artifact@<SHA> # v3
        with:
          path: _site

  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - uses: actions/deploy-pages@<SHA> # v4
        id: deployment
```

**One-time setup:** Settings → Pages → Source → **GitHub Actions**

### Adapting for other deploy targets

| Target | Replace deploy step with |
|--------|--------------------------|
| AWS S3 | `aws s3 sync _site/ s3://bucket` |
| Netlify | `netlify deploy --prod --dir=_site` |
| Docker registry | `docker build && docker push` |
| VPS | `rsync` or `ssh` + `scp` |

---

## 9. Dependabot — Automated Dependency Updates

### Why it matters

Outdated dependencies are the #1 source of known vulnerabilities. Dependabot opens
PRs automatically when a new version is available, so you never fall behind.

### `.github/dependabot.yml`

```yaml
version: 2
updates:
  # ── Python packages ───────────────────────────────────────────────────
  - package-ecosystem: pip
    directory: "/"              # where requirements.txt lives
    schedule:
      interval: weekly
      day: monday              # consistent with other security scans
    open-pull-requests-limit: 5 # don't flood the board
    target-branch: dev         # PRs go to dev, not main
    labels:
      - dependencies

  # ── GitHub Actions ────────────────────────────────────────────────────
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

### Adapting for other stacks

| Stack | `package-ecosystem` value |
|-------|--------------------------|
| Node.js (npm) | `npm` |
| Node.js (yarn) | `yarn` |
| Java (Maven) | `maven` |
| Java (Gradle) | `gradle` |
| Go | `gomod` |
| Rust | `cargo` |
| Docker | `docker` |
| Terraform | `terraform` |

---

## 10. Docker

### Why containerise

- **Reproducibility** — same environment on every machine, every CI run
- **Isolation** — no "it works on my machine" problems
- **Portability** — run anywhere Docker is installed

### Annotated `Dockerfile`

```dockerfile
# ── Base image ────────────────────────────────────────────────────────
FROM python:3.12-slim
# -slim: smaller image, no dev tools. Use -alpine for even smaller but
# sometimes causes issues with C extensions (numpy, pandas, etc.)

# ── Working directory ─────────────────────────────────────────────────
WORKDIR /app
# All subsequent commands run relative to /app

# ── Install dependencies BEFORE copying source ────────────────────────
COPY requirements.txt* requirements-dev.txt ./
RUN pip install --no-cache-dir -r requirements-dev.txt \
    && if [ -f requirements.txt ]; then \
         pip install --no-cache-dir -r requirements.txt; \
       fi
# WHY copy deps first? Docker caches each layer. If you copy source first,
# any source change invalidates the pip install cache. This way, the
# pip layer is only rebuilt when requirements files change.

# ── Copy source code ──────────────────────────────────────────────────
COPY scripts/ ./scripts/
COPY data/ ./data/

# ── Default command ───────────────────────────────────────────────────
CMD ["python", "-m", "scripts"]
```

### Common Docker commands

```bash
docker build -t myproject .              # build image tagged "myproject"
docker build -t myproject:1.0.0 .        # build with version tag
docker run --rm myproject                # run and delete container on exit
docker run --rm -v $(pwd)/data:/app/data myproject  # mount local data dir
docker run --rm -it myproject bash       # interactive shell for debugging
docker images                            # list images
docker ps                                # list running containers
docker system prune                      # clean up unused images/containers
```

### Adding Docker build to CI (optional but professional)

```yaml
- name: Build Docker image
  run: docker build -t myproject:${{ github.sha }} .

- name: Run tests in container
  run: docker run --rm myproject:${{ github.sha }} pytest
```

---

## 11. Branch Protection Rules

### Why protection matters

Without protection, anyone (including yourself by accident) can:
- Push broken code directly to `main`
- Delete a branch
- Force-push and rewrite history

### Applying rules via GitHub CLI

```bash
# ── Protected branches (main, dev) ────────────────────────────────────
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
```

**Field explanations:**
- `strict: true` — the branch must be up to date with the target before merging
- `contexts` — the exact names of required CI checks (must match the `name:` in your workflow jobs)
- `enforce_admins: false` — admins can bypass (set to `true` for stricter compliance)
- `dismiss_stale_reviews: true` — if new commits are pushed, existing approvals are invalidated
- `restrictions: null` — no user/team restrictions on who can push (once PR requirements are met)

```bash
# ── Light protection (group branches) ────────────────────────────────
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

> **Important:** The `contexts` array must exactly match the `name:` field of your
> CI jobs, not the workflow name. If CI hasn't run yet, the check names won't appear
> in GitHub's dropdown — add them manually via the API anyway, they'll link up
> once CI runs for the first time.

### Adapting protection levels

| Team size | main | integration branch | feature branches |
|-----------|------|--------------------|-----------------|
| Solo | CI required, no PR | — | — |
| 2–5 people | PR + 1 review + CI | PR + CI | CI only |
| 5–20 people | PR + 2 reviews + CI | PR + 1 review + CI | CI only |
| Enterprise | PR + 2 reviews + CI + signed commits | PR + 1 review + CI | CI only |

---

## 12. Documentation Site with MkDocs

### Why MkDocs

- Write docs in Markdown (same as README)
- Generates a professional static site
- Material theme is the industry standard for technical docs
- Free hosting via GitHub Pages

### `mkdocs.yml`

```yaml
site_name: My Project
site_description: What the project does
site_url: https://<github-username>.github.io/<repo-name>/

docs_dir: docs        # source markdown files
site_dir: _site       # generated HTML output (add to .gitignore)

theme:
  name: material
  palette:
    scheme: default
    primary: indigo
  features:
    - navigation.instant   # fast page transitions
    - navigation.top       # back-to-top button
    - content.code.copy    # copy button on code blocks

nav:
  - Home: index.md
  - Guide: guide.md
  - API Reference: api.md
```

### Local development

```bash
pip install mkdocs mkdocs-material
mkdocs serve              # live-reload server at http://127.0.0.1:8000
mkdocs build              # build static site to _site/
mkdocs build --strict     # fail on warnings (used in CI)
```

---

## 13. GitHub Issue Templates

### Why templates matter

Without templates, issues are vague: "it doesn't work". With templates, contributors
provide structured information you actually need to act on.

### `.github/ISSUE_TEMPLATE/bug_report.md`

```markdown
---
name: Bug report
about: Report a problem
labels: bug
---

## Description

## Steps to reproduce
1.
2.

## Expected behaviour

## Actual behaviour

## Environment
- OS:
- Python version:
- Relevant package versions:
```

### `.github/ISSUE_TEMPLATE/feature_request.md`

```markdown
---
name: Feature request
about: Propose a new feature or improvement
labels: enhancement
---

## Summary

## Motivation

## Proposed approach

## Acceptance criteria
- [ ]
- [ ]
```

---

## 14. SHA Pinning — Supply Chain Security

### The attack this prevents

GitHub Actions tags (like `@v4`) are mutable — anyone with write access to that
repo can move the tag to point to malicious code. In 2023, the `tj-actions/changed-files`
action was compromised this way and exfiltrated secrets from thousands of repos.

SHA pinning makes your workflow use an **immutable** specific commit, regardless
of what the tag points to.

### How to find the SHA for any action

```bash
# Step 1: get the tag's SHA
gh api repos/<owner>/<action>/git/ref/tags/<tag> \
  --jq '{sha: .object.sha, type: .object.type}'

# Step 2: if type is "tag" (annotated tag), dereference it
gh api repos/<owner>/<action>/git/tags/<SHA-from-step-1> \
  --jq '.object.sha'

# The second SHA is the commit SHA to use
```

### Example

```bash
# actions/checkout@v4
gh api repos/actions/checkout/git/ref/tags/v4 \
  --jq '{sha: .object.sha, type: .object.type}'
# → {"sha": "34e114876b0b11c390a56381ad16ebd13914f8d5", "type": "commit"}
# type is "commit" → use directly
```

### How to write it

```yaml
# Instead of:
uses: actions/checkout@v4

# Write:
uses: actions/checkout@34e114876b0b11c390a56381ad16ebd13914f8d5 # v4
```

The comment tells humans what version this SHA corresponds to.
Dependabot will automatically update the SHA when a new version is released.

---

## 15. CLAUDE.md — AI Assistant Context

### What it is

`CLAUDE.md` is a file read by Claude Code at the start of every session. It gives
the AI context about your project so it can be productive immediately without you
having to re-explain everything.

### What to include

```markdown
# CLAUDE.md

## Project Context
What the project does, tech stack, purpose.

## Branch Strategy
The diagram and rules — what merges where.

## Development Commands
Every command a developer needs to run day-to-day.

## CI/CD
Table of all workflows, their triggers, and their jobs.

## Security
List of all security tools and where their results appear.

## Docker
Build and run commands.

## Tool Configuration
Where each tool's config lives and key settings.
```

### When to update it

Update `CLAUDE.md` whenever you:
- Add a new workflow
- Change the branch strategy
- Add a new tool or dependency
- Change a command

Think of it as documentation for an AI collaborator — the more accurate it is,
the better help you get.

---

## 16. Day-to-Day Workflow

### Starting a new feature

```bash
# 1. Make sure your branch is up to date
git checkout input
git pull origin input

# 2. (Optional) Create a sub-branch for the specific feature
git checkout -b input/parse-json-data

# 3. Write code, then commit
git add scripts/parse_data.py tests/test_parse_data.py
git commit -m "Add JSON parser for course input data"
# ↑ pre-commit hooks run here automatically

# 4. Push
git push origin input/parse-json-data

# 5. Open PR on GitHub: input/parse-json-data → input
#    (or directly input → dev if not using sub-branches)
```

### The PR checklist

Before requesting review:
- [ ] CI is green (lint, test, security all pass)
- [ ] Tests cover the new code
- [ ] No `TODO` or debug `print()` left in
- [ ] PR description explains *why*, not just *what*
- [ ] Linked to the relevant Issue (`Closes #42`)

### Commit message format

```
<imperative verb> <what changed>

<optional body: why this change was needed>

Closes #<issue-number>
```

Examples:
```
Add room-capacity constraint to OPL model

The previous model ignored room size, causing infeasible solutions
when large classes were assigned to small rooms.

Closes #15
```

```
Fix off-by-one error in slot indexing
```

---

## 17. Checklist for Any New Project

Use this when starting from zero.

### Phase 1 — Repository skeleton (30 min)

- [ ] `git init` + create repo on GitHub
- [ ] Create folder structure + `.gitkeep` placeholders
- [ ] Write `README.md` (project goal, structure, getting started)
- [ ] Write `CONTRIBUTING.md` (branch strategy, commit style, PR process)
- [ ] First commit + push

### Phase 2 — Tooling (20 min)

- [ ] `requirements-dev.txt` with pytest, black, flake8, bandit, pip-audit, pre-commit
- [ ] `pyproject.toml` with black + pytest config
- [ ] `.flake8` config
- [ ] `.pre-commit-config.yaml`
- [ ] Run `pre-commit install`

### Phase 3 — Branches (10 min)

- [ ] Create all branches (`dev` + team branches)
- [ ] Push all branches to remote

### Phase 4 — CI/CD (30 min)

- [ ] Resolve SHAs for all actions you'll use
- [ ] Write `ci.yml` (lint, test, security, domain-specific)
- [ ] Write `codeql.yml`
- [ ] Write `scorecard.yml`
- [ ] Write `deploy-docs.yml` (if you have docs)
- [ ] Write `.github/dependabot.yml`

### Phase 5 — Docker (15 min)

- [ ] Write `Dockerfile`
- [ ] Test locally: `docker build -t myproject . && docker run --rm myproject`

### Phase 6 — GitHub configuration (20 min)

- [ ] Apply branch protection rules via `gh api` or GitHub UI
- [ ] Add issue templates
- [ ] Enable GitHub Pages (Settings → Pages → GitHub Actions)
- [ ] Enable secret scanning (Settings → Security → Secret scanning)
- [ ] Enable Dependabot security updates (Settings → Security → Dependabot)

### Phase 7 — Documentation (15 min)

- [ ] `mkdocs.yml`
- [ ] `docs/index.md`
- [ ] `CLAUDE.md`
- [ ] Sync all branches with main

**Total: ~2 hours for a fully configured professional repository.**

---

## 18. Concepts Glossary

| Term | Definition |
|------|------------|
| **CI** (Continuous Integration) | Automatically build and test code on every push |
| **CD** (Continuous Delivery/Deployment) | Automatically deploy code after CI passes |
| **SAST** (Static Application Security Testing) | Analysing source code for vulnerabilities without running it |
| **CVE** (Common Vulnerabilities and Exposures) | A public database entry for a known security vulnerability |
| **SARIF** | JSON format for security scan results, understood by GitHub |
| **Pre-commit hook** | Script that runs before `git commit` completes |
| **Branch protection** | GitHub rules that enforce process on specific branches |
| **SHA pinning** | Using a full commit hash instead of a mutable tag |
| **Supply chain attack** | Compromising a dependency to attack its users |
| **OSSF** | Open Source Security Foundation — maintains security standards |
| **Scorecard** | OSSF tool that scores a repo's security practices 0–10 |
| **CodeQL** | GitHub's semantic code analysis engine |
| **Dependabot** | GitHub bot that opens PRs for outdated dependencies |
| **MkDocs** | Static site generator that turns Markdown into a docs website |
| **SARIF** | Standard format for reporting security findings to GitHub |
| **Runner** | The virtual machine that executes a GitHub Actions job |
| **Artifact** | A file produced by a CI job and stored for later download |
| **Concurrency group** | Prevents duplicate workflow runs for the same branch |
