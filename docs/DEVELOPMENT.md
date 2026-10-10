# Development Workflow — Archther OS

How to work in this repository safely. This guide describes the workflow as
it exists now; component-specific guides will be added with their phases.

## Branch Strategy

| Branch | Purpose |
|---|---|
| `main` | Stable and release-ready Archther OS |
| `dev` | Integration branch for ongoing development |
| `feature/<name>` | Short-lived scoped work, cut from `dev` |

Rules:

- `main` already exists and is the default branch. Retain it; do not rename
  or delete branches.
- Cut `feature/*` branches from `dev`, not from `main`.
- Do not merge `feature/*` into `dev`, or `dev` into `main`, without an
  explicit reviewed promotion step.
- Never use `git push --force`, `git reset --hard`, history rewriting, or
  branch deletion.
- Do not change the default-branch setting or branch protection rules from
  routine development work.

## Before Changing Anything

1. Inspect `git status`, the current branch (`git branch --show-current`),
   remotes (`git remote -v`), and recent history (`git log --oneline -10`).
2. Confirm the remote points at the intended Archther OS repository before
   any push.
3. If uncommitted work exists, leave it alone: do not stash, discard, or
   commit someone else's changes. Avoid switching branches until the tree
   is clean or the switch is proven safe.

## Checks Before Every Commit

- `git diff --check` must pass (no whitespace errors).
- Review the complete diff (`git diff`, `git diff --cached`), not just the
  stat summary.
- Stage only the files belonging to the focused change; unrelated files,
  secrets, and local-only context files must never be staged.
- Verify no credentials, tokens, browser profiles, or machine-local paths
  are included in the diff.
- One focused change per commit, with a descriptive imperative message
  (for example, `chore: ignore local AI context files`).

## Safety Boundaries

- No disk, partition, LUKS, Btrfs/Snapper, Limine, or boot-entry changes as
  part of desktop setup work.
- No silent privileged commands, firewall changes, service changes, package
  removals, or network-access changes.
- Back up any existing configuration before replacing it, and record how to
  recover from a broken session.
- Never store sudo passwords, API keys, tokens, or private keys in files,
  shell history, or Git.

## Local-Only Context

The `context/` directory holds local AI working instructions. It is excluded
from Git via the root `.gitignore` and must never be staged, committed, or
pushed. `.gitignore` does not erase history: if context files ever end up
tracked, remove them from the index with `git rm --cached -r context/`
(keeping local copies) under a separate explicit approval — never rewrite
history to fix it without approval.
