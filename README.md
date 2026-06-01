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
3. **Patch** — found a problem? Land the fix on `main` first (a normal `fix:` PR), then bring
   it onto the release branch with a **backport PR**:
   ```sh
   git fetch origin
   git switch --create backport/<short-name> origin/release/<date>
   git cherry-pick <commit-sha-from-main>
   git push --set-upstream origin backport/<short-name>
   gh pr create --base release/<date> --title "fix: <same as the original>"
   ```
   Backports go through PRs (the release branches require it) so they show up in the notes.
4. **Publish** — when soak passes, merge the release PR. That cuts the `vX.Y.Z` tag and a
   GitHub Release with notes grouped by type. Then **squash-merge the auto-opened "merge back
   into main" PR** — do this promptly; it's what advances `main` to the released version.

## Conventions

- **Title PRs with [Conventional Commits](https://www.conventionalcommits.org)** — `feat:`,
  `fix:`, `docs:`, … A check enforces it and adds a matching `type:` label. `feat` → minor,
  `fix` → patch; `feat!:`/`BREAKING CHANGE:` → minor (pre-1.0).
- **Everything is squash-merged**, so the PR title becomes the commit release-please reads.

## Knowing which release shipped your PR

After a release, every PR it included is labeled **`released: X.Y.Z`** with a comment linking
the release, and is listed under its type (Features, Bug Fixes, …) in the release notes.

## Hotfixing an already-shipped version

The release branch sticks around as that version's maintenance line — open a backport PR onto
it for a `X.Y.Z+1` patch. If it was pruned, recreate the exact snapshot first: **Cut release
branch** with `from: vX.Y.Z`.

> A fix you backport appears in both the release it shipped in and the next release's notes —
> it's two commits (the `main` original and the backport). That double-listing is expected.
