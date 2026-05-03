# Copilot Instructions

## Build, test, and lint

This repository does not have a build system, automated test suite, or linter configuration.

| Task | Command |
| --- | --- |
| Rename PDFs from extracted titles | `./renamePdfs.swift [path/to/file.pdf]` |
| Run a single test | Not available |
| Run full test suite | Not available |
| Run linter | Not available |

## High-level architecture

This is a flat artifact repository, not an application codebase. The root directory is the data store: each tracked PDF is a newsletter file downloaded from `https://www.entomophagy.or.jp/newsletter`.

The remaining workflow logic lives in `renamePdfs.swift`. The renamer uses PDFKit to read the first page and normalizes filenames to the visible newsletter or article title; when given a file path argument it renames only that PDF in place. In practice, most commits are binary file updates rather than source changes.

## Key conventions

- Keep the repository flat. Store tracked PDFs at the repository root rather than reorganizing them into topic or year subdirectories unless the repository structure itself is being intentionally redesigned.
- Treat this repository as a curated PDF archive, not an automated download workspace. Do not assume a download script or a refresh pipeline exists when making changes.
- Preserve human-readable filenames. Newsletter issues should continue to use the existing `Vol.%02d_<title>.pdf` pattern, and non-series documents should use the visible document title as the filename.
- Use `renamePdfs.swift` only for filename normalization or targeted cleanup of PDF names. If a new document does not fit the current rules, update the script deliberately instead of inventing one-off naming schemes.
- Do not leave temporary working files in the root directory. Aside from repository metadata and helper files such as `renamePdfs.swift`, the top level should stay focused on the tracked PDF collection.
- Most meaningful changes in this repo are PDF additions, removals, replacements, or renames. Text edits are usually limited to repository metadata or the rename helper.
