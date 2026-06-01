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

Say `v1.4.0` is in prod and you find a bug. You want `v1.4.1` with **only** that fix — nothing
that's landed on `main` since. The release branch was deleted at merge-back, but the `v1.4.0`
**tag is the exact snapshot**, so you re-cut the branch from it:

1. **Make sure the fix is on `main`.** If it isn't already there (the bug usually exists on
   `main` too), land it as a normal `fix:` PR and squash-merge — same as any patch. Note the
   squash commit SHA; you'll cherry-pick it in step 3.
   ```sh
   gh pr merge <fix-pr> --squash && git fetch origin
   FIX=$(git rev-parse origin/main)        # the fix's squash commit
   ```
2. **Re-cut the release branch from the tag.** Actions ▸ **Cut release branch** ▸ *Run
   workflow*, set **`from: v1.4.0`** (optionally a `name` like `1.4.x`, otherwise it's today's
   date). This recreates `release/<suffix>` at the exact `v1.4.0` snapshot — no `main` history
   rides along. Cut from a tag, it opens **no** release PR yet (nothing new is on the branch).
3. **Backport the fix onto the recreated branch.** Cherry-pick the `main` fix onto a topic
   branch and open a **backport PR** targeting it (a direct push is rejected by the ruleset):
   ```sh
   git switch -c jl/hotfix-1.4.1 origin/release/<suffix>
   git cherry-pick "$FIX"
   git push -u origin jl/hotfix-1.4.1
   gh pr create --base release/<suffix> --title "fix: <same title as the main fix>"
   ```
   Squash-merge it. release-please then opens a **`release 1.4.1`** PR on the branch (fix only,
   `version.txt` 1.4.0 → 1.4.1).
4. **Publish.** Merge the `1.4.1` release PR → `v1.4.1` tag + notes listing just the fix.
5. **Merge-back self-skips when `main` is ahead.** If `main` already shipped something newer
   (e.g. `1.5.0`), the forward-only gate opens **no** merge-back PR — merging would regress
   `main`, and the fix is already there from step 1. The `v1.4.1` tag stands on its own. If
   `main` is still at `1.4.0`, the merge-back PR opens as usual; squash-merge it to advance
   `main` to `1.4.1`.

> A fix you backport appears in both the release it shipped in and the next release's notes —
> it's two commits (the `main` original and the backport). That double-listing is expected.
