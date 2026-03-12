# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a **GitHub Actions reusable workflow repository** for the BakeFoundry organization. It centralizes CI/CD pipelines for Python projects — there is no application code, build system, or test suite here.

## Workflow Architecture

All workflows live in `.github/workflows/`. The key design pattern is **reusable workflows** (`workflow_call` trigger) consumed by other BakeFoundry repositories.

### Workflows

| File | Type | Purpose |
|------|------|---------|
| `all-ci.yml` | Reusable (`workflow_call`) | Main CI pipeline — called by consuming repos |
| `notify-pr.yml` | Standard | Discord notifications for PR review requests |
| `pre-commit.yml` | Standard | Runs pre-commit hooks on push/PR |
| `version.yml` | Standard | Semantic versioning and GitHub releases |

### `all-ci.yml` Pipeline Flow

Three security/quality jobs run **in parallel**:
1. **secret-scan** → `BakeFoundry/bk-secret-scan-workflow@v1`
2. **code-quality** → `BakeFoundry/bk-sonar-scan-workflow@v1` (SonarQube)
3. **sast-scan** → `BakeFoundry/bk-sast-workflow@v1` (Python vulnerability scanning)

Only if **all three pass** does the gating job run:
4. **bake-ami-scan** → `BakeFoundry/bk-bake-ami-workflow@v1` (creates/scans AMI via Ansible playbook on AWS)

Any failure triggers a Discord notification.

### `all-ci.yml` Inputs

| Input | Default | Description |
|-------|---------|-------------|
| `baking_recipe_playbook` | `bake/playbook/bakeami.yml` | Ansible playbook path for AMI baking |
| `application_name` | repository name | App name passed to downstream workflows |
| `version_tag` | (none) | Version tag passed to AMI baking workflow |

### Required Secrets

- `BK_ROLE_TO_ASSUME` — AWS IAM role ARN for OIDC authentication
- `BK_DISCORD_WEBHOOK` — Discord webhook URL for notifications

## How Consuming Repositories Use This

```yaml
# In another repo's .github/workflows/ci.yml
jobs:
  call-all-ci:
    uses: BakeFoundry/bk-python-workflow/.github/workflows/all-ci.yml@v1
    with:
      application_name: "my-app"
      version_tag: "v1.2.3"
    secrets:
      BK_ROLE_TO_ASSUME: ${{ secrets.BK_ROLE_TO_ASSUME }}
      BK_DISCORD_WEBHOOK: ${{ secrets.BK_DISCORD_WEBHOOK }}
```

## Versioning

Releases are managed by `version.yml` using `bakefoundry/bk-release-workflow@v1`. Pushing to `main` triggers an actual release; PRs to `main` run in dry-run mode. Consuming repos pin to tags (e.g., `@v1`).

## Pre-commit Hooks

Configured in `.pre-commit-config.yaml`: trailing whitespace, end-of-file newlines, YAML validation, large file detection. Run locally with `pre-commit run --all-files`.
