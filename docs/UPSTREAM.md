# Upstream foundation

Zlet AI Pulse uses the Windows implementation work from [nesszer/Win-CodexBar](https://github.com/nesszer/Win-CodexBar) as its initial technical foundation.

## Pinned base

- Repository: `nesszer/Win-CodexBar`
- Release: `v0.55.0`
- Commit: `bdf0773f66c60810886037cfe5f160e0a9fa4fe7`
- Local path: `vendor/win-codexbar`

The upstream source is pinned as a Git submodule instead of tracking `main`. This keeps the first bootstrap reproducible and prevents unrelated upstream changes from silently entering Zlet AI Pulse.

## Bootstrap model

The repository keeps upstream code read-only under `vendor/win-codexbar`. `scripts/bootstrap.ps1` creates a disposable working copy under `.work/zlet-ai-pulse` and applies the initial Zlet product overlay there.

```text
vendor/win-codexbar (pinned upstream, do not edit)
            |
            v
scripts/bootstrap.ps1
            |
            v
.work/zlet-ai-pulse (generated development workspace)
```

The first overlay intentionally changes only low-risk product-facing metadata such as the Tauri product name, application identifier, window title, frontend package name and HTML title. Backend/provider modules are not pruned during bootstrap.

## Why not copy everything immediately?

Keeping a pinned upstream reference gives us:

- an exact provenance trail for MIT-derived code;
- a reproducible base for comparing future upstream fixes;
- a safe way to preserve provider implementations while Zlet AI Pulse replaces the product UI;
- less risk of accidental destructive rewrites during the first Windows bring-up.

This is a bootstrap strategy, not a permanent restriction. Once the Windows build is validated, selected upstream code can be promoted into first-party Zlet-owned paths in controlled changes.

## Updating upstream

Do not point the submodule at a moving branch.

For an upstream update:

1. choose a specific stable Win-CodexBar tag/commit;
2. review release notes and relevant diffs;
3. update the gitlink in a dedicated PR;
4. regenerate `.work/zlet-ai-pulse` using `scripts/bootstrap.ps1`;
5. run the Windows QA matrix and provider smoke tests;
6. update this document and `THIRD_PARTY_NOTICES.md` when provenance changes.

## Licensing

Win-CodexBar and the original CodexBar are MIT-licensed. Win-CodexBar also contains MIT-derived code from `codexcontrol`. Required notices must remain in `THIRD_PARTY_NOTICES.md` and be shipped with distributions that contain derived portions.

Zlet AI Pulse branding, artwork and product UI are separate from upstream branding. Do not reuse upstream logos or present Zlet AI Pulse as an official CodexBar build.
