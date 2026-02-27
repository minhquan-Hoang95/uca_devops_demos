# Contributing

## Branch Strategy

```
main
 └── dev               ← integration branch (merge here before main)
      ├── input        ← input data group
      ├── output       ← output / results group
      ├── solver       ← OPL/CPLEX solver group
      └── documentation← docs group
```

| Branch | Who works here | Merges into |
|--------|---------------|-------------|
| `input` | Input data group | `dev` |
| `output` | Output / results group | `dev` |
| `solver` | OPL/CPLEX solver group | `dev` |
| `documentation` | Documentation group | `dev` |
| `dev` | Integration — all groups | `main` |
| `main` | Stable releases only | — |

**Rules:**
- Each group works exclusively on their named branch.
- Open a PR from your group branch → `dev` when a feature is ready.
- `dev` → `main` PRs are opened only when the integrated work is stable and reviewed.
- Never commit directly to `main` or `dev`.

**Branch protection summary:**

| Branch | Direct push | PR required | Review required | CI must pass |
|--------|:-----------:|:-----------:|:---------------:|:------------:|
| `main` | blocked | yes | 1 approval | yes (branch must be up to date) |
| `dev` | blocked | yes | 1 approval | yes (branch must be up to date) |
| `input` | allowed | no | no | yes |
| `output` | allowed | no | no | yes |
| `solver` | allowed | no | no | yes |
| `documentation` | allowed | no | no | yes |

For short-lived work within a group branch, sub-branches are welcome:

```
solver/room-capacity-constraint
input/parse-json-format
```

## Commits

Use short, imperative subject lines (≤ 72 chars):

```
Add room-capacity constraint to OPL model
Fix off-by-one error in slot indexing
```

Reference the related issue when relevant: `Closes #12`.

## Pull Requests

- Keep PRs focused on a single concern.
- Describe *what* changed and *why* in the PR body.
- At least one review approval required before merging.

## Issues

All work should be tracked via a GitHub Issue before starting. Use the provided templates for bugs and feature requests.
