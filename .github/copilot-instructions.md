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

- Keep newsletter PDFs at the repository root. Do not reorganize them into subdirectories unless the repository structure is intentionally being redesigned.
- Normalize filenames to the visible newsletter or article title instead of keeping the hashed upstream download names.
- Avoid leaving behind temporary download or extraction output in the repository root; the repo convention is that tracked PDFs and the rename helper live at the top level.
- Most meaningful changes in this repo are additions, removals, or replacements of PDF binaries. Text edits are usually limited to the rename script or repository metadata such as this file.
