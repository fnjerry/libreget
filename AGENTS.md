# LibreGet Agent Instructions & Release Protocol

Welcome to LibreGet. This file serves as the definitive reference and operating manual for all AI agents working in this repository.

---

## 1. Project Architecture

- **Desktop Framework**: Tauri v2 (`src-tauri/`) with Rust 1.97.0.
- **Frontend**: SvelteKit / Svelte 5 (`src/`) powered by Vite.
- **Embedded Plugins**: Statically linked core plugins (`courses`, `telegram`, `convert`) in `src-tauri/plugins/`.
- **Companion Browser Extension**: `browser-extension/chrome/`.

---

## 2. Release Protocol & Mandatory Post-Release SOP

> [!IMPORTANT]
> **NEVER skip writing the release notes when cutting or preparing a release.**
> The in-app changelog modal (`src/lib/stores/changelog-store.svelte.ts`) fetches the GitHub release body directly from `https://api.github.com/repos/OpenSelena/libreget/releases/tags/v<VERSION>`. Leaving release notes blank breaks the in-app user experience.

### Standard Operating Procedure for Every Release:

1. **Version Bump**:
   - Run: `pnpm version:set <major|minor|patch|X.Y.Z>`
   - This automatically updates:
     - `package.json`
     - `src-tauri/Cargo.toml` & `src-tauri/Cargo.lock`
     - `src-tauri/tauri.conf.json`
     - `src/lib/stores/changelog-store.svelte.ts`
     - `SECURITY.md` & `.github/SECURITY.md` (supported versions table)

2. **Git Commit & Tag**:
   - Format: `chore(release): bump version to vX.Y.Z, ...`
   - Create annotated/signed tag: `git tag vX.Y.Z`
   - Push: `git push origin main --tags`

3. **GitHub Release Notes (MANDATORY)**:
   - As soon as the GitHub release is published by the workflow (or manually):
   - Compile comprehensive release notes detailing:
     - `## What's New` (categorized by feature area)
     - `## Fixes`
   - Update the release via GitHub CLI:
     ```bash
     gh release edit vX.Y.Z --notes-file <notes.md>
     ```
   - Verify the notes with:
     ```bash
     gh release view vX.Y.Z
     ```

4. **Asset Name & Casing Verification**:
   - Check the exact asset filenames uploaded by Tauri (`gh release view vX.Y.Z --json assets`).
   - Notice casing: e.g. `LibreGet_0.11.0_x64-setup.exe` (capitalized `LibreGet`) vs `libreget_0.11.0_x64-portable.exe` (lowercase `libreget`).

---

## 3. Branch Strategy & Quality Gates

### Branch Workflow
- **`dev` (Development & Staging)**: All feature development, refactoring, and bug fixes must be committed and pushed to `dev` first.
- **Continuous Integration (CI) Gate**: Pushing to `dev` automatically triggers GitHub Actions (`.github/workflows/ci.yml`) to test across Linux, Windows, and macOS.
- **`main` (Production / Stable)**: Code is never pushed directly to `main`. The `dev` branch is only merged into `main` after all GitHub Actions CI checks have completed with a green checkmark (100% passing).

### Local Pre-Commit Verification
Before pushing to `dev`:
- `pnpm fmt:rs` : Auto-formats Rust workspace (`cargo fmt`) — enforced automatically via `.githooks/pre-commit` and `.githooks/pre-push`.
- `pnpm test` : Runs full Vitest suite (must pass 100%).
- `pnpm lint:ui <target>` : Required whenever modifying Svelte routes, UI components, or stylesheets — see [.agents/skills/ui-lint/SKILL.md](.agents/skills/ui-lint/SKILL.md).

---

## Agent skills

### Issue tracker

GitHub Issues at OpenSelena/libreget via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Canonical triage roles (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context (`GLOSSARY.md` and `docs/adr/`). See `docs/agents/domain.md`.

### Video datasets from the CLI

`libreget search` + `libreget archive` build a resumable local video archive (search terms, filters, size cap). See [.agents/skills/video-archive/SKILL.md](.agents/skills/video-archive/SKILL.md).

---

## Local Overrides & Session Protocol

If present, private developer environment overrides, local notes, or personal tool paths are read from `AGENTS.local.md` (git-ignored).
All agents and subagents must strictly adhere to the pre-task retrieval and post-task writeback protocols specified in `AGENTS.local.md` before concluding any task.



