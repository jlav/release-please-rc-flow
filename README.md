# release-please-rc-flow

Releases go through a **soak**: we snapshot `main` into a release branch, validate that
branch, and only then cut a stable release — all without blocking work on `main`. Automated
with [release-please](https://github.com/googleapis/release-please).

## How a release works

1. **Cut** — Actions ▸ **Cut release branch** ▸ *Run workflow*. This creates
   `release/<date>` from `main` and opens a **release PR** on it. That branch is now frozen:
   nothing merged to `main` afterwards affects it.
2. **Soak** — deploy/validate the `release/<date>` branch. Meanwhile `main` stays open for
   everyone else.
3. **Patch** — found a problem? Land the fix on `main` first (a normal `fix:` PR), then
   cherry-pick it onto the release branch via a **backport PR**. Backports must be PRs (the
   release branches enforce it), so the fix shows up in the release notes.
4. **Publish** — when soak passes, merge the release PR. That cuts the `vX.Y.Z` tag and a
   GitHub Release with notes grouped by type. Then **squash-merge the auto-opened "merge back
   into main" PR** — do this promptly; it's what advances `main` to the released version.
   Merging it also deletes the release branch (the tag is the permanent snapshot).

## Conventions

- **Title PRs with [Conventional Commits](https://www.conventionalcommits.org)** — `feat:`,
  `fix:`, `docs:`, … A check enforces it and adds a matching `type:` label. `feat` → minor,
  `fix` → patch; `feat!:`/`BREAKING CHANGE:` → minor (pre-1.0).
- **Everything is squash-merged**, so the PR title becomes the commit release-please reads.

## Knowing which release shipped your PR

After a release, every PR it included is labeled **`released: X.Y.Z`** with a comment linking
the release, and is listed under its type (Features, Bug Fixes, …) in the release notes.

## Hotfixing an already-shipped version

The release branch is gone after merge-back, but the tag is the exact snapshot. To patch a
shipped version: **Cut release branch** with `from: vX.Y.Z` to recreate it, then open a backport
PR onto the recreated branch for the `X.Y.Z+1` patch — nothing from `main` comes along.

> A fix you backport appears in both the release it shipped in and the next release's notes —
> it's two commits (the `main` original and the backport). That double-listing is expected.
