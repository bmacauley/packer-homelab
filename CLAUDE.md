# CLAUDE.md

This document provides guidance for Claude Code when working in this repository. It defines the conventions, structure, and safe-editing rules for all packer files used to configure proxmox templates.



The conventions below apply strictly to anything that is developed in this repository.
When using third-party content (e.g. Terraform modules), aim to align with these conventions where reasonable, but a perfect match is not required.

---

## Project Scope

This repository manages packer configs to create proxmox templates in the homelab proxmox environment



A Makefile is used as a uniform interface for common operational tasks across the repository.
All targets must be:
- Non-interactive
- Idempotent
- Safe to run multiple times
- Explicit about their outputs

The overarching goals:
- Provide short, memorable commands (make ping, make lint, etc.)
- Wrap Ansible and Python scripts cleanly...use Python rather than shell scripts as much as possible
- Avoid repeating long command chains in documentation or CI
- Standardize developer workflows

---

## Repository Architecture

### Directory Structure
```
  Typical structure:
  packer-homelab/
  ├── ubuntu/
  │   ├── ubuntu-2404.pkr.hcl
  │   └── scripts/
  │       └── setup.sh
  ├── alpine/
  │   └── alpine-321.pkr.hcl
  ├── variables.pkrvars.hcl
  └── README.md
```

---

## Editing Rules for Claude

### Required Behaviors
- Preserve all directory and naming conventions.


## Makefile Conventions

The Makefile provides a uniform interface for operational tasks. All targets must be non-interactive, idempotent, safe to run multiple times, and explicit about outputs.

### Target Documentation

All user-facing targets must use `##` comments for help text:
```makefile
target-name: ## description appears in make help

### Git Workflow & Pull Requests

When developing features, Claude must:

1. **Create a feature branch** from the main branch (or current base branch)
   - Use descriptive branch names: `feat/<feature-name>`, `fix/<issue-name>`, etc.

2. **Make incremental, logical commits** that tell a story
   - Each commit should represent a single, understandable step in the feature development
   - Break down large features into smaller, reviewable commits
   - Examples of good commit granularity:
     - "Add defaults/main.yml with initial variables"
     - "Implement task to install package dependencies"
     - "Add template for service configuration"
     - "Add handlers for service restart"
     - "Update playbook to include new role"
   - Avoid monolithic commits that mix multiple concerns (e.g., "Add new role" with 20 files changed)

3. **Write clear commit messages**
   - Use imperative mood: "Add role defaults" not "Added role defaults"
   - First line should be concise (50-72 chars) and summarize the change
   - Include body explaining the "why" if the commit is non-obvious
   - Reference related issues/PRs when applicable

4. **Create a Pull Request** when the feature is complete or ready for review
   - PR title should clearly describe what the feature does
   - PR description should explain:
     - What the feature adds/changes
     - Why it's needed
     - Any breaking changes or migration steps
     - How to test the changes
   - Keep PRs focused on a single feature or fix
   - If a feature is large, consider breaking it into multiple PRs

5. **Commit incrementally during development**
   - Don't wait until the end to commit everything
   - Commit working, logical units as you build them
   - This makes it easier to review, debug, and rollback if needed

Example of good incremental commits for a new role:
```
feat: add packer image for ubuntu2404
feat(ubuntu2404): add packer image for ubuntu2404 defaults and variables

```

