# bk-python-workflow

## Intention
The primary intention of this repository is to centralize and standardize the Continuous Integration (CI) workflows for Python projects within the BakeFoundry organization. By defining reusable workflows here, we ensure that all projects adhere to the same high standards for code quality and security without duplicating configuration files across multiple repositories.

## Context
This repository hosts the `all-ci.yml` reusable workflow. This workflow is designed to be called by other repositories to perform comprehensive checks on code changes.

Currently, the `all-ci.yml` workflow includes:
- **Secret Scanning**: It triggers the `bk-secret-scan-workflow` to detect any sensitive information (API keys, tokens, passwords) committed to the codebase.

## How this helps Developers and Reviewers

### For Developers
- **Automated Security**: The formatting and security checks run automatically, catching issues early in the development cycle before code is even reviewed.
- **Consistency**: Developers don't need to worry about configuring their own CI pipelines; they can simply consume the standardized workflows.
- **Feedback Loop**: Immediate feedback on pull requests helps developers fix issues quickly.

### For Reviewers
- **Reduced Mental Load**: Reviewers can focus on the logic and architecture of the changes, knowing that style and security (like secret leaks) have already been verified by the automated system.
- **Confidence**: Seeing a green checkmark on the PR provides high confidence that the code meets the organization's baseline standards.
- **Standardization**: Enforces a consistent bar for quality across all projects.
